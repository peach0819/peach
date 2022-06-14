v_date=$1
supply_date=$4
supply_mode='not_supply'
pltype=$5

if [[ $pltype = "" ]]
then
	pltype='cur'
fi

if [[ $supply_date != "" ]]
then
  supply_mode='supply'
fi

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;

with plan as (
    SELECT no,
           month,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.payout_object_type'),'$.value'),'\"',''),'[',''),']','') as payout_object_type,
           if('$pltype' = 'cur', '$v_date', split(backward_date, ',')[0]) as plan_date,
           bounty_payout_object_code,
           get_json_object(get_json_object(filter_config_json,'$.filter_user'),'$.value') as filter_user_value,
           get_json_object(get_json_object(filter_config_json,'$.filter_user'),'$.operator') as filter_user_operator,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.grant_user'),'$.value'),'\"',''),'[',''),']','') as grant_user
    FROM dw_bounty_plan_schedule_d
    WHERE bounty_rule_type = 4
    AND array_contains(split(if('$pltype' = 'cur', forward_date, backward_date), ','), '$v_date')
    AND ('$supply_mode' = 'not_supply' OR array_contains(split(supply_date, ','), '$supply_date'))
),

compare_data as (
    SELECT planno,
           shop_id,
           shop_name,
           brand_id
    FROM dw_salary_brand_shop_compare_shop_sum_d compare_shop_sum
    INNER JOIN plan ON plan.no = compare_shop_sum.planno AND compare_shop_sum.dayid = plan.plan_date
    WHERE is_valid_brand = 1
),

current_data as (
    SELECT planno,
           shop_id,
           shop_name,
           brand_id,
           grant_object_user_id,
           total_gmv_less_refund
    FROM dw_salary_brand_shop_current_shop_sum_d
    WHERE dayid = '$v_date'
    AND pltype = '$pltype'
),

--参与计算的门店， 取当前周期、比对周期 门店合集
shop as (
    SELECT distinct planno, shop_id, shop_name
    FROM (
        SELECT planno, shop_id, shop_name FROM compare_data
        UNION ALL
        SELECT planno, shop_id, shop_name FROM current_data
    ) t
),

shop_service as (
    SELECT * FROM dim_hpc_shp_shop_service_d
),

--发放对象为冻结的方案涉及的人员
frozen_plan_user as (
    SELECT distinct planno, shop_id, grant_object_user_id, is_kn_sale_user
    FROM (
        SELECT distinct current_data.planno,
                        current_data.shop_id,
                        current_data.grant_object_user_id,
                        if(current_data.grant_object_user_id = shop_service.shop_service_bd_id, '库内', '非库内') as is_kn_sale_user
        FROM current_data
        INNER JOIN plan ON current_data.planno = plan.no AND plan.payout_object_type = '冻结'
        LEFT JOIN shop_service ON current_data.shop_id = shop_service.shop_id AND shop_service.dayid = plan.plan_date

        UNION ALL

        SELECT distinct plan.no as planno,
                        shop.shop_id,
                        shop_service.shop_service_bd_id as grant_object_user_id,
                        '库内' as is_kn_sale_user
        FROM shop
        INNER JOIN plan ON shop.planno = plan.no AND plan.payout_object_type = '冻结'
        LEFT JOIN shop_service ON shop.shop_id = shop_service.shop_id AND plan.plan_date = shop_service.dayid
    ) t
),

--发放对象为库内的方案涉及的人员, 取当前周期发放对象即可
kn_plan_user as (
    SELECT distinct planno, shop_id, grant_object_user_id, is_kn_sale_user
    FROM (
        SELECT distinct current_data.planno,
                        current_data.shop_id,
                        current_data.grant_object_user_id,
                        '库内' as is_kn_sale_user
        FROM current_data
        INNER JOIN plan ON current_data.planno = plan.no AND plan.payout_object_type = '库内'

        UNION ALL

        SELECT distinct plan.no as planno,
                        shop.shop_id,
                        case when plan.bounty_payout_object_code= 'WAR_ZONE_MANAGE' then shop_service.shop_theater_manager_id
                             when plan.bounty_payout_object_code= 'AREA_MANAGER' then shop_service.shop_region_manager_id
                             when plan.bounty_payout_object_code= 'BD_MANAGER' then shop_service.shop_supervisor_id
                             when plan.bounty_payout_object_code= 'BD' then shop_service.shop_service_bd_id
                             when plan.bounty_payout_object_code= 'GRANT_USER' then plan.grant_user
                        end as grant_object_user_id,
                        '库内' as is_kn_sale_user
        FROM shop
        INNER JOIN plan ON shop.planno = plan.no AND plan.payout_object_type = '库内'
        LEFT JOIN shop_service ON shop.shop_id = shop_service.shop_id AND plan.plan_date = shop_service.dayid
    ) t
),

