--@exclude_input=prod_mdson.dim_pub_date_d
--@exclude_input=prod_mdson.inf_mdson_vacation_np
--@exclude_input=prod_mdson_dev.inf_mdson_white_list_store
--odps sql
--********************************************************************--
--author:hipac_shuai.wu12190
--create time:2026-07-05 23:25:03
--********************************************************************--

SET odps.sql.allow.cartesian=true;

-- 20260705：作战室-明细表v2
WITH mdson_user AS
(-- 员工信息
    SELECT  user_id
            ,user_real_name
            ,job_name
            ,channel_name
            ,empno
    FROM    prod_mdson.dim_user_d
    WHERE   dayid = '${v_date}'
    AND     account_type = 1
    AND     is_deleted = 0
    AND     dismiss_status = 0
    AND     substr(nvl(join_time, create_time), 1, 7) <= '${v_opt_month}'
)
,mdson_service_obj AS
(-- 服务对象信息
    SELECT  t1.service_obj_id
            ,out_service_obj_id
            ,service_obj_name
            ,service_obj_type
            ,service_obj_type_name
            ,region
            ,sub_region
            ,channel_type
            ,channel_sub_type
            ,link_account
            ,if_nc_service_obj
            ,if_ncm_service_obj
            ,if_virtual_service_obj
            ,if_sepecial_service_obj
            ,t1.is_nc
            ,isaroundhospital_pgroup
            ,status
            ,store_class_name
            ,is_star_shop
            ,shop_star
            ,coalesce(t2.is_nc,0) as is_nc_new_service_obj
            ,coalesce(t2.is_low_new_nc,0) as is_low_new_nc
    FROM    prod_mdson.dim_service_obj_d t1
    LEFT JOIN
    (-- 20260707：取锁定的NC门店标签
    SELECT
        service_obj_id,
        is_nc,
        is_low_new_nc
    FROM
        prod_mdson.ads_mdson_nc_shop_m
    WHERE
        dayid = '${v_cur_month}'
    )t2 ON t1.service_obj_id = t2.service_obj_id
    WHERE   dayid = '${v_date}'
    AND     status != 0 -- 正常营业
    AND     is_deleted = 0
)
,mdson_service_obj_sever AS
(-- 服务对象及人员信息
-- 每月挂靠关系以1号为准，即取上个月底最后一天分区的数据
-- 20260720：门店类型取所有人为服务人员，其他类型取所有人(仅一条记录)
    SELECT  store_code
            ,server_code
            ,server_name
            ,job_name
            ,extra_json
    FROM    prod_mdson.ads_service_obj_server_d
    WHERE   dayid = REPLACE(DATEADD(date'${v_opt_month}-01', -1, 'dd'), '-', '')
            AND store_code like '1-%'
            AND job_name = 'SHOP_SERVER'
    UNION ALL
    SELECT  store_code
            ,server_code
            ,server_name
            ,job_name
            ,extra_json
    FROM    prod_mdson.ads_service_obj_server_d
    WHERE   dayid = REPLACE(DATEADD(date'${v_opt_month}-01', -1, 'dd'), '-', '')
            AND store_code NOT like '1-%'
    -- AND     store_code NOT LIKE '3-%'
    -- UNION ALL
    -- SELECT  store_code
    --         ,server_code
    --         ,server_name
    --         ,job_name
    --         ,extra_json
    -- FROM    prod_mdson.ads_service_obj_server_d
    -- WHERE   dayid = '${v_date_1}'
    -- AND     store_code LIKE '3-%'
)
,mdson_visit AS
(-- 拜访信息
    SELECT  id
            ,visit_type
            ,visit_time
            ,visit_aim_type
            ,visit_template_content_id
            ,visit_mode
            ,visit_status
            ,service_obj_id
            ,user_id
            ,extra_json
            ,plan_id
            ,visit_type_name
            ,visit_mode_name
            ,visit_status_name
            ,user_name
            ,service_obj_name
            ,timelength AS time_lengeth
    FROM    prod_mdson.dw_crm_visit_record_d
    WHERE   dayid = '${v_date}'
    AND     is_deleted = 0
    AND     visit_status = 2
)
,base_detail_data AS
(-- 指标明细数据
    -- 20260612：当月专职NC门店拜访达成率
    SELECT  'month_nc_shop_visit_valid_cnt' AS indicator_id
            ,'当月专职NC门店拜访数' AS indicator_name
            ,mdson_user.user_id
            ,mdson_service_obj.service_obj_id
            ,COUNT(DISTINCT
                  CASE    WHEN visit_type = 1
                              AND visit_mode = 1
                              AND mdson_user.user_id = mdson_visit.user_id
                              AND REGEXP_REPLACE(SUBSTR(mdson_visit.visit_time,1,7),'-','') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END
            ) AS valid_visit_m
    FROM    mdson_service_obj
    LEFT JOIN mdson_service_obj_sever
    ON      mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit
    ON      mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user
    ON      mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE   store_class_name = '实体门店'
    AND     status != 0 -- 正常营业
    AND     is_nc_new_service_obj = 1
    AND     service_obj_type = 1
    AND     mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id
             ,mdson_service_obj.service_obj_id
    -- 20260612：当月星级门店拜访达成率
    UNION ALL
    SELECT  'month_star_shop_visit_valid_cnt' AS indicator_id
            ,'当月星级门店拜访数' AS indicator_name
            ,mdson_user.user_id
            ,mdson_service_obj.service_obj_id
            ,COUNT(DISTINCT
                  CASE    WHEN visit_type = 1
                              AND visit_mode = 1
                              AND mdson_user.user_id = mdson_visit.user_id
                              AND REGEXP_REPLACE(SUBSTR(mdson_visit.visit_time,1,7),'-','') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END
            ) AS valid_visit_m
    FROM    mdson_service_obj
    LEFT JOIN mdson_service_obj_sever
    ON      mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit
    ON      mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user
    ON      mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE   store_class_name = '实体门店'
    AND     status != 0 -- 正常营业
    AND     is_star_shop = 1
    AND     service_obj_type = 1
    AND     mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id
             ,mdson_service_obj.service_obj_id
    -- 20260612：当月整体门店拜访达成率
    -- 20260713：当月拜访家数达成率(指标名调整)计算拜访即可，不关注是否在其名下
    UNION ALL
    SELECT  'month_shop_visit_valid_cnt_1' AS indicator_id
            ,'当月整体门店拜访数' AS indicator_name
            ,mdson_visit.user_id
            ,mdson_visit.service_obj_id
            -- ,COUNT(DISTINCT
            --       CASE    WHEN visit_type = 1
            --                   AND visit_mode = 1
            --                   AND mdson_user.user_id = mdson_visit.user_id
            --                   AND REGEXP_REPLACE(SUBSTR(mdson_visit.visit_time,1,7),'-','') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END
            -- ) AS valid_visit_m
            -- 20260707：从仅门店修改为包含门店、客户、经销商、服务商
            ,COUNT(DISTINCT CASE
                WHEN (visit_type = 1 AND visit_mode = 1) or (visit_type <> 1)
                THEN mdson_visit.id
                ELSE NULL END) AS valid_visit_m
    FROM    mdson_visit
    LEFT JOIN mdson_service_obj ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    WHERE REGEXP_REPLACE(SUBSTR(mdson_visit.visit_time,1,7),'-','') = '${v_cur_month}'
    AND (service_obj_type <> 1 or (store_class_name = '实体门店' AND status != 0))
    AND     mdson_visit.user_id IS NOT NULL
    GROUP BY mdson_visit.user_id
             ,mdson_visit.service_obj_id
    -- 20260612：当季全渠道重点门店拜访达成率
    UNION ALL
    SELECT  'quar_key_shop_visit_valid_cnt' AS indicator_id
            ,'当季全渠道重点门店拜访数' AS indicator_name
            ,mdson_user.user_id
            ,mdson_service_obj.service_obj_id
            ,COUNT(DISTINCT
                  CASE    WHEN visit_type = 1
                              AND visit_mode = 1
                              AND mdson_user.user_id = mdson_visit.user_id
                              -- 20260716：因季度累计需要单季计算改为单月计算
                              AND  substr(mdson_visit.visit_time,1,7) = '${v_opt_month}'
                              THEN mdson_visit.id ELSE NULL END
            ) AS valid_visit_m
    FROM    mdson_service_obj
    LEFT JOIN mdson_service_obj_sever
    ON      mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit
    ON      mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user
    ON      mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE   store_class_name = '实体门店'
    AND     status != 0 -- 正常营业
    AND     service_obj_type = 1
    AND     (channel_type in ('COT','KA') or (channel_type = 'GT' and is_nc_new_service_obj = 1) or isaroundhospital_pgroup = 1 or is_star_shop = 1)
    AND     mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id
             ,mdson_service_obj.service_obj_id
    -- 20260616：门店拜访频次达标率明细
    UNION ALL
    SELECT  'month_visit_valid_cnt_1' AS indicator_id
            ,'门店拜访频次达成率明细_1' AS indicator_name
            ,mdson_visit.user_id
            ,mdson_visit.service_obj_id
            ,COUNT(DISTINCT CASE    WHEN (visit_type = 1 AND visit_mode = 1) or (visit_type <> 1) THEN mdson_visit.id ELSE NULL END) AS valid_visit_m --当月总拜访店次
    FROM    mdson_visit
    LEFT JOIN mdson_service_obj
    ON      mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    WHERE   (service_obj_type <> 1 or (store_class_name = '实体门店' AND status != 0))
    AND     REGEXP_REPLACE(SUBSTR(mdson_visit.visit_time,1,7),'-','') = '${v_cur_month}'
    GROUP BY mdson_visit.user_id
             ,mdson_visit.service_obj_id
    -- 20260616：月度服务商拜访明细
    UNION ALL
    SELECT  'month_fws_visit_valid_cnt_1' AS indicator_id
            ,'月度有效拜访服务商数明细_1' AS indicator_name
            ,mdson_user.user_id
            ,mdson_service_obj.service_obj_id
            ,COUNT(DISTINCT
                  CASE    WHEN visit_type = 4
                              AND mdson_user.user_id = mdson_visit.user_id
                              AND REGEXP_REPLACE(SUBSTR(mdson_visit.visit_time,1,7),'-','') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END
            ) AS valid_visit_m --当月有效拜访服务商数
    FROM    mdson_service_obj
    LEFT JOIN mdson_service_obj_sever
    ON      mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit
    ON      mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user
    ON      mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE   service_obj_type = 3
    AND     status != 0
    AND     mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id
             ,mdson_service_obj.service_obj_id
    -- 20260616：季度服务商拜访明细
    UNION ALL
    SELECT  'quar_fws_visit_valid_cnt_1' AS indicator_id
            ,'季度有效拜访服务商数明细_1' AS indicator_name
            ,mdson_user.user_id
            ,mdson_service_obj.service_obj_id
            ,COUNT(DISTINCT
                  CASE    WHEN visit_type = 4
                              AND mdson_user.user_id = mdson_visit.user_id
                              -- 20260716：因季度累计需要单季计算改为单月计算
                              AND  substr(mdson_visit.visit_time,1,7) = '${v_opt_month}'
                              THEN mdson_visit.id ELSE NULL END
            ) AS valid_visit_m --季度有效拜访服务商数
    FROM    mdson_service_obj
    LEFT JOIN mdson_service_obj_sever
    ON      mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit
    ON      mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user
    ON      mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE   service_obj_type = 3
    AND     status != 0
    AND     mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id
             ,mdson_service_obj.service_obj_id
    -- 20260616：当月院线店拜访明细
    UNION ALL
    SELECT  'month_hospital_visit_valid_cnt_1' AS indicator_id
            ,'院线店有效拜访门店数明细_1' AS indicator_name
            ,mdson_user.user_id
            ,mdson_service_obj.service_obj_id
            ,COUNT(DISTINCT
                  CASE    WHEN visit_type = 1
                              AND visit_mode = 1
                              AND mdson_user.user_id = mdson_visit.user_id
                              AND REGEXP_REPLACE(SUBSTR(mdson_visit.visit_time,1,7),'-','') = '${v_cur_month}' THEN mdson_visit.id ELSE NULL END
            ) AS valid_visit_m --当月院线店有效拜访店次
    FROM    mdson_service_obj
    LEFT JOIN mdson_service_obj_sever
    ON      mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_visit
    ON      mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user
    ON      mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE   isaroundhospital_pgroup = 1
    AND     service_obj_type = 1
    AND     status != 0
    AND     store_class_name = '实体门店'
    AND     mdson_user.user_id IS NOT NULL
    GROUP BY mdson_user.user_id
             ,mdson_service_obj.service_obj_id
    -- 20260616：当月全渠道拜访
    UNION ALL
    SELECT  'month_all_visit_valid_cnt' AS indicator_id
            ,'月度全渠道拜访次数' AS indicator_name
            ,mdson_visit.user_id
            ,mdson_visit.service_obj_id
            ,COUNT(DISTINCT CASE
                WHEN visit_type = 1 AND visit_mode = 1 THEN mdson_visit.id
                WHEN visit_type in (2,3,4) then mdson_visit.id
                ELSE NULL END) AS valid_visit_m
    FROM    mdson_visit
    LEFT JOIN mdson_service_obj
    ON      mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    WHERE   (service_obj_type <> 1 or (store_class_name = '实体门店' AND status != 0))
    AND     REGEXP_REPLACE(SUBSTR(mdson_visit.visit_time,1,7),'-','') = '${v_cur_month}'
    GROUP BY mdson_visit.user_id
             ,mdson_visit.service_obj_id
)
-- 20260622：门店白名单
,white_list_store as
(-- 当月门店白名单
SELECT
    store_code,
    change_indicator,
    change_target
FROM
    prod_mdson_dev.inf_mdson_white_list_store
WHERE
    year_month = '${v_cur_month}'
)
,white_list_store_month as
(-- 月度指标
SELECT
    store_code,
    change_indicator,
    change_target
FROM
    white_list_store
WHERE
    change_indicator = '月度门店目标拜访频次'
)
,white_list_store_quar as
(-- 季度目标
SELECT
    store_code,
    change_indicator,
    change_target
FROM
    white_list_store
WHERE
    change_indicator = '季度门店目标拜访频次'
)
-- 20260707：人员节假日及休假折算比例
,user_discount_rate as
(-- 人员节假日及休假折算比例
SELECT
   distinct user_id,
   discount_rate
FROM
    prod_mdson.ads_crm_user_visit_target_d_v2
WHERE
    data_month = '${v_opt_month}'
    and dayid = '${v_cur_month}'
)
-- 20260622：增加节假日及休假折算部分
-- 节假日
,vacation_info as
(-- 节假日
SELECT
    year_month,
    total_days,
    work_days,
    vacation_days
FROM
    prod_mdson.inf_mdson_vacation_np
)
,vacation_info_quar as
(-- 季度节假日
SELECT
    year_quarter,
    max(year_month) as year_month,
    sum(total_days) as total_days,
    sum(work_days) as work_days,
    sum(vacation_days) as vacation_days
FROM
    prod_mdson.inf_mdson_vacation_np
GROUP BY
    year_quarter
)
,vacation_info_quar_process as
(-- 季度节假日
SELECT
    year_quarter,
    concat(substr(year_month_id,1,4),'-',substr(year_month_id,5,2)) as year_month,
    total_days,
    work_days,
    vacation_days
FROM
    vacation_info_quar t1
    JOIN
    (-- 取季度各月
    SELECT
        distinct year_quarter_id
        ,year_month_id
    FROM
        prod_mdson.dim_pub_date_d
    )t2 ON t1.year_quarter = t2.year_quarter_id
)
-- 休假
,leave_info AS
(-- 系统请假信息
SELECT
    user_id,
    vacation_begin_time,
    vacation_end_time
FROM
    prod_mdson.dwd_crm_vacation_d
WHERE
    dayid = '${v_date}'
    AND is_deleted = 0
    AND vacation_status != 2
)
,udaf AS
(-- 请假明细日期
SELECT
    user_id,
    vacation_begin_time,
    vacation_end_time,
    t.vacation_date AS mid_date
FROM
    leave_info
LATERAL VIEW yt_date_flat_map(vacation_begin_time,vacation_end_time) t AS vacation_date
)
,user_leave as
(-- 用户请假汇总
SELECT
    user_id,
    substr(mid_date,1,7) as year_month,
    count(distinct mid_date) leave_days
FROM
    udaf
GROUP BY
    user_id,
    substr(mid_date,1,7)
)
,user_leave_quar as
(-- 用户按季请假汇总
SELECT
    user_id,
    t2.year_quarter_id as year_quarter,
    count(distinct mid_date) as leave_days
FROM
    udaf t1
    LEFT JOIN prod_mdson.dim_pub_date_d t2 ON t1.mid_date = t2.calendar_date
GROUP BY
    user_id,
    t2.year_quarter_id
)
,user_discount_rate_quar as
(-- 用户入职时间(join_time字段不可用，用账户创建时间替代)
SELECT
    t1.user_id,
    0 as discount_rate_quar
FROM
    user_leave_quar t1
    JOIN vacation_info_quar_process t2 ON t1.year_quarter = t2.year_quarter and t1.leave_days >= t2.work_days
WHERE
    t2.year_month = '${v_opt_month}'
)
-- 20260622：当月新入职员工及全月请假员工不计入个人达成及团队达成
,user_discard as
(-- 用户入职时间(join_time字段不可用，用账户创建时间替代)
SELECT
    user_id,
    substr(nvl(join_time, create_time),1,7) as year_month,
    1 as is_discard_user
FROM
    prod_mdson.dim_user_d
WHERE
    dayid = '${v_date}'
    AND substr(nvl(join_time, create_time),1,7) = '${v_opt_month}'
UNION
-- 全月请假员工
SELECT
    t1.user_id,
    t1.year_month,
    1 as is_discard_user
FROM
    user_leave t1
    JOIN vacation_info t2 ON t1.year_month = t2.year_month and t1.leave_days >= t2.work_days
)
,quar_rate AS
(
    SELECT  year_month_id
            ,round(MAX(diff) / MAX(diff1),4) AS quar_rate
            ,round(MAX(diff2) / MAX(diff3),4) AS month_rate
    FROM    (
                SELECT  year_month_id
                        ,date_id
                        ,CAST(yt_date_diff(date_id,quarter_first_date) AS INT) + 1 AS diff
                        ,yt_date_diff(quarter_last_date,quarter_first_date) + 1 AS diff1
                        ,CAST(yt_date_diff(date_id,month_first_date) AS INT) + 1 AS diff2
                        ,yt_date_diff(month_last_date,month_first_date) + 1 AS diff3
                FROM    prod_mdson.dim_pub_date_d
                WHERE   date_id <= '${v_date}'
                AND     year_month_id = '${v_cur_month}'
                ORDER BY date_id
            ) t
    GROUP BY year_month_id
    ORDER BY year_month_id
)

