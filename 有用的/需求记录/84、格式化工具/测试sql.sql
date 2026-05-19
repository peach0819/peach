INSERT OVERWRITE TABLE st_crm_recommend_visit_d PARTITION (dayid='${v_date}')
SELECT shop.shop_id AS shop_id, refund.brand_ids AS customer_complaint_brand,
	CASE
	 WHEN refund.refund_count = ''
		OR refund.refund_count IS NULL
	 THEN 0
	 ELSE refund.refund_count
	END AS refund_order_count,
	CASE
	 WHEN will_opt.b_will_be_closed > 0 THEN 1
	 ELSE 0
	END AS b_will_be_closed, will_opt.b_will_be_closed_brand AS b_will_be_closed_brand,
	CASE
	 WHEN thisMonthAGmv.this_pure_gmv = ''
		OR thisMonthAGmv.this_pure_gmv IS NULL
	 THEN 0
	 ELSE thisMonthAGmv.this_pure_gmv
	END AS a_gmv_this_month,
	CASE
	 WHEN lastMonthAGmv.last_pure_gmv = ''
		OR lastMonthAGmv.last_pure_gmv IS NULL
	 THEN 0
	 ELSE lastMonthAGmv.last_pure_gmv
	END AS a_gmv_last_month,
	CASE
	 WHEN bdvisit.visit_count = ''
		OR bdvisit.visit_count IS NULL
	 THEN 0
	 ELSE bdvisit.visit_count
	END AS bd_record_count,
	CASE
	 WHEN telemarketing.record_count = ''
		OR telemarketing.record_count IS NULL
	 THEN 0
	 ELSE telemarketing.record_count
	END AS telemarketing_record,
	CASE
	 WHEN shopBrand.brand_count = ''
		OR shopBrand.brand_count IS NULL
	 THEN 0
	 ELSE shopBrand.brand_count
	END AS cooperative_brand_count, shopBrand.brand_ids AS cooperative_brand
FROM (
	SELECT shop_id
	FROM ytdw.dim_ytj_shp_shop_d
	WHERE dayid = '${v_date}'
	AND shop_prov_id IS NOT NULL
	AND shop_prov_id != ''
	AND shop_status IN (1, 2, 3, 4, 5)
	AND shop_is_inuse = 1
	AND shop_store_type != 11
	AND shop_store_type != 9
	AND bu_id = 0
	AND dc_id = 0
) shop
LEFT JOIN (
		SELECT shopOrder.shop_id, count(DISTINCT shopOrder.trade_id) AS refund_count,
			concat_ws(',', collect_set(CAST(shopOrder.brand_id AS string))) AS brand_ids
		FROM ytdw.dw_order_d shopOrder
		INNER JOIN ytdw.dwd_order_refund_all_d orderRefund ON shopOrder.refund_id = orderRefund.id
		WHERE shopOrder.dayid = '${v_date}'
		AND orderRefund.dayid = '${v_date}'
		AND orderRefund.shop_status IN (1, 2, 3, 4, 5, 6, 11, 12, 13, 14)
		AND shopOrder.item_style = 1
		GROUP BY shopOrder.shop_id
	) refund ON refund.shop_id = shop.shop_id
LEFT JOIN (
		SELECT shop_id, concat_ws(',', collect_set(CAST(brand_id AS string))) AS b_will_be_closed_brand,
			count(*) AS b_will_be_closed
		FROM yt_crm.st_shop_group_will_opt_d
		WHERE dayid = '${v_date}'
		GROUP BY shop_id
	) will_opt ON shop.shop_id = will_opt.shop_id
LEFT JOIN (
		SELECT shop_id,
			SUM(CASE
			 WHEN SUBSTR(pay_time, 1, 6) = '${v_cur_month}' THEN total_pay_amount
			 ELSE 0
			END) - SUM(CASE
			 WHEN SUBSTR(refund_end_time, 1, 6) = '${v_cur_month}'
				AND refund_status = 9
			 THEN refund_actual_amount
			 ELSE 0
			END) AS this_pure_gmv
		FROM ytdw.dw_order_d
		WHERE dayid = '${v_date}'
		AND business_unit NOT IN ('卡券票', '其他')
		AND substr(pay_time, 1, 6) = '${v_cur_month}'
		AND bu_id = 0
		AND item_style = 0
		GROUP BY shop_id
	) thisMonthAGmv ON thisMonthAGmv.shop_id = shop.shop_id
LEFT JOIN (
		SELECT shop_id,
			SUM(CASE
			 WHEN SUBSTR(pay_time, 1, 6) = '${v_pre_month}' THEN total_pay_amount
			 ELSE 0
			END) - SUM(CASE
			 WHEN SUBSTR(refund_end_time, 1, 6) = '${v_pre_month}'
				AND refund_status = 9
			 THEN refund_actual_amount
			 ELSE 0
			END) AS last_pure_gmv
		FROM ytdw.dw_order_d
		WHERE dayid = '${v_date}'
		AND business_unit NOT IN ('卡券票', '其他')
		AND substr(pay_time, 1, 6) = '${v_pre_month}'
		AND bu_id = 0
		AND item_style = 0
		GROUP BY shop_id
	) lastMonthAGmv ON lastMonthAGmv.shop_id = shop.shop_id
LEFT JOIN (
		SELECT shop_id, count(*) AS visit_count
		FROM ytdw.dw_sel_bd_visit_record_d
		WHERE dayid = '${v_date}'
		AND SUBSTR(visit_start_time, 1, 8) >= '${v_30_days_ago}'
		GROUP BY shop_id
	) bdvisit ON bdvisit.shop_id = shop.shop_id
LEFT JOIN (
		SELECT shop_id, count(*) AS record_count
		FROM ytdw.dw_sel_dx_visit_record_d
		WHERE dayid = '${v_date}'
		AND SUBSTR(visit_time, 1, 8) >= '${v_30_days_ago}'
		GROUP BY shop_id
	) telemarketing ON telemarketing.shop_id = shop.shop_id
LEFT JOIN (
		SELECT shopMapping.shop_id, count(DISTINCT brand.id) AS brand_count,
			concat_ws(',', collect_set(CAST(brand.id AS string))) AS brand_ids
		FROM (
			SELECT shop_id, group_id
			FROM ytdw.dwd_shop_group_mapping_d
			WHERE dayid = '${v_date}'
			AND is_deleted = 0
		) shopMapping
		INNER JOIN (
				SELECT id, shop_group_id
				FROM ytdw.dwd_brand_d
				WHERE dayid = '${v_date}'
				AND is_deleted = 0
			) brand ON brand.shop_group_id = shopMapping.group_id
		GROUP BY shopMapping.shop_id
	) shopBrand ON shopBrand.shop_id = shop.shop_id