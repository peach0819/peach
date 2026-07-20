--odps sql
--********************************************************************--
--author:quanru.wang4324(Role)
--create time:2024-11-18 16:02:25
--********************************************************************--
WITH mdson_user as (
    SELECT user_id,
           user_real_name,
           job_name,
           channel_name,
           department_charger_id,
           department_charger_name,
           dept_id,
           department_name,
           empno
    FROM dim_user_d
    WHERE dayid = '${v_date}'
    AND account_type = '1'
    AND is_deleted = 0
    AND dismiss_status = 0
    AND
),

mdson_service_obj as (
    SELECT service_obj_id,
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
           if_sepecial_service_obj
    FROM dim_service_obj_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
),

mdson_service_obj_sever as (
    SELECT store_code,
           server_code,
           server_name,
           job_name,
           extra_json
    FROM ads_service_obj_server_d
    WHERE dayid = '${v_date}'
),

mdson_visit as (
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
    FROM dw_crm_visit_record_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
    AND visit_status = 2
),

mdson_plan as (
    SELECT id,
           plan_type,
           service_obj_id,
           user_id,
           plan_status,
           start_time,
           create_time,
           content
    FROM dwd_crm_plan_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0 --and REGEXP_REPLACE(SUBSTR(start_time,1,7),'-','')='${v_cur_month}'
),

mdson_visit_summary as (
    SELECT mdson_visit.user_id,
           count(DISTINCT CASE WHEN visit_type = 1 THEN mdson_visit.id ELSE NULL END) as all_visit_m, --当月总拜访店次
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 THEN mdson_visit.id ELSE NULL END) as all_valid_visit_m, --当月有效拜访店次
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 THEN mdson_visit.service_obj_id ELSE NULL END) as all_valid_visit_obj_m, --当月有效拜访门店数
           count(DISTINCT CASE WHEN visit_type = 4 THEN mdson_visit.service_obj_id ELSE NULL END) as all_valid_visit_obj_fws_m, --当月服务商拜访数
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND if_nc_service_obj = 1 THEN mdson_visit.service_obj_id ELSE NULL END) as all_valid_visit_nc_obj_m, --当月NC有效拜访门店数
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND if_sepecial_service_obj = 1 AND time_lengeth >= 30 THEN mdson_visit.id ELSE NULL END) as all_valid_visit_spec_obj_m, --当月重点有效拜访店次
           round(sum(CASE WHEN visit_type = 1 THEN time_lengeth ELSE 0 END) / count(DISTINCT CASE WHEN visit_type = 1 THEN mdson_visit.id ELSE NULL END), 2) as avg_visit_time_length --当月平均在店时长
    FROM mdson_visit
    LEFT JOIN mdson_service_obj ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    WHERE if_virtual_service_obj = 0
    AND regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}'
    GROUP BY mdson_visit.user_id
),

mdson_plan_summary as (
    SELECT mdson_plan.user_id,
           count(DISTINCT CASE WHEN plan_type = 1 THEN mdson_plan.id ELSE NULL END) as all_visit_plan_m, --当月计划拜访店次(门店)
           count(DISTINCT CASE WHEN plan_type = 1 AND visit_status = 2 THEN mdson_plan.id ELSE NULL END) as all_vaild_visit_plan_m ----当月已完成计划拜访店次(门店)
    FROM mdson_plan
    LEFT JOIN mdson_visit ON mdson_plan.id = mdson_visit.plan_id
    LEFT JOIN mdson_service_obj ON mdson_plan.service_obj_id = mdson_service_obj.service_obj_id
    WHERE regexp_replace(substr(start_time, 1, 7), '-', '') = '${v_cur_month}'
    GROUP BY mdson_plan.user_id
),

mdson_service_obj_sever_summary as (
    SELECT mdson_user.user_id,
           count(DISTINCT CASE WHEN service_obj_type = 1 THEN service_obj_id ELSE NULL END) as user_sever_obj_m, --名下拜访门店数
           count(DISTINCT CASE WHEN service_obj_type = 3 THEN service_obj_id ELSE NULL END) as user_sever_fws_m, --名下拜访服务商数
           count(DISTINCT CASE WHEN service_obj_type = 1 AND if_nc_service_obj = 1 THEN service_obj_id ELSE NULL END) as user_sever_nc_obj_m --名下NC拜访门店数
    FROM mdson_service_obj_sever
    LEFT JOIN mdson_service_obj ON mdson_service_obj_sever.store_code = mdson_service_obj.service_obj_id
    LEFT JOIN mdson_user ON mdson_service_obj_sever.server_code = mdson_user.empno
    WHERE if_virtual_service_obj = 0
    GROUP BY mdson_user.user_id
),

