with plan as (
    SELECT *,
           if(payout_rule_type = 3, '实物', '金额') as commission_reward_type,
           case when payout_rule_type = 1 then '累计阶梯返现'
                when payout_rule_type = 2 then '累计阶梯返点'
                when payout_rule_type = 3 then '累计阶梯返实物'
                when payout_rule_type = 4 then '累计阶梯单价返点'
                when payout_rule_type = 5 then '排名返现'
                end as commission_plan_type,
           replace(replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),']',''),'\"',''),'[',''),',','~') as plan_pay_time,

           --CRM工作室指标名
           case when bounty_payout_object_id IN (4) AND bounty_indicator_code = 'SIGN_BRAND_GMV_RATE' then 'class_b_capacity_pure'
                when bounty_payout_object_id IN (1,2,3) AND bounty_indicator_code = 'SIGN_BRAND_GMV_RATE' then 'class_b_area_pure'
           end as kpi_indicator_type,

           replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),',')[0],'[',''),'\"',''),'-','') as calculate_date_value_start,
           replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),',')[1],']',''),'\"',''),'-','') as calculate_date_value_end
    FROM yt_crm.dw_bounty_plan_schedule_d
    WHERE array_contains(split(backward_date, ','), '${v_date}')
    AND ('@@{supply_mode}' = 'not_supply' OR array_contains(split(supply_date, ','), '${supply_date}'))
    AND bounty_rule_type = 3
),

detail as (
    SELECT planno,
           grant_object_user_id,
           grant_object_user_name,
           grant_object_user_dep_id,
           grant_object_user_dep_name,
           leave_time,
           count(distinct if(is_leave='否' and is_succ_sign='是', shop_id, null)) as sign_shop_count,
           count(distinct if(is_leave='否' and is_succ_sign='是', concat(shop_id, '_', brand_id), null)) as sign_shop_brand_count,
           sum(if(is_leave='否' and is_succ_sign='是', gmv_less_refund, 0)) as gmv_less_refund,
           sum(if(is_leave='否' and is_succ_sign='是', pay_amount_less_refund, 0)) as pay_amount_less_refund
    FROM yt_crm.dw_salary_sign_brand_rule_public_d
    WHERE dayid = '${v_date}'
    AND pltype = 'pre'
    group by planno,
             grant_object_user_id,
             grant_object_user_name,
             grant_object_user_dep_id,
             grant_object_user_dep_name,
             leave_time
),

underling as (
    select user_id, max(underling_cnt) as underling_cnt, dayid
    from ytdw.dws_usr_bd_manager_underling_d
    where dayid > '0'
    group by user_id, dayid
),

target as (
    select t.user_id,
           t.indicator,
           t.target,
           substr(a.start_time, 0, 8) as start_time,
           substr(a.end_time, 0, 8) as end_time
    from (SELECT * FROM ytdw.dwd_kpi_indicator_target_d WHERE dayid = '${v_date}' and is_deleted = 0) t
    INNER JOIN (SELECT * FROM ytdw.dwd_kpi_assessment_d WHERE dayid = '${v_date}' AND is_deleted = 0 AND status IN (2,3)) a ON t.assessment_id = a.id
),

plan_user_target as (
    SELECT plan.no as plan_no,
           target.user_id as user_id,
           max(target.target) as target
    FROM plan
    INNER JOIN target ON plan.calculate_date_value_start <= target.end_time AND plan.calculate_date_value_end >= target.start_time AND plan.kpi_indicator_type = target.indicator
    group by plan.no,
             target.user_id
),

