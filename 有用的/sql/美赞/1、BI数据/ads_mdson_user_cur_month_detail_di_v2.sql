--@exclude_input=prod_mdson.dim_pub_date_d
--@exclude_input=prod_mdson.inf_mdson_vacation_np
--@exclude_input=prod_mdson_dev.inf_mdson_white_list_store
--odps sql
--********************************************************************--
--author:hipac_shuai.wu12190
--create time:2026-07-05 23:25:03
--********************************************************************--
SET odps.sql.allow.cartesian = TRUE;
 -- 20260705：作战室-明细表v2
WITH mdson_user as ( -- 员工信息
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

mdson_service_obj as ( -- 服务对象信息
    SELECT t1.service_obj_id,
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
           t1.is_nc,
           isaroundhospital_pgroup,
           status,
           store_class_name,
           is_star_shop,
           shop_star,
           coalesce(t2.is_nc, 0) as is_nc_new_service_obj,
           is_service_obj_active,
           coalesce(t2.is_low_new_nc, 0) as is_low_new_nc
    FROM prod_mdson.dim_service_obj_d t1
    LEFT JOIN ( -- 20260707：取锁定的NC门店标签
        SELECT service_obj_id,
               is_nc,
               is_low_new_nc
        FROM prod_mdson.ads_mdson_nc_shop_m
        WHERE dayid = '${v_cur_month}'
    ) t2 ON t1.service_obj_id = t2.service_obj_id
    WHERE dayid = '${v_date}'
    AND is_deleted = 0 --and      status != 0
),

mdson_service_obj_sever as ( -- 服务对象及人员信息
    SELECT store_code,
           server_code,
           server_name,
           job_name,
           extra_json
    FROM prod_mdson.ads_service_obj_server_d
    WHERE dayid = '${v_date}'
    AND store_code NOT LIKE '3-%'

    UNION ALL

    SELECT store_code,
           server_code,
           server_name,
           job_name,
           extra_json
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

base_detail_data as ( -- 指标明细数据
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
    -- 20260713：当月拜访家数达成率(指标名调整)计算拜访即可，不关注是否在其名下


    UNION ALL

    SELECT 'month_shop_visit_valid_cnt_1' as indicator_id,
           '当月整体门店拜访数' as indicator_name,
           mdson_visit.user_id,
           mdson_visit.service_obj_id -- ,COUNT(DISTINCT
    --       CASE    WHEN visit_type = 1
    --                   AND visit_mode = 1
    --                   AND mdson_user.user_id = mdson_visit.user_id
    --                   AND REGEXP_REPLACE(SUBSTR(mdson_visit.visit_time,1,7),'-','') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END
    -- ) AS valid_visit_m
    -- 20260707：从仅门店修改为包含门店、客户、经销商、服务商
       ,
           count(DISTINCT CASE WHEN (visit_type = 1 AND visit_mode = 1) OR (visit_type <> 1) THEN mdson_visit.id ELSE NULL END) as valid_visit_m
    FROM mdson_visit
    LEFT JOIN mdson_service_obj ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    WHERE if_virtual_service_obj = 0
    AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}'
    AND NOT (service_obj_type = 1
    AND store_class_name <> '实体门店') -- store_class_name = '实体门店'
    -- AND     is_service_obj_active = 1 -- 正常营业
    -- AND     service_obj_type = 1
    -- AND     status != 0
    AND mdson_visit.user_id IS NOT NULL
    GROUP BY mdson_visit.user_id,
             mdson_visit.service_obj_id -- 20260612：当季全渠道重点门店拜访达成率


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
    AND NOT (service_obj_type = 1
    AND store_class_name <> '实体门店')
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
    AND NOT (service_obj_type = 1
    AND store_class_name <> '实体门店')
    AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}'
    GROUP BY mdson_visit.user_id,
             mdson_visit.service_obj_id
) -- 20260622：门店白名单
,

white_list_store as ( -- 当月门店白名单
    SELECT store_code,
           change_indicator,
           change_target
    FROM prod_mdson_dev.inf_mdson_white_list_store
    WHERE year_month = '${v_cur_month}'
),

white_list_store_month as ( -- 月度指标
    SELECT store_code,
           change_indicator,
           change_target
    FROM white_list_store
    WHERE change_indicator = '月度门店目标拜访频次'
),

white_list_store_quar as ( -- 季度目标
    SELECT store_code,
           change_indicator,
           change_target
    FROM white_list_store
    WHERE change_indicator = '季度门店目标拜访频次'
) -- 20260707：人员节假日及休假折算比例
,

