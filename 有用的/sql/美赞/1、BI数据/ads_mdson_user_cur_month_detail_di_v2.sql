--@exclude_input=prod_mdson_dev.inf_mdson_white_list_store
-- 员工信息
WITH mdson_user as (
    SELECT user_id,
           user_real_name,
           job_name,
           channel_name,
           empno
    FROM prod_mdson.dim_user_d
    WHERE dayid = '${v_date}'
    AND account_type = 1
    AND is_deleted = 0
    AND dismiss_status = 0
),

-- 服务对象信息
mdson_service_obj as (
    SELECT service_obj_id,
           out_service_obj_id,
           service_obj_name,
           service_obj_type,
           service_obj_type_name,
           region,
           sub_region,
           channel_type,
           channel_sub_type,
           link_account,
           if_nc_service_obj,
           if_ncm_service_obj,
           if_virtual_service_obj,
           if_sepecial_service_obj,
           is_nc,
           isaroundhospital_pgroup,
           status,
           store_class_name,
           is_star_shop,
           shop_star,
           is_nc_new_service_obj,
           is_service_obj_active,
           is_low_new_nc
    FROM prod_mdson.dim_service_obj_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
),

-- 服务对象及人员信息
mdson_service_obj_sever as (
    SELECT store_code,
           server_code
    FROM prod_mdson.ads_service_obj_server_d
    WHERE dayid = '${v_date}'
    AND store_code NOT LIKE '3-%'

    UNION ALL

    SELECT store_code,
           server_code
    FROM prod_mdson.ads_service_obj_server_d
    WHERE dayid = '${v_date_1}'
    AND store_code LIKE '3-%'
),

mdson_visit as ( -- 拜访信息
    SELECT id,
           visit_type,
           visit_time,
           visit_aim_type,
           visit_template_content_id,
           visit_mode,
           visit_status,
           service_obj_id,
           user_id,
           extra_json,
           plan_id,
           visit_type_name,
           visit_mode_name,
           visit_status_name,
           user_name,
           service_obj_name,
           timelength as time_lengeth
    FROM prod_mdson.dw_crm_visit_record_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
    AND visit_status = 2
),

