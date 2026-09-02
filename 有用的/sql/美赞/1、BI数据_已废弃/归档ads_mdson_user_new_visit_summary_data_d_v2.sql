--@exclude_input=prod_mdson.dim_pub_date_d
--@exclude_input=prod_mdson.inf_mdson_vacation_np
--@exclude_input=prod_mdson_dev.inf_mdson_white_list_empno
--odps sql
--********************************************************************--
--author:hipac_shuai.wu12190
--create time:2026-07-05 23:40:15
--********************************************************************--


-- 20260705：作战室-汇总表v2
WITH user_info AS
(-- 人员信息
    SELECT  user_id
            ,user_real_name
            ,job_name
            ,channel_name
            ,department_charger_id
            ,department_charger_name
            ,dept_id
            ,department_name
            ,region_name
            ,sub_region_name
            ,data_month
    FROM    prod_mdson.ads_mdspn_user_cur_month_summary_di
    WHERE   dayid <= '${v_cur_month}'
    AND     dayid > '${v_pre_3_month}'
)
,mdson_target AS
(-- 系统目标
    SELECT  user_id
            ,data_month
            ,CAST(MAX(
                CASE    WHEN indicator_id = 2 AND service_obj_type = 1 THEN actual_indicator_value ELSE 0 END
            ) AS BIGINT) AS visit_m_target -- 当月目标拜访店次
            ,CAST(MAX(
                CASE    WHEN indicator_id = 2 AND service_obj_type = 1 THEN actual_indicator_value_1 ELSE 0 END
            ) AS BIGINT) AS visit_m_target_1 -- 20260626：二期当月目标拜访店次
            ,discount_rate
    FROM    prod_mdson.ads_crm_user_visit_target_d_v2
    WHERE   dayid = '${v_cur_month}'
    AND     REGEXP_REPLACE(data_month,'-','') <= '${v_cur_month}'
    AND     REGEXP_REPLACE(data_month,'-','') > '${v_pre_3_month}'
    GROUP BY user_id
             ,data_month
             ,discount_rate
)
-- 20260623：增加人员白名单部分
,white_list_empno as
(-- 人员白名单家数部分
SELECT
    concat(substr(year_month,1,4),'-',substr(year_month,5,6)) as year_month,
    t1.empno,
    t2.user_id,
    change_indicator,
    change_target
FROM
    prod_mdson_dev.inf_mdson_white_list_empno t1
    LEFT JOIN
    (-- 关联人员ID
    SELECT
        user_id,
        (case when instr(empno,'-')>0 then split(empno,'-')[1] else empno end) as empno
    FROM
        prod_mdson.dim_user_d
    WHERE
        dayid = '${v_date}'
        and account_type = 1 -- 员工账号
        and is_deleted = 0 -- 未删除
        and dismiss_status = 0 -- 未离职
    )t2 ON t1.empno = t2.empno
WHERE
    change_indicator = '每月拜访不重复门店/客户/经销商'
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
,user_leave_month as
(-- 用户按月请假汇总
SELECT
    user_id,
    substr(mid_date,1,7) as year_month,
    count(distinct mid_date) as leave_days
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
-- 20260622：当月新入职员工不计入个人达成及团队达成
,user_discard_month as
(-- 用户入职时间(join_time字段不可用，用账户创建时间替代)
SELECT
    user_id,
    substr(nvl(join_time,create_time),1,7) as year_month,
    1 as is_discard_user
FROM
    prod_mdson.dim_user_d
WHERE
    dayid = '${v_date}'
-- 20260708：全月请假员工不纳入统计
UNION
SELECT
    t1.user_id,
    t1.year_month,
    1 as is_discard_user
FROM
    user_leave_month t1
    JOIN vacation_info t2 ON t1.year_month = t2.year_month and t1.leave_days >= t2.work_days
)
,user_discard_quar as
(-- 用户入职时间(join_time字段不可用，用账户创建时间替代)
SELECT
    user_id,
    substr(nvl(join_time,create_time),1,7) as year_month,
    1 as is_discard_user
FROM
    prod_mdson.dim_user_d
WHERE
    dayid = '${v_date}'
-- 20260708：全季请假员工不纳入统计
UNION
SELECT
    t1.user_id,
    t2.year_month,
    1 as is_discard_user
FROM
    user_leave_quar t1
    JOIN vacation_info_quar_process t2 ON t1.year_quarter = t2.year_quarter and t1.leave_days >= t2.work_days
)
,user_summary_data AS
(-- 拜访达成明细
    SELECT  data_month
            ,user_id
            --门店拜访频次达标率
            ,SUM(
                CASE    WHEN indicator_id = 'month_visit_valid_cnt' AND if_visit_qualified = '达标' THEN valid_visit_m ELSE 0 END
            ) AS month_visit_valid_cnt --当月有效拜访店次
            --NKA 专职NC门店拜访达成率
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ) AS month_nka_sever_obj_m --当月NKA 目标拜访覆盖店数
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_nka_nc_visit_valid_cnt --当月NKA 有效拜访专职NC门店数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ),4) AS month_nka_nc_visit_valid_rate --当月NKA 专职NC门店拜访达成率
            --RKA 专职NC门店拜访达成率
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ) AS month_rka_sever_obj_m --当月RKA目标拜访覆盖店数
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_rka_nc_visit_valid_cnt --当月RKA 有效拜访专职门店数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ),4) AS month_rka_nc_visit_valid_rate --当月RKA 专职NC门店拜访达成率
            --门店拜访覆盖率
            ,COUNT(DISTINCT CASE WHEN indicator_id = 'month_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END) AS month_sever_obj_m --当月名下拜访门店数
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_shop_visit_valid_cnt --当月有效拜访门店数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT CASE WHEN indicator_id = 'month_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END),4) AS month_shop_visit_valid_rate --当月门店拜访覆盖率
            --院线店拜访达成率
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_hospital_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ) AS month_hospital_sever_obj_m --当月名下名下院线店数
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_hospital_visit_valid_cnt --当月有效拜访院线店数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_hospital_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ),4) AS month_hospital_visit_valid_rate --当月院线店拜访达成率
            --当月服务商拜访达成率
            ,COUNT(DISTINCT CASE    WHEN indicator_id = 'month_fws_visit_valid_cnt' THEN service_obj_id ELSE NULL END) AS month_fws_sever_obj_m --当月名下服务商个数
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_fws_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_fws_visit_valid_cnt --当月服务商拜访个数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_fws_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT CASE    WHEN indicator_id = 'month_fws_visit_valid_cnt' THEN service_obj_id ELSE NULL END),4) AS month_fws_visit_valid_rate --当月服务商拜访达成率
            --季度服务商拜访达成率
            ,COUNT(DISTINCT CASE    WHEN indicator_id = 'quar_fws_visit_valid_cnt' THEN service_obj_id ELSE NULL END) AS quar_fws_sever_obj_m --季度名下服务商个数
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_fws_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS quar_fws_visit_valid_cnt --季度服务商拜访个数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_fws_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT CASE    WHEN indicator_id = 'quar_fws_visit_valid_cnt' THEN service_obj_id ELSE NULL END),4) AS quar_fws_visit_valid_rate --季度服务商拜访达成率
            --当月GT门店拜访覆盖率
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_gt_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ) AS month_gt_sever_obj_m --当月月度拜访门店数
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_gt_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_gt_shop_visit_valid_cnt --当月GT有效拜访门店数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_gt_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_gt_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ),4) AS month_gt_shop_visit_valid_rate --当月GT门店拜访覆盖率
            --当季GT门店拜访覆盖率
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_gt_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ) AS quar_gt_sever_obj_m --季度拜访门店数
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_gt_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS quar_gt_shop_visit_valid_cnt --季度GT门店有效拜访门店数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_gt_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_gt_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ),4) AS quar_gt_shop_visit_valid_rate --季度GT门店拜访覆盖率
            --院线店拜访达成率新
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END
            ) AS month_hospital_sever_obj_m_new --当月名下名下院线店数新
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_hospital_visit_valid_cnt_new --当月有效拜访院线店数新
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END
            ),4) AS month_hospital_visit_valid_rate_new --当月院线店拜访达成率新
            --当月GT院线门店拜访覆盖率
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_gt_hospital_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ) AS month_gt_hospital_sever_obj_m --月度拜访院线店店数目标
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_gt_hospital_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_gt_hospital_shop_visit_valid_cnt --当月GT有效拜访院线店门店数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_gt_hospital_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / 10,4) AS month_gt_hospital_shop_visit_valid_rate --当月GT院线店门店拜访覆盖率
            --当月GT院线门店拜访覆盖率
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_gt_hospital_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ) AS quar_gt_hospital_sever_obj_m --季度拜访院线门店数
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_gt_hospital_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS quar_gt_hospital_shop_visit_valid_cnt --季度GT门店有效拜访院线门店数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_gt_hospital_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_gt_hospital_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END
            ),4) AS quar_gt_hospital_shop_visit_valid_rate --季度GT院线门店拜访覆盖率
            -- 20260612：新增指标
                -- 当月专职NC门店拜访达成
            ,COUNT(DISTINCT CASE WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND visit_target > 0 THEN service_obj_id ELSE NULL END) AS month_nc_shop_server_obj_m -- 当月专职NC门店目标拜访覆盖店数
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND visit_target > 0 AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_nc_shop_visit_valid_cnt -- 当月专职NC门店有效拜访数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND visit_target > 0 AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT CASE    WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND visit_target > 0 THEN service_obj_id ELSE NULL END),4) AS month_nc_shop_visit_valid_rate -- 当月专职NC门店拜访达成率
                -- 当月星级门店拜访达成
            ,COUNT(DISTINCT CASE    WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND visit_target > 0 THEN service_obj_id ELSE NULL END) AS month_star_shop_server_obj_m -- 当月星级门店目标拜访覆盖店数
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND visit_target > 0 AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_star_shop_visit_valid_cnt -- 当月星级门店有效拜访数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND visit_target > 0 AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT CASE    WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND visit_target > 0 THEN service_obj_id ELSE NULL END),4) AS month_star_shop_visit_valid_rate -- 当月星级门店拜访达成率
                -- 当季全渠道重点门店拜访覆盖率
            ,COUNT(DISTINCT CASE    WHEN indicator_id = 'quar_key_shop_visit_valid_cnt' AND visit_target > 0 THEN service_obj_id ELSE NULL END)
            AS quar_key_shop_server_obj_m -- 当季全渠道重点门店目标拜访覆盖店数
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_key_shop_visit_valid_cnt' AND visit_target > 0 AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS quar_key_shop_visit_valid_cnt -- 当季全渠道重点门店有效拜访数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_key_shop_visit_valid_cnt' AND visit_target > 0 AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT CASE    WHEN indicator_id = 'quar_key_shop_visit_valid_cnt' AND visit_target > 0 THEN service_obj_id ELSE NULL END) ,4) AS quar_key_shop_visit_valid_rate -- 当季全渠道重点门店拜访达成率
            -- 20260616：新增指标
                -- 当月拜访频次达标率_改造
            ,SUM(
                CASE WHEN indicator_id = 'month_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN valid_visit_m
                ELSE 0
                END) AS month_visit_valid_cnt_1
                -- 当月服务商拜访达成
            ,COUNT(DISTINCT CASE    WHEN indicator_id = 'month_fws_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END) AS month_fws_sever_obj_m_1
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_fws_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_fws_visit_valid_cnt_1
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_fws_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT CASE    WHEN indicator_id = 'month_fws_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END),4) AS month_fws_visit_valid_rate_1
                -- 当季服务商拜访达成
            ,COUNT(DISTINCT CASE    WHEN indicator_id = 'quar_fws_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END) AS quar_fws_sever_obj_m_1
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_fws_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS quar_fws_visit_valid_cnt_1 --季度服务商拜访个数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'quar_fws_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT CASE    WHEN indicator_id = 'quar_fws_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END),4) AS quar_fws_visit_valid_rate_1
                -- 门店拜访达成
            ,COUNT(DISTINCT CASE    WHEN indicator_id = 'month_shop_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END) AS month_sever_obj_m_1
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_shop_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_shop_visit_valid_cnt_1 --当月有效拜访门店数
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_shop_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT CASE    WHEN indicator_id = 'month_shop_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END),4) AS month_shop_visit_valid_rate_1
                -- 院线店拜访达成
            ,COUNT(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND visit_target > 0 THEN service_obj_id ELSE NULL END)
            AS month_hospital_sever_obj_m_1
            ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND visit_target > 0 AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) AS month_hospital_visit_valid_cnt_1
            ,round(COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND visit_target > 0 AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END
            ) / COUNT(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND visit_target > 0 THEN service_obj_id ELSE NULL END),4) AS month_hospital_visit_valid_rate_1
                -- 全渠道拜访达成
            ,SUM(
                CASE WHEN indicator_id = 'month_all_visit_valid_cnt' AND if_visit_qualified = '达标' THEN valid_visit_m
                ELSE 0
                END) AS month_all_visit_valid_cnt
           ,COUNT(DISTINCT
                  CASE    WHEN indicator_id = 'month_all_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id
                  ELSE NULL END
            ) AS month_all_visit_valid_obj_m
    FROM
        prod_mdson.ads_mdson_user_cur_month_detail_d_v2
    WHERE
        dayid = '${v_date}'
    GROUP BY
        data_month
        ,user_id
)
,quar_rate AS
(
    SELECT  year_month_id
            -- 20260717：按产品需求时间进度保留两位小数，如48.38%改为48%
            ,round(MAX(diff) / MAX(diff1),2) AS quar_rate
            ,round(MAX(diff2) / MAX(diff3),2) AS month_rate
    FROM    (
                SELECT  year_month_id
                        ,date_id
                        ,CAST(yt_date_diff(date_id,quarter_first_date) AS INT) + 1 AS diff
                        ,yt_date_diff(quarter_last_date,quarter_first_date) + 1 AS diff1
                        ,CAST(yt_date_diff(date_id,month_first_date) AS INT) + 1 AS diff2
                        ,yt_date_diff(month_last_date,month_first_date) + 1 AS diff3
                FROM    prod_mdson.dim_pub_date_d
                WHERE   date_id <= '${v_date}'
                AND     year_month_id >= '202501'
                ORDER BY date_id
            ) t
    GROUP BY year_month_id
    ORDER BY year_month_id
)
-- 20260617: 判定人员为仅GT渠道覆盖还是多渠道覆盖
,mdson_user AS
(-- 员工信息
    SELECT  user_id
            ,user_real_name
            ,job_id
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
    SELECT  service_obj_id
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
            ,is_nc
            ,isaroundhospital_pgroup
            ,status
            ,store_class_name
            ,is_star_shop
            ,shop_star
    FROM    prod_mdson.dim_service_obj_d
    WHERE   dayid = '${v_date}'
    AND     status != 0 -- 若不为正常营业则需剔除
    AND     is_deleted = 0
)
,mdson_service_obj_sever AS
(-- 服务对象及人员信息
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
)
,mdson_service_obj_user as
(-- 门店渠道及人员整合
    SELECT
        distinct service_obj_id,
        (case when channel_type = 'GT' then 0 else 1 end) as channel_type_1,
        t3.user_id
    FROM
        mdson_service_obj t1
        LEFT JOIN mdson_service_obj_sever t2
        ON  t1.service_obj_id = t2.store_code
        LEFT JOIN mdson_user t3
        ON  t2.server_code = t3.empno
    WHERE
        user_id is not null
        and service_obj_type_name = '门店'
)
,channel_type_cnt_user as
(-- 人员是仅GT渠道还是多渠道判定(仅保留多渠道)
SELECT
    user_id,
    sum(channel_type_1) as channel_type_cnt,
    1 as is_many_channel_type
FROM
    mdson_service_obj_user
GROUP BY
    user_id
HAVING
    channel_type_cnt > 0
)