user_discount_rate as ( -- 人员节假日及休假折算比例
    SELECT DISTINCT user_id,
           discount_rate
    FROM prod_mdson.ads_crm_user_visit_target_d_v2
    WHERE data_month = '${v_opt_month}'
    AND dayid = '${v_cur_month}'
) -- 20260622：增加节假日及休假折算部分
-- 节假日
,

vacation_info as ( -- 节假日
    SELECT year_month,
           total_days,
           work_days,
           vacation_days
    FROM prod_mdson.inf_mdson_vacation_np
) -- 休假
,

leave_info as ( -- 系统请假信息
    SELECT user_id,
           vacation_begin_time,
           vacation_end_time
    FROM prod_mdson.dwd_crm_vacation_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
    AND vacation_status != 2
),

udaf as ( -- 请假明细日期
    SELECT user_id,
           vacation_begin_time,
           vacation_end_time,
           t.vacation_date as mid_date
    FROM leave_info LATERAL VIEW yt_date_flat_map(vacation_begin_time, vacation_end_time) t as vacation_date
),

user_leave as ( -- 用户请假汇总
    SELECT user_id,
           substr(mid_date, 1, 7) as year_month,
           count(DISTINCT mid_date) leave_days
    FROM udaf
    GROUP BY user_id,
             substr(mid_date, 1, 7)
) -- 20260622：当月新入职员工及全月请假员工不计入个人达成及团队达成
,

user_discard as ( -- 用户入职时间(join_time字段不可用，用账户创建时间替代)
    SELECT user_id,
           substr(create_time, 1, 7) as year_month,
           1 as is_discard_user
    FROM prod_mdson.dim_user_d
    WHERE dayid = '${v_date}'
    AND replace(substr(create_time, 1, 7), '-', '') = '${v_cur_month}'

    UNION

    -- 全月请假员工
    SELECT t1.user_id,
           t1.year_month,
           1 as is_discard_user
    FROM user_leave t1
    JOIN vacation_info t2 ON t1.year_month = t2.year_month AND t1.leave_days >= t2.work_days
),

quar_rate as (
    SELECT year_month_id,
           round(max(diff) / max(diff1), 4) as quar_rate,
           round(max(diff2) / max(diff3), 4) as month_rate
    FROM (
        SELECT year_month_id,
               date_id,
               cast(yt_date_diff(date_id, quarter_first_date) as INT) + 1 as diff,
               yt_date_diff(quarter_last_date, quarter_first_date) + 1 as diff1,
               cast(yt_date_diff(date_id, month_first_date) as INT) + 1 as diff2,
               yt_date_diff(month_last_date, month_first_date) + 1 as diff3
        FROM prod_mdson.dim_pub_date_d
        WHERE date_id <= '${v_date}'
        AND year_month_id = '${v_cur_month}'
        ORDER BY date_id
    ) t
    GROUP BY year_month_id
    ORDER BY year_month_id
) -- ,process_white_list_store as
-- (-- 处理原始的门店白名单
-- SELECT
--     concat('1-',t1.store_code) as service_obj_id,
--     t1.change_indicator,
--     change_target,
--     (-- 调整后的目标次数
--     CASE
--         WHEN change_target = '减半' and
--     )
-- FROM
--     white_list_store t1
--     LEFT JOIN mdson_service_obj t2 ON concat('1-',store_code) = t2.service_obj_id
-- )
-- 主查询


