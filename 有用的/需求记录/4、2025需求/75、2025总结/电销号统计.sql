with touch_task_info as (
    select task_id,
           task_name,
           dmp_id,
           touch_task_scene,
           touch_task_create_user_id,
           touch_task_create_user_real_name,
           nvl(job_id,99999) as job_id,
           job_name,
           dept_name
    from (
        select touch_task_id as task_id,
               touch_task_name as task_name,
               dmp_id,
               touch_task_create_user_id,
               touch_task_create_user_real_name,
               touch_task_scene
        from ytdw.dim_ytj_sel_touch_task_d
        where dayid = '${v_date}'
    ) t1
    left join (
        select user_id,
               job_id,
               job_name,
               dept_name
        from dim_hpc_pub_user_admin
    )t2 on t1.touch_task_create_user_id=t2.user_id
),

shop_se_info as (
    select shop_id,
           shop_service_dx_id,
           ytdw.get_service_info('service_type:电销',shop_service_info,'service_user_name') as shop_service_dx_name,
           ytdw.get_service_info('service_type:电销',shop_service_info,'service_department_name') as shop_service_dx_dept
    from ytdw.dim_hpc_shp_shop_service_d
    where dayid='${v_date}'
),

base_wx_data as (
    SELECT base_wx_data.sel_shop_wx_msg_id as union_id,
           base_wx_data.shop_id,
           wx_msg_send_type_name,
           wx_msg_type_name,
           wx_msg_time,
           wx_msg_content,
           wx_msg_source_name,
           wx_msg_send_status_name,
           admin_wx_nick_name,
           admin_user_virtual_group_name_lv2,
           admin_user_virtual_group_name_lv3,
           shop_wx_nick_name,
           wx_msg_scence1,
           wx_msg_scence2,
           item_id,
           case when wx_msg_scence2='奶粉价格表' then '905.6.1.0.0'
           else concat(ytms_log_code,'0.0') end as ytms_log_code,
           base_wx_data.shop_name,
           task_id,
           task_name,
           dmp_id,
           touch_task_create_user_id,
           touch_task_create_user_real_name,
           nvl(job_id,99999) as job_id,
           job_name,
           dept_name
    from (
        select *
        from ytdw.dw_ytj_sel_admin_shop_wx_msg_di
        where dayid>='20250101'
        and dayid<='20251231'
        --这里改时间
        and (wx_msg_source in (2))
        and (ytms_log_code is not null or item_id is not null or wx_msg_type=2013)
    ) base_wx_data
    left join (
        select *,
               case when qw_msg_id is not null then concat('wx#',qw_msg_id)
                    when tuse_wx_msg_id is not null then concat('tuse#',tuse_wx_msg_id)
                    end as wx_msg_id,
               -rand() * 1000 as rand_id
       from ytdw.dim_ytj_sel_task_detail_msg_d
       where dayid='${v_date}'
    ) touch_task_detaild_data on base_wx_data.wx_msg_id=nvl(touch_task_detaild_data.wx_msg_id,touch_task_detaild_data.rand_id)
    left join touch_task_info on touch_task_detaild_data.touch_task_id=touch_task_info.task_id
),

flow as (
    SELECT t1.dayid,
           shop_id,
           code,
           t1.item_id,
           request_time,
           rp_app_id
    FROM (
    	SELECT *, (-rand()) * 1000 AS rand_id
    	FROM ytdw.dwd_flow_di
    	WHERE dayid >= '20250101'
    	AND dayid <= '20251231' -- 这里改时间
    	AND (code IN ('905.3.1.0.0', '905.6.1.0.0')
    		OR code LIKE '%905.10.%')
    ) t1
    LEFT JOIN (
    	SELECT item_id
    	FROM ytdw.dim_hpc_itm_item_d
    	WHERE dayid = '${v_date}'
    	AND business_unit NOT IN ('其他', '卡券票')
    	AND item_style = 0
    ) t2 ON t1.item_id = t2.item_id
    LEFT JOIN (
    	SELECT *
    	FROM ytdw.dim_ytj_pub_user_d
    	WHERE dayid = yt_date_format(date_sub(CURRENT_DATE, 1), 'yyyyMMdd')
    ) b ON nvl(t1.uid, t1.rand_id) = b.user_id
),

