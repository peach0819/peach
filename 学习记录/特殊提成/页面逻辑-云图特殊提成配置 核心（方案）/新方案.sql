

case when sum(gmv_less_refund) >= bounty_rules.new_sign_line then '是' else '否' end as is_over_sign_line --是否满足新签门槛
from dw_salary_sign_rule_public_mid_v2_d
  cross join (
        select *
        from ods_vf_bounty_plan_rules
        where bounty_type = 2
        and interval_start_day <= '$v_op_time'
        and interval_end_day <= '$v_op_time'
        and is_deleted = 0
  ) bounty_rules on 1 = 1
  --- 过滤条件中的 全局过滤条件
  where dayid='$v_date'
    and shop_brand_sign_day between bounty_rules.interval_start_day and bounty_rules.interval_end_day
  and pay_day <= bounty_rules.interval_end_day
  and ytdw.simple_expr(item_id, get_json_object(bounty_rules.plan_filters, "$.item_id"), "=") = 1
  and ytdw.simple_expr(war_zone_dep_id, get_json_object(bounty_rules.plan_filters, "$.war_zone_dep_id"), "=") = 1
  and ytdw.simple_expr(sale_team_freezed_id, get_json_object(bounty_rules.plan_filters, "$.sale_team_freezed_id"), "=") = 1
  and ytdw.simple_expr(item_style_name, get_json_object(bounty_rules.plan_filters, "$.item_style_name"), "=") = 1
  and ytdw.simple_expr(category_id_first, get_json_object(bounty_rules.plan_filters, "$.category_id_first"), "in") = 1
  and ytdw.simple_expr(category_id_second, get_json_object(bounty_rules.plan_filters, "$.category_id_second"), "in") = 1
  and ytdw.simple_expr(brand_id, get_json_object(bounty_rules.plan_filters, "$.brand_id"), "in") = 1
  and ytdw.simple_expr(area_manager_dep_id, get_json_object(bounty_rules.plan_filters, "$.area_manager_dep_id"), "=") = 1
  group by
        brand_id,
        brand_name,--商品品牌
        item_style,
        item_style_name,--ab类型
        shop_id,
        shop_name,--门店名称
        store_type,--门店类型
        store_type_name,
          war_zone_id       , --战区经理ID
          war_zone_name     , --战区经理
          war_zone_dep_id   , --战区ID
          war_zone_dep_name , --战区
          area_manager_id      ,   --大区经理id
          area_manager_name    ,   --大区经理
          area_manager_dep_id,--大区区域ID
          area_manager_dep_name   --大区

















select
    ytdw.bounty_payout(bounty_rules.payout_rules, bounty_rules.payout_upper_limit) commission_reward --提成奖品
 from (
  select
       case
         --统计指标名称为新签品牌门店数'
         when bounty_rules.indicator_key = "sts_target_NEW_SING_BRAND_SHOPS" then count(distinct case when is_leave='否' and is_succ_sign='是' then shop_id else null end )
         --'统计指标名称为新签GMV'
         when bounty_rules.indicator_key = "sts_target_NEW_SING_GMV" then sum(case when is_leave='否' and is_succ_sign='是' then gmv_less_refund else 0 end )
         --'统计指标名称为累计新签支付金额'
         when bounty_rules.indicator_key = "sts_target_NEW_SING_PAY_AMT" then sum(case when is_leave='否' and is_succ_sign='是' then pay_amount_less_refund else 0 end )
       else 0 end as  sts_target
      from dw_salary_sign_brand_rule_public_d public
  left join (
      select *
      from ods_vf_bounty_plan_rules
      where bounty_type = 2
      and interval_start_day <= '$v_op_time'
      and interval_end_day <= '$v_op_time'
      and is_deleted = 0
  ) bounty_rules on plan.plan_no = public.planno

   where dayid ='$v_date' and pltype='cur'
      group by
        plan_month,--方案月份
        plan_pay_time,--方案时间
        planno,--方案编号
        plan_name,--方案名称
        plan_group_id,--归属业务组ID
        plan_group_name,--归属业务组
        ---以下为个性化的配置信息---
        grant_object_type,--发放对象类型
        grant_object_user_id, --发放对象ID
        grant_object_user_name,--发放对象名称
        grant_object_user_dep_id,--发放对象部门ID
        grant_object_user_dep_name,--发放对象部门
        leave_time,--发放对象离职时间
        --统计指标名称
        sts_target_name
) tmp