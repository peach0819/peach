--@exclude_input=prod_mdson.inf_mdson_vacation_np
--@exclude_input=prod_mdson_dev.inf_mdson_white_list_empno
-- 人员信息
WITH user_info as (
    SELECT user_id,
           user_real_name,
           job_name,
           channel_name,
           department_charger_id,
           department_charger_name,
           dept_id,
           department_name,
           region_name,
           sub_region_name,
           data_month
    FROM prod_mdson.ads_mdspn_user_cur_month_summary_di
    WHERE dayid <= '${v_cur_month}'
    AND dayid > '${v_pre_3_month}'
),

-- 系统目标
mdson_target as (
    SELECT user_id,
           data_month,
           cast(max(CASE WHEN indicator_id = 2 AND service_obj_type = 1 THEN actual_indicator_value ELSE 0 END) as BIGINT) as visit_m_target, -- 当月目标拜访店次
           cast(max(CASE WHEN indicator_id = 2 AND service_obj_type = 1 THEN actual_indicator_value_1 ELSE 0 END) as BIGINT) as visit_m_target_1 -- 20260626：二期当月目标拜访店次
    FROM prod_mdson.ads_crm_user_visit_target_d_v2
    WHERE dayid = '${v_cur_month}'
    AND regexp_replace(data_month, '-', '') <= '${v_cur_month}'
    AND regexp_replace(data_month, '-', '') > '${v_pre_3_month}'
    GROUP BY user_id,
             data_month
) -- 20260623：增加人员白名单部分
,