mdson_taeget as (
    SELECT user_id,
           max(CASE WHEN indicator_id = 2 AND service_obj_type = 1 THEN actual_indicator_value ELSE 0 END) as visit_m_target, --当月目标拜访店次
           max(CASE WHEN indicator_id = 1 AND service_obj_type = 1 THEN actual_indicator_value ELSE 0 END) as visit_obi_m_target, --当月有效拜访门店数
           max(CASE WHEN indicator_id = 4 AND service_obj_type = 1 AND chain_id IN ('山姆', '孩子王') THEN actual_indicator_value ELSE 0 END) as visit_spec_obi_m_target, --当月重点门店目标拜访店次
           max(CASE WHEN indicator_id = 3 AND service_obj_type = 3 THEN actual_indicator_value ELSE 0 END) as visit_fws_m_target --当月服务商拜访数
    FROM dw_crm_user_visit_target_d
    WHERE dayid = '${v_cur_month}'
    AND regexp_replace(data_month, '-', '') = '${v_cur_month}'
    GROUP BY user_id
),

mdson_visit_summary_quar as (
    SELECT mdson_visit.user_id,
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 THEN mdson_visit.id ELSE NULL END) as all_valid_visit_m_quar, --季度有效拜访店次
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 THEN mdson_visit.service_obj_id ELSE NULL END) as all_valid_visit_obj_m_quar, --季度有效拜访门店数
           count(DISTINCT CASE WHEN visit_type = 4 THEN mdson_visit.service_obj_id ELSE NULL END) as all_valid_visit_obj_fws_m_quar, --季度服务商拜访数
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND if_nc_service_obj = 1 THEN mdson_visit.service_obj_id ELSE NULL END) as all_valid_visit_nc_obj_m_quar, --季度NC有效拜访门店数
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND if_ncm_service_obj = 1 AND time_lengeth >= 30 THEN mdson_visit.service_obj_id ELSE NULL END) as all_valid_visit_ncm_obj_m_quar, --季度NCM有效拜访门店数
           count(DISTINCT CASE WHEN visit_type = 1 AND visit_mode = 1 AND if_sepecial_service_obj = 1 AND time_lengeth >= 30 THEN mdson_visit.id ELSE NULL END) as all_valid_visit_spec_obj_m_quar, --季度重点有效拜访店次
           round(sum(CASE WHEN visit_type = 1 THEN time_lengeth ELSE 0 END) / count(DISTINCT CASE WHEN visit_type = 1 THEN mdson_visit.id ELSE NULL END), 2) as avg_visit_time_length_quar --季度平均在店时长
    FROM mdson_visit
    LEFT JOIN mdson_service_obj ON mdson_visit.service_obj_id = mdson_service_obj.service_obj_id
    WHERE if_virtual_service_obj = 0
    AND ceil(int(regexp_replace(substr(mdson_visit.visit_time, 5, 3), '-', '')) / 3) = ceil(int(substr('${v_cur_month}', 5, 2)) / 3)
    GROUP BY mdson_visit.user_id
),

user_reion_name as (
    SELECT mdson_user.user_id,
           region_name,
           sub_region_name,
           area_name
    FROM ads_sale_area_d a
    LEFT JOIN mdson_user ON a.user_code = mdson_user.empno
    WHERE a.dayid = '${v_date}'
),

--修改NCM相关指标
ncm_user as (
    SELECT user_id,
           ncm_id
    FROM ads_ncm_user_mapping_d
    WHERE dayid = '${v_date}'
),

ncm_service_nc_obj as (
    SELECT store_code, -- ncm 工号
           manager_person_code
    FROM dwd_r_ncinfo_d
    WHERE dayid = '${v_date}'
    AND nc_position IN ('NC')
    AND nc_status = '在职员工'
    AND store_status = '正常营业'
    AND nc_jobtype = '专职'
    AND store_code IS NOT NULL
),

ncm_service_spec_obj as (
    SELECT store_code,
           manager_person_code
    FROM dwd_mdson_nc_key_store_d
    WHERE pt = '${v_date}' -- 只保留当月数据
    AND regexp_replace(month_period, '-', '') = '${v_cur_month}'
),

store_service_obj_info as (
    SELECT out_service_obj_id,
           service_obj_id
    FROM dim_service_obj_d
    WHERE dayid = '${v_date}'
    AND service_obj_type = 1
),