-- ,process_white_list_store as
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



,main as
(-- 主查询
SELECT  DISTINCT base_detail_data.indicator_id
        ,base_detail_data.indicator_name
        ,base_detail_data.user_id
        ,user_real_name
        ,job_name
        ,base_detail_data.service_obj_id
        ,out_service_obj_id
        ,service_obj_name
        ,valid_visit_m
        ,-- 20260618：if_visit_qualified_month字段为线上字段，不能灰度，因此合并新逻辑到该字段
        CASE
            -- WHEN
            --     indicator_id = 'month_nka_nc_visit_valid_cnt'
            --     AND b1.change_type = '有效拜访名下所有NKA专职NC门店每月2访的门店数'
            --     AND valid_visit_m >= 2 THEN '达标'
            -- WHEN indicator_id = 'month_nka_nc_visit_valid_cnt'
            --     AND b1.change_type = '有效拜访名下所有NKA专职NC门店每月1访的门店数'
            --     AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt'
                AND valid_visit_m >= 3
                AND SUBSTR(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10' THEN '达标'
            -- 20260625：白名单临时补充到老指标里
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND valid_visit_m >= round(4*month_rate,0) THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND t1.change_target in ('减半','2') AND valid_visit_m >= round(2*month_rate,0) THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND t1.change_target in ('1') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND t1.change_target in ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' THEN '未达标'
            -- WHEN
            --     indicator_id = 'month_rka_nc_visit_valid_cnt'
            --     AND b1.change_type = '有效拜访名下所有RKA专职NC门店每月1访的门店数'
            --     AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND valid_visit_m >= round(2*month_rate,0) THEN '达标'
            WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND t1.change_target in ('1','减半') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND t1.change_target in ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' THEN '未达标'
            -- WHEN
            --     indicator_id = 'month_hospital_visit_valid_cnt'
            --     AND b2.change_type = '当月有效拜访次数为1次的院线店数'
            --     AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND valid_visit_m >= round(2*month_rate,0) THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND t1.change_target in ('1','减半') AND valid_visit_m >= 1 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND t1.change_target in ('0') AND valid_visit_m >= 0 THEN '达标'
            WHEN indicator_id = 'month_hospital_visit_valid_cnt' THEN '未达标'
            -- WHEN
            --     indicator_id = 'month_hospital_visit_valid_cnt_1'
            --     AND b2.change_type = '当月有效拜访次数为1次的院线店数'
            --     AND valid_visit_m >= 1 THEN '达标'
            -- WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND valid_visit_m >= 2 THEN '达标'
            -- WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' THEN '未达标'
        -- 20260612：新增达标判定逻辑
        -- 20260720：在计算是否达标时，从按时间进度折算目标频次(取整后)再与已拜访频次调整为频次达标率直接与时间进度比较
            -- 当月COT/KA渠道专职NC门店拜访达成
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 0 and t1.change_target is null
                and valid_visit_m >= if(ceil(2*month_rate*coalesce(t2.discount_rate,1))=1,1,round(round(2*coalesce(t2.discount_rate,1),0)*month_rate,2)) then '达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 0 and t1.change_target in ('0')
                and valid_visit_m >= 0 then '达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 0 and t1.change_target in ('1','减半')
                and valid_visit_m >= if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),2)) then '达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 0 and t1.change_target in ('2')
                and valid_visit_m >= if(ceil(2*month_rate*coalesce(t2.discount_rate,1))=1,1,round(round(2*coalesce(t2.discount_rate,1),0)*month_rate,2)) then '达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 0 then '未达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 1 and t1.change_target is null
                and valid_visit_m >= if(ceil(4*month_rate*coalesce(t2.discount_rate,1))=1,1,round(round(4*coalesce(t2.discount_rate,1),0)*month_rate,2)) then '达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 1 and t1.change_target in ('0')
                and valid_visit_m >= 0 then '达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 1 and t1.change_target in ('1')
                and valid_visit_m >= if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),2)) then '达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 1 and t1.change_target in ('2','减半')
                and valid_visit_m >= if(ceil(2*month_rate*coalesce(t2.discount_rate,1))=1,1,round(round(2*coalesce(t2.discount_rate,1),0)*month_rate,2)) then '达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 1 then '未达标'
            -- 当月COT/KA渠道院线店拜访达成
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and t1.change_target is null
                and valid_visit_m >= if(ceil(2*month_rate*coalesce(t2.discount_rate,1))=1,1,round(round(2*coalesce(t2.discount_rate,1),0)*month_rate,2)) then '达标'
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and t1.change_target in ('0')
                and valid_visit_m >= 0 then '达标'
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and t1.change_target in ('1','减半')
                and valid_visit_m >= if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),2)) then '达标'
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and t1.change_target in ('2')
                and valid_visit_m >= if(ceil(2*month_rate*coalesce(t2.discount_rate,1))=1,1,round(round(2*coalesce(t2.discount_rate,1),0)*month_rate,2)) then '达标'
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                then '未达标'
            -- 当月GT渠道专职NC门店拜访达成
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target is null
                and valid_visit_m >= if(ceil(2*month_rate*coalesce(t2.discount_rate,1))=1,1,round(round(2*coalesce(t2.discount_rate,1),0)*month_rate,2)) then '达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target in ('0')
                and valid_visit_m >= 0 then '达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target in ('1','减半')
                and valid_visit_m >= if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),2)) then '达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target in ('2')
                and valid_visit_m >= if(ceil(2*month_rate*coalesce(t2.discount_rate,1))=1,1,round(round(2*coalesce(t2.discount_rate,1),0)*month_rate,2)) then '达标'
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                then '未达标'
            -- 当月GT渠道院线店拜访达成
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and is_star_shop = 1 and t1.change_target is null
                and valid_visit_m >= if(ceil(2*month_rate*coalesce(t2.discount_rate,1))=1,1,round(round(2*coalesce(t2.discount_rate,1),0)*month_rate,2)) then '达标'
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and is_star_shop = 1 and t1.change_target in ('0') and valid_visit_m >= 0 then '达标'
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and is_star_shop = 1 and t1.change_target in ('1','减半')
                and valid_visit_m >= if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),2)) then '达标'
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and is_star_shop = 1 and t1.change_target in ('2')
                and valid_visit_m >= if(ceil(2*month_rate*coalesce(t2.discount_rate,1))=1,1,round(round(2*coalesce(t2.discount_rate,1),0)*month_rate,2)) then '达标'
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and is_star_shop = 1 then '未达标'
            -- 当月星级门店拜访达成
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and shop_star = 5 and t1.change_target is null
                and valid_visit_m >= if(ceil(2*month_rate*coalesce(t2.discount_rate,1))=1,1,round(round(2*coalesce(t2.discount_rate,1),0)*month_rate,2)) then '达标'
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and shop_star = 5 and t1.change_target in ('0')
                and valid_visit_m >= 0 then '达标'
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and shop_star = 5 and t1.change_target in ('1','减半')
                and valid_visit_m >= if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),2)) then '达标'
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and shop_star = 5 and t1.change_target in ('2')
                and valid_visit_m >= if(ceil(2*month_rate*coalesce(t2.discount_rate,1))=1,1,round(round(2*coalesce(t2.discount_rate,1),0)*month_rate,2)) then '达标'
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and shop_star = 5 then '未达标'
            -- 20260714：当季全渠道重点门店拜访覆盖率，季度不等于单月累加
            WHEN
                indicator_id = 'quar_key_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人')
                and valid_visit_m >= if(ceil(1*coalesce(t4.discount_rate_quar,1))=1,1,round(1*coalesce(t4.discount_rate_quar,1),2))
                then '达标'
            WHEN
                indicator_id = 'quar_key_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人')
                then '未达标'
            -- 20260714：当季服务商拜访覆盖率，季度不等于单月累加
            WHEN
                indicator_id = 'quar_fws_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人')
                and valid_visit_m >= if(ceil(1*coalesce(t4.discount_rate_quar,1))=1,1,round(1*coalesce(t4.discount_rate_quar,1),2))
                then '达标'
            WHEN
                indicator_id = 'quar_fws_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人')
                then '未达标'
            -- 其他情况
            WHEN valid_visit_m >= if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),2)) THEN '达标'
            ELSE '未达标'
        END AS if_visit_qualified
        ,'${v_opt_month}' AS data_month
        ,channel_name
        ,channel_type
        ,CAST(-- 20260612：拜访目标调整
        CASE
            -- 当月COT/KA渠道专职NC门店拜访
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 0 and t1.change_target is null
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 0 and t1.change_target in ('0')
                then 0
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 0 and t1.change_target in ('1','减半')
                then if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 0 and t1.change_target in ('2')
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 1 and t1.change_target is null
                then if(ceil(4*coalesce(t2.discount_rate,1))=1,1,round(4*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 1 and t1.change_target = '0'
                then 0
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 1 and t1.change_target in ('1')
                then if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and is_low_new_nc = 1 and t1.change_target in ('2','减半')
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            -- 当月COT/KA渠道院线店拜访
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and t1.change_target is null
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and t1.change_target in ('0')
                then 0
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and t1.change_target in ('1','减半')
                then if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('COT','KA')
                and t1.change_target in ('2')
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            -- 当月GT渠道专职NC门店拜访
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target is null
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target in ('0')
                then 0
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target in ('1','减半')
                then if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_nc_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target in ('2')
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            -- 当月GT渠道院线店拜访
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and is_star_shop = 1 and t1.change_target is null
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and is_star_shop = 1 and t1.change_target in ('0')
                then 0
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and is_star_shop = 1 and t1.change_target in ('1','减半')
                then if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and is_star_shop = 1 and t1.change_target in ('2')
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target is null
                then if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target in ('0')
                then 0
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target in ('1','减半')
                then if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_hospital_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target in ('2')
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            -- 当月星级门店拜访达成
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and shop_star = 5 and t1.change_target is null
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and shop_star = 5 and t1.change_target in ('0')
                then 0
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and shop_star = 5 and t1.change_target in ('1','减半')
                then if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and shop_star = 5 and t1.change_target in ('2')
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target is null
                then if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target in ('0')
                then 0
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target in ('1','减半')
                then if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),0))
            WHEN
                indicator_id = 'month_star_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人') and channel_type in ('GT')
                and t1.change_target in ('2')
                then if(ceil(2*coalesce(t2.discount_rate,1))=1,1,round(2*coalesce(t2.discount_rate,1),0))
            -- 当季全渠道重点门店拜访达成
            WHEN
                indicator_id = 'quar_key_shop_visit_valid_cnt'
                and job_name in ('城市渠道负责人','城市群负责人')
                then coalesce(t3.change_target,1)
            -- 当季服务商拜访覆盖率
            WHEN
                indicator_id = 'quar_fws_visit_valid_cnt_1'
                and job_name in ('城市渠道负责人','城市群负责人','大区通路发展经理')
                then 1
            -- 20260714：其他指标明细展示要剔除目标为0的门店/服务商
            ELSE if(ceil(1*coalesce(t2.discount_rate,1))=1,1,round(1*coalesce(t2.discount_rate,1),0))
        END AS BIGINT) as visit_target
        ,'废弃' as if_visit_qualified_1
