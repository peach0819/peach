select * from (select a.plan_no, a.grant_object_user_id,
case when coalesce(a.plan_month,'#') <> coalesce(b.plan_month,'#') then concat('存在差异【',a.plan_month,'：',b.plan_month,'】') else '无差异' end as plan_month_diff_flg,
case when coalesce(a.plan_pay_time,'#') <> coalesce(b.plan_pay_time,'#') then concat('存在差异【',a.plan_pay_time,'：',b.plan_pay_time,'】') else '无差异' end as plan_pay_time_diff_flg,
case when coalesce(a.grant_object_type,'#') <> coalesce(b.grant_object_type,'#') then concat('存在差异【',a.grant_object_type,'：',b.grant_object_type,'】') else '无差异' end as grant_object_type_diff_flg,
case when coalesce(a.grant_object_user_name,'#') <> coalesce(b.grant_object_user_name,'#') then concat('存在差异【',a.grant_object_user_name,'：',b.grant_object_user_name,'】') else '无差异' end as grant_object_user_name_diff_flg,
case when coalesce(a.grant_object_user_dep_id,'#') <> coalesce(b.grant_object_user_dep_id,'#') then concat('存在差异【',a.grant_object_user_dep_id,'：',b.grant_object_user_dep_id,'】') else '无差异' end as grant_object_user_dep_id_diff_flg,
case when coalesce(a.grant_object_user_dep_name,'#') <> coalesce(b.grant_object_user_dep_name,'#') then concat('存在差异【',a.grant_object_user_dep_name,'：',b.grant_object_user_dep_name,'】') else '无差异' end as grant_object_user_dep_name_diff_flg,
case when coalesce(a.leave_time,'#') <> coalesce(b.leave_time,'#') then concat('存在差异【',a.leave_time,'：',b.leave_time,'】') else '无差异' end as leave_time_diff_flg,
case when coalesce(a.sts_target_name,'#') <> coalesce(b.sts_target_name,'#') then concat('存在差异【',a.sts_target_name,'：',b.sts_target_name,'】') else '无差异' end as sts_target_name_diff_flg,
case when abs(coalesce(a.sts_target,0) - coalesce(b.sts_target,0))>0.0003 then concat('存在差异【',a.sts_target,'：',b.sts_target,'】')

when coalesce(a.sts_target,0) <> coalesce(b.sts_target,0) then concat('少量差异【',a.sts_target,'：',b.sts_target,'】') end as sts_target_diff_flg,
case when coalesce(a.commission_cap,'#') <> coalesce(b.commission_cap,'#') then concat('存在差异【',a.commission_cap,'：',b.commission_cap,'】') else '无差异' end as commission_cap_diff_flg,
case when coalesce(a.commission_plan_type,'#') <> coalesce(b.commission_plan_type,'#') then concat('存在差异【',a.commission_plan_type,'：',b.commission_plan_type,'】') else '无差异' end as commission_plan_type_diff_flg,
case when coalesce(a.commission_reward_type,'#') <> coalesce(b.commission_reward_type,'#') then concat('存在差异【',a.commission_reward_type,'：',b.commission_reward_type,'】') else '无差异' end as commission_reward_type_diff_flg,

case when a.commission_reward_type = '实物' then (
        case when coalesce(a.cur_commission_reward,'#') <> coalesce(b.cur_commission_reward,'#')
        then concat('存在差异【',a.cur_commission_reward,'：',b.cur_commission_reward,'】')
        else '无差异' end
     )
     when a.commission_reward_type = '金额' then (
        case when abs(coalesce(a.cur_commission_reward,0) - coalesce(b.cur_commission_reward,0))>0.0003
        then concat('存在差异【',a.cur_commission_reward,'：',coalesce(b.cur_commission_reward,'】'))
        else '无差异' end
     )
     end as cur_commission_reward_diff_flg,

case when a.commission_reward_type = '实物' then (
        case when coalesce(a.pre_commission_reward,'#') <> coalesce(b.pre_commission_reward,'#')
        then concat('存在差异【',a.pre_commission_reward,'：',b.pre_commission_reward,'】')
        else '无差异' end
     )
     when a.commission_reward_type = '金额' then (
        case when abs(coalesce(a.pre_commission_reward,0) - coalesce(b.pre_commission_reward,0))>0.0003
        then concat('存在差异【',a.pre_commission_reward,'：',coalesce(b.pre_commission_reward,'】'))
        else '无差异' end
     )
     end as pre_commission_reward_diff_flg,

case when coalesce(a.commission_reward_change,'#') <> coalesce(b.commission_reward_change,'#') then concat('存在差异【',a.commission_reward_change,'：',b.commission_reward_change,'】') else '无差异' end as commission_reward_change_diff_flg
 from ( select * from dw_salary_backward_plan_sum_d where dayid='20211031' ) a

left join (select * from dw_salary_backward_plan_sum_new_d where dayid='20211031' ) b on 1=1
 and coalesce(a.plan_no,'#') = coalesce(b.plan_no,'#')
 and coalesce(a.grant_object_user_id,'#') = coalesce(b.grant_object_user_id,'#')
 and coalesce(a.planno,'#') = coalesce(b.planno,'#')
 left join (select * from dw_bounty_plan_d WHERE dayid = '$v_date') plan ON a.plan_no = plan.no
 WHERE plan.status = 1
 and a.plan_no!=12531
 ) t where
 plan_month_diff_flg like '存在差异%'
 or plan_pay_time_diff_flg like '存在差异%'
 or grant_object_type_diff_flg like '存在差异%'
 or grant_object_user_name_diff_flg like '存在差异%'
 or grant_object_user_dep_id_diff_flg like '存在差异%'
 or grant_object_user_dep_name_diff_flg like '存在差异%'
 or leave_time_diff_flg like '存在差异%'
 or sts_target_name_diff_flg like '存在差异%'
 or sts_target_diff_flg like '存在差异%'
 or commission_cap_diff_flg like '存在差异%'
 or commission_plan_type_diff_flg like '存在差异%'
 or commission_reward_type_diff_flg like '存在差异%'
 or cur_commission_reward_diff_flg like '存在差异%'
 or pre_commission_reward_diff_flg like '存在差异%'
 or commission_reward_change_diff_flg like '存在差异%'
