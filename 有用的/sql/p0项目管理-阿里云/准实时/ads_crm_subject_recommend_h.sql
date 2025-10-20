--@exclude_input=ytdw.ods_vf_t_sp_order_snapshot
--@exclude_input=yt_crm.nrt_ts_shop_visit
--@exclude_input=ytdw.ods_vf_pt_order_shop
--@exclude_input=ytdw.ods_vf_t_p0_subject
--@exclude_input=ytdw.ods_vf_t_p0_subject_shop
WITH shop_user as (
    select *
    from yt_crm.ads_crm_subject_shop_user_d
    WHERE dayid = '${v_date}'
),

shop_saler as (
	SELECT if(nvl(ts.shop_id,'')='',vs.shop_id,ts.shop_id) as shop_id,
           ts.user_id AS ts_user_id,
           ts.dept_id AS ts_dept_id,
           ts.parent_dept_id AS ts_parent_dept_id,
           ts.parent_2_dept_id AS ts_parent_2_dept_id,
           vs.user_id AS vs_user_id,
           vs.dept_id AS vs_dept_id,
           vs.parent_dept_id AS vs_parent_dept_id,
           vs.parent_2_dept_id AS vs_parent_2_dept_id
    FROM (select * from shop_user WHERE group_type_tag = 'ts') ts
    FULL JOIN (select * from shop_user WHERE group_type_tag = 'vs') vs on ts.shop_id = vs.shop_id
)

INSERT OVERWRITE TABLE ads_crm_subject_recommend_h PARTITION (dayid='${v_date}')
SELECT shop_subject.shop_id,
       shop.shop_name,
       nvl(shop.shop_pro_id, 0),
       nvl(shop.shop_city_id, 0),
       nvl(shop.shop_area_id, 0),
       nvl(shop.shop_address_id, 0),
       nvl(if(shop_saler.ts_user_id != '', shop_saler.ts_user_id, shop_saler.vs_user_id), '') AS user_id,
       nvl(if(shop_saler.ts_dept_id != 0, shop_saler.ts_dept_id, shop_saler.vs_dept_id), 0) AS dept_id,
       nvl(if(shop_saler.ts_parent_dept_id != 0, shop_saler.ts_parent_dept_id, shop_saler.vs_parent_dept_id), 0) AS parent_dept_id,
       nvl(if(shop_saler.ts_parent_2_dept_id != 0, shop_saler.ts_parent_2_dept_id, shop_saler.vs_parent_2_dept_id), 0) AS parent_2_dept_id,
       nvl(subject_ids, ''),
       nvl(subject_count, 0),
       nvl(subject_data, ''),
       nvl(shop_visit.visit_frequency, ''),
	   CASE WHEN visit_times > 0 THEN 1 ELSE 0 END AS no_valid_visit,
	   CASE WHEN invalid_visit_times > 0 THEN 1 ELSE 0 END AS no_invalid_visit,
       shop_subject.last_visit_time AS last_visit_time,
       shop_visit.last_visit_time AS last_request_time,
       shop_pay.pay_time AS last_pay_time
FROM (
	SELECT subject_shop.shop_id,
           count(*) AS subject_count,
           concat_ws(',', sort_array(collect_set(CAST(subject_shop.subject_id AS string)))) AS subject_ids,
           concat(
               '[',
                concat_ws(',',
                    sort_array(
                        collect_set(
                            concat(
                                '{"subject_id":', subject_shop.subject_id,
                                ',"subject_gmv":', nvl(subject_gmv, 0),
                                ',"this_month_gmv":', nvl(this_month_gmv, 0),
                                ',"last_1_month_gmv":', nvl(last_1_month_gmv, 0),
                                ',"last_2_month_gmv":', nvl(last_2_month_gmv, 0),
                                ',"valid_visit_times":', nvl(visit_times, 0),
                                ',"invalid_visit_times":', nvl(invalid_visit_times, 0), '}')
                            )
                        )
                    ),
                ']'
            ) AS subject_data,
           sum(visit_times) AS visit_times,
           sum(invalid_visit_times) AS invalid_visit_times,
           max(last_visit_time) AS last_visit_time
	FROM (
		SELECT subject_id,
               shop_id
		FROM ytdw.ods_vf_t_p0_subject_shop
		WHERE is_deleted = 0
		AND is_object_shop = 1
	) subject_shop
	JOIN (
		SELECT id
		FROM ytdw.ods_vf_t_p0_subject
		WHERE is_deleted = 0
		AND status = 1
		AND feature_type = 2
		AND substr(do_start, 1, 10) <= '${v_op_date}'
		AND substr(do_end, 1, 10) >= '${v_op_date}'
	) subject ON subject_shop.subject_id = subject.id
	LEFT JOIN (
		SELECT subject_id,
               shop_id,
               subject_gmv,
               this_month_gmv,
               last_1_month_gmv,
               last_2_month_gmv,
               visit_times,
               invalid_visit_times,
               last_visit_time
		FROM yt_crm.nrt_p0_subject_ts_h
		WHERE dayid = '${v_date}'
	) subject_shop_gmv ON subject_shop_gmv.subject_id = subject_shop.subject_id AND subject_shop_gmv.shop_id = subject_shop.shop_id
	GROUP BY subject_shop.shop_id
) shop_subject
left JOIN shop_saler ON shop_subject.shop_id = shop_saler.shop_id
left join (select * FROM ytdw.dw_shop_base_d WHERE dayid='${v_date}') shop on shop.shop_id=shop_subject.shop_id
LEFT JOIN (
	SELECT shop_id,
           visit_frequency,
           last_visit_time
	FROM yt_crm.nrt_ts_shop_visit
	WHERE dayid = '${v_date}'
) shop_visit ON shop_subject.shop_id = shop_visit.shop_id
LEFT JOIN (
	SELECT shop_id,
           max(pay_time) AS pay_time
	FROM (
		SELECT shop_id,
               item_id,
               order_id,
               pay_time
		FROM ytdw.ods_vf_pt_order_shop
		WHERE is_deleted = 0
		AND bu_id = 0
	) all_order
	JOIN (
		SELECT id
		FROM ytdw.dwd_item_d
		WHERE dayid = '${v_date}'
		AND item_style = 0
	) item ON all_order.item_id = item.id
	LEFT JOIN (
		SELECT order_id,
               sp_id
		FROM ytdw.ods_vf_t_sp_order_snapshot
		WHERE is_deleted = 0
	) sp_order ON all_order.order_id = sp_order.order_id
	WHERE sp_order.sp_id IS NULL
	GROUP BY shop_id
) shop_pay ON shop_subject.shop_id = shop_pay.shop_id