-- 主查询
INSERT OVERWRITE TABLE ads_mdson_user_new_visit_summary_data_d_v2 PARTITION (dayid = '${v_date}')
SELECT  user_info.data_month
        ,user_info.user_id
        ,user_real_name
        ,job_name
        ,channel_name
        ,region_name
        ,sub_region_name
        ,dept_id
        ,department_name
        ,department_charger_id
        ,department_charger_name
        ,visit_m_target
        ,CAST(NVL(month_visit_valid_cnt,0) AS BIGINT) AS month_visit_valid_cnt
        ,ROUND(CAST(NVL(month_visit_valid_cnt,0) AS BIGINT) / CAST(nvl(visit_m_target,0) AS BIGINT),4) AS month_visit_valid_rate
        ,CAST(NVL(month_nka_sever_obj_m,0) AS BIGINT) AS month_nka_sever_obj_m
        ,CAST(NVL(month_nka_nc_visit_valid_cnt,0) AS BIGINT) AS month_nka_nc_visit_valid_cnt
        ,month_nka_nc_visit_valid_rate
        ,CAST(NVL(month_rka_sever_obj_m,0) AS BIGINT) AS month_rka_sever_obj_m
        ,CAST(NVL(month_rka_nc_visit_valid_cnt,0) AS BIGINT) AS month_rka_nc_visit_valid_cnt
        ,month_rka_nc_visit_valid_rate
        ,CAST(NVL(month_sever_obj_m,0) AS BIGINT) AS month_sever_obj_m
        ,CAST(NVL(month_shop_visit_valid_cnt,0) AS BIGINT) AS month_shop_visit_valid_cnt
        ,month_shop_visit_valid_rate
        ,CAST(NVL(month_hospital_sever_obj_m,0) AS BIGINT) AS month_hospital_sever_obj_m
        ,CAST(NVL(month_hospital_visit_valid_cnt,0) AS BIGINT) AS month_hospital_visit_valid_cnt
        ,month_hospital_visit_valid_rate
        ,CASE   WHEN job_name IN ('大区通路发展经理') and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10' THEN 4   ----202510拜访次数 = 原次数 * (31-8)/31
				WHEN job_name IN ('大区通路发展经理') THEN 5
				WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10' THEN CAST(round(IF(month_fws_sever_obj_m <= 5,month_fws_sever_obj_m,5) * (31-8)/31,0) as BIGINT )----202510拜访次数 = 原次数 * (31-8)/31
                WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') THEN IF(month_fws_sever_obj_m <= 5,month_fws_sever_obj_m,5)
                ELSE CAST(NVL(month_fws_sever_obj_m,0) AS BIGINT)
        END AS month_fws_sever_obj_m
        ,CAST(NVL(month_fws_visit_valid_cnt,0) AS BIGINT) AS month_fws_visit_valid_cnt
        ,CASE   WHEN job_name IN ('大区通路发展经理') and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10'  THEN round(NVL(month_fws_visit_valid_cnt,0) / 4,4) ----202510拜访次数 = 原次数 * (31-8)/31
				WHEN job_name IN ('大区通路发展经理') THEN round(NVL(month_fws_visit_valid_cnt,0) / 5,4)
				WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10' THEN round(month_fws_visit_valid_cnt / round(IF(month_fws_sever_obj_m <= 5,month_fws_sever_obj_m,5) * (31-8)/31,0),4)----202510调整lsp目标拜访
                WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') THEN round(month_fws_visit_valid_cnt / IF(month_fws_sever_obj_m <= 5,month_fws_sever_obj_m,5),4)
                ELSE round(NVL(month_fws_visit_valid_cnt,0) / NVL(month_fws_sever_obj_m,0),4)
        END AS month_fws_visit_valid_rate
        ,CASE   WHEN job_name IN ('大区通路发展经理') and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd')  THEN 14  ----2025Q4总次数调整
				WHEN job_name IN ('大区通路发展经理') THEN 15
                ELSE CAST(NVL(quar_fws_sever_obj_m,0) AS BIGINT)
        END AS quar_fws_sever_obj_m
        ,CAST(NVL(quar_fws_visit_valid_cnt,0) AS BIGINT) AS quar_fws_visit_valid_cnt
        -- 20251016修改：原脚本在计算季度服务商拜访达成率时，对于大区通路发展经理，其分子为名下服务商数，而非拜访服务商数
        ,CASE   WHEN job_name IN ('大区通路发展经理') and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd') THEN ROUND(NVL(quar_fws_visit_valid_cnt,0) / 14,4) ----2025Q4特殊处理Q4的季度服务商拜访达成率
				WHEN job_name IN ('大区通路发展经理') THEN ROUND(NVL(quar_fws_visit_valid_cnt,0) / 15,4)
                ELSE quar_fws_visit_valid_rate
        END AS quar_fws_visit_valid_rate
        ,CASE   WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10' THEN 22 ---202510Fydia要求目标拜访数按照（31-8）/31 *30
				WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') THEN 30
				WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10' THEN 2    ----2o2510按业务要求变更次数为2
                WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') THEN 3
                ELSE 0
        END AS month_gt_sever_obj_m
        ,CAST(NVL(month_gt_shop_visit_valid_cnt,0) AS BIGINT) AS month_gt_shop_visit_valid_cnt
        ,CASE   WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10' THEN round(NVL(month_gt_shop_visit_valid_cnt,0) / 22,4) ---202510Fydia要求拜访数
				WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') THEN round(NVL(month_gt_shop_visit_valid_cnt,0) / 30,4)
				WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10' THEN round(NVL(month_gt_shop_visit_valid_cnt,0) / 2,4) ----2o2510按业务要求修改拜访达成率
                WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') THEN round(NVL(month_gt_shop_visit_valid_cnt,0) / 3,4)
                ELSE 0
        END AS month_gt_shop_visit_valid_rate
        ,CASE   WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd') THEN 52 ----2025Q4拜访目标门店数特殊处理
				WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') THEN 60
				WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd')  THEN 11
                WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') THEN 12
                ELSE 0
        END AS quar_gt_sever_obj_m
        ,CAST(NVL(quar_gt_shop_visit_valid_cnt,0) AS BIGINT) AS quar_gt_shop_visit_valid_cnt
        ,CASE   WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd') THEN round(NVL(quar_gt_shop_visit_valid_cnt,0) / 52,4) ----2025Q4拜访达成率特殊处理
				WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') THEN round(NVL(quar_gt_shop_visit_valid_cnt,0) / 60,4)
				WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd') THEN round(NVL(quar_gt_shop_visit_valid_cnt,0) / 11,4)
                WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') THEN round(NVL(quar_gt_shop_visit_valid_cnt,0) / 12,4)
                ELSE 0
        END AS quar_gt_shop_visit_valid_rate
        --,CASE   WHEN channel_name IN ('NKA','RKA')
        ,CASE   WHEN channel_name IN ('NKA','RKA','COT','KA') -- 20260311接通知NKA更名为COT，删除LKA、RKA(保留)=>新增KA
                    AND job_name IN ('城市渠道负责人')
                    AND ROUND(CAST(NVL(month_visit_valid_cnt,0) AS BIGINT) / CAST(nvl(visit_m_target,0) AS BIGINT),4) >= month_rate
                    AND (
                            month_nka_nc_visit_valid_rate >= month_rate
                                OR NVL(month_nka_sever_obj_m,0) = 0
                )
                    AND (
                            month_rka_nc_visit_valid_rate >= month_rate
                                OR NVL(month_rka_sever_obj_m,0) = 0
                )
                    AND (
                            month_hospital_visit_valid_rate_new >= month_rate
                                OR NVL(month_hospital_sever_obj_m_new,0) = 0
                ) THEN '达标'
                WHEN channel_name IN ('NKA','RKA','COT','KA') AND job_name IN ('城市渠道负责人') THEN '未达标'
                WHEN channel_name IN ('NKA','RKA','COT','KA')
                    AND job_name IN ('地区渠道负责人','省区渠道负责人')
                    AND ROUND(CAST(NVL(month_visit_valid_cnt,0) AS BIGINT) / CAST(nvl(visit_m_target,0) AS BIGINT),4) >= month_rate
                    AND (
                            month_nka_nc_visit_valid_rate >= month_rate
                                OR NVL(month_nka_sever_obj_m,0) = 0
                )
                    AND (
                            month_rka_nc_visit_valid_rate >= month_rate
                                OR NVL(month_rka_sever_obj_m,0) = 0
                ) THEN '达标'
                WHEN channel_name IN ('NKA','RKA','COT','KA') AND job_name IN ('地区渠道负责人','省区渠道负责人') THEN '未达标'

				WHEN channel_name IN ('GT')	-----202510月新增逻辑
                    AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人')
					and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10'
                    AND (
                            round(month_gt_shop_visit_valid_cnt / 22,4) >= month_rate
                                --OR NVL(month_gt_sever_obj_m,0) = 0  -- 0919修改：无拜访记录默认不达标
                )
                    AND (
                            round(month_fws_visit_valid_cnt / round(IF(month_fws_sever_obj_m <= 5,month_fws_sever_obj_m,5) *(31-8)/31,0),4) >= month_rate
                                OR NVL(month_fws_sever_obj_m,0) = 0
                )
                    AND (
                            round(NVL(month_gt_hospital_shop_visit_valid_cnt,0) / round(IF(month_gt_hospital_sever_obj_m <= 10,month_gt_hospital_sever_obj_m,10) *(31-8)/31,0) ,4) >= month_rate ----202510 GT渠道的省地城院线店拜访目标变更
                                OR NVL(month_gt_hospital_sever_obj_m,0) = 0
                ) THEN '达标'

                WHEN channel_name IN ('GT')
                    AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人')
                    AND (
                            round(month_gt_shop_visit_valid_cnt / 30,4) >= month_rate
                                -- OR NVL(month_gt_sever_obj_m,0) = 0 -- 0919修改：无拜访记录默认不达标
                )
                    AND (
                            round(month_fws_visit_valid_cnt / IF(month_fws_sever_obj_m <= 5,month_fws_sever_obj_m,5),4) >= month_rate
                                OR NVL(month_fws_sever_obj_m,0) = 0
                )
                    AND (
                            round(NVL(month_gt_hospital_shop_visit_valid_cnt,0) / IF(month_gt_hospital_sever_obj_m <= 10,month_gt_hospital_sever_obj_m,10),4) >= month_rate
                                OR NVL(month_gt_hospital_sever_obj_m,0) = 0
                ) THEN '达标'
                WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') THEN '未达标' ------20250917调整GT区域渠道负责人 是否达标只与拜访GT门店有关