FROM    base_detail_data
LEFT JOIN mdson_user
ON      base_detail_data.user_id = mdson_user.user_id
LEFT JOIN mdson_service_obj
ON      base_detail_data.service_obj_id = mdson_service_obj.service_obj_id
LEFT JOIN white_list_store_month t1 ON mdson_service_obj.service_obj_id = concat('1-',t1.store_code)
LEFT JOIN user_discount_rate t2 ON base_detail_data.user_id = t2.user_id
-- 20260708：明细表直接剔除当月新入职及全月休假员工
LEFT JOIN user_discard ON base_detail_data.user_id = user_discard.user_id
LEFT JOIN white_list_store_quar t3 ON mdson_service_obj.service_obj_id = concat('1-',t3.store_code)
LEFT JOIN user_discount_rate_quar t4 ON base_detail_data.user_id = t4.user_id
JOIN quar_rate ON 1=1
-- 20260710：明细表按需求再加上全月休假及当月新入职人员
-- WHERE
--     coalesce(user_discard.is_discard_user,0) = 0

-- -- 老的白名单作废
-- LEFT JOIN   (
--                 SELECT  store_code
--                         ,change_type
--                 FROM    prod_mdson_dev.inf_mdson_visit_change_shop
--                 WHERE   change_type IN ('有效拜访名下所有RKA专职NC门店每月1访的门店数','有效拜访名下所有NKA专职NC门店每月2访的门店数','有效拜访名下所有NKA专职NC门店每月1访的门店数')
--             ) b1
-- ON      mdson_service_obj.out_service_obj_id = b1.store_code
-- LEFT JOIN   (
--                 SELECT  store_code
--                         ,change_type
--                 FROM    prod_mdson_dev.inf_mdson_visit_change_shop
--                 WHERE   change_type IN ('当月有效拜访次数为1次的院线店数')
--             ) b2
-- ON      mdson_service_obj.out_service_obj_id = b2.store_code
)


INSERT OVERWRITE TABLE ads_mdson_user_cur_month_detail_di_v2 PARTITION (dayid = '${v_cur_month}')
SELECT * FROM main WHERE visit_target > 0