mdson_ncm_nc_summary as (
    SELECT ncm_user.user_id,
           count(DISTINCT ncm_service_nc_obj.store_code) as user_sever_ncm_obj_m,
           count(DISTINCT mdson_visit.service_obj_id) as all_valid_visit_ncm_obj_m
    FROM ncm_service_nc_obj
    LEFT JOIN ncm_user ON ncm_service_nc_obj.manager_person_code = ncm_user.ncm_id
    LEFT JOIN store_service_obj_info ON ncm_service_nc_obj.store_code = store_service_obj_info.out_service_obj_id
    LEFT JOIN (
        SELECT DISTINCT service_obj_id,
               user_id
        FROM mdson_visit
        WHERE regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}'
        AND visit_type = 1
        AND visit_mode = 1
        AND time_lengeth >= 30
    ) mdson_visit ON ncm_user.user_id = mdson_visit.user_id AND store_service_obj_info.service_obj_id = mdson_visit.service_obj_id
    GROUP BY ncm_user.user_id
),

mdson_ncm_spec_summary as (
    SELECT ncm_user.user_id,
           count(DISTINCT ncm_service_spec_obj.store_code) as user_sever_ncm_spec_obj_m,
           count(DISTINCT mdson_visit.service_obj_id) as all_valid_visit_ncm_spec_obj_m
    FROM ncm_service_spec_obj
    LEFT JOIN ncm_user ON ncm_service_spec_obj.manager_person_code = ncm_user.ncm_id
    LEFT JOIN store_service_obj_info ON ncm_service_spec_obj.store_code = store_service_obj_info.out_service_obj_id
    LEFT JOIN (
        SELECT DISTINCT service_obj_id,
               user_id
        FROM mdson_visit
        WHERE regexp_replace(substr(mdson_visit.visit_time, 1, 7), '-', '') = '${v_cur_month}'
        AND visit_type = 1
        AND visit_mode = 1
        AND time_lengeth >= 30
    ) mdson_visit ON ncm_user.user_id = mdson_visit.user_id AND store_service_obj_info.service_obj_id = mdson_visit.service_obj_id
    GROUP BY ncm_user.user_id
)

