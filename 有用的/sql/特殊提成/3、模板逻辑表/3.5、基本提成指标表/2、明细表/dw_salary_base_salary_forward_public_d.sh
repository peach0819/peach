v_date=$1
supply_date=$4
supply_mode='not_supply'

if [[ $supply_date != "" ]]
then
  supply_mode='supply'
fi

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;

with plan as (
    SELECT *,
           get_json_object(get_json_object(filter_config_json,'$.war_area'),'$.value') as war_area_value,
           get_json_object(get_json_object(filter_config_json,'$.war_area'),'$.operator') as war_area_operator,
           get_json_object(get_json_object(filter_config_json,'$.bd_area'),'$.value') as bd_area_value,
           get_json_object(get_json_object(filter_config_json,'$.bd_area'),'$.operator') as bd_area_operator,
           get_json_object(get_json_object(filter_config_json,'$.manage_area'),'$.value') as manage_area_value,
           get_json_object(get_json_object(filter_config_json,'$.manage_area'),'$.operator') as manage_area_operator,
           replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),',')[0],'[',''),'\"',''),'-','') as calculate_date,
           get_json_object(get_json_object(filter_config_json,'$.filter_user'),'$.value') as filter_user_value,
           get_json_object(get_json_object(filter_config_json,'$.filter_user'),'$.operator') as filter_user_operator,
           get_json_object(get_json_object(filter_config_json,'$.dept'),'$.value') as dept_value,
           get_json_object(get_json_object(filter_config_json,'$.dept'),'$.operator') as dept_operator,

           --岗位
           case when bounty_payout_object_id = 1 then 146 --战区经理
                when bounty_payout_object_id = 2 then 4   --大区经理
                when bounty_payout_object_id = 3 then 9   --BD主管
                when bounty_payout_object_id = 4 then 8   --BD
                end as job_id,

           --数据类型 （取基本提成主管表还是销售表）
           if(bounty_payout_object_id IN (1,2,3), 'MANAGER', 'SALE') as data_type,

           --CRM工作室指标名
           case when bounty_payout_object_id IN (4) AND bounty_indicator_code = 'B_PFM_RATE_NO_C' then 'class_b_capacity'
                when bounty_payout_object_id IN (4) AND bounty_indicator_code = 'B_SHIHUO_RATE_NO_C' then 'class_b_capacity_pure'
                when bounty_payout_object_id IN (1,2,3) AND bounty_indicator_code = 'B_PFM_RATE_NO_C' then 'class_b_area_nonebig_nonesp'
                when bounty_payout_object_id IN (1,2,3) AND bounty_indicator_code = 'B_SHIHUO_RATE_NO_C' then 'class_b_area_pure'
           end as kpi_indicator_type
    FROM dw_bounty_plan_schedule_d
    WHERE array_contains(split(forward_date, ','), '$v_date')
    AND ('$supply_mode' = 'not_supply' OR array_contains(split(supply_date, ','), '$supply_date'))
    AND bounty_rule_type = 5
),

area as (
    SELECT area_id,
           area_name,
           area_type
    FROM st_sales_area_snapshot_d
    WHERE dayid = '$v_date'
),

user_admin as (
    SELECT a.user_id,
           a.user_real_name,
           a.dept_id,
           a.dept_name,
           a.job_id, --岗位
           war.area_id as war_area_id,         --战区
           bd.area_id as bd_area_id,           --大区
           manager.area_id as manager_area_id  --主管区域
    FROM dim_ytj_pub_user_admin_m a
    LEFT JOIN area war ON a.virtual_group_name_lv3 = war.area_name AND war.area_type = 2
    LEFT JOIN area bd ON a.virtual_group_name_lv4 = bd.area_name AND bd.area_type = 1
    LEFT JOIN area manager ON a.virtual_group_name_lv5 = manager.area_name AND manager.area_type = 3
    WHERE dayid = '$v_cur_month'
),

data as (
    SELECT dayid,
           'SALE' as data_type,
           service_user_id as user_id,
           leave_time,
           b_coefficient_summary as b_pfm, --B类业绩口径目标完成值
           gmv_shihuo as b_shihuo          --B类实货口径目标完成值
    FROM ads_salary_result_sale_d

    UNION ALL

    SELECT dayid,
           'MANAGER' as data_type,
           user_id,
           null as leave_time,
           pure_b_gmv as b_pfm, --B类业绩口径目标完成值
           pure_b_gmv_shihuo as b_shihuo  --B类实货口径目标完成值
    FROM ads_salary_result_manager_d
),