order_tmp as (
    SELECT t1.*,
           biz_net_pay_total_amt_1d,
           profit
    FROM (
    	SELECT order_id,
               pay_time,
               item_id,
               shop_id,
               trade_source,
               category_1st_name,
               business_unit
    	FROM ytdw.dw_ytj_trd_ord_d
    	WHERE dayid = yt_date_format(date_sub(CURRENT_DATE, 1), 'yyyyMMdd')
    	AND substr(pay_time, 1, 8) >= '20250101'
    	AND substr(pay_time, 1, 8) <= '20251231' -- 这里改时间
    	AND business_unit NOT IN ('其他', '卡券票')
    	AND item_style = 0
    ) t1
    LEFT JOIN (
    	SELECT order_id,
               sum(biz_net_pay_total_amt_1d) AS biz_net_pay_total_amt_1d
    	FROM ytdw.dws_hpc_trd_detail_d
    	WHERE dayid = yt_date_format(date_sub(CURRENT_DATE, 1), 'yyyyMMdd')
    	AND date_id <= '${v_date}'
    	GROUP BY order_id
    ) t2 ON t1.order_id = t2.order_id
    LEFT JOIN (
    	SELECT order_id,
               sum(platform_check_gross_profit) AS profit
    	FROM yt_fin.ads_fin_gross_profit_v2_d
    	WHERE dayid = '${v_date}'
    	AND business_unit_new NOT IN ('卡券票', '其他')
    	GROUP BY order_id
    ) t3 ON t1.order_id = t3.order_id
),

dacu_ri as (
    SELECT date_id,
           from_unixtime(unix_timestamp(date_sub(from_unixtime(unix_timestamp(date_id, 'yyyyMMdd'), 'yyyy-MM-dd'), 1), 'yyyy-MM-dd'), 'yyyyMMdd') AS date_id_1,
           from_unixtime(unix_timestamp(date_sub(from_unixtime(unix_timestamp(date_id, 'yyyyMMdd'), 'yyyy-MM-dd'), 2), 'yyyy-MM-dd'), 'yyyyMMdd') AS date_id_2,
           promotion_date_type_names
    FROM (
    	SELECT date_id,
               promotion_date_type_names
    	FROM ytdw.dw_hpc_prm_promotion_date_item_di
    	WHERE dayid >= '20250101'
    	AND dayid <= '20251231'
    	GROUP BY date_id,
                 promotion_date_type_names
    ) a
    WHERE promotion_date_type_names IN ('A类大促B类小促', 'AB类大促', 'A类大促', 'A类超级品类日', 'A类超级品类日B类大促')
),

dacu_before as (
    SELECT date_id_2 as date_id,
           promotion_date_type_names,
           '大促前2天' as date_type
    from dacu_ri
    where promotion_date_type_names in ('A类大促B类小促','AB类大促','A类大促')

    union all

    SELECT date_id_1 as date_id,
           promotion_date_type_names,
           '大促前1天' as date_type
    from dacu_ri
),

chuda_dakai as (
    SELECT union_id,
           t1.shop_id,
           admin_wx_nick_name,
           min(request_time) AS request_time
    FROM (
    	SELECT union_id,
               shop_id,
               wx_msg_time AS data_time,
               item_id,
               admin_wx_nick_name
    	FROM base_wx_data
    	WHERE item_id IS NOT NULL
    ) t1
    LEFT JOIN (
    	SELECT shop_id,
               request_time,
               item_id,
               rp_app_id,
               code
    	FROM flow
    ) t2 ON t1.shop_id = t2.shop_id
    	AND t2.request_time >= t1.data_time
    	AND (unix_timestamp(t2.request_time, 'yyyyMMddHHmmss') - unix_timestamp(t1.data_time, 'yyyyMMddHHmmss')) / 3600 <= 24
    	AND t1.item_id = t2.item_id
    GROUP BY union_id,
             t1.shop_id,
             admin_wx_nick_name

    union all

    SELECT union_id,
           t1.shop_id,
           admin_wx_nick_name,
           min(request_time) AS request_time
    FROM (
    	SELECT union_id,
               shop_id,
               wx_msg_time AS data_time,
               ytms_log_code,
               admin_wx_nick_name
    	FROM base_wx_data
    	WHERE ytms_log_code IS NOT NULL
    ) t1
    LEFT JOIN (
    	SELECT DISTINCT shop_id,
               request_time,
               rp_app_id,
               code
    	FROM flow
    ) t2 ON t1.shop_id = t2.shop_id
    	AND t2.request_time >= t1.data_time
    	AND (unix_timestamp(t2.request_time, 'yyyyMMddHHmmss') - unix_timestamp(t1.data_time, 'yyyyMMddHHmmss')) / 3600 <= 24
    	AND t1.ytms_log_code = t2.code
    GROUP BY union_id,
             t1.shop_id,
             admin_wx_nick_name
),

