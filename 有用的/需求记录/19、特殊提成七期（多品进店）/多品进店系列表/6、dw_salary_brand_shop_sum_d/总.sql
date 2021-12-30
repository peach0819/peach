use ytdw;

with plan as (
    SELECT no,
           month,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.payout_object_type'),'$.value'),'\"',''),'[',''),']','') as payout_object_type
    FROM dw_bounty_plan_schedule_d
    WHERE dayid = '$v_date'
    AND array_contains(split(forward_date, ','), '$v_date')
    AND bounty_rule_type = 4
),

compare_data as (
    SELECT planno,
           shop_id,
           shop_name,
           brand_id
    FROM dw_salary_brand_shop_compare_shop_sum_d
    WHERE dayid = '$v_date'
    AND is_valid_brand = 1
),

current_data as (
    SELECT planno,
           shop_id,
           shop_name,
           brand_id,
           grant_object_user_id
    FROM dw_salary_brand_shop_current_shop_sum_d
    WHERE dayid = '$v_date'
    AND pltype = 'cur'
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
        LEFT JOIN (SELECT * FROM dim_hpc_shp_shop_service_d WHERE dayid  = '$v_date') shop_service ON current_data.shop_id = shop_service.shop_id

        UNION ALL

        SELECT distinct current_data.planno,
                        current_data.shop_id,
                        shop_service.shop_service_bd_id as grant_object_user_id,
                        '库内' as is_kn_sale_user
        FROM current_data
        INNER JOIN plan ON current_data.planno = plan.no AND plan.payout_object_type = '冻结'
        INNER JOIN (SELECT * FROM dim_hpc_shp_shop_service_d WHERE dayid  = '$v_date') shop_service ON current_data.shop_id = shop_service.shop_id and shop_service.shop_service_bd_id is not null
    ) t
),

--发放对象为库内的方案涉及的人员, 取当前周期发放对象即可
kn_plan_user as (
    SELECT distinct current_data.planno,
                    current_data.shop_id,
                    current_data.grant_object_user_id,
                    '库内' as is_kn_sale_user
    FROM current_data
    INNER JOIN plan ON current_data.planno = plan.no AND plan.payout_object_type = '库内'
),

--人员离职状态
user_admin as (
    SELECT user_id,
           dismiss_status,
           leave_time
    FROM dim_ytj_pub_user_admin_ds
    WHERE start_time <= concat('$v_date', '235959')
    AND end_time >= concat('$v_date', '235959')
),

cur as (
    SELECT from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
           from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,
           plan.no as planno,
           plan.month as plan_month,
           shop.shop_id,
           shop.shop_name,
           plan_user.grant_object_user_id,
           plan_user.is_kn_sale_user,
           if(user_admin.dismiss_status = 0, '否', '是') as is_leave,
           user_admin.leave_time,
           if(user_admin.dismiss_status = 0, ifnull(count(distinct compare_data.brand_id), 0), 0) as compare_brand_shop_num,
           if(user_admin.dismiss_status = 0, ifnull(count(distinct current_data.brand_id), 0), 0) as current_brand_shop_num
    FROM plan
    INNER JOIN shop ON plan.no = shop.planno
    INNER JOIN (
        SELECT planno, shop_id, grant_object_user_id, is_kn_sale_user FROM frozen_plan_user
        UNION ALL
        SELECT planno, shop_id, grant_object_user_id, is_kn_sale_user FROM kn_plan_user
    ) plan_user ON shop.planno = plan_user.planno AND shop.shop_id = plan_user.shop_id
    LEFT JOIN user_admin ON user_admin.user_id = plan_user.grant_object_user_id
    LEFT JOIN compare_data ON plan_user.planno = compare_data.planno and compare_data.shop_id = plan_user.shop_id
    LEFT JOIN current_data ON plan_user.planno = current_data.planno and current_data.shop_id = plan_user.shop_id AND current_data.grant_object_user_id = plan_user.grant_object_user_id
    GROUP BY plan.no,
             plan.month,
             shop.shop_id,
             shop.shop_name,
             plan_user.grant_object_user_id,
             plan_user.is_kn_sale_user,
             user_admin.dismiss_status
)

insert overwrite table dw_salary_brand_shop_sum_d partition (dayid='$v_date', pltype='cur')
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
       current_brand_shop_num
FROM cur