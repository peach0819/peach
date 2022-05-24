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
           case when bounty_payout_object_id = 1 then 146 --战区经理
                when bounty_payout_object_id = 2 then 4   --大区经理
                when bounty_payout_object_id = 3 then 9   --BD主管
                when bounty_payout_object_id = 4 then 8   --BD
                end as job_id,
           if(bounty_payout_object_id IN (1,2,3), 'MANAGER', 'SALE') as data_type
    FROM dw_bounty_plan_schedule_d
    WHERE array_contains(split(forward_date, ','), '$v_date')
    AND ('$supply_mode' = 'not_supply' OR array_contains(split(supply_date, ','), '$supply_date'))
    AND bounty_rule_type = 5
),

user_admin as (
    SELECT dayid,
           user_id,
           job_id, --岗位
           virtual_group_id_lv3, --战区
           virtual_group_id_lv4, --大区
           virtual_group_id_lv5  --主管区域
    FROM dim_ytj_pub_user_admin_m
),

data as (
    SELECT
    FROM ads_salary_result_sale_d

    UNION ALL

    SELECT
    FROM ads_salary_result_manager_d
)

cur as (
    SELECT
    FROM plan
    CROSS JOIN user_admin ON plan.job_id = user_admin.job_id AND substr(plan.calculate_date, 0, 6) = user_admin.dayid
    INNER JOIN data ON data.dayid = plan.calculate_date AND data.data_type = plan.data_type
    WHERE ytdw.simple_expr(user_admin.virtual_group_id_lv3, 'in', war_area_value) = (case when war_area_operator = '=' then 1 else 0 end)
    AND ytdw.simple_expr(user_admin.virtual_group_id_lv4, 'in', bd_area_value) = (case when bd_area_operator = '=' then 1 else 0 end)
    AND ytdw.simple_expr(user_admin.virtual_group_id_lv5, 'in', manage_area_value) = (case when manage_area_operator = '=' then 1 else 0 end)
    AND ytdw.simple_expr(user_admin.user_id, 'in', filter_user_value) = (case when filter_user_operator = '=' then 1 else 0 end)
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

