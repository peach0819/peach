--本月订单信息
with cur_month_order as (
    select bd_service_info,
           service_info,
           pay_time,
           0 as refund_actual_amount,
           0 as refund_pickup_card_amount,
           case when is_pickup_recharge_order=1 then '1' else item_style end as item_style, --修改提货卡充值订单的商品类型为1
           total_pay_amount,
           pay_amount,
           nvl(pickup_card_amount,0) as pickup_card_amount,
           is_pickup_recharge_order,
           business_group_name,
           business_unit
    from ads_salary_base_cur_month_order_d
    lateral view explode(split(regexp_replace(ytdw.get_service_info('service_type:销售',service_info),'\},','\}\;'),'\;')) tmp as bd_service_info
    where dayid='$v_date'
    and is_spec_order!=1  --  剔除薪资特殊订单
    and sale_team_name in ('BD部','大客户部')

    union all

    select bd_service_info,
           service_info,
           pay_time,
           refund_actual_amount,
           refund_pickup_card_amount,
           case when is_pickup_recharge_order=1 then '1' else item_style end as item_style, --修改提货卡充值订单的商品类型为1
           0 as total_pay_amount,
           0 as pay_amount,
           0 as pickup_card_amount,
           is_pickup_recharge_order,
           business_group_name,
           business_unit
    from ads_salary_base_cur_month_refund_d
    lateral view explode(split(regexp_replace(ytdw.get_service_info('service_type:销售',service_info),'\},','\}\;'),'\;')) tmp as bd_service_info
    where dayid='$v_date'
    and is_spec_order!=1  --  剔除薪资特殊订单
    and sale_team_name in ('BD部','大客户部')
),

--员工离职信息
user as (
    select user_id,
           leave_time
    from dim_usr_user_d
    where dayid = '$v_date'
),

--销售人员信息（配置）
salary_user as (
    select user_name,
           is_split,
           is_coefficient
    from ads_salary_base_user_d
    where dayid = '$v_date'
),

--订单场景（配置）
salary_logical_scene as (
    select is_split,
           service_feature_names,
           service_feature_name,
           coefficient_logical
    from ads_salary_base_logical_scene_d
    where dayid = '$v_date'
),

order_tmp as (
    select ytdw.get_service_info('service_type:销售',cur_month_order.bd_service_info,'service_user_id') as service_user_id,
           cur_month_order.service_info,
           case when substr(cur_month_order.pay_time,1,8)  > substr(user.leave_time,1,8) then 1 else 0 end as is_leave,
           cur_month_order.item_style,
           salary_logical_scene.coefficient_logical,
           business_group_name,
           business_unit,

           --库内A类净GMV(提货卡口径)
           (case when cur_month_order.item_style=0 then cur_month_order.total_pay_amount else 0 end)
               -nvl(case when cur_month_order.item_style=0 then cur_month_order.refund_actual_amount else 0 end,0)
               -nvl(case when cur_month_order.item_style=0 then cur_month_order.pickup_card_amount else 0 end,0)
               +nvl(case when cur_month_order.item_style=0 then cur_month_order.refund_pickup_card_amount else 0 end,0)
           as a_pure_gmv,

           --库内A类净支付金额
           (case when cur_month_order.item_style=0 then cur_month_order.pay_amount else 0 end)
               -nvl(case when cur_month_order.item_style=0 then cur_month_order.refund_actual_amount else 0 end,0)
           as a_pure_pay_amount,

           --库内B类净GMV(提货卡口径)
           (case when cur_month_order.item_style=1 then cur_month_order.total_pay_amount else 0 end)
               -nvl(case when cur_month_order.item_style=1 then cur_month_order.refund_actual_amount else 0 end,0)
               -nvl(case when cur_month_order.item_style=1 then cur_month_order.pickup_card_amount else 0 end,0)
               +nvl(case when cur_month_order.item_style=1 then cur_month_order.refund_pickup_card_amount else 0 end,0)
           as b_pure_gmv,

           cur_month_order.is_pickup_recharge_order as is_pickup_recharge_order,

           --库内净GMV(提货卡口径)
           nvl(cur_month_order.total_pay_amount,0)
           -nvl(cur_month_order.refund_actual_amount,0)
           -nvl(cur_month_order.pickup_card_amount,0)
           +nvl(cur_month_order.refund_pickup_card_amount,0)
           as pure_gmv,

           --库内当月GMV(实货口径)
           nvl(case when cur_month_order.is_pickup_recharge_order=0 then cur_month_order.total_pay_amount else 0 end,0) as gmv_shihuo,

           --库内B类净GMV(实货口径)
           nvl((case when cur_month_order.item_style=1 and cur_month_order.is_pickup_recharge_order=0 then cur_month_order.total_pay_amount else 0 end),0)
           -nvl((case when cur_month_order.item_style=1 and cur_month_order.is_pickup_recharge_order=0 then cur_month_order.refund_actual_amount else 0 end),0)
           as b_pure_gmv_shihuo
    from cur_month_order
    left join user on user.user_id=ytdw.get_service_info('service_type:销售',cur_month_order.bd_service_info,'service_user_id')
    left join salary_user on salary_user.user_name=ytdw.get_service_info('service_type:销售',cur_month_order.bd_service_info,'service_user_name')
    left join salary_logical_scene on salary_logical_scene.is_split=salary_user.is_split
          and salary_logical_scene.service_feature_names=concat_ws(',',ytdw.get_service_info('service_type:销售',cur_month_order.service_info,'service_feature_name'),ytdw.get_service_info('service_type:电销',cur_month_order.service_info,'service_feature_name'))
          and salary_logical_scene.service_feature_name=ytdw.get_service_info('service_type:销售',cur_month_order.bd_service_info,'service_feature_name')
)