INSERT OVERWRITE TABLE ads_mdspn_user_cur_month_summary_di PARTITION (dayid = '${v_cur_month}')
SELECT mdson_user.user_id,
       user_real_name,
       job_name,
       channel_name,
       department_charger_id,
       department_charger_name,
       dept_id,
       department_name,
       region_name,
       sub_region_name,
       cast(nvl(all_visit_m, 0) as INT) as all_visit_m,
       cast(nvl(all_valid_visit_m, 0) as INT) as all_valid_visit_m,
       round(nvl(all_valid_visit_m, 0) / all_visit_m, 4) as valid_visit_m_pre, --当月有效拜访率
       cast(nvl(all_visit_plan_m, 0) as INT) as all_visit_plan_m,
       cast(nvl(all_vaild_visit_plan_m, 0) as INT) as all_vaild_visit_plan_m,
       round(nvl(all_vaild_visit_plan_m, 0) / nvl(all_visit_plan_m, 0), 4) as valid_plan_m_pre, --当月计划拜访门店完成率
       cast(visit_m_target as INT) as visit_m_target,
       round(nvl(all_valid_visit_m, 0) / visit_m_target, 4) as target_visit_m_pre, --当月门店拜访频次达标率
       cast(user_sever_obj_m as INT) as user_sever_obj_m,
       cast(nvl(all_valid_visit_obj_m, 0) as INT) as all_valid_visit_obj_m,
       round(all_valid_visit_obj_m / user_sever_obj_m, 4) as valid_visit_obj_m_pre, --当月门店拜访覆盖率
       cast(user_sever_fws_m as INT) as user_sever_fws_m,
       cast(nvl(all_valid_visit_obj_fws_m, 0) as INT) as all_valid_visit_obj_fws_m,
       round(all_valid_visit_obj_fws_m / user_sever_fws_m, 4) as valid_visit_obj_fws_m_pre, --当月服务商拜访覆盖率
       cast(user_sever_nc_obj_m as INT) as user_sever_nc_obj_m,
       cast(nvl(all_valid_visit_nc_obj_m, 0) as INT) as all_valid_visit_nc_obj_m,
       round(all_valid_visit_nc_obj_m / user_sever_nc_obj_m, 4) as valid_visit_nc_obj_m_pre, --当月NC门店拜访覆盖率
       cast(user_sever_ncm_obj_m as INT) as user_sever_ncm_obj_m,
       cast(all_valid_visit_ncm_obj_m as INT) as all_valid_visit_ncm_obj_m,
       round(all_valid_visit_ncm_obj_m / user_sever_ncm_obj_m, 4) as valid_visit_ncm_obj_m_pre, --当月NCM门店拜访覆盖率
       cast(visit_spec_obi_m_target as INT) as visit_spec_obi_m_target,
       CASE WHEN job_name IN ('NCM') THEN cast(all_valid_visit_ncm_spec_obj_m as INT) ELSE cast(all_valid_visit_spec_obj_m as INT) END as all_valid_visit_spec_obj_m,
       CASE WHEN job_name IN ('NCM') THEN round(all_valid_visit_ncm_spec_obj_m / user_sever_ncm_spec_obj_m, 4) ELSE round(all_valid_visit_spec_obj_m / visit_spec_obi_m_target, 4) END as valid_visit_spec_obj_m_pre, --当月重点门店拜访频次达成率
       avg_visit_time_length,
       cast(all_valid_visit_m_quar as INT) as all_valid_visit_m_quar,
       cast(all_valid_visit_obj_fws_m_quar as INT) as all_valid_visit_obj_fws_m_quar,
       round(all_valid_visit_obj_fws_m_quar / user_sever_fws_m, 4) as valid_visit_obj_fws_m_quar_pre, --季度服务商拜访覆盖率
       CASE WHEN channel_name IN ('NKA', 'RKA', 'LKA', 'COT', 'KA') -- ('NKA','RKA','LKA')  -- 20260311接通知NKA更名为COT，删除LKA、RKA(保留)=>新增KA
 AND job_name IN ('城市渠道负责人', '地区渠道负责人', '省区渠道负责人') AND round(all_valid_visit_m / visit_m_target, 4) >= round(dayofmonth(to_date('${v_date}', 'yyyymmdd')) / dayofmonth(last_day(to_date('${v_date}', 'yyyymmdd'))), 4) AND round(all_valid_visit_nc_obj_m / user_sever_nc_obj_m, 4) >= round(dayofmonth(to_date('${v_date}', 'yyyymmdd')) / dayofmonth(last_day(to_date('${v_date}', 'yyyymmdd'))), 4) THEN '达标'
            WHEN channel_name IN ('GT') AND job_name IN ('城市渠道负责人', '地区渠道负责人', '省区渠道负责人') AND round(all_valid_visit_obj_m / 30, 4) >= round(dayofmonth(to_date('${v_date}', 'yyyymmdd')) / dayofmonth(last_day(to_date('${v_date}', 'yyyymmdd'))), 4) AND round(all_valid_visit_obj_fws_m / 5, 4) >= round(dayofmonth(to_date('${v_date}', 'yyyymmdd')) / dayofmonth(last_day(to_date('${v_date}', 'yyyymmdd'))), 4) THEN '达标'
            WHEN channel_name IN ('GT') AND job_name IN ('服务商销售代表') AND round(all_valid_visit_obj_m / 30, 4) >= round(dayofmonth(to_date('${v_date}', 'yyyymmdd')) / dayofmonth(last_day(to_date('${v_date}', 'yyyymmdd'))), 4) THEN '达标'
            WHEN job_name IN ('NCM') AND round(all_valid_visit_ncm_obj_m / user_sever_ncm_obj_m, 4) >= round(dayofmonth(to_date('${v_date}', 'yyyymmdd')) / dayofmonth(last_day(to_date('${v_date}', 'yyyymmdd'))), 4) AND round(all_valid_visit_ncm_spec_obj_m / user_sever_ncm_spec_obj_m, 4) >= round(dayofmonth(to_date('${v_date}', 'yyyymmdd')) / dayofmonth(last_day(to_date('${v_date}', 'yyyymmdd'))), 4) THEN '达标'
            WHEN job_name NOT IN ('城市渠道负责人', '地区渠道负责人', '省区渠道负责人', '服务商销售代表', 'NCM') AND round(all_valid_visit_m / visit_m_target, 4) >= round(dayofmonth(to_date('${v_date}', 'yyyymmdd')) / dayofmonth(last_day(to_date('${v_date}', 'yyyymmdd'))), 4) THEN '达标'
            WHEN round(all_valid_visit_m / visit_m_target, 4) >= round(dayofmonth(to_date('${v_date}', 'yyyymmdd')) / dayofmonth(last_day(to_date('${v_date}', 'yyyymmdd'))), 4) THEN '达标'
            ELSE '未达标' END as if_visit_qualified,
       '${v_opt_month}' as data_month
FROM mdson_user
LEFT JOIN mdson_visit_summary ON mdson_user.user_id = mdson_visit_summary.user_id
LEFT JOIN mdson_plan_summary ON mdson_user.user_id = mdson_plan_summary.user_id
LEFT JOIN mdson_service_obj_sever_summary ON mdson_user.user_id = mdson_service_obj_sever_summary.user_id
LEFT JOIN mdson_taeget ON mdson_user.user_id = mdson_taeget.user_id
LEFT JOIN mdson_visit_summary_quar ON mdson_user.user_id = mdson_visit_summary_quar.user_id
LEFT JOIN user_reion_name ON mdson_user.user_id = user_reion_name.user_id
LEFT JOIN mdson_ncm_nc_summary ON mdson_user.user_id = mdson_ncm_nc_summary.user_id
LEFT JOIN mdson_ncm_spec_summary ON mdson_user.user_id = mdson_ncm_spec_summary.user_id