cur as (
    select from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
           from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,

           --方案基础信息
           plan.month as plan_month,
           plan.plan_pay_time,
           plan.no as planno,
           plan.name as plan_name,
           plan.biz_group_id as plan_group_id,
           plan.biz_group_name as plan_group_name,
           plan.bounty_payout_object_name as grant_object_type,
           plan.bounty_indicator_name as sts_target_name,
           plan.payout_upper_limit as commission_cap,
           plan.payout_config_json,
           plan.payout_rule_type,
           plan.commission_reward_type,
           plan.commission_plan_type,

           --方案数据
           detail.grant_object_user_id,
           detail.grant_object_user_name,
           detail.grant_object_user_dep_id,
           detail.grant_object_user_dep_name,
           detail.leave_time,

           --统计指标
           nvl(underling.underling_cnt,1) as grant_object_underling_cnt,
           case when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_3_NEW_SING_SHOPS' then detail.sign_shop_count  --'统计指标名称为新签门店数'
                when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_3_NEW_SING_BRAND_SHOPS' then detail.sign_shop_brand_count  --统计指标名称为新签品牌门店数'
                when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_3_ACC_NEW_SING_GMV' then detail.gmv_less_refund  --'统计指标名称为新签GMV'
                when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_3_ACC_NEW_SING_PAY_AMT' then detail.pay_amount_less_refund  --'统计指标名称为累计新签支付金额'
                when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_AVG_NEW_SING_SHOPS' then detail.sign_shop_brand_count/nvl(underling_cnt,1)  --人均新签品牌门店数'
                when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_AVG_NEW_SING_GMV' then detail.gmv_less_refund/nvl(underling_cnt,1)  --'人均新签品GMV'
                when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_AVG_NEW_SING_PAY_AMT' then detail.pay_amount_less_refund/nvl(underling_cnt,1)  --'人均新签支付金额'
                when plan.bounty_indicator_code = 'SIGN_BRAND_GMV_RATE' then (detail.gmv_less_refund / plan_user_target.target) * 100 --新签gmv占比目标完成率
                end as sts_target,

           --排名
           rank() over(partition by plan.no order by (
                case when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_3_NEW_SING_SHOPS' then detail.sign_shop_count  --'统计指标名称为新签门店数'
                     when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_3_NEW_SING_BRAND_SHOPS' then detail.sign_shop_brand_count  --统计指标名称为新签品牌门店数'
                     when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_3_ACC_NEW_SING_GMV' then detail.gmv_less_refund  --'统计指标名称为新签GMV'
                     when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_3_ACC_NEW_SING_PAY_AMT' then detail.pay_amount_less_refund  --'统计指标名称为累计新签支付金额'
                     when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_AVG_NEW_SING_SHOPS' then detail.sign_shop_brand_count/nvl(underling_cnt,1)  --人均新签品牌门店数'
                     when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_AVG_NEW_SING_GMV' then detail.gmv_less_refund/nvl(underling_cnt,1)  --'人均新签品GMV'
                     when plan.bounty_indicator_code = 'NEW_SIGNING_BRAND_AVG_NEW_SING_PAY_AMT' then detail.pay_amount_less_refund/nvl(underling_cnt,1)  --'人均新签支付金额'
                     when plan.bounty_indicator_code = 'SIGN_BRAND_GMV_RATE' then (detail.gmv_less_refund / plan_user_target.target) * 100 --新签gmv占比目标完成率
                     end
           ) desc, detail.gmv_less_refund desc) as grant_object_rk
    from plan
    INNER JOIN detail ON plan.no = detail.planno
    LEFT JOIN underling ON detail.grant_object_user_id = underling.user_id AND underling.dayid = split(plan.backward_date, ',')[0]
    LEFT JOIN plan_user_target ON plan.no = plan_user_target.plan_no AND detail.grant_object_user_id = plan_user_target.user_id
)

insert overwrite table dw_salary_backward_plan_sum_mid_d partition (dayid='${v_date}', bounty_rule_type=3)
SELECT update_time,
       update_month,
       plan_month,
       plan_pay_time,
       planno as plan_no,
       plan_name,
       plan_group_id,
       plan_group_name,
       grant_object_type,
       grant_object_user_id,
       grant_object_user_name,
       grant_object_user_dep_id,
       grant_object_user_dep_name,
       leave_time,
       sts_target_name,
       sts_target,
       concat('grant_object_rk:', if(commission_plan_type ='排名返现', grant_object_rk, ''), '\;grant_object_underling_cnt:', grant_object_underling_cnt) as real_coefficient_goal_rate,
       commission_cap,
       commission_plan_type,
       commission_reward_type,
       if(
          payout_rule_type=5 and (sts_target <= 0 OR (commission_cap is not null AND sts_target < commission_cap)),
          0,
          yt_crm.bounty_payout(payout_rule_type, if(payout_rule_type IN (1,2,3,4), sts_target, grant_object_rk), cast(commission_cap as DOUBLE), payout_config_json)
       ) as commission_reward,
       planno
FROM cur
WHERE sts_target is not null

UNION ALL

SELECT update_time,
       update_month,
       plan_month,
       plan_pay_time,
       plan_no,
       plan_name,
       plan_group_id,
       plan_group_name,
       grant_object_type,
       grant_object_user_id,
       grant_object_user_name,
       grant_object_user_dep_id,
       grant_object_user_dep_name,
       leave_time,
       sts_target_name,
       sts_target,
       real_coefficient_goal_rate,
       commission_cap,
       commission_plan_type,
       commission_reward_type,
       commission_reward,
       planno
FROM (
    SELECT *
    FROM yt_crm.dw_salary_backward_plan_sum_mid_d
    WHERE dayid = '${v_date}'
    AND bounty_rule_type=3
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null