----202510节假日目标有调整
				WHEN channel_name IN ('GT')
                    AND job_name IN ('区域渠道负责人')
					and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10'
                    AND (
                            round(month_gt_shop_visit_valid_cnt / 2,4) >= month_rate
                                OR NVL(month_gt_sever_obj_m,0) = 0
                )  THEN '达标'
				WHEN channel_name IN ('GT')
                    AND job_name IN ('区域渠道负责人')
                    AND (
                            round(month_gt_shop_visit_valid_cnt / 3,4) >= month_rate
                                OR NVL(month_gt_sever_obj_m,0) = 0
                ) THEN '达标'
                WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') THEN '未达标'
                WHEN job_name IN ('大区销售总经理') AND ROUND(CAST(NVL(month_visit_valid_cnt,0) AS BIGINT) / CAST(nvl(visit_m_target,0) AS BIGINT),4) >= month_rate THEN '达标'
                WHEN job_name IN ('大区销售总经理') THEN '未达标'
                WHEN channel_name NOT IN ('GT')
                    AND job_name IN ('区域渠道负责人')
                    AND ROUND(CAST(NVL(month_visit_valid_cnt,0) AS BIGINT) / CAST(nvl(visit_m_target,0) AS BIGINT),4) >= month_rate THEN '达标'
                WHEN job_name IN ('大区销售总经理') THEN '未达标'
				---202510大区通路发展服务商拜访降至4家
				 WHEN job_name IN ('大区通路发展经理')
				 and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10'
                    AND ROUND(CAST(NVL(month_visit_valid_cnt,0) AS BIGINT) / CAST(nvl(visit_m_target,0) AS BIGINT),4) >= month_rate
                    AND (
                            round(month_fws_visit_valid_cnt / 4,4) >= month_rate
                                OR NVL(month_fws_sever_obj_m,0) = 0
                ) THEN '达标'

                WHEN job_name IN ('大区通路发展经理')
                    AND ROUND(CAST(NVL(month_visit_valid_cnt,0) AS BIGINT) / CAST(nvl(visit_m_target,0) AS BIGINT),4) >= month_rate
                    AND (
                            round(month_fws_visit_valid_cnt / 5,4) >= month_rate
                                OR NVL(month_fws_sever_obj_m,0) = 0
                ) THEN '达标'
                WHEN job_name IN ('大区通路发展经理') THEN '未达标'
                WHEN ROUND(CAST(NVL(month_visit_valid_cnt,0) AS BIGINT) / CAST(nvl(visit_m_target,0) AS BIGINT),4) >= month_rate THEN '达标'
                ELSE '未达标'
        END AS if_visit_qualified_month