-- 指标明细数据
base_detail_data AS (
       -- 门店拜访频次达标率明细
    SELECT 'month_visit_valid_cnt' as indicator_id,
           '门店拜访频次达成率明细' as indicator_name,
           mdson_visit.user_id,
           mdson_visit.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 THEN mdson_visit.id ELSE NULL END) as valid_visit_m --当月总拜访店次
    FROM mdson_visit
    LEFT JOIN mdson_service_obj ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    WHERE if_virtual_service_obj = 0
    AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}'
    AND visit_type = 1
    GROUP BY mdson_visit.user_id,
             mdson_visit.service_obj_id -- NKA专职NC门店拜访达成率


    UNION ALL

    SELECT 'month_nka_nc_visit_valid_cnt' as indicator_id,
           'NKA 有效拜访专职NC门店数明细' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END) as valid_visit_m --当月NKA 有效拜访专职NC门店店次
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    AND channel_type IN ('NKA', 'COT') -- 20260311接通知NKA更名为COT，删除LKA、RKA(保留)=>新增KA
    AND if_nc_service_obj = 1
    AND service_obj_type = 1
    AND status != 0
    AND mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id ----RKA专职NC门店拜访达成率


    UNION ALL

    SELECT 'month_rka_nc_visit_valid_cnt' as indicator_id,
           'RKA有效拜访专职NC门店数明细' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END) as valid_visit_m --当月RKA 有效拜访专职NC门店店次
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    AND channel_type IN ('RKA', 'KA') -- 20260311接通知NKA更名为COT，删除LKA、RKA(保留)=>新增KA
    AND if_nc_service_obj = 1
    AND service_obj_type = 1
    AND status != 0
    AND mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 院线店拜访达成率


    UNION ALL

    SELECT 'month_hospital_visit_valid_cnt' as indicator_id,
           '院线店有效拜访门店数明细' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END) as valid_visit_m --当月院线店有效拜访店次
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    AND isaroundhospital_pgroup = 1
    AND service_obj_type = 1
    AND status != 0
    AND mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 门店拜访达成率


    UNION ALL

    SELECT 'month_shop_visit_valid_cnt' as indicator_id,
           '门店有效拜访门店数明细' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END) as valid_visit_m --当有效拜访门店店次
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    AND service_obj_type = 1
    AND status != 0
    AND mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 月度服务商拜访达成率

    UNION ALL

    SELECT 'month_fws_visit_valid_cnt' as indicator_id,
           '月度有效拜访服务商数明细' as indicator_name,
           mdson_visit.user_id,
           mdson_visit.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 4 AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END) as valid_visit_m --当月有效拜访服务商数
    FROM mdson_visit
    LEFT JOIN mdson_service_obj ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_visit.user_id = mdson_user.user_id
    WHERE if_virtual_service_obj = 0
    AND service_obj_type = 3
    AND mdson_user.user_id IS NOT NULL
    AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}'
    AND (channel_name NOT IN ('GT')
    OR mdson_user.job_name NOT IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人')) --不需要按照名下考核
    GROUP BY mdson_visit.user_id,
             mdson_visit.service_obj_id -- 季度服务商拜访达成率


    UNION ALL

    SELECT 'quar_fws_visit_valid_cnt' as indicator_id,
           '季度有效拜访服务商数明细' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 4 AND mdson_user.user_id = mdson_visit.user_id AND substr(mdson_visit.visit_time, 1, 4) = substr('${v_cur_month}', 1, 4) -- 20260105新增：年份需相同
     AND ceil(int(regexp_replace(substr(mdson_visit.visit_time, 5, 3), '-', '')) / 3) = ceil(int(substr('${v_cur_month}', 5, 2)) / 3) THEN mdson_visit.id ELSE NULL END) as valid_visit_m --季度有效拜访服务商数
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    AND service_obj_type = 3
    AND status != 0
    AND mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id

    UNION ALL

    SELECT 'quar_fws_visit_valid_cnt' as indicator_id,
           '季度有效拜访服务商数明细' as indicator_name,
           mdson_visit.user_id,
           mdson_visit.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 4 AND ceil(int(regexp_replace(substr(mdson_visit.visit_time, 5, 3), '-', '')) / 3) = ceil(int(substr('${v_cur_month}', 5, 2)) / 3) THEN mdson_visit.id ELSE NULL END) as valid_visit_m --季度有效拜访服务商数
    FROM mdson_visit
    LEFT JOIN mdson_service_obj ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_visit.user_id = mdson_user.user_id
    WHERE if_virtual_service_obj = 0
    AND service_obj_type = 3
    AND mdson_user.user_id IS NOT NULL
    AND substr(mdson_visit.visit_time, 1, 4) = substr('${v_cur_month}', 1, 4) -- 20260105新增：年份需相同
    AND ceil(int(regexp_replace(substr(mdson_visit.visit_time, 5, 3), '-', '')) / 3) = ceil(int(substr('${v_cur_month}', 5, 2)) / 3)
    AND (channel_name NOT IN ('GT')
    OR mdson_user.job_name NOT IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人')) --不需要按照名下考核
    GROUP BY mdson_visit.user_id,
             mdson_visit.service_obj_id -- 当月GT门店拜访覆盖率


    UNION ALL

    SELECT 'month_gt_shop_visit_valid_cnt' as indicator_id,
           '月度GT有效拜访门店数明细' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END) as valid_visit_m --当月GT有效拜访门店店次
    FROM mdson_visit
    LEFT JOIN mdson_service_obj ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_visit.user_id = mdson_user.user_id
    WHERE if_virtual_service_obj = 0
    AND service_obj_type = 1
    AND mdson_user.user_id IS NOT NULL
    AND channel_name = 'GT'
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 季度GT门店拜访覆盖率

    UNION ALL

    SELECT 'quar_gt_shop_visit_valid_cnt' as indicator_id,
           '季度GT有效拜访门店数明细' as indicator_name,
           mdson_visit.user_id,
           mdson_visit.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND substr(mdson_visit.visit_time, 1, 4) = substr('${v_cur_month}', 1, 4) -- 20260105新增：年份需相同
     AND ceil(int(regexp_replace(substr(mdson_visit.visit_time, 5, 3), '-', '')) / 3) = ceil(int(substr('${v_cur_month}', 5, 2)) / 3) THEN mdson_visit.id ELSE NULL END) as valid_visit_m --季度GT效拜访门店店次
    FROM mdson_visit
    LEFT JOIN mdson_service_obj ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_visit.user_id = mdson_user.user_id
    WHERE if_virtual_service_obj = 0
    AND service_obj_type = 1
    AND mdson_user.user_id IS NOT NULL
    AND channel_name = 'GT'
    GROUP BY mdson_visit.user_id,
             mdson_visit.service_obj_id -- 月度GT渠道院线店拜访覆盖率

    UNION ALL

    SELECT 'month_gt_hospital_shop_visit_valid_cnt' as indicator_id,
           '月度GT有效拜访院线店门店数明细' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END) as valid_visit_m --当月GT有效拜访院线门店店次
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    AND service_obj_type = 1
    AND mdson_user.user_id IS NOT NULL
    AND channel_name = 'GT'
    AND isaroundhospital_pgroup = 1
    AND status != 0
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 季度GT渠道院线店拜访覆盖率


    UNION ALL

    SELECT 'quar_gt_hospital_shop_visit_valid_cnt' as indicator_id,
           '季度GT有效拜访院线店门店数明细' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND substr(mdson_visit.visit_time, 1, 4) = substr('${v_cur_month}', 1, 4) -- 20260105新增：年份需相同
     AND ceil(int(regexp_replace(substr(mdson_visit.visit_time, 5, 3), '-', '')) / 3) = ceil(int(substr('${v_cur_month}', 5, 2)) / 3) THEN mdson_visit.id ELSE NULL END) as valid_visit_m --季度GT效拜访门店店次
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    AND service_obj_type = 1
    AND mdson_user.user_id IS NOT NULL
    AND channel_name = 'GT'
    AND isaroundhospital_pgroup = 1
    AND status != 0
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 20260612：当月专职NC门店拜访达成率


    UNION ALL

    SELECT 'month_nc_shop_visit_valid_cnt' as indicator_id,
           '当月专职NC门店拜访数' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END) as valid_visit_m
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    AND is_nc_new_service_obj = 1
    AND service_obj_type = 1
    AND status != 0
    AND mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 20260612：当月星级门店拜访达成率


    UNION ALL

    SELECT 'month_star_shop_visit_valid_cnt' as indicator_id,
           '当月星级门店拜访数' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END) as valid_visit_m
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    AND is_star_shop = 1
    AND service_obj_type = 1
    AND status != 0
    AND mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 20260612：当月整体门店拜访达成率


    UNION ALL

    SELECT 'month_shop_visit_valid_cnt_1' as indicator_id,
           '当月整体门店拜访数' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END) as valid_visit_m
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE store_class_name = '实体门店'
    AND is_service_obj_active = 1 -- 正常营业
    AND service_obj_type = 1
    AND status != 0
    AND mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 20260612：当季全渠道重点门店拜访达成率


    UNION ALL

    SELECT 'quar_key_shop_visit_valid_cnt' as indicator_id,
           '当季全渠道重点门店拜访数' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND substr(mdson_visit.visit_time, 1, 4) = substr('${v_cur_month}', 1, 4) -- 年份相同
     AND ceil(int(regexp_replace(substr(mdson_visit.visit_time, 5, 3), '-', '')) / 3) = ceil(int(substr('${v_cur_month}', 5, 2)) / 3) THEN mdson_visit.id ELSE NULL END) as valid_visit_m
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE store_class_name = '实体门店'
    AND is_service_obj_active = 1 -- 正常营业
    AND service_obj_type = 1
    AND status != 0
    AND (channel_type IN ('COT', 'KA')
    OR (channel_type = 'GT'
    AND is_nc_new_service_obj = 1)
    OR isaroundhospital_pgroup = 1
    OR is_star_shop = 1)
    AND mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 20260616：门店拜访频次达标率明细


    UNION ALL

    SELECT 'month_visit_valid_cnt_1' as indicator_id,
           '门店拜访频次达成率明细_1' as indicator_name,
           mdson_visit.user_id,
           mdson_visit.service_obj_id,
           count(DISTINCT CASE WHEN (visit_type = 1 AND visit_mode = 1) OR (visit_type <> 1) THEN mdson_visit.id ELSE NULL END) as valid_visit_m --当月总拜访店次
    FROM mdson_visit
    LEFT JOIN mdson_service_obj ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    WHERE if_virtual_service_obj = 0
    AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}'
    GROUP BY mdson_visit.user_id,
             mdson_visit.service_obj_id -- 20260616：月度服务商拜访明细


    UNION ALL

    SELECT 'month_fws_visit_valid_cnt_1' as indicator_id,
           '月度有效拜访服务商数明细_1' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 4 AND mdson_user.user_id = mdson_visit.user_id AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END) as valid_visit_m --当月有效拜访服务商数
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    AND service_obj_type = 3
    AND status != 0
    AND mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 20260616：季度服务商拜访明细


    UNION ALL

    SELECT 'quar_fws_visit_valid_cnt_1' as indicator_id,
           '季度有效拜访服务商数明细_1' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 4 AND mdson_user.user_id = mdson_visit.user_id AND substr(mdson_visit.visit_time, 1, 4) = substr('${v_cur_month}', 1, 4) -- 20260105新增：年份需相同
     AND ceil(int(regexp_replace(substr(mdson_visit.visit_time, 5, 3), '-', '')) / 3) = ceil(int(substr('${v_cur_month}', 5, 2)) / 3) THEN mdson_visit.id ELSE NULL END) as valid_visit_m --季度有效拜访服务商数
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    AND service_obj_type = 3
    AND status != 0
    AND mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 20260616：当月院线店拜访明细


    UNION ALL

    SELECT 'month_hospital_visit_valid_cnt_1' as indicator_id,
           '院线店有效拜访门店数明细_1' as indicator_name,
           mdson_user.user_id,
           mdson_service_obj.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND mdson_user.user_id = mdson_visit.user_id AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END) as valid_visit_m --当月院线店有效拜访店次
    FROM mdson_service_obj
    LEFT JOIN mdson_service_obj_sever ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    AND isaroundhospital_pgroup = 1
    AND service_obj_type = 1
    AND status != 0
    AND mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id,
             mdson_service_obj.service_obj_id -- 20260616：当月全渠道拜访


    UNION ALL

    SELECT 'month_all_visit_valid_cnt' as indicator_id,
           '月度全渠道拜访次数' as indicator_name,
           mdson_visit.user_id,
           mdson_visit.service_obj_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 THEN mdson_visit.id
                               WHEN visit_type IN (2, 3, 4) THEN mdson_visit.id
                               ELSE NULL END) as valid_visit_m
    FROM mdson_visit
    LEFT JOIN mdson_service_obj ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    WHERE if_virtual_service_obj = 0
    AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}'
    GROUP BY mdson_visit.user_id,
             mdson_visit.service_obj_id
),