INSERT OVERWRITE TABLE prod_mdson.ads_mdson_user_cur_month_detail_di_v2 PARTITION (dayid = '${v_cur_month}')
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

            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND valid_visit_m >= round(4 * month_rate, 0) THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND t1.change_target IN ('减半', '2') AND valid_visit_m >= round(2 * month_rate, 0) THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND t1.change_target IN ('1') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' THEN '未达标' -- WHEN

            WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND valid_visit_m >= round(2 * month_rate, 0) THEN '达标'
            WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND t1.change_target IN ('1', '减半') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' THEN '未达标' -- WHEN

            WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND valid_visit_m >= round(2 * month_rate, 0) THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND t1.change_target IN ('1', '减半') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt' THEN '未达标' -- WHEN

            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IS NULL AND valid_visit_m >= if(ceil(2 * month_rate * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * month_rate * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IN ('1', '减半') AND valid_visit_m >= if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IN ('2') AND valid_visit_m >= if(ceil(2 * month_rate * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * month_rate * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 THEN '未达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IS NULL AND valid_visit_m >= if(ceil(4 * month_rate * coalesce(t2.discount_rate, 1)) = 1, 1, round(4 * month_rate * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IN ('1') AND valid_visit_m >= if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IN ('2', '减半') AND valid_visit_m >= if(ceil(2 * month_rate * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * month_rate * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 THEN '未达标' -- 当月COT/KA渠道院线店拜访达成

            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IS NULL AND valid_visit_m >= if(ceil(2 * month_rate * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * month_rate * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IN ('1', '减半') AND valid_visit_m >= if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IN ('2') AND valid_visit_m >= if(ceil(2 * month_rate * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * month_rate * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') THEN '未达标' -- 当月GT渠道专职NC门店拜访达成

            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IS NULL AND valid_visit_m >= if(ceil(2 * month_rate * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * month_rate * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('1', '减半') AND valid_visit_m >= if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('2') AND valid_visit_m >= if(ceil(2 * month_rate * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * month_rate * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') THEN '未达标' -- 当月GT渠道院线店拜访达成

            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IS NULL AND valid_visit_m >= if(ceil(2 * month_rate * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * month_rate * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IN ('1', '减半') AND valid_visit_m >= if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IN ('2') AND valid_visit_m >= if(ceil(2 * month_rate * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * month_rate * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 THEN '未达标' -- 当月星级门店拜访达成

            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IS NULL AND valid_visit_m >= if(ceil(2 * month_rate * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * month_rate * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IN ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IN ('1', '减半') AND valid_visit_m >= if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IN ('2') AND valid_visit_m >= if(ceil(2 * month_rate * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * month_rate * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 THEN '未达标' -- 其他情况

            WHEN valid_visit_m >= if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0)) THEN '达标'
            ELSE '未达标' END as if_visit_qualified,
       '${v_opt_month}' as data_month,
       channel_name,
       channel_type,
       cast( -- 20260612：拜访目标调整
CASE  -- 当月COT/KA渠道专职NC门店拜访
WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IS NULL THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IN ('0') THEN 0
WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IN ('1', '减半') THEN if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 0 AND t1.change_target IN ('2') THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IS NULL THEN if(ceil(4 * coalesce(t2.discount_rate, 1)) = 1, 1, round(4 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target = '0' THEN 0
WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IN ('1') THEN if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_low_new_nc = 1 AND t1.change_target IN ('2', '减半') THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0)) -- 当月COT/KA渠道院线店拜访

WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IS NULL THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IN ('0') THEN 0
WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IN ('1', '减半') THEN if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND t1.change_target IN ('2') THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0)) -- 当月GT渠道专职NC门店拜访

WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IS NULL THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('0') THEN 0
WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('1', '减半') THEN if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('2') THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0)) -- 当月GT渠道院线店拜访

WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IS NULL THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IN ('0') THEN 0
WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IN ('1', '减半') THEN if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_star_shop = 1 AND t1.change_target IN ('2') THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IS NULL THEN if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('0') THEN 0
WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('1', '减半') THEN if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('2') THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0)) -- 当月星级门店拜访达成

WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IS NULL THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IN ('0') THEN 0
WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IN ('1', '减半') THEN if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND shop_star = 5 AND t1.change_target IN ('2') THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IS NULL THEN if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('0') THEN 0
WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('1', '减半') THEN if(ceil(1 * coalesce(t2.discount_rate, 1)) = 1, 1, round(1 * coalesce(t2.discount_rate, 1), 0))
WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND t1.change_target IN ('2') THEN if(ceil(2 * coalesce(t2.discount_rate, 1)) = 1, 1, round(2 * coalesce(t2.discount_rate, 1), 0)) -- 当季全渠道重点门店拜访达成

WHEN indicator_id = 'quar_key_shop_visit_valid_cnt' AND job_name IN ('城市渠道负责人', '城市群负责人') THEN coalesce(t3.change_target, 1)
ELSE 0 END as BIGINT) as visit_target
FROM base_detail_data
LEFT JOIN mdson_user ON base_detail_data.user_id = mdson_user.user_id
LEFT JOIN mdson_service_obj ON base_detail_data.service_obj_id = mdson_service_obj.service_obj_id
LEFT JOIN white_list_store_month t1 ON mdson_service_obj.service_obj_id = concat('1-', t1.store_code)
LEFT JOIN user_discount_rate t2 ON base_detail_data.user_id = t2.user_id -- 20260708：明细表直接剔除当月新入职及全月休假员工
LEFT JOIN user_discard ON base_detail_data.user_id = user_discard.user_id
LEFT JOIN white_list_store_quar t3 ON mdson_service_obj.service_obj_id = concat('1-', t3.store_code)
JOIN quar_rate ON 1 = 1