----202510Q4季度达成率有变动
         ,CASE  WHEN channel_name IN ('GT')
                    AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人')
					and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd')
                    AND (round(quar_gt_shop_visit_valid_cnt / 52,4) >= quar_rate
                    --OR NVL(quar_gt_sever_obj_m,0) = 0
					)-- 0919修改：无拜访记录默认不达标
                    AND (
                            quar_fws_visit_valid_rate >= quar_rate
                                OR NVL(quar_fws_sever_obj_m,0) = 0
                )
                    AND (
                            quar_gt_hospital_shop_visit_valid_rate >= quar_rate
                                OR NVL(quar_gt_hospital_sever_obj_m,0) = 0
                ) THEN '达标'
			    WHEN channel_name IN ('GT')
                    AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人')
                    AND (round(quar_gt_shop_visit_valid_cnt / 60,4) >= quar_rate
                    -- OR NVL(quar_gt_sever_obj_m,0) = 0 -- 0919修改：无拜访记录默认不达标
                    )
                    AND (
                            quar_fws_visit_valid_rate >= quar_rate
                                OR NVL(quar_fws_sever_obj_m,0) = 0
                )
                    AND (
                            quar_gt_hospital_shop_visit_valid_rate >= quar_rate
                                OR NVL(quar_gt_hospital_sever_obj_m,0) = 0
                ) THEN '达标'

				----202510Q4季度达成率有变动
				WHEN job_name IN ('大区通路发展经理') and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd') AND round(quar_fws_visit_valid_cnt / 14,4) >= quar_rate THEN '达标'
                WHEN job_name IN ('大区通路发展经理') AND round(quar_fws_visit_valid_cnt / 15,4) >= quar_rate THEN '达标' -----20250903新增GT渠道区域负责人季度达标

				----202510Q4季度GT渠道总拜访门店数有变动
				 WHEN channel_name IN ('GT')
                    AND job_name IN ('区域渠道负责人')
					and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd')
                    AND (
                            round(quar_gt_shop_visit_valid_cnt / 11,4) >= quar_rate
                                OR NVL(quar_gt_sever_obj_m,0) = 0
                ) -----季度门店
                THEN '达标'

				WHEN channel_name IN ('GT')
                    AND job_name IN ('区域渠道负责人')
                    AND (
                            round(quar_gt_shop_visit_valid_cnt / 12,4) >= quar_rate
                                OR NVL(quar_gt_sever_obj_m,0) = 0
                ) -----季度门店
                THEN '达标'
                ELSE '未达标'
        END AS if_visit_qualified_quar
        ,CASE   WHEN ROUND(CAST(NVL(month_visit_valid_cnt,0) AS BIGINT) / CAST(nvl(visit_m_target,0) AS BIGINT),4) >= month_rate THEN '达标'
                ELSE '未达标'
        END AS month_visit_valid_rate_qualified
        ,CASE   WHEN (month_nka_nc_visit_valid_rate >= month_rate OR NVL(month_nka_sever_obj_m,0) = 0) THEN '达标'
                ELSE '未达标'
        END AS month_nka_nc_visit_valid_rate_qualified
        ,CASE   WHEN (month_rka_nc_visit_valid_rate >= month_rate OR NVL(month_rka_sever_obj_m,0) = 0) THEN '达标'
                ELSE '未达标'
        END AS month_rka_nc_visit_valid_rate_qualified
        ,CASE   WHEN (month_hospital_visit_valid_rate >= month_rate OR NVL(month_hospital_sever_obj_m,0) = 0) THEN '达标'
                ELSE '未达标'
        END AS month_hospital_visit_valid_rate_qualified
        ,CASE   WHEN (month_shop_visit_valid_rate >= month_rate OR NVL(month_sever_obj_m,0) = 0) THEN '达标'
                ELSE '未达标'
        END AS month_shop_visit_valid_rate_qualified
        ,CASE
		----202510服务商达标特殊处理
				WHEN job_name IN ('大区通路发展经理') and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10' AND round(NVL(month_fws_visit_valid_cnt,0) / 4,4) >= month_rate THEN '达标'
				WHEN job_name IN ('大区通路发展经理') AND round(NVL(month_fws_visit_valid_cnt,0) / 5,4) >= month_rate THEN '达标'
                WHEN job_name IN ('大区通路发展经理') THEN '未达标'

				----202510服务商达标特殊处理
				WHEN channel_name IN ('GT')
                    AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人')
					and substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10'
                    AND (
                            round(month_fws_visit_valid_cnt / round(IF(month_fws_sever_obj_m <= 5,month_fws_sever_obj_m,5) * (31-8)/31,0),4) >= month_rate
                                OR NVL(month_fws_sever_obj_m,0) = 0
                ) THEN '达标'

                WHEN channel_name IN ('GT')
                    AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人')
                    AND (
                            round(month_fws_visit_valid_cnt / IF(month_fws_sever_obj_m <= 5,month_fws_sever_obj_m,5),4) >= month_rate
                                OR NVL(month_fws_sever_obj_m,0) = 0
                ) THEN '达标'
                WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人') THEN '未达标'
                WHEN (
                            round(month_fws_visit_valid_cnt / month_fws_sever_obj_m,4) >= month_rate OR NVL(month_fws_sever_obj_m,0) = 0
                ) THEN '达标'
                ELSE '未达标'
        END AS month_fws_visit_valid_rate_qualified
        ,CASE   WHEN channel_name IN ('GT')
                    AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人')
                    AND (quar_fws_visit_valid_rate >= quar_rate
                    OR NVL(quar_fws_sever_obj_m,0) = 0) THEN '达标'

					----2025Q4季度服务商达成率调整
					WHEN channel_name IN ('GT')
                    AND job_name IN ('区域渠道负责人')
					and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd')
                    AND (
                            round(quar_fws_visit_valid_cnt / 11,4) >= quar_rate
                                OR NVL(quar_fws_sever_obj_m,0) = 0
                ) THEN '达标'

                WHEN channel_name IN ('GT')
                    AND job_name IN ('区域渠道负责人')
                    AND (
                            round(quar_fws_visit_valid_cnt / 12,4) >= quar_rate
                                OR NVL(quar_fws_sever_obj_m,0) = 0
                ) THEN '达标'
                -- 2025Q4季度服务商达成率调整
				WHEN job_name IN ('大区通路发展经理') and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd') AND round(quar_fws_visit_valid_cnt / 14,4) >= quar_rate THEN '达标'
                WHEN job_name IN ('大区通路发展经理') AND round(quar_fws_visit_valid_cnt / 15,4) >= quar_rate THEN '达标'
                ELSE '未达标'
        END AS quar_fws_visit_valid_rate_qualified
                -- 202510GT渠道门目标门店数调整
        ,CASE   WHEN channel_name IN ('GT')
					AND substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10'
                    AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人')
                    AND (round(month_gt_shop_visit_valid_cnt / 22,4) >= month_rate) THEN '达标'
				WHEN channel_name IN ('GT')
                    AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人')
                    AND (round(month_gt_shop_visit_valid_cnt / 30,4) >= month_rate) THEN '达标'
                -- 202510GT渠道门目标门店数调整
				WHEN channel_name IN ('GT')
                    AND job_name IN ('区域渠道负责人')
					AND substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10'
                    AND (
                            round(month_gt_shop_visit_valid_cnt / 2,4) >= month_rate
                                OR NVL(month_gt_sever_obj_m,0) = 0
                ) THEN '达标'
                WHEN channel_name IN ('GT')
                    AND job_name IN ('区域渠道负责人')
                    AND (
                            round(month_gt_shop_visit_valid_cnt / 3,4) >= month_rate
                                OR NVL(month_gt_sever_obj_m,0) = 0
                ) THEN '达标'
                ELSE '未达标'
        END AS month_gt_shop_visit_valid_rate_qualified
        ,CASE   WHEN channel_name IN ('GT')
					and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd')
                    AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人')
                    AND (round(quar_gt_shop_visit_valid_cnt / 52,4) >= quar_rate) THEN '达标'-----2025Q4GT渠道门目标门店数调整
				WHEN channel_name IN ('GT')
                    AND job_name IN ('地区渠道负责人','省区渠道负责人','城市渠道负责人')
                    AND (round(quar_gt_shop_visit_valid_cnt / 60,4) >= quar_rate) THEN '达标'
                -- 2025Q4GT渠道门目标门店数调整
				WHEN channel_name IN ('GT')
                    AND job_name IN ('区域渠道负责人')
					and DATEADD(GETDATE(),-1,'dd') >=  TO_DATE('2025-10-01','yyyy-MM-dd')  AND DATEADD(GETDATE(),-1,'dd') <= TO_DATE('2025-12-31','yyyy-MM-dd')
                    AND (
                            round(month_gt_shop_visit_valid_cnt / 11,4) >= month_rate
                ) THEN '达标'
                WHEN channel_name IN ('GT')
                    AND job_name IN ('区域渠道负责人')
                    AND (
                            round(month_gt_shop_visit_valid_cnt / 12,4) >= month_rate
                ) THEN '达标'
                ELSE '未达标'
        END AS quar_gt_shop_visit_valid_rate_qualified
        ,CAST(NVL(month_hospital_sever_obj_m_new,0) AS BIGINT) AS month_hospital_sever_obj_m_new
        ,CAST(NVL(month_hospital_visit_valid_cnt_new,0) AS BIGINT) AS month_hospital_visit_valid_cnt_new
        ,month_hospital_visit_valid_rate_new
        ,CASE   WHEN (month_hospital_visit_valid_rate_new >= month_rate OR NVL(month_hospital_sever_obj_m_new,0) = 0) THEN '达标'
                ELSE '未达标'
        END AS month_hospital_visit_valid_rate_new_qualified
        ,case
				when  substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10' then CAST(NVL(round(IF(month_gt_hospital_sever_obj_m <= 10,month_gt_hospital_sever_obj_m,10) *(31-8)/31,0),0) AS BIGINT)
			    ELSE  CAST(NVL(IF(month_gt_hospital_sever_obj_m <= 10,month_gt_hospital_sever_obj_m,10),0) AS BIGINT) END AS month_gt_hospital_sever_obj_m
        ,CAST(NVL(month_gt_hospital_shop_visit_valid_cnt,0) AS BIGINT) AS month_gt_hospital_shop_visit_valid_cnt
        ,case
				when substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10' then  round(NVL(month_gt_hospital_shop_visit_valid_cnt,0) / round(IF(month_gt_hospital_sever_obj_m <= 10,month_gt_hospital_sever_obj_m,10) *(31-8)/31 ,0),4)
				else round(NVL(month_gt_hospital_shop_visit_valid_cnt,0) / IF(month_gt_hospital_sever_obj_m <= 10,month_gt_hospital_sever_obj_m,10),4) end AS month_gt_hospital_shop_visit_valid_rate
        ,CASE   WHEN substr(DATEADD(GETDATE(),-1,'dd'),1,7) = '2025-10' and (round(NVL(month_gt_hospital_shop_visit_valid_cnt,0) / round(IF(month_gt_hospital_sever_obj_m <= 10,month_gt_hospital_sever_obj_m,10) *(31-8)/31,0),4) >= month_rate OR NVL(month_gt_hospital_sever_obj_m,0) = 0) THEN '达标'
				WHEN (round(NVL(month_gt_hospital_shop_visit_valid_cnt,0) / IF(month_gt_hospital_sever_obj_m <= 10,month_gt_hospital_sever_obj_m,10),4) >= month_rate OR NVL(month_gt_hospital_sever_obj_m,0) = 0) THEN '达标'
                ELSE '未达标'
        END AS month_gt_hospital_shop_visit_valid_rate_qualified
        ,CAST(NVL(quar_gt_hospital_sever_obj_m,0) AS BIGINT) AS quar_gt_hospital_sever_obj_m
        ,CAST(NVL(quar_gt_hospital_shop_visit_valid_cnt,0) AS BIGINT) AS quar_gt_hospital_shop_visit_valid_cnt
        ,quar_gt_hospital_shop_visit_valid_rate
        ,CASE   WHEN (quar_gt_hospital_shop_visit_valid_rate >= quar_rate OR NVL(quar_gt_hospital_sever_obj_m,0) = 0) THEN '达标'
                ELSE '未达标'
        END AS quar_gt_hospital_shop_visit_valid_rate_qualified
        ,NULL AS quar_sever_obj_m
        ,NULL AS quar_shop_visit_valid_cnt
        ,NULL AS quar_shop_visit_valid_rate
        -- 20260612：当月专职NC门店拜访达成率
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,CAST(COALESCE(month_nc_shop_server_obj_m,0) as bigint)) as month_nc_shop_server_obj_m
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,CAST(COALESCE(month_nc_shop_visit_valid_cnt,0) as bigint)) as month_nc_shop_visit_valid_cnt
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,month_nc_shop_visit_valid_rate) as month_nc_shop_visit_valid_rate
        ,CASE
            WHEN COALESCE(user_discard_month.is_discard_user,0) = 1 then NULL
            WHEN (month_nc_shop_visit_valid_rate >= month_rate OR NVL(month_nc_shop_server_obj_m,0) = 0) THEN '达标'
            ELSE '未达标'
        END AS month_nc_shop_visit_valid_rate_qualified
        -- 20260612：当月星级门店拜访达成率
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,CAST(COALESCE(month_star_shop_server_obj_m,0) as bigint)) as month_star_shop_server_obj_m
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,CAST(COALESCE(month_star_shop_visit_valid_cnt,0) as bigint)) as month_star_shop_visit_valid_cnt
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,month_star_shop_visit_valid_rate) as month_star_shop_visit_valid_rate
        ,CASE
            WHEN COALESCE(user_discard_month.is_discard_user,0) = 1 then NULL
            WHEN (month_star_shop_visit_valid_rate >= month_rate OR NVL(month_star_shop_server_obj_m,0) = 0) THEN '达标'
            ELSE '未达标'
        END AS month_star_shop_visit_valid_rate_qualified
        -- 20260612：当季全渠道重点门店拜访覆盖率
        ,if(COALESCE(user_discard_quar.is_discard_user,0) = 1,null,CAST(COALESCE(quar_key_shop_server_obj_m,0) as bigint)) as quar_key_shop_server_obj_m
        ,if(COALESCE(user_discard_quar.is_discard_user,0) = 1,null,CAST(COALESCE(quar_key_shop_visit_valid_cnt,0) as bigint)) as quar_key_shop_visit_valid_cnt
        ,if(COALESCE(user_discard_quar.is_discard_user,0) = 1,null,quar_key_shop_visit_valid_rate) as quar_key_shop_visit_valid_rate
        ,CASE
            WHEN COALESCE(user_discard_quar.is_discard_user,0) = 1 then NULL
            WHEN (quar_key_shop_visit_valid_rate >= quar_rate OR NVL(quar_key_shop_server_obj_m,0) = 0) THEN '达标'
            ELSE '未达标'
        END AS quar_key_shop_visit_valid_rate_qualified
        -- 20260616：当月我的拜访达标
        -- 20260713：按指标可见性矩阵调整拜访标准
        ,CASE       WHEN COALESCE(user_discard_month.is_discard_user,0) = 1 then NULL
                    WHEN (job_name IN ('城市渠道负责人') AND user_real_name <> '胡志伟') -- 20260707：胡志伟按城市群负责人标准考核
                    AND (-- 当月拜访频次达成
                    ROUND(CAST(NVL(month_visit_valid_cnt_1,0) AS BIGINT) / CAST(nvl(visit_m_target_1,0) AS BIGINT),4) >= month_rate
                    )
                    AND (-- 当月专职NC门店拜访达成
                        month_nc_shop_visit_valid_rate >= month_rate OR NVL(month_nc_shop_server_obj_m,0) = 0
                    )
                    AND (-- 当月院线店拜访达成
                        month_hospital_visit_valid_rate_1 >= month_rate OR NVL(month_hospital_sever_obj_m_1,0) = 0
                    )
                    AND (-- 当月服务商拜访达成
                        (coalesce(is_many_channel_type,0) = 1
                        AND (round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT)/IF(NVL(month_fws_sever_obj_m_1,0) <= 3,NVL(month_fws_sever_obj_m_1,0),3),4) >= month_rate
                        or NVL(month_fws_sever_obj_m_1,0) = 0))
                        OR
                        (coalesce(is_many_channel_type,0) = 0
                        AND (round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT)/IF(NVL(month_fws_sever_obj_m_1,0) <= 5,NVL(month_fws_sever_obj_m_1,0),5),4) >= month_rate
                        or NVL(month_fws_sever_obj_m_1,0) = 0))
                    )
                    AND (-- 当月星级门店拜访达成
                        month_star_shop_visit_valid_rate >= month_rate OR NVL(month_star_shop_server_obj_m,0) = 0
                    )
                THEN '达标'
                WHEN (job_name IN ('城市群负责人') or user_real_name = '胡志伟') -- 20260707：胡志伟按城市群负责人标准考核
                    AND (-- 当月专职NC门店拜访达成
                        month_nc_shop_visit_valid_rate >= month_rate OR NVL(month_nc_shop_server_obj_m,0) = 0
                    )
                    AND (-- 当月院线店拜访达成
                        month_hospital_visit_valid_rate_1 >= month_rate OR NVL(month_hospital_sever_obj_m_1,0) = 0
                    )
                    AND (-- 当月拜访家数达成(城市群负责人每月40家，其他名下)
                        month_shop_visit_valid_cnt_1/(coalesce(white_list_empno.change_target,40)*coalesce(mdson_target.discount_rate,1)) >= month_rate
                    )
                    AND (-- 当月服务商拜访达成
                        (coalesce(is_many_channel_type,0) = 1
                        AND (round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT)/IF(NVL(month_fws_sever_obj_m_1,0) <= 3,NVL(month_fws_sever_obj_m_1,0),3),4) >= month_rate
                        or NVL(month_fws_sever_obj_m_1,0) = 0))
                        OR
                        (coalesce(is_many_channel_type,0) = 0
                        AND (round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT)/IF(NVL(month_fws_sever_obj_m_1,0) <= 5,NVL(month_fws_sever_obj_m_1,0),5),4) >= month_rate
                        or NVL(month_fws_sever_obj_m_1,0) = 0))
                    )
                    AND (-- 当月星级门店拜访达成
                        month_star_shop_visit_valid_rate >= month_rate OR NVL(month_star_shop_server_obj_m,0) = 0
                    )
                THEN '达标'
                WHEN job_name IN ('城市渠道负责人','城市群负责人') THEN '未达标'
                WHEN job_name IN ('大区通路发展经理')
                    AND ROUND(CAST(NVL(month_visit_valid_cnt_1,0) AS BIGINT) / CAST(nvl(visit_m_target_1,0) AS BIGINT),4) >= month_rate
                    AND (
                            round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT) / 5,4) >= month_rate
                ) THEN '达标'
                WHEN job_name IN ('大区通路发展经理') THEN '未达标'
                WHEN ROUND(CAST(NVL(month_visit_valid_cnt_1,0) AS BIGINT) / CAST(nvl(visit_m_target_1,0) AS BIGINT),4) >= month_rate
                THEN '达标'
                ELSE '未达标' -- 20260710：从置空改为未达标
        END AS if_visit_qualified_month_1
        -- 20260616：当季我的拜访达标
        ,CASE
                WHEN COALESCE(user_discard_quar.is_discard_user,0) = 1 then NULL
                WHEN job_name IN ('城市渠道负责人','城市群负责人')
                    AND (-- 当季服务商拜访达成
                        round(quar_fws_visit_valid_cnt_1/quar_fws_sever_obj_m_1,4) >= quar_rate
                            or NVL(quar_fws_sever_obj_m_1,0) = 0
                    )
                    AND (-- 当季全渠道重点门店拜访覆盖
                        quar_key_shop_visit_valid_rate >= quar_rate OR NVL(quar_key_shop_server_obj_m,0) = 0
                    )
                THEN '达标'
                WHEN job_name IN ('城市渠道负责人','城市群负责人')
                THEN '未达标'
                WHEN job_name IN ('大区通路发展经理')
                    AND round(quar_fws_visit_valid_cnt_1 / 15,4) >= quar_rate THEN '达标' -----20250903新增GT渠道区域负责人季度达标
                WHEN job_name IN ('大区通路发展经理') THEN '未达标'
                ELSE '未达标' -- 20260710：从置空改为未达标
        END AS if_visit_qualified_quar_1
        -- 20260616：当月拜访频次达标
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,visit_m_target_1) as visit_m_target_1
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,CAST(NVL(month_visit_valid_cnt_1,0) AS BIGINT)) AS month_visit_valid_cnt_1
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,ROUND(CAST(NVL(month_visit_valid_cnt_1,0) AS BIGINT) / CAST(nvl(visit_m_target_1,0) AS BIGINT),4))
         AS month_visit_valid_rate_1
        ,CASE
            WHEN COALESCE(user_discard_month.is_discard_user,0) = 1 then NULL
            WHEN ROUND(CAST(NVL(month_visit_valid_cnt_1,0) AS BIGINT) / CAST(nvl(visit_m_target_1,0) AS BIGINT),4) >= month_rate THEN '达标'
            ELSE '未达标'
        END AS month_visit_valid_rate_qualified_1
        -- 20260616：当月服务商拜访达成率
        ,CASE   WHEN COALESCE(user_discard_month.is_discard_user,0) = 1 THEN NULL
				WHEN job_name IN ('大区通路发展经理') THEN 5
                WHEN job_name in ('城市渠道负责人','城市群负责人') AND coalesce(is_many_channel_type,0) = 1 then  IF(NVL(month_fws_sever_obj_m_1,0) <= 3,NVL(month_fws_sever_obj_m_1,0),3)
                WHEN job_name in ('城市渠道负责人','城市群负责人') AND coalesce(is_many_channel_type,0) = 0 then  IF(NVL(month_fws_sever_obj_m_1,0) <= 5,NVL(month_fws_sever_obj_m_1,0),5)
                ELSE CAST(NVL(month_fws_sever_obj_m_1,0) AS BIGINT)
        END AS month_fws_sever_obj_m_1
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT)) AS month_fws_visit_valid_cnt_1
        ,CASE   WHEN COALESCE(user_discard_month.is_discard_user,0) = 1 THEN NULL
				WHEN job_name IN ('大区通路发展经理') THEN round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT) / 5,4)
                WHEN job_name in ('城市渠道负责人','城市群负责人') AND coalesce(is_many_channel_type,0) = 1 then  round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT)/IF(NVL(month_fws_sever_obj_m_1,0) <= 3,NVL(month_fws_sever_obj_m_1,0),3),4)
                WHEN job_name in ('城市渠道负责人','城市群负责人') AND coalesce(is_many_channel_type,0) = 0 then  round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT)/IF(NVL(month_fws_sever_obj_m_1,0) <= 5,NVL(month_fws_sever_obj_m_1,0),5),4)
                ELSE round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT) / NVL(month_fws_sever_obj_m_1,0),4)
        END AS month_fws_visit_valid_rate_1
        ,CASE
                WHEN COALESCE(user_discard_month.is_discard_user,0) = 1 then NULL
				WHEN job_name IN ('大区通路发展经理') AND round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT) / 5,4) >= month_rate THEN '达标'
                WHEN job_name IN ('大区通路发展经理') THEN '未达标'
                WHEN job_name in ('城市渠道负责人','城市群负责人')
                    AND coalesce(is_many_channel_type,0) = 1
                    AND (round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT)/IF(NVL(month_fws_sever_obj_m_1,0) <= 3,NVL(month_fws_sever_obj_m_1,0),3),4) >= month_rate
                        or NVL(month_fws_sever_obj_m_1,0) = 0)
                    then '达标'
                WHEN job_name in ('城市渠道负责人','城市群负责人')
                    AND coalesce(is_many_channel_type,0) = 0
                    AND (round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT)/IF(NVL(month_fws_sever_obj_m_1,0) <= 5,NVL(month_fws_sever_obj_m_1,0),5),4) >= month_rate
                        or NVL(month_fws_sever_obj_m_1,0) = 0)
                    then '达标'
                WHEN channel_name in ('GT') AND job_name in ('城市渠道负责人','城市群负责人')
                    THEN '未达标'
                WHEN (
                            round(CAST(NVL(month_fws_visit_valid_cnt_1,0) AS BIGINT) / NVL(month_fws_sever_obj_m_1,0),4) >= month_rate OR NVL(month_fws_sever_obj_m_1,0) = 0
                ) THEN '达标'
                ELSE '未达标'
        END AS month_fws_visit_valid_rate_qualified_1
        -- 20260616：当季服务商拜访达成
        ,CASE   WHEN COALESCE(user_discard_quar.is_discard_user,0) = 1 then NULL
				WHEN job_name IN ('大区通路发展经理') THEN 15
                -- WHEN job_name in ('城市渠道负责人','城市群负责人') AND coalesce(is_many_channel_type,0) = 1 then  IF(quar_fws_sever_obj_m_1 <= 9,quar_fws_sever_obj_m_1,9)
                -- WHEN job_name in ('城市渠道负责人','城市群负责人') AND coalesce(is_many_channel_type,0) = 0 then  IF(quar_fws_sever_obj_m_1 <= 15,quar_fws_sever_obj_m_1,15)
                ELSE CAST(NVL(quar_fws_sever_obj_m_1,0) AS BIGINT)
        END AS quar_fws_sever_obj_m_1
        ,if(COALESCE(user_discard_quar.is_discard_user,0) = 1,null,CAST(NVL(quar_fws_visit_valid_cnt_1,0) AS BIGINT)) AS quar_fws_visit_valid_cnt_1
            -- 20251016修改：原脚本在计算季度服务商拜访达成率时，对于大区通路发展经理，其分子为名下服务商数，而非拜访服务商数
        ,CASE   WHEN COALESCE(user_discard_quar.is_discard_user,0) = 1 then NULL
				WHEN job_name IN ('大区通路发展经理') THEN ROUND(NVL(quar_fws_visit_valid_cnt_1,0) / 15,4)
                ELSE quar_fws_visit_valid_rate_1
        END AS quar_fws_visit_valid_rate_1
        ,CASE
                WHEN COALESCE(user_discard_quar.is_discard_user,0) = 1 then NULL
                -- 2025Q4季度服务商达成率调整
                WHEN job_name IN ('大区通路发展经理') AND round(quar_fws_visit_valid_cnt_1 / 15,4) >= quar_rate THEN '达标'
                -- 20260617新增
                WHEN job_name in ('城市渠道负责人','城市群负责人')
                    AND (round(quar_fws_visit_valid_cnt_1/quar_fws_sever_obj_m_1,4) >= quar_rate
                        or NVL(quar_fws_sever_obj_m_1,0) = 0)
                    then '达标'
                WHEN job_name in ('城市渠道负责人','城市群负责人') THEN '未达标'
                ELSE '未达标'
        END AS quar_fws_visit_valid_rate_qualified_1
        -- 20260616：当月门店拜访达成
        ,CAST(
            CASE
                WHEN COALESCE(user_discard_month.is_discard_user,0) = 1 then NULL
                WHEN (job_name in ('城市群负责人') or user_real_name = '胡志伟') then coalesce(white_list_empno.change_target,40)*coalesce(mdson_target.discount_rate,1)
                ELSE nvl(month_sever_obj_m_1, 0)
                END
        AS BIGINT) AS month_sever_obj_m_1
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,CAST(NVL(month_shop_visit_valid_cnt_1,0) AS BIGINT)) AS month_shop_visit_valid_cnt_1
        ,(-- 20260712：城市群负责人按40家(白名单及折算前考核，其余按名下)
        CASE
            WHEN COALESCE(user_discard_month.is_discard_user,0) = 1 then NULL
            WHEN (job_name in ('城市群负责人') or user_real_name = '胡志伟') then CAST(NVL(month_shop_visit_valid_cnt_1,0) AS BIGINT)/CAST(coalesce(white_list_empno.change_target,40)*coalesce(mdson_target.discount_rate,1) AS BIGINT)
            ELSE month_shop_visit_valid_rate_1
            END) AS month_shop_visit_valid_rate_1
        ,-- 20260712：城市群负责人按40家(白名单及折算前考核，其余按名下)
        (CASE
            WHEN COALESCE(user_discard_month.is_discard_user,0) = 1 then NULL
            WHEN (job_name in ('城市群负责人') or user_real_name = '胡志伟') THEN if(CAST(NVL(month_shop_visit_valid_cnt_1,0) AS BIGINT)/CAST(coalesce(white_list_empno.change_target,40)*coalesce(mdson_target.discount_rate,1) AS BIGINT) >= month_rate, '达标', '未达标')
            WHEN month_shop_visit_valid_rate_1 >= month_rate OR NVL(month_sever_obj_m_1,0) = 0 THEN '达标'
            ELSE '未达标'
        END) AS month_shop_visit_valid_rate_qualified_1
        -- 20260616：当月院线店拜访达成
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,CAST(NVL(month_hospital_sever_obj_m_1,0) AS BIGINT))
         AS month_hospital_sever_obj_m_1
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,CAST(NVL(month_hospital_visit_valid_cnt_1,0) AS BIGINT))
         AS month_hospital_visit_valid_cnt_1
        ,if(COALESCE(user_discard_month.is_discard_user,0) = 1,null,month_hospital_visit_valid_rate_1) as month_hospital_visit_valid_rate_1
        ,CASE
            WHEN COALESCE(user_discard_month.is_discard_user,0) = 1 then NULL
            WHEN (month_hospital_visit_valid_rate_1 >= month_rate OR NVL(month_hospital_sever_obj_m_1,0) = 0) THEN '达标'
            ELSE '未达标'
        END AS month_hospital_visit_valid_rate_qualified_1
FROM    user_info
LEFT JOIN mdson_target
ON      user_info.user_id = mdson_target.user_id
AND     user_info.data_month = mdson_target.data_month
LEFT JOIN user_summary_data
ON      user_info.user_id = user_summary_data.user_id
AND     user_info.data_month = user_summary_data.data_month
LEFT JOIN quar_rate
ON      REGEXP_REPLACE(user_info.data_month,'-','') = quar_rate.year_month_id
LEFT JOIN channel_type_cnt_user
ON user_info.user_id = channel_type_cnt_user.user_id
LEFT JOIN user_discard_month
ON user_info.user_id = user_discard_month.user_id
AND user_info.data_month = user_discard_month.year_month
LEFT JOIN user_discard_quar
ON user_info.user_id = user_discard_quar.user_id
AND user_info.data_month = user_discard_quar.year_month
LEFT JOIN white_list_empno
ON user_info.user_id = white_list_empno.user_id
AND user_info.data_month = white_list_empno.year_month