-- 20260622：门店白名单
white_list_store as (-- 当月门店白名单
    SELECT store_code,
           change_indicator,
           change_target
    FROM prod_mdson_dev.inf_mdson_white_list_store
    WHERE year_month = '${v_cur_month}'
),

-- 月度指标
white_list_store_month as (
    SELECT store_code,
           change_indicator,
           change_target
    FROM white_list_store
    WHERE change_indicator = '月度门店目标拜访频次'
),

-- 季度目标
white_list_store_quar as (
    SELECT store_code,
           change_indicator,
           change_target
    FROM white_list_store
    WHERE change_indicator = '季度门店目标拜访频次'
)

-- 主查询
INSERT OVERWRITE TABLE ads_mdson_user_cur_month_detail_di_v2 PARTITION (dayid = '${v_cur_month}')
SELECT DISTINCT base_detail_data.indicator_id,
       base_detail_data.indicator_name,
       base_detail_data.user_id,
       user_real_name,
       job_name,
       base_detail_data.service_obj_id,
       out_service_obj_id,
       service_obj_name,
       valid_visit_m, -- 20260618：if_visit_qualified_month字段为线上字段，不能灰度，因此合并新逻辑到该字段
       CASE WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND valid_visit_m >= 3 AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN '达标' -- 20260625：白名单临时补充到老指标里
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND valid_visit_m >= 4 THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND t1.change_target IN ('减半', '2') AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND t1.change_target IN ('1') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' THEN '未达标'
            WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND t1.change_target IN ('1', '减半') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' THEN '未达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND t1.change_target IN ('1', '减半') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt' THEN '未达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IS NULL AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IN ('1', '减半') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IN ('2') AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 THEN '未达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IS NULL AND valid_visit_m >= 4 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IN ('1') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IN ('2', '减半') AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 THEN '未达标' -- 当月COT/KA渠道院线店拜访达成
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IS NULL AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IN ('1', '减半') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IN ('2') AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') THEN '未达标' -- 当月GT渠道专职NC门店拜访达成
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IS NULL AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('1', '减半') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('2') AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') THEN '未达标' -- 当月GT渠道院线店拜访达成
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IS NULL AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IN ('1', '减半') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IN ('2') AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 THEN '未达标' -- 当月星级门店拜访达成
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IS NULL AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IN ('1', '减半') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IN ('2') AND valid_visit_m >= 2 THEN '达标'
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 THEN '未达标' -- 其他情况
            WHEN valid_visit_m >= 1 THEN '达标'
            ELSE '未达标' END as if_visit_qualified,
       '${v_opt_month}' as data_month,
       channel_name,
       channel_type,
       -- 20260612：拜访目标调整
       -- 当月COT/KA渠道专职NC门店拜访
       CASE WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IS NULL THEN 2
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IN ('0') THEN 0
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IN ('1', '减半') THEN 1
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IN ('2') THEN 2
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IS NULL THEN 4
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target = '0' THEN 0
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IN ('1') THEN 1
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IN ('2', '减半') THEN 2 -- 当月COT/KA渠道院线店拜访

            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IS NULL THEN 2
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IN ('0') THEN 0
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IN ('1', '减半') THEN 1
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IN ('2') THEN 2 -- 当月GT渠道专职NC门店拜访

            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IS NULL THEN 2
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('0') THEN 0
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('1', '减半') THEN 1
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('2') THEN 2 -- 当月GT渠道院线店拜访

            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IS NULL THEN 2
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IN ('0') THEN 0
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IN ('1', '减半') THEN 1
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IN ('2') THEN 2
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IS NULL THEN 1
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('0') THEN 0
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('1', '减半') THEN 1
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('2') THEN 2 -- 当月星级门店拜访达成

            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IS NULL THEN 2
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IN ('0') THEN 0
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IN ('1', '减半') THEN 1
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IN ('2') THEN 2
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IS NULL THEN 1
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('0') THEN 0
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('1', '减半') THEN 1
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('2') THEN 2
            ELSE 0 END as visit_target,
       '废弃' as if_visit_qualified_1
FROM base_detail_data
LEFT JOIN mdson_user ON base_detail_data.user_id = mdson_user.user_id
LEFT JOIN mdson_service_obj ON base_detail_data.service_obj_id = mdson_service_obj.service_obj_id
LEFT JOIN white_list_store_month t1 ON mdson_service_obj.service_obj_id = concat('1-', t1.store_code)