--人员离职状态
user_admin as (
    SELECT user_id,
           dismiss_status,
           leave_time,
           start_time,
           end_time,
           job_id,
           job_name
    FROM dim_ytj_pub_user_admin_ds
),

cur as (
    SELECT from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
           from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,
           plan.no as planno,
           plan.month as plan_month,
           shop.shop_id,
           shop.shop_name,
           if(plan.bounty_payout_object_code = 'BD' AND user_admin.job_id != 8, null, plan_user.grant_object_user_id) as grant_object_user_id,
           plan_user.is_kn_sale_user,
           if(user_admin.dismiss_status = 0, '否', '是') as is_leave,
           user_admin.leave_time,
           if(user_admin.dismiss_status = 0, ifnull(count(distinct compare_data.brand_id), 0), 0) as compare_brand_shop_num,
           if(user_admin.dismiss_status = 0, ifnull(count(distinct current_data.brand_id), 0), 0) as current_brand_shop_num,
           sum(current_data.total_gmv_less_refund) as total_gmv_less_refund,

           plan.filter_user_value,
           plan.filter_user_operator
    FROM plan
    INNER JOIN shop ON plan.no = shop.planno
    INNER JOIN (
        SELECT planno, shop_id, grant_object_user_id, is_kn_sale_user FROM frozen_plan_user
        UNION ALL
        SELECT planno, shop_id, grant_object_user_id, is_kn_sale_user FROM kn_plan_user
    ) plan_user ON shop.planno = plan_user.planno AND shop.shop_id = plan_user.shop_id
    LEFT JOIN user_admin ON user_admin.user_id = plan_user.grant_object_user_id AND user_admin.start_time <= concat(plan.plan_date, '235959') AND user_admin.end_time >= concat(plan.plan_date, '235959')
    LEFT JOIN compare_data ON plan_user.planno = compare_data.planno and compare_data.shop_id = plan_user.shop_id
    LEFT JOIN current_data ON plan_user.planno = current_data.planno and current_data.shop_id = plan_user.shop_id AND current_data.grant_object_user_id = plan_user.grant_object_user_id
    GROUP BY plan.no,
             plan.month,
             shop.shop_id,
             shop.shop_name,
             plan_user.grant_object_user_id,
             plan_user.is_kn_sale_user,
             user_admin.dismiss_status,
             user_admin.leave_time,
             user_admin.job_id,
             plan.filter_user_value,
             plan.filter_user_operator
    HAVING ytdw.simple_expr(grant_object_user_id, 'in', filter_user_value) = (case when filter_user_operator = '=' then 1 else 0 end)
)

insert overwrite table dw_salary_brand_shop_sum_d partition (dayid='$v_date', pltype='$pltype')
SELECT planno,
       plan_month,
       update_time,
       update_month,
       shop_id,
       shop_name,
       grant_object_user_id,
       is_kn_sale_user,
       is_leave,
       leave_time,
       compare_brand_shop_num,
       current_brand_shop_num,
       total_gmv_less_refund,
       if(current_brand_shop_num = 1 AND compare_brand_shop_num = 0, 0, current_brand_shop_num - compare_brand_shop_num) as brand_shop_score
FROM cur
WHERE grant_object_user_id is not null
AND grant_object_user_id != ''

UNION ALL

SELECT planno,
       plan_month,
       update_time,
       update_month,
       shop_id,
       shop_name,
       grant_object_user_id,
       is_kn_sale_user,
       is_leave,
       leave_time,
       compare_brand_shop_num,
       current_brand_shop_num,
       total_gmv_less_refund,
       brand_shop_score
FROM (
    SELECT *
    FROM dw_salary_brand_shop_sum_d
    WHERE dayid = '$v_date'
    AND pltype = '$pltype'
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null
;
" &&

exit 0