chuda_order as (
    SELECT union_id,
           shop_id,
           sum(biz_net_pay_total_amt_1d) AS gmv,
           sum(profit) AS profit
    FROM (
    	SELECT union_id,
               shop_id,
               data_time,
               order_id,
               biz_net_pay_total_amt_1d,
               profit,
               row_number() OVER (PARTITION BY order_id ORDER BY data_time DESC) AS order_rn
    	FROM (
    		SELECT union_id,
                   t1.shop_id,
                   data_time,
                   admin_wx_nick_name,
                   order_id,
                   biz_net_pay_total_amt_1d,
                   profit,
    			   CASE WHEN nvl(date_type, 0) = 0 AND (unix_timestamp(t2.pay_time, 'yyyyMMddHHmmss') - unix_timestamp(t1.data_time, 'yyyyMMddHHmmss')) / 3600 <= 24
    				    THEN 1
    				    WHEN date_type = '大促前1天' AND (unix_timestamp(t2.pay_time, 'yyyyMMddHHmmss') - unix_timestamp(t1.data_time, 'yyyyMMddHHmmss')) / 3600 <= 48
    				    THEN 1
    				    WHEN date_type = '大促前2天' AND (unix_timestamp(t2.pay_time, 'yyyyMMddHHmmss') - unix_timestamp(t1.data_time, 'yyyyMMddHHmmss')) / 3600 <= 72
    				    THEN 1
    				    ELSE 0 END AS if_order
    		FROM (
    			SELECT union_id,
                       shop_id,
                       request_time AS data_time,
                       admin_wx_nick_name
    			FROM chuda_dakai
    		) t1
    		LEFT JOIN (
    			SELECT order_id,
                       pay_time,
                       item_id,
                       shop_id,
                       trade_source,
                       business_unit,
                       biz_net_pay_total_amt_1d,
                       profit
    			FROM order_tmp
    		) t2 ON t1.shop_id = t2.shop_id
    			AND t2.pay_time >= t1.data_time
    			AND (unix_timestamp(t2.pay_time, 'yyyyMMddHHmmss') - unix_timestamp(t1.data_time, 'yyyyMMddHHmmss')) / 3600 <= 72
    		LEFT JOIN (
    			SELECT date_id,
                       date_type
    			FROM dacu_before
    		) dacu_before ON substr(t1.data_time, 1, 8) = dacu_before.date_id
    	) t
    	WHERE if_order = 1
    ) t
    WHERE order_rn = 1
    GROUP BY union_id,
             shop_id
),