white_list_empno as ( -- 人员白名单家数部分
    SELECT concat(substr(year_month, 1, 4), '-', substr(year_month, 5, 6)) as year_month,
           t1.empno,
           t2.user_id,
           change_indicator,
           change_target
    FROM prod_mdson_dev.inf_mdson_white_list_empno t1
    LEFT JOIN ( -- 关联人员ID
        SELECT user_id,
               CASE WHEN instr(empno, '-') > 0 THEN split(empno, '-')[1] ELSE empno END as empno
        FROM prod_mdson.dim_user_d
        WHERE dayid = '${v_date}'
        AND account_type = 1 -- 员工账号
        AND is_deleted = 0 -- 未删除
        AND dismiss_status = 0 -- 未离职
    ) t2 ON t1.empno = t2.empno
    WHERE t1.year_month = '${v_cur_month}'
    AND change_indicator = '每月拜访不重复门店/客户/经销商'
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

user_summary_data as ( -- 拜访达成明细
    SELECT data_month,
           t1.user_id, --门店拜访频次达标率
           sum(CASE WHEN indicator_id = 'month_visit_valid_cnt' AND if_visit_qualified = '达标' THEN valid_visit_m ELSE 0 END) as month_visit_valid_cnt --当月有效拜访店次
    --NKA 专职NC门店拜访达成率
       ,
           count(DISTINCT CASE WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' THEN service_obj_id ELSE NULL END) as month_nka_sever_obj_m, --当月NKA 目标拜访覆盖店数
           count(DISTINCT CASE WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_nka_nc_visit_valid_cnt, --当月NKA 有效拜访专职NC门店数
           round(count(DISTINCT CASE WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / count(DISTINCT CASE WHEN indicator_id = 'month_nka_nc_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 4) as month_nka_nc_visit_valid_rate --当月NKA 专职NC门店拜访达成率
    --RKA 专职NC门店拜访达成率
       ,
           count(DISTINCT CASE WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' THEN service_obj_id ELSE NULL END) as month_rka_sever_obj_m, --当月RKA目标拜访覆盖店数
           count(DISTINCT CASE WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_rka_nc_visit_valid_cnt, --当月RKA 有效拜访专职门店数
           round(count(DISTINCT CASE WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / count(DISTINCT CASE WHEN indicator_id = 'month_rka_nc_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 4) as month_rka_nc_visit_valid_rate --当月RKA 专职NC门店拜访达成率
    --门店拜访覆盖率
       ,
           count(DISTINCT CASE WHEN indicator_id = 'month_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END) as month_sever_obj_m, --当月名下拜访门店数
           count(DISTINCT CASE WHEN indicator_id = 'month_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_shop_visit_valid_cnt, --当月有效拜访门店数
           round(count(DISTINCT CASE WHEN indicator_id = 'month_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / count(DISTINCT CASE WHEN indicator_id = 'month_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 4) as month_shop_visit_valid_rate --当月门店拜访覆盖率
    --院线店拜访达成率
       ,
           count(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt' THEN service_obj_id ELSE NULL END) as month_hospital_sever_obj_m, --当月名下名下院线店数
           count(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_hospital_visit_valid_cnt, --当月有效拜访院线店数
           round(count(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / count(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 4) as month_hospital_visit_valid_rate --当月院线店拜访达成率
    --当月服务商拜访达成率
       ,
           count(DISTINCT CASE WHEN indicator_id = 'month_fws_visit_valid_cnt' THEN service_obj_id ELSE NULL END) as month_fws_sever_obj_m, --当月名下服务商个数
           count(DISTINCT CASE WHEN indicator_id = 'month_fws_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_fws_visit_valid_cnt, --当月服务商拜访个数
           round(count(DISTINCT CASE WHEN indicator_id = 'month_fws_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / count(DISTINCT CASE WHEN indicator_id = 'month_fws_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 4) as month_fws_visit_valid_rate --当月服务商拜访达成率
    --季度服务商拜访达成率
       ,
           count(DISTINCT CASE WHEN indicator_id = 'quar_fws_visit_valid_cnt' THEN service_obj_id ELSE NULL END) as quar_fws_sever_obj_m, --季度名下服务商个数
           count(DISTINCT CASE WHEN indicator_id = 'quar_fws_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as quar_fws_visit_valid_cnt, --季度服务商拜访个数
           round(count(DISTINCT CASE WHEN indicator_id = 'quar_fws_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / count(DISTINCT CASE WHEN indicator_id = 'quar_fws_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 4) as quar_fws_visit_valid_rate --季度服务商拜访达成率
    --当月GT门店拜访覆盖率
       ,
           count(DISTINCT CASE WHEN indicator_id = 'month_gt_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END) as month_gt_sever_obj_m, --当月月度拜访门店数
           count(DISTINCT CASE WHEN indicator_id = 'month_gt_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_gt_shop_visit_valid_cnt, --当月GT有效拜访门店数
           round(count(DISTINCT CASE WHEN indicator_id = 'month_gt_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / count(DISTINCT CASE WHEN indicator_id = 'month_gt_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 4) as month_gt_shop_visit_valid_rate --当月GT门店拜访覆盖率
    --当季GT门店拜访覆盖率
       ,
           count(DISTINCT CASE WHEN indicator_id = 'quar_gt_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END) as quar_gt_sever_obj_m, --季度拜访门店数
           count(DISTINCT CASE WHEN indicator_id = 'quar_gt_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as quar_gt_shop_visit_valid_cnt, --季度GT门店有效拜访门店数
           round(count(DISTINCT CASE WHEN indicator_id = 'quar_gt_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / count(DISTINCT CASE WHEN indicator_id = 'quar_gt_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 4) as quar_gt_shop_visit_valid_rate --季度GT门店拜访覆盖率
    --院线店拜访达成率新
       ,
           count(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END) as month_hospital_sever_obj_m_new, --当月名下名下院线店数新
           count(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_hospital_visit_valid_cnt_new, --当月有效拜访院线店数新
           round(count(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / count(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END), 4) as month_hospital_visit_valid_rate_new --当月院线店拜访达成率新
    --当月GT院线门店拜访覆盖率
       ,
           count(DISTINCT CASE WHEN indicator_id = 'month_gt_hospital_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END) as month_gt_hospital_sever_obj_m, --月度拜访院线店店数目标
           count(DISTINCT CASE WHEN indicator_id = 'month_gt_hospital_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_gt_hospital_shop_visit_valid_cnt, --当月GT有效拜访院线店门店数
           round(count(DISTINCT CASE WHEN indicator_id = 'month_gt_hospital_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / 10, 4) as month_gt_hospital_shop_visit_valid_rate --当月GT院线店门店拜访覆盖率
    --当月GT院线门店拜访覆盖率
       ,
           count(DISTINCT CASE WHEN indicator_id = 'quar_gt_hospital_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END) as quar_gt_hospital_sever_obj_m, --季度拜访院线门店数
           count(DISTINCT CASE WHEN indicator_id = 'quar_gt_hospital_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as quar_gt_hospital_shop_visit_valid_cnt, --季度GT门店有效拜访院线门店数
           round(count(DISTINCT CASE WHEN indicator_id = 'quar_gt_hospital_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / count(DISTINCT CASE WHEN indicator_id = 'quar_gt_hospital_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 4) as quar_gt_hospital_shop_visit_valid_rate --季度GT院线门店拜访覆盖率
    -- 20260612：新增指标
    -- 当月专职NC门店拜访达成
       ,
           cast(round(((if(t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0) < 0, 0, t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0))) / nullif(t2.total_days, 0)) * count(DISTINCT CASE WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 0) as bigint) as month_nc_shop_server_obj_m, -- 当月专职NC门店目标拜访覆盖店数
           count(DISTINCT CASE WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_nc_shop_visit_valid_cnt, -- 当月专职NC门店有效拜访数
           round(count(DISTINCT CASE WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / round(((if(t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0) < 0, 0, t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0))) / nullif(t2.total_days, 0)) * count(DISTINCT CASE WHEN indicator_id = 'month_nc_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 0), 4) as month_nc_shop_visit_valid_rate -- 当月专职NC门店拜访达成率
    -- 当月星级门店拜访达成
       ,
           cast(round(((if(t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0) < 0, 0, t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0))) / nullif(t2.total_days, 0)) * count(DISTINCT CASE WHEN indicator_id = 'month_star_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 0) as bigint) as month_star_shop_server_obj_m, -- 当月星级门店目标拜访覆盖店数
           count(DISTINCT CASE WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_star_shop_visit_valid_cnt, -- 当月星级门店有效拜访数
           round(count(DISTINCT CASE WHEN indicator_id = 'month_star_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / round(((if(t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0) < 0, 0, t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0))) / nullif(t2.total_days, 0)) * count(DISTINCT CASE WHEN indicator_id = 'month_star_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 0), 4) as month_star_shop_visit_valid_rate -- 当月星级门店拜访达成率
    -- 当季全渠道重点门店拜访覆盖率
       ,
           count(DISTINCT CASE WHEN indicator_id = 'quar_key_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END) as quar_key_shop_server_obj_m, -- 当季全渠道重点门店目标拜访覆盖店数
           count(DISTINCT CASE WHEN indicator_id = 'quar_key_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as quar_key_shop_visit_valid_cnt, -- 当季全渠道重点门店有效拜访数
           round(count(DISTINCT CASE WHEN indicator_id = 'quar_key_shop_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / count(DISTINCT CASE WHEN indicator_id = 'quar_key_shop_visit_valid_cnt' THEN service_obj_id ELSE NULL END), 4) as quar_key_shop_visit_valid_rate -- 当季全渠道重点门店拜访达成率
    -- 20260616：新增指标
    -- 当月拜访频次达标率_改造
       ,
           sum(CASE WHEN indicator_id = 'month_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN valid_visit_m ELSE 0 END) as month_visit_valid_cnt_1, -- 当月服务商拜访达成
           cast(round(((if(t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0) < 0, 0, t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0))) / nullif(t2.total_days, 0)) * count(DISTINCT CASE WHEN indicator_id = 'month_fws_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END), 0) as bigint) as month_fws_sever_obj_m_1,
           count(DISTINCT CASE WHEN indicator_id = 'month_fws_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_fws_visit_valid_cnt_1,
           round(count(DISTINCT CASE WHEN indicator_id = 'month_fws_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / round(((if(t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0) < 0, 0, t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0))) / nullif(t2.total_days, 0)) * count(DISTINCT CASE WHEN indicator_id = 'month_fws_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END), 0), 4) as month_fws_visit_valid_rate_1, -- 当季服务商拜访达成
           count(DISTINCT CASE WHEN indicator_id = 'quar_fws_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END) as quar_fws_sever_obj_m_1,
           count(DISTINCT CASE WHEN indicator_id = 'quar_fws_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as quar_fws_visit_valid_cnt_1, --季度服务商拜访个数
           round(count(DISTINCT CASE WHEN indicator_id = 'quar_fws_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / count(DISTINCT CASE WHEN indicator_id = 'quar_fws_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END), 4) as quar_fws_visit_valid_rate_1, -- 门店拜访达成
           cast(round(((if(t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0) < 0, 0, t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0))) / nullif(t2.total_days, 0)) * count(DISTINCT CASE WHEN indicator_id = 'month_shop_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END), 0) as bigint) as month_sever_obj_m_1,
           count(DISTINCT CASE WHEN indicator_id = 'month_shop_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_shop_visit_valid_cnt_1, --当月有效拜访门店数
           round(count(DISTINCT CASE WHEN indicator_id = 'month_shop_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / round(((if(t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0) < 0, 0, t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0))) / nullif(t2.total_days, 0)) * count(DISTINCT CASE WHEN indicator_id = 'month_shop_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END), 0), 4) as month_shop_visit_valid_rate_1, -- 院线店拜访达成
           cast(round(((if(t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0) < 0, 0, t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0))) / nullif(t2.total_days, 0)) * count(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END), 0) as bigint) as month_hospital_sever_obj_m_1,
           count(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_hospital_visit_valid_cnt_1,
           round(count(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) / round(((if(t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0) < 0, 0, t2.total_days - t2.vacation_days - coalesce(t3.leave_days, 0))) / nullif(t2.total_days, 0)) * count(DISTINCT CASE WHEN indicator_id = 'month_hospital_visit_valid_cnt_1' THEN service_obj_id ELSE NULL END), 0), 4) as month_hospital_visit_valid_rate_1, -- 全渠道拜访达成
           sum(CASE WHEN indicator_id = 'month_all_visit_valid_cnt' AND if_visit_qualified = '达标' THEN valid_visit_m ELSE 0 END) as month_all_visit_valid_cnt,
           count(DISTINCT CASE WHEN indicator_id = 'month_all_visit_valid_cnt' AND if_visit_qualified = '达标' THEN service_obj_id ELSE NULL END) as month_all_visit_valid_obj_m
    FROM prod_mdson.ads_mdson_user_cur_month_detail_d_v2 t1
    LEFT JOIN vacation_info t2 ON t1.data_month = t2.year_month
    LEFT JOIN user_leave t3 ON t1.data_month = t3.year_month AND t1.user_id = t3.user_id
    WHERE dayid = '${v_date}'
    GROUP BY data_month,
             t1.user_id,
             t2.total_days,
             t2.vacation_days,
             t3.leave_days
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
        AND year_month_id >= '202501'
        ORDER BY date_id
    ) t
    GROUP BY year_month_id
    ORDER BY year_month_id
) -- 20260617: 判定人员为仅GT渠道覆盖还是多渠道覆盖
,

mdson_user as ( -- 员工信息
    SELECT user_id,
           user_real_name,
           job_id,
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

mdson_service_obj_user as ( -- 门店渠道及人员整合
    SELECT DISTINCT service_obj_id,
           CASE WHEN channel_type = 'GT' THEN 0 ELSE 1 END as channel_type_1,
           t3.user_id
    FROM mdson_service_obj t1
    LEFT JOIN mdson_service_obj_sever t2 ON t1.service_obj_id = t2.store_code
    LEFT JOIN mdson_user t3 ON t2.server_code = t3.empno
    WHERE user_id IS NOT NULL
    AND service_obj_type_name = '门店'
),

channel_type_cnt_user as ( -- 人员是仅GT渠道还是多渠道判定(仅保留多渠道)
    SELECT user_id,
           sum(channel_type_1) as channel_type_cnt,
           1 as is_many_channel_type
    FROM mdson_service_obj_user
    GROUP BY user_id
    HAVING channel_type_cnt > 0
) -- 主查询


INSERT OVERWRITE TABLE prod_mdson.ads_mdson_user_new_visit_summary_data_d_v2 PARTITION (dayid = '${v_date}')
SELECT user_info.data_month,
       user_info.user_id,
       user_real_name,
       job_name,
       channel_name,
       region_name,
       sub_region_name,
       dept_id,
       department_name,
       department_charger_id,
       department_charger_name,
       visit_m_target,
       cast(nvl(month_visit_valid_cnt, 0) as BIGINT) as month_visit_valid_cnt,
       round(cast(nvl(month_visit_valid_cnt, 0) as BIGINT) / cast(nvl(visit_m_target, 0) as BIGINT), 4) as month_visit_valid_rate,
       cast(nvl(month_nka_sever_obj_m, 0) as BIGINT) as month_nka_sever_obj_m,
       cast(nvl(month_nka_nc_visit_valid_cnt, 0) as BIGINT) as month_nka_nc_visit_valid_cnt,
       month_nka_nc_visit_valid_rate,
       cast(nvl(month_rka_sever_obj_m, 0) as BIGINT) as month_rka_sever_obj_m,
       cast(nvl(month_rka_nc_visit_valid_cnt, 0) as BIGINT) as month_rka_nc_visit_valid_cnt,
       month_rka_nc_visit_valid_rate,
       cast(nvl(month_sever_obj_m, 0) as BIGINT) as month_sever_obj_m,
       cast(nvl(month_shop_visit_valid_cnt, 0) as BIGINT) as month_shop_visit_valid_cnt,
       month_shop_visit_valid_rate,
       cast(nvl(month_hospital_sever_obj_m, 0) as BIGINT) as month_hospital_sever_obj_m,
       cast(nvl(month_hospital_visit_valid_cnt, 0) as BIGINT) as month_hospital_visit_valid_cnt,
       month_hospital_visit_valid_rate,
       CASE WHEN job_name IN ('大区通路发展经理') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN 4 ----202510拜访次数 = 原次数 * (31-8)/31

            WHEN job_name IN ('大区通路发展经理') THEN 5
            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN cast(round(if(month_fws_sever_obj_m <= 5, month_fws_sever_obj_m, 5) * (31 - 8) / 31, 0) as BIGINT) ----202510拜访次数 = 原次数 * (31-8)/31

            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') THEN if(month_fws_sever_obj_m <= 5, month_fws_sever_obj_m, 5)
            ELSE cast(nvl(month_fws_sever_obj_m, 0) as BIGINT) END as month_fws_sever_obj_m,
       cast(nvl(month_fws_visit_valid_cnt, 0) as BIGINT) as month_fws_visit_valid_cnt,
       CASE WHEN job_name IN ('大区通路发展经理') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN round(nvl(month_fws_visit_valid_cnt, 0) / 4, 4) ----202510拜访次数 = 原次数 * (31-8)/31

            WHEN job_name IN ('大区通路发展经理') THEN round(nvl(month_fws_visit_valid_cnt, 0) / 5, 4)
            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN round(month_fws_visit_valid_cnt / round(if(month_fws_sever_obj_m <= 5, month_fws_sever_obj_m, 5) * (31 - 8) / 31, 0), 4) ----202510调整lsp目标拜访

            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') THEN round(month_fws_visit_valid_cnt / if(month_fws_sever_obj_m <= 5, month_fws_sever_obj_m, 5), 4)
            ELSE round(nvl(month_fws_visit_valid_cnt, 0) / nvl(month_fws_sever_obj_m, 0), 4) END as month_fws_visit_valid_rate,
       CASE WHEN job_name IN ('大区通路发展经理') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') THEN 14 ----2025Q4总次数调整

            WHEN job_name IN ('大区通路发展经理') THEN 15
            ELSE cast(nvl(quar_fws_sever_obj_m, 0) as BIGINT) END as quar_fws_sever_obj_m,
       cast(nvl(quar_fws_visit_valid_cnt, 0) as BIGINT) as quar_fws_visit_valid_cnt, -- 20251016修改：原脚本在计算季度服务商拜访达成率时，对于大区通路发展经理，其分子为名下服务商数，而非拜访服务商数
       CASE WHEN job_name IN ('大区通路发展经理') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') THEN round(nvl(quar_fws_visit_valid_cnt, 0) / 14, 4) ----2025Q4特殊处理Q4的季度服务商拜访达成率

            WHEN job_name IN ('大区通路发展经理') THEN round(nvl(quar_fws_visit_valid_cnt, 0) / 15, 4)
            ELSE quar_fws_visit_valid_rate END as quar_fws_visit_valid_rate,
       CASE WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN 22 ---202510Fydia要求目标拜访数按照（31-8）/31 *30

            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') THEN 30
            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN 2 ----2o2510按业务要求变更次数为2

            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') THEN 3
            ELSE 0 END as month_gt_sever_obj_m,
       cast(nvl(month_gt_shop_visit_valid_cnt, 0) as BIGINT) as month_gt_shop_visit_valid_cnt,
       CASE WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN round(nvl(month_gt_shop_visit_valid_cnt, 0) / 22, 4) ---202510Fydia要求拜访数

            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') THEN round(nvl(month_gt_shop_visit_valid_cnt, 0) / 30, 4)
            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN round(nvl(month_gt_shop_visit_valid_cnt, 0) / 2, 4) ----2o2510按业务要求修改拜访达成率

            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') THEN round(nvl(month_gt_shop_visit_valid_cnt, 0) / 3, 4)
            ELSE 0 END as month_gt_shop_visit_valid_rate,
       CASE WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') THEN 52 ----2025Q4拜访目标门店数特殊处理

            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') THEN 60
            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') THEN 11
            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') THEN 12
            ELSE 0 END as quar_gt_sever_obj_m,
       cast(nvl(quar_gt_shop_visit_valid_cnt, 0) as BIGINT) as quar_gt_shop_visit_valid_cnt,
       CASE WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') THEN round(nvl(quar_gt_shop_visit_valid_cnt, 0) / 52, 4) ----2025Q4拜访达成率特殊处理

            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') THEN round(nvl(quar_gt_shop_visit_valid_cnt, 0) / 60, 4)
            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') THEN round(nvl(quar_gt_shop_visit_valid_cnt, 0) / 11, 4)
            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') THEN round(nvl(quar_gt_shop_visit_valid_cnt, 0) / 12, 4)
            ELSE 0 END as quar_gt_shop_visit_valid_rate, --,CASE   WHEN channel_name IN ('NKA','RKA')
       CASE WHEN channel_name IN ('NKA', 'RKA', 'COT', 'KA') -- 20260311接通知NKA更名为COT，删除LKA、RKA(保留)=>新增KA
 AND job_name IN ('城市渠道负责人') AND round(cast(nvl(month_visit_valid_cnt, 0) as BIGINT) / cast(nvl(visit_m_target, 0) as BIGINT), 4) >= month_rate AND (month_nka_nc_visit_valid_rate >= month_rate OR nvl(month_nka_sever_obj_m, 0) = 0) AND (month_rka_nc_visit_valid_rate >= month_rate OR nvl(month_rka_sever_obj_m, 0) = 0) AND (month_hospital_visit_valid_rate_new >= month_rate OR nvl(month_hospital_sever_obj_m_new, 0) = 0) THEN '达标'
            WHEN channel_name IN ('NKA', 'RKA', 'COT', 'KA') AND job_name IN ('城市渠道负责人') THEN '未达标'
            WHEN channel_name IN ('NKA', 'RKA', 'COT', 'KA') AND job_name IN ('地区渠道负责人', '省区渠道负责人') AND round(cast(nvl(month_visit_valid_cnt, 0) as BIGINT) / cast(nvl(visit_m_target, 0) as BIGINT), 4) >= month_rate AND (month_nka_nc_visit_valid_rate >= month_rate OR nvl(month_nka_sever_obj_m, 0) = 0) AND (month_rka_nc_visit_valid_rate >= month_rate OR nvl(month_rka_sever_obj_m, 0) = 0) THEN '达标'
            WHEN channel_name IN ('NKA', 'RKA', 'COT', 'KA') AND job_name IN ('地区渠道负责人', '省区渠道负责人') THEN '未达标'
            WHEN channel_name IN ('GT') -----202510月新增逻辑
 AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' AND (round(month_gt_shop_visit_valid_cnt / 22, 4) >= month_rate --OR NVL(month_gt_sever_obj_m,0) = 0  -- 0919修改：无拜访记录默认不达标
) AND (round(month_fws_visit_valid_cnt / round(if(month_fws_sever_obj_m <= 5, month_fws_sever_obj_m, 5) * (31 - 8) / 31, 0), 4) >= month_rate OR nvl(month_fws_sever_obj_m, 0) = 0) AND (round(nvl(month_gt_hospital_shop_visit_valid_cnt, 0) / round(if(month_gt_hospital_sever_obj_m <= 10, month_gt_hospital_sever_obj_m, 10) * (31 - 8) / 31, 0), 4) >= month_rate ----202510 GT渠道的省地城院线店拜访目标变更
 OR nvl(month_gt_hospital_sever_obj_m, 0) = 0) THEN '达标'
            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND (round(month_gt_shop_visit_valid_cnt / 30, 4) >= month_rate -- OR NVL(month_gt_sever_obj_m,0) = 0 -- 0919修改：无拜访记录默认不达标
) AND (round(month_fws_visit_valid_cnt / if(month_fws_sever_obj_m <= 5, month_fws_sever_obj_m, 5), 4) >= month_rate OR nvl(month_fws_sever_obj_m, 0) = 0) AND (round(nvl(month_gt_hospital_shop_visit_valid_cnt, 0) / if(month_gt_hospital_sever_obj_m <= 10, month_gt_hospital_sever_obj_m, 10), 4) >= month_rate OR nvl(month_gt_hospital_sever_obj_m, 0) = 0) THEN '达标'
            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') THEN '未达标' ------20250917调整GT区域渠道负责人 是否达标只与拜访GT门店有关
----202510节假日目标有调整

            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' AND (round(month_gt_shop_visit_valid_cnt / 2, 4) >= month_rate OR nvl(month_gt_sever_obj_m, 0) = 0) THEN '达标'
            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND (round(month_gt_shop_visit_valid_cnt / 3, 4) >= month_rate OR nvl(month_gt_sever_obj_m, 0) = 0) THEN '达标'
            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') THEN '未达标'
            WHEN job_name IN ('大区销售总经理') AND round(cast(nvl(month_visit_valid_cnt, 0) as BIGINT) / cast(nvl(visit_m_target, 0) as BIGINT), 4) >= month_rate THEN '达标'
            WHEN job_name IN ('大区销售总经理') THEN '未达标'
            WHEN channel_name NOT IN ('GT') AND job_name IN ('区域渠道负责人') AND round(cast(nvl(month_visit_valid_cnt, 0) as BIGINT) / cast(nvl(visit_m_target, 0) as BIGINT), 4) >= month_rate THEN '达标'
            WHEN job_name IN ('大区销售总经理') THEN '未达标' ---202510大区通路发展服务商拜访降至4家

            WHEN job_name IN ('大区通路发展经理') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' AND round(cast(nvl(month_visit_valid_cnt, 0) as BIGINT) / cast(nvl(visit_m_target, 0) as BIGINT), 4) >= month_rate AND (round(month_fws_visit_valid_cnt / 4, 4) >= month_rate OR nvl(month_fws_sever_obj_m, 0) = 0) THEN '达标'
            WHEN job_name IN ('大区通路发展经理') AND round(cast(nvl(month_visit_valid_cnt, 0) as BIGINT) / cast(nvl(visit_m_target, 0) as BIGINT), 4) >= month_rate AND (round(month_fws_visit_valid_cnt / 5, 4) >= month_rate OR nvl(month_fws_sever_obj_m, 0) = 0) THEN '达标'
            WHEN job_name IN ('大区通路发展经理') THEN '未达标'
            WHEN round(cast(nvl(month_visit_valid_cnt, 0) as BIGINT) / cast(nvl(visit_m_target, 0) as BIGINT), 4) >= month_rate THEN '达标'
            ELSE '未达标' END as if_visit_qualified_month, ----202510Q4季度达成率有变动
       CASE WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') AND (round(quar_gt_shop_visit_valid_cnt / 52, 4) >= quar_rate --OR NVL(quar_gt_sever_obj_m,0) = 0
)-- 0919修改：无拜访记录默认不达标
 AND (quar_fws_visit_valid_rate >= quar_rate OR nvl(quar_fws_sever_obj_m, 0) = 0) AND (quar_gt_hospital_shop_visit_valid_rate >= quar_rate OR nvl(quar_gt_hospital_sever_obj_m, 0) = 0) THEN '达标'
            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND (round(quar_gt_shop_visit_valid_cnt / 60, 4) >= quar_rate -- OR NVL(quar_gt_sever_obj_m,0) = 0 -- 0919修改：无拜访记录默认不达标
) AND (quar_fws_visit_valid_rate >= quar_rate OR nvl(quar_fws_sever_obj_m, 0) = 0) AND (quar_gt_hospital_shop_visit_valid_rate >= quar_rate OR nvl(quar_gt_hospital_sever_obj_m, 0) = 0) THEN '达标' ----202510Q4季度达成率有变动

            WHEN job_name IN ('大区通路发展经理') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') AND round(quar_fws_visit_valid_cnt / 14, 4) >= quar_rate THEN '达标'
            WHEN job_name IN ('大区通路发展经理') AND round(quar_fws_visit_valid_cnt / 15, 4) >= quar_rate THEN '达标' -----20250903新增GT渠道区域负责人季度达标
----202510Q4季度GT渠道总拜访门店数有变动

            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') AND (round(quar_gt_shop_visit_valid_cnt / 11, 4) >= quar_rate OR nvl(quar_gt_sever_obj_m, 0) = 0) -----季度门店
THEN '达标'
            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND (round(quar_gt_shop_visit_valid_cnt / 12, 4) >= quar_rate OR nvl(quar_gt_sever_obj_m, 0) = 0) -----季度门店
THEN '达标'
            ELSE '未达标' END as if_visit_qualified_quar,
       CASE WHEN round(cast(nvl(month_visit_valid_cnt, 0) as BIGINT) / cast(nvl(visit_m_target, 0) as BIGINT), 4) >= month_rate THEN '达标' ELSE '未达标' END as month_visit_valid_rate_qualified,
       CASE WHEN (month_nka_nc_visit_valid_rate >= month_rate OR nvl(month_nka_sever_obj_m, 0) = 0) THEN '达标' ELSE '未达标' END as month_nka_nc_visit_valid_rate_qualified,
       CASE WHEN (month_rka_nc_visit_valid_rate >= month_rate OR nvl(month_rka_sever_obj_m, 0) = 0) THEN '达标' ELSE '未达标' END as month_rka_nc_visit_valid_rate_qualified,
       CASE WHEN (month_hospital_visit_valid_rate >= month_rate OR nvl(month_hospital_sever_obj_m, 0) = 0) THEN '达标' ELSE '未达标' END as month_hospital_visit_valid_rate_qualified,
       CASE WHEN (month_shop_visit_valid_rate >= month_rate OR nvl(month_sever_obj_m, 0) = 0) THEN '达标' ELSE '未达标' END as month_shop_visit_valid_rate_qualified,
       CASE  ----202510服务商达标特殊处理
WHEN job_name IN ('大区通路发展经理') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' AND round(nvl(month_fws_visit_valid_cnt, 0) / 4, 4) >= month_rate THEN '达标'
WHEN job_name IN ('大区通路发展经理') AND round(nvl(month_fws_visit_valid_cnt, 0) / 5, 4) >= month_rate THEN '达标'
WHEN job_name IN ('大区通路发展经理') THEN '未达标' ----202510服务商达标特殊处理

WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' AND (round(month_fws_visit_valid_cnt / round(if(month_fws_sever_obj_m <= 5, month_fws_sever_obj_m, 5) * (31 - 8) / 31, 0), 4) >= month_rate OR nvl(month_fws_sever_obj_m, 0) = 0) THEN '达标'
WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND (round(month_fws_visit_valid_cnt / if(month_fws_sever_obj_m <= 5, month_fws_sever_obj_m, 5), 4) >= month_rate OR nvl(month_fws_sever_obj_m, 0) = 0) THEN '达标'
WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') THEN '未达标'
WHEN (round(month_fws_visit_valid_cnt / month_fws_sever_obj_m, 4) >= month_rate OR nvl(month_fws_sever_obj_m, 0) = 0) THEN '达标'
ELSE '未达标' END as month_fws_visit_valid_rate_qualified,
       CASE WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND (quar_fws_visit_valid_rate >= quar_rate OR nvl(quar_fws_sever_obj_m, 0) = 0) THEN '达标' ----2025Q4季度服务商达成率调整

            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') AND (round(quar_fws_visit_valid_cnt / 11, 4) >= quar_rate OR nvl(quar_fws_sever_obj_m, 0) = 0) THEN '达标'
            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND (round(quar_fws_visit_valid_cnt / 12, 4) >= quar_rate OR nvl(quar_fws_sever_obj_m, 0) = 0) THEN '达标' -- 2025Q4季度服务商达成率调整

            WHEN job_name IN ('大区通路发展经理') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') AND round(quar_fws_visit_valid_cnt / 14, 4) >= quar_rate THEN '达标'
            WHEN job_name IN ('大区通路发展经理') AND round(quar_fws_visit_valid_cnt / 15, 4) >= quar_rate THEN '达标'
            ELSE '未达标' END as quar_fws_visit_valid_rate_qualified, -- 202510GT渠道门目标门店数调整
       CASE WHEN channel_name IN ('GT') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND (round(month_gt_shop_visit_valid_cnt / 22, 4) >= month_rate) THEN '达标'
            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND (round(month_gt_shop_visit_valid_cnt / 30, 4) >= month_rate) THEN '达标' -- 202510GT渠道门目标门店数调整

            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' AND (round(month_gt_shop_visit_valid_cnt / 2, 4) >= month_rate OR nvl(month_gt_sever_obj_m, 0) = 0) THEN '达标'
            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND (round(month_gt_shop_visit_valid_cnt / 3, 4) >= month_rate OR nvl(month_gt_sever_obj_m, 0) = 0) THEN '达标'
            ELSE '未达标' END as month_gt_shop_visit_valid_rate_qualified,
       CASE WHEN channel_name IN ('GT') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND (round(quar_gt_shop_visit_valid_cnt / 52, 4) >= quar_rate) THEN '达标' -----2025Q4GT渠道门目标门店数调整

            WHEN channel_name IN ('GT') AND job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND (round(quar_gt_shop_visit_valid_cnt / 60, 4) >= quar_rate) THEN '达标' -- 2025Q4GT渠道门目标门店数调整

            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') AND (round(month_gt_shop_visit_valid_cnt / 11, 4) >= month_rate) THEN '达标'
            WHEN channel_name IN ('GT') AND job_name IN ('区域渠道负责人') AND (round(month_gt_shop_visit_valid_cnt / 12, 4) >= month_rate) THEN '达标'
            ELSE '未达标' END as quar_gt_shop_visit_valid_rate_qualified,
       cast(nvl(month_hospital_sever_obj_m_new, 0) as BIGINT) as month_hospital_sever_obj_m_new,
       cast(nvl(month_hospital_visit_valid_cnt_new, 0) as BIGINT) as month_hospital_visit_valid_cnt_new,
       month_hospital_visit_valid_rate_new,
       CASE WHEN (month_hospital_visit_valid_rate_new >= month_rate OR nvl(month_hospital_sever_obj_m_new, 0) = 0) THEN '达标' ELSE '未达标' END as month_hospital_visit_valid_rate_new_qualified,
       CASE WHEN substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN cast(nvl(round(if(month_gt_hospital_sever_obj_m <= 10, month_gt_hospital_sever_obj_m, 10) * (31 - 8) / 31, 0), 0) as BIGINT) ELSE cast(nvl(if(month_gt_hospital_sever_obj_m <= 10, month_gt_hospital_sever_obj_m, 10), 0) as BIGINT) END as month_gt_hospital_sever_obj_m,
       cast(nvl(month_gt_hospital_shop_visit_valid_cnt, 0) as BIGINT) as month_gt_hospital_shop_visit_valid_cnt,
       CASE WHEN substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN round(nvl(month_gt_hospital_shop_visit_valid_cnt, 0) / round(if(month_gt_hospital_sever_obj_m <= 10, month_gt_hospital_sever_obj_m, 10) * (31 - 8) / 31, 0), 4) ELSE round(nvl(month_gt_hospital_shop_visit_valid_cnt, 0) / if(month_gt_hospital_sever_obj_m <= 10, month_gt_hospital_sever_obj_m, 10), 4) END as month_gt_hospital_shop_visit_valid_rate,
       CASE WHEN substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' AND (round(nvl(month_gt_hospital_shop_visit_valid_cnt, 0) / round(if(month_gt_hospital_sever_obj_m <= 10, month_gt_hospital_sever_obj_m, 10) * (31 - 8) / 31, 0), 4) >= month_rate OR nvl(month_gt_hospital_sever_obj_m, 0) = 0) THEN '达标'
            WHEN (round(nvl(month_gt_hospital_shop_visit_valid_cnt, 0) / if(month_gt_hospital_sever_obj_m <= 10, month_gt_hospital_sever_obj_m, 10), 4) >= month_rate OR nvl(month_gt_hospital_sever_obj_m, 0) = 0) THEN '达标'
            ELSE '未达标' END as month_gt_hospital_shop_visit_valid_rate_qualified,
       cast(nvl(quar_gt_hospital_sever_obj_m, 0) as BIGINT) as quar_gt_hospital_sever_obj_m,
       cast(nvl(quar_gt_hospital_shop_visit_valid_cnt, 0) as BIGINT) as quar_gt_hospital_shop_visit_valid_cnt,
       quar_gt_hospital_shop_visit_valid_rate,
       CASE WHEN (quar_gt_hospital_shop_visit_valid_rate >= quar_rate OR nvl(quar_gt_hospital_sever_obj_m, 0) = 0) THEN '达标' ELSE '未达标' END as quar_gt_hospital_shop_visit_valid_rate_qualified,
       NULL  as quar_sever_obj_m,
       NULL  as quar_shop_visit_valid_cnt,
       NULL  as quar_shop_visit_valid_rate, -- 20260612：当月专职NC门店拜访达成率
       cast(coalesce(month_nc_shop_server_obj_m, 0) as bigint) as month_nc_shop_server_obj_m,
       cast(coalesce(month_nc_shop_visit_valid_cnt, 0) as bigint) as month_nc_shop_visit_valid_cnt,
       month_nc_shop_visit_valid_rate,
       CASE WHEN (month_nc_shop_visit_valid_rate >= month_rate OR nvl(month_nc_shop_server_obj_m, 0) = 0) THEN '达标' ELSE '未达标' END as month_nc_shop_visit_valid_rate_qualified, -- 20260612：当月星级门店拜访达成率
       cast(coalesce(month_star_shop_server_obj_m, 0) as bigint) as month_star_shop_server_obj_m,
       cast(coalesce(month_star_shop_visit_valid_cnt, 0) as bigint) as month_star_shop_visit_valid_cnt,
       month_star_shop_visit_valid_rate,
       CASE WHEN (month_star_shop_visit_valid_rate >= month_rate OR nvl(month_star_shop_server_obj_m, 0) = 0) THEN '达标' ELSE '未达标' END as month_star_shop_visit_valid_rate_qualified, -- 20260612：当季全渠道重点门店拜访覆盖率
       cast(coalesce(quar_key_shop_server_obj_m, 0) as bigint) as quar_key_shop_server_obj_m,
       cast(coalesce(quar_key_shop_visit_valid_cnt, 0) as bigint) as quar_key_shop_visit_valid_cnt,
       quar_key_shop_visit_valid_rate,
       CASE WHEN (quar_key_shop_visit_valid_rate >= quar_rate OR nvl(quar_key_shop_server_obj_m, 0) = 0) THEN '达标' ELSE '未达标' END as quar_key_shop_visit_valid_rate_qualified, -- 20260616：当月我的拜访达标
       CASE WHEN coalesce(user_discard.is_discard_user, 0) = 1 THEN NULL
            WHEN job_name IN ('城市渠道负责人') AND ( -- 当月拜访频次达成
round(cast(nvl(month_visit_valid_cnt_1, 0) as BIGINT) / cast(nvl(visit_m_target_1, 0) as BIGINT), 4) >= month_rate) AND ( -- 当月专职NC门店拜访达成
month_nc_shop_visit_valid_rate >= month_rate OR nvl(month_nc_shop_server_obj_m, 0) = 0) AND ( -- 当月院线店拜访达成
month_hospital_visit_valid_rate_1 >= month_rate OR nvl(month_hospital_sever_obj_m_1, 0) = 0) AND ( -- 当月门店拜访达成
month_shop_visit_valid_rate_1 >= month_rate OR nvl(month_sever_obj_m_1, 0) = 0) AND ( -- 当月服务商拜访达成
(coalesce(is_many_channel_type, 0) = 1 AND (round(month_fws_visit_valid_cnt_1 / if(month_fws_sever_obj_m_1 <= 3, month_fws_sever_obj_m_1, 3), 4) >= month_rate OR nvl(month_fws_sever_obj_m_1, 0) = 0)) OR (coalesce(is_many_channel_type, 0) = 0 AND (round(month_fws_visit_valid_cnt_1 / if(month_fws_sever_obj_m_1 <= 5, month_fws_sever_obj_m_1, 5), 4) >= month_rate OR nvl(month_fws_sever_obj_m_1, 0) = 0))) AND ( -- 当月星级门店拜访达成
month_star_shop_visit_valid_rate >= month_rate OR nvl(month_star_shop_server_obj_m, 0) = 0) AND ( -- 当月全渠道拜访
month_all_visit_valid_cnt / coalesce(visit_m_target_1, 80) >= month_rate) THEN '达标'
            WHEN job_name IN ('城市群负责人') AND ( -- 当月拜访频次达成
round(cast(nvl(month_visit_valid_cnt_1, 0) as BIGINT) / cast(nvl(visit_m_target_1, 0) as BIGINT), 4) >= month_rate) AND ( -- 当月专职NC门店拜访达成
month_nc_shop_visit_valid_rate >= month_rate OR nvl(month_nc_shop_server_obj_m, 0) = 0) AND ( -- 当月院线店拜访达成
month_hospital_visit_valid_rate_1 >= month_rate OR nvl(month_hospital_sever_obj_m_1, 0) = 0) AND ( -- 当月门店拜访达成
month_shop_visit_valid_rate_1 >= month_rate OR nvl(month_sever_obj_m_1, 0) = 0) AND ( -- 当月服务商拜访达成
(coalesce(is_many_channel_type, 0) = 1 AND (round(month_fws_visit_valid_cnt_1 / if(month_fws_sever_obj_m_1 <= 3, month_fws_sever_obj_m_1, 3), 4) >= month_rate OR nvl(month_fws_sever_obj_m_1, 0) = 0)) OR (coalesce(is_many_channel_type, 0) = 0 AND (round(month_fws_visit_valid_cnt_1 / if(month_fws_sever_obj_m_1 <= 5, month_fws_sever_obj_m_1, 5), 4) >= month_rate OR nvl(month_fws_sever_obj_m_1, 0) = 0))) AND ( -- 当月星级门店拜访达成
month_star_shop_visit_valid_rate >= month_rate OR nvl(month_star_shop_server_obj_m, 0) = 0) AND ( -- 当月全渠道拜访达成
month_all_visit_valid_obj_m / coalesce(white_list_empno.change_target, 40) >= month_rate) THEN '达标'
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') THEN '未达标'
            WHEN job_name IN ('大区通路发展经理') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' AND round(cast(nvl(month_visit_valid_cnt_1, 0) as BIGINT) / cast(nvl(visit_m_target_1, 0) as BIGINT), 4) >= month_rate AND (round(month_fws_visit_valid_cnt_1 / 4, 4) >= month_rate OR nvl(month_fws_sever_obj_m_1, 0) = 0) THEN '达标'
            WHEN job_name IN ('大区通路发展经理') AND round(cast(nvl(month_visit_valid_cnt_1, 0) as BIGINT) / cast(nvl(visit_m_target_1, 0) as BIGINT), 4) >= month_rate AND (round(month_fws_visit_valid_cnt_1 / 5, 4) >= month_rate OR nvl(month_fws_sever_obj_m_1, 0) = 0) THEN '达标'
            WHEN job_name IN ('大区通路发展经理') THEN '未达标'
            WHEN round(cast(nvl(month_visit_valid_cnt_1, 0) as BIGINT) / cast(nvl(visit_m_target_1, 0) as BIGINT), 4) >= month_rate THEN '达标'
            ELSE '未达标' END as if_visit_qualified_month_1, -- 20260616：当季我的拜访达标
       CASE WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND ( -- 当季服务商拜访达成
round(quar_fws_visit_valid_cnt_1 / quar_fws_sever_obj_m_1, 4) >= quar_rate OR nvl(quar_fws_sever_obj_m_1, 0) = 0) AND ( -- 当季全渠道重点门店拜访覆盖
quar_key_shop_visit_valid_rate >= quar_rate OR nvl(quar_key_shop_server_obj_m, 0) = 0) THEN '达标'
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') THEN '未达标'
            WHEN job_name IN ('大区通路发展经理') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') AND round(quar_fws_visit_valid_cnt_1 / 14, 4) >= quar_rate THEN '达标'
            WHEN job_name IN ('大区通路发展经理') AND round(quar_fws_visit_valid_cnt_1 / 15, 4) >= quar_rate THEN '达标' -----20250903新增GT渠道区域负责人季度达标

            ELSE '未达标' END as if_visit_qualified_quar_1, -- 20260616：当月拜访频次达标
       visit_m_target_1,
       cast(nvl(month_visit_valid_cnt_1, 0) as BIGINT) as month_visit_valid_cnt_1,
       round(cast(nvl(month_visit_valid_cnt_1, 0) as BIGINT) / cast(nvl(visit_m_target_1, 0) as BIGINT), 4) as month_visit_valid_rate_1,
       CASE WHEN round(cast(nvl(month_visit_valid_cnt, 0) as BIGINT) / cast(nvl(visit_m_target_1, 0) as BIGINT), 4) >= month_rate THEN '达标' ELSE '未达标' END as month_visit_valid_rate_qualified_1, -- 20260616：当月服务商拜访达成率
       CASE WHEN job_name IN ('大区通路发展经理') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN 4 ----202510拜访次数 = 原次数 * (31-8)/31

            WHEN job_name IN ('大区通路发展经理') THEN 5
            WHEN job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN cast(round(if(month_fws_sever_obj_m <= 5, month_fws_sever_obj_m, 5) * (31 - 8) / 31, 0) as BIGINT) ----202510拜访次数 = 原次数 * (31-8)/31

            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND coalesce(is_many_channel_type, 0) = 1 THEN if(month_fws_sever_obj_m_1 <= 3, month_fws_sever_obj_m_1, 3)
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND coalesce(is_many_channel_type, 0) = 0 THEN if(month_fws_sever_obj_m_1 <= 5, month_fws_sever_obj_m_1, 5)
            ELSE cast(nvl(month_fws_sever_obj_m_1, 0) as BIGINT) END as month_fws_sever_obj_m_1,
       cast(nvl(month_fws_visit_valid_cnt_1, 0) as BIGINT) as month_fws_visit_valid_cnt_1,
       CASE WHEN job_name IN ('大区通路发展经理') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN round(nvl(month_fws_visit_valid_cnt_1, 0) / 4, 4) ----202510拜访次数 = 原次数 * (31-8)/31

            WHEN job_name IN ('大区通路发展经理') THEN round(nvl(month_fws_visit_valid_cnt_1, 0) / 5, 4)
            WHEN job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' THEN round(month_fws_visit_valid_cnt_1 / round(if(month_fws_sever_obj_m_1 <= 5, month_fws_sever_obj_m_1, 5) * (31 - 8) / 31, 0), 4) ----202510调整lsp目标拜访

            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND coalesce(is_many_channel_type, 0) = 1 THEN round(month_fws_visit_valid_cnt_1 / if(month_fws_sever_obj_m_1 <= 3, month_fws_sever_obj_m_1, 3), 4)
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND coalesce(is_many_channel_type, 0) = 0 THEN round(month_fws_visit_valid_cnt_1 / if(month_fws_sever_obj_m_1 <= 5, month_fws_sever_obj_m_1, 5), 4)
            ELSE round(nvl(month_fws_visit_valid_cnt_1, 0) / nvl(month_fws_sever_obj_m_1, 0), 4) END as month_fws_visit_valid_rate_1,
       CASE  ----202510服务商达标特殊处理
WHEN job_name IN ('大区通路发展经理') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' AND round(nvl(month_fws_visit_valid_cnt_1, 0) / 4, 4) >= month_rate THEN '达标'
WHEN job_name IN ('大区通路发展经理') AND round(nvl(month_fws_visit_valid_cnt_1, 0) / 5, 4) >= month_rate THEN '达标'
WHEN job_name IN ('大区通路发展经理') THEN '未达标' ----202510服务商达标特殊处理

WHEN job_name IN ('地区渠道负责人', '省区渠道负责人', '城市渠道负责人') AND substr(dateadd(getdate(), - 1, 'dd'), 1, 7) = '2025-10' AND (round(month_fws_visit_valid_cnt_1 / round(if(month_fws_sever_obj_m_1 <= 5, month_fws_sever_obj_m_1, 5) * (31 - 8) / 31, 0), 4) >= month_rate OR nvl(month_fws_sever_obj_m_1, 0) = 0) THEN '达标'
WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND coalesce(is_many_channel_type, 0) = 1 AND (round(month_fws_visit_valid_cnt_1 / if(month_fws_sever_obj_m_1 <= 3, month_fws_sever_obj_m_1, 3), 4) >= month_rate OR nvl(month_fws_sever_obj_m_1, 0) = 0) THEN '达标'
WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND coalesce(is_many_channel_type, 0) = 0 AND (round(month_fws_visit_valid_cnt_1 / if(month_fws_sever_obj_m_1 <= 5, month_fws_sever_obj_m_1, 5), 4) >= month_rate OR nvl(month_fws_sever_obj_m_1, 0) = 0) THEN '达标'
WHEN channel_name IN ('GT') AND job_name IN ('城市渠道负责人', '城市群负责人') THEN '未达标'
WHEN (round(month_fws_visit_valid_cnt_1 / month_fws_sever_obj_m_1, 4) >= month_rate OR nvl(month_fws_sever_obj_m_1, 0) = 0) THEN '达标'
ELSE '未达标' END as month_fws_visit_valid_rate_qualified_1, -- 20260616：当季服务商拜访达成
       CASE WHEN job_name IN ('大区通路发展经理') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') THEN 14 ----2025Q4总次数调整

            WHEN job_name IN ('大区通路发展经理') THEN 15 -- WHEN job_name in ('城市渠道负责人','城市群负责人') AND coalesce(is_many_channel_type,0) = 1 then  IF(quar_fws_sever_obj_m_1 <= 9,quar_fws_sever_obj_m_1,9)
-- WHEN job_name in ('城市渠道负责人','城市群负责人') AND coalesce(is_many_channel_type,0) = 0 then  IF(quar_fws_sever_obj_m_1 <= 15,quar_fws_sever_obj_m_1,15)

            ELSE cast(nvl(quar_fws_sever_obj_m_1, 0) as BIGINT) END as quar_fws_sever_obj_m_1,
       cast(nvl(quar_fws_visit_valid_cnt_1, 0) as BIGINT) as quar_fws_visit_valid_cnt_1, -- 20251016修改：原脚本在计算季度服务商拜访达成率时，对于大区通路发展经理，其分子为名下服务商数，而非拜访服务商数
       CASE WHEN job_name IN ('大区通路发展经理') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') THEN round(nvl(quar_fws_visit_valid_cnt_1, 0) / 14, 4) ----2025Q4特殊处理Q4的季度服务商拜访达成率

            WHEN job_name IN ('大区通路发展经理') THEN round(nvl(quar_fws_visit_valid_cnt_1, 0) / 15, 4)
            ELSE quar_fws_visit_valid_rate_1 END as quar_fws_visit_valid_rate_1,
       CASE  -- 2025Q4季度服务商达成率调整
WHEN job_name IN ('大区通路发展经理') AND dateadd(getdate(), - 1, 'dd') >= to_date('2025-10-01', 'yyyy-MM-dd') AND dateadd(getdate(), - 1, 'dd') <= to_date('2025-12-31', 'yyyy-MM-dd') AND round(quar_fws_visit_valid_cnt_1 / 14, 4) >= quar_rate THEN '达标'
WHEN job_name IN ('大区通路发展经理') AND round(quar_fws_visit_valid_cnt_1 / 15, 4) >= quar_rate THEN '达标' -- 20260617新增

WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND (round(quar_fws_visit_valid_cnt_1 / quar_fws_sever_obj_m_1, 4) >= quar_rate OR nvl(quar_fws_sever_obj_m_1, 0) = 0) THEN '达标'
WHEN job_name IN ('城市渠道负责人', '城市群负责人') THEN '未达标'
WHEN (round(quar_fws_visit_valid_cnt_1 / quar_fws_sever_obj_m_1, 4) >= quar_rate OR nvl(quar_fws_sever_obj_m_1, 0) = 0) THEN '达标'
ELSE '未达标' END as quar_fws_visit_valid_rate_qualified_1, -- 20260616：当月门店拜访达成
       cast(nvl(month_sever_obj_m_1, 0) as BIGINT) as month_sever_obj_m_1,
       cast(nvl(month_shop_visit_valid_cnt_1, 0) as BIGINT) as month_shop_visit_valid_cnt_1,
       month_shop_visit_valid_rate_1,
       CASE WHEN (month_shop_visit_valid_rate_1 >= month_rate OR nvl(month_sever_obj_m_1, 0) = 0) THEN '达标' ELSE '未达标' END as month_shop_visit_valid_rate_qualified_1, -- 20260616：当月院线店拜访达成
       cast(nvl(month_hospital_sever_obj_m_1, 0) as BIGINT) as month_hospital_sever_obj_m_1,
       cast(nvl(month_hospital_visit_valid_cnt_1, 0) as BIGINT) as month_hospital_visit_valid_cnt_1,
       month_hospital_visit_valid_rate_1,
       CASE WHEN (month_hospital_visit_valid_rate_1 >= month_rate OR nvl(month_hospital_sever_obj_m_1, 0) = 0) THEN '达标' ELSE '未达标' END as month_hospital_visit_valid_rate_qualified_1
FROM user_info
LEFT JOIN mdson_target ON user_info.user_id = mdson_target.user_id AND user_info.data_month = mdson_target.data_month
LEFT JOIN user_summary_data ON user_info.user_id = user_summary_data.user_id AND user_info.data_month = user_summary_data.data_month
LEFT JOIN quar_rate ON regexp_replace(user_info.data_month, '-', '') = quar_rate.year_month_id
LEFT JOIN channel_type_cnt_user ON user_info.user_id = channel_type_cnt_user.user_id
LEFT JOIN user_discard ON user_info.user_id = user_discard.user_id AND user_info.data_month = user_discard.year_month
LEFT JOIN white_list_empno ON user_info.user_id = white_list_empno.user_id AND user_info.data_month = white_list_empno.year_month