target as (
    select t.user_id,
           t.indicator,
           t.target,
           substr(a.start_time, 0, 8) as start_time,
           substr(a.end_time, 0, 8) as end_time
    from (SELECT * FROM dwd_kpi_indicator_target_d WHERE dayid = '$v_date' and is_deleted = 0) t
    INNER JOIN (SELECT * FROM dwd_kpi_assessment_d WHERE dayid = '$v_date' AND is_deleted = 0 AND status IN (2,3)) a ON t.assessment_id = a.id
),

cur as (
    SELECT plan.no as planno,
           plan.month as plan_month,
           from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
           from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,
           plan.bounty_payout_object_name as grant_object_type,
           user_admin.user_id as grant_object_user_id,
           user_admin.user_real_name as grant_object_user_name,
           user_admin.dept_id as grant_object_dept_id,
           user_admin.dept_name as grant_object_dept_name,
           data.leave_time as leave_time,

           --指标计算
           plan.bounty_indicator_name as sts_target_name,
           ((case when plan.bounty_indicator_code = 'B_PFM_RATE_NO_C' then data.b_pfm
                  when plan.bounty_indicator_code = 'B_SHIHUO_RATE_NO_C' then data.b_shihuo
                  end)
             / max(target.target)) * 100 as sts_target,

           --冗余字段
           to_json(named_struct(
               'b_pfm', data.b_pfm,
               'b_shihuo', data.b_shihuo,
               'target', nvl(max(target.target), 0)
           )) as extra
    FROM plan
    CROSS JOIN user_admin ON plan.job_id = user_admin.job_id
    INNER JOIN data ON data.dayid = least(plan.calculate_date, '$v_date') AND data.data_type = plan.data_type AND user_admin.user_id = data.user_id
    LEFT JOIN target ON plan.calculate_date <= target.end_time AND plan.calculate_date >= target.start_time AND user_admin.user_id = target.user_id AND plan.kpi_indicator_type = target.indicator
    WHERE ytdw.simple_expr(user_admin.war_area_id, 'in', war_area_value) = (case when war_area_operator = '=' then 1 else 0 end)
    AND ytdw.simple_expr(user_admin.bd_area_id, 'in', bd_area_value) = (case when bd_area_operator = '=' then 1 else 0 end)
    AND ytdw.simple_expr(user_admin.manager_area_id, 'in', manage_area_value) = (case when manage_area_operator = '=' then 1 else 0 end)
    AND ytdw.simple_expr(user_admin.user_id, 'in', filter_user_value) = (case when filter_user_operator = '=' then 1 else 0 end)
    AND ytdw.simple_expr(user_admin.dept_id, 'in', dept_value) = (case when dept_operator = '=' then 1 else 0 end)
    GROUP BY plan.no,
             plan.month,
             plan.bounty_payout_object_name,
             plan.bounty_indicator_code,
             user_admin.user_id,
             user_admin.user_real_name,
             user_admin.dept_id,
             user_admin.dept_name,
             data.leave_time,
             plan.bounty_indicator_name,
             data.b_pfm,
             data.b_shihuo
)

insert overwrite table dw_salary_base_salary_public_d partition (dayid='$v_date',pltype='cur')
SELECT planno,
       plan_month,
       update_time,
       update_month,
       grant_object_type,
       grant_object_user_id,
       grant_object_user_name,
       grant_object_dept_id,
       grant_object_dept_name,
       leave_time,
       sts_target_name,
       sts_target,
       extra
FROM cur

UNION ALL

SELECT planno,
       plan_month,
       update_time,
       update_month,
       grant_object_type,
       grant_object_user_id,
       grant_object_user_name,
       grant_object_dept_id,
       grant_object_dept_name,
       leave_time,
       sts_target_name,
       sts_target,
       extra
FROM (
    SELECT *
    FROM dw_salary_base_salary_public_d
    WHERE dayid = '$v_date'
    AND pltype='cur'
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null
;
" &&

exit 0