select service_user_id,
       sum(coefficient_actual_amount) as coefficient_summary,
       sum(case when item_style=0 then coefficient_actual_amount else 0 end) as a_coefficient_summary,
       sum(case when item_style=1 then coefficient_actual_amount else 0 end) as b_coefficient_summary,
       sum(case when item_style=0 and coefficient_actual_amount>0 then coefficient_actual_amount else a_pure_gmv end) as a_target_finish,
       sum(case when item_style=1 and coefficient_actual_amount>0 then coefficient_actual_amount else b_pure_gmv end) as b_target_finish,
       sum(case when is_pickup_recharge_order=1 then coefficient_actual_amount else 0 end) as pickup_card_coefficient_summary,
       sum(case when is_pickup_recharge_order=0 then coefficient_actual_amount else 0 end) as goods_coefficient_summary,
       sum(case when business_group_name in ('跨境奶纸','大贸奶纸') then a_pure_gmv else 0 end) as big_a_coefficient_summary,
       sum(case when business_group_name='跨境长尾' or business_unit in ('KA','品牌','美妆个护','长尾') then a_pure_gmv else 0 end),
       sum(case when business_group_name in ('跨境奶纸','大贸奶纸') then a_pure_pay_amount else 0 end) as big_a_coefficient_amount,
       sum(case when business_group_name='跨境长尾' or business_unit in ('KA','品牌','美妆个护','长尾') then a_pure_pay_amount else 0 end) as small_a_coefficient_amount
from (
    select service_user_id,
           item_style,
           a_pure_gmv,
           b_pure_gmv,
           a_pure_pay_amount,
           case when is_leave=1 then 0
                when coefficient_logical='0' then 0
                when coefficient_logical='库内净GMV(提货卡口径)' then pure_gmv
                when coefficient_logical='库内当月GMV(实货口径)' then gmv_shihuo
                when coefficient_logical='库内B类净GMV(提货卡口径)' then b_pure_gmv
                when coefficient_logical='库内B类净GMV(实货口径)' then b_pure_gmv_shihuo
                else 0 end as coefficient_actual_amount,

           --新增提货卡字段
           is_pickup_recharge_order,
           business_group_name,
           business_unit
    from order_tmp
) kn_total
group by service_user_id