chuda_order1 as (
    SELECT union_id,
           shop_id,
           sum(biz_net_pay_total_amt_1d) AS gmv,
           sum(profit) AS profit
    FROM (
    	SELECT union_id,
               shop_id,
               data_time,
               order_id,
               biz_net_pay_total_amt_1d,
               profit,
               row_number() OVER (PARTITION BY order_id ORDER BY data_time DESC) AS order_rn
    	FROM (
    		SELECT union_id,
                   t1.shop_id,
                   data_time,
                   admin_wx_nick_name,
                   order_id,
                   biz_net_pay_total_amt_1d,
                   profit,
    			   CASE WHEN nvl(date_type, 0) = 0
    				AND (unix_timestamp(t2.pay_time, 'yyyyMMddHHmmss') - unix_timestamp(t1.data_time, 'yyyyMMddHHmmss')) / 3600 >= -24
    				    THEN 1
    				    WHEN date_type = '大促前1天'
    				AND (unix_timestamp(t2.pay_time, 'yyyyMMddHHmmss') - unix_timestamp(t1.data_time, 'yyyyMMddHHmmss')) / 3600 >= -48
    				    THEN 1
    				    WHEN date_type = '大促前2天'
    				AND (unix_timestamp(t2.pay_time, 'yyyyMMddHHmmss') - unix_timestamp(t1.data_time, 'yyyyMMddHHmmss')) / 3600 >= -72
    				    THEN 1 ELSE 0 END AS if_order
    		FROM (
    			SELECT union_id,
                       shop_id,
                       request_time AS data_time,
                       admin_wx_nick_name
    			FROM chuda_dakai
    		) t1
    		LEFT JOIN (
    			SELECT order_id,
                       pay_time,
                       item_id,
                       shop_id,
                       trade_source,
                       business_unit,
                       biz_net_pay_total_amt_1d,
                       profit
    			FROM order_tmp
    		) t2 ON t1.shop_id = t2.shop_id
    			AND t2.pay_time < t1.data_time
    			AND (unix_timestamp(t2.pay_time, 'yyyyMMddHHmmss') - unix_timestamp(t1.data_time, 'yyyyMMddHHmmss')) / 3600 >= -72
    		LEFT JOIN (
    			SELECT date_id,
                       date_type
    			FROM dacu_before
    		) dacu_before ON substr(t1.data_time, 1, 8) = dacu_before.date_id
    	) t
    	WHERE if_order = 1
    ) t
    WHERE order_rn = 1
    GROUP BY union_id,
             shop_id
)

SELECT substr(wx_msg_time, 1, 8) AS `日期`,
       task_id,
       task_name,
       count(DISTINCT CASE WHEN wx_msg_send_status_name = '发送成功' THEN base_wx_data.shop_id ELSE NULL END) AS `触达成功门店数`,
       count(DISTINCT CASE WHEN wx_msg_send_status_name = '发送成功' AND chuda_dakai.request_time IS NOT NULL THEN base_wx_data.shop_id ELSE NULL END) AS `打开门店数`,
       count(DISTINCT CASE WHEN wx_msg_send_status_name = '发送成功' AND chuda_order.gmv > 0 THEN base_wx_data.shop_id ELSE NULL END) AS `下单门店数`,
       sum(CASE WHEN wx_msg_send_status_name = '发送成功' AND abs(chuda_order.gmv) > 0 THEN chuda_order.gmv ELSE 0 END) AS `下单gmv`,
       sum(CASE WHEN wx_msg_send_status_name = '发送成功' AND abs(chuda_order.profit) > 0 THEN chuda_order.profit ELSE 0 END) AS `下单毛利`,
       sum(CASE WHEN wx_msg_send_status_name = '发送成功' AND abs(chuda_order1.gmv) > 0 THEN chuda_order1.gmv ELSE 0 END) AS `前下单gmv`,
       sum(CASE WHEN wx_msg_send_status_name = '发送成功' AND abs(chuda_order1.profit) > 0 THEN chuda_order1.profit ELSE 0 END) AS `前下单毛利`
FROM base_wx_data
LEFT JOIN chuda_dakai ON base_wx_data.union_id = chuda_dakai.union_id AND base_wx_data.shop_id = chuda_dakai.shop_id
LEFT JOIN chuda_order ON base_wx_data.union_id = chuda_order.union_id AND base_wx_data.shop_id = chuda_order.shop_id
LEFT JOIN chuda_order1 ON base_wx_data.union_id = chuda_order1.union_id AND base_wx_data.shop_id = chuda_order1.shop_id
LEFT JOIN shop_se_info ON base_wx_data.shop_id = shop_se_info.shop_id
GROUP BY substr(wx_msg_time, 1, 8),
         task_id,
         task_name