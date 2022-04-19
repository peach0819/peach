
--基本提成
with salary_summary as (
    select from_unixtime(unix_timestamp()) as update_time,--更新时间
           service_user_id,
           service_user_name,
           service_department_id,
           service_department_name,
           is_split,
           coefficient_summary,--系数金额
           coefficient_goal, --系数目标
           real_coefficient_goal_rate,--理论目标完成率
           case when is_split='BD' then (
                case when real_coefficient_goal_rate>=1.4 then 1.6
                     when real_coefficient_goal_rate>=1.2 then 1.4
                     when real_coefficient_goal_rate>=1 then 1.2
                     when real_coefficient_goal_rate>=0.8 then 1
                     else 0.8 end
                )
                when is_split='大BD' then (
                    case when real_coefficient_goal_rate>=1 then 1
                         when real_coefficient_goal_rate>0  then round(real_coefficient_goal_rate,4)
                         else 0 end
                )
                else 0 end as real_coefficient,--理论系数
           theoretical_commission_amt,--基本支付金额提成
           if(is_split='BD',new_sign_commission_amt,0) as new_sign_commission_amt, --有效新开门店数奖励金额

           --底薪未配置化
           --如果是否拆分为 BD,则默认为 3000.
           --如果是否拆分为 大BD.则默认为 4000.
           case when is_split='BD' then 3000 else 4000 end as base_salary,--底薪
           0 as base_salary_deduction,--底薪扣款
           0 as commission_deduction--提成扣款
    from ads_salary_result_sale_d
    where dayid='$v_date'
    and is_split in ('BD','大BD')
),

--新开通门店账号奖励
new_open as (

)

with t as (
select salary_summary.update_time,--更新时间
       salary_summary.service_user_id,
       salary_summary.service_user_name,
       salary_summary.service_department_id,
       salary_summary.service_department_name,
       salary_summary.is_split,
       salary_summary.coefficient_summary,--系数金额
       salary_summary.coefficient_goal, --系数目标
       salary_summary.real_coefficient_goal_rate,--理论目标完成率
       salary_summary.real_coefficient,--理论系数
       salary_summary.base_salary,--底薪
       salary_summary.base_salary_deduction,--底薪扣款
       salary_summary.commission_deduction,--提成扣款
       salary_summary.theoretical_commission_amt,--基本支付金额提成
       salary_summary.new_sign_commission_amt,--有效新开门店数奖励
       new_open.summary_reward,--新开通门店账号奖励
       secret_key.secret_key_commission_amt,--拍口令提成
       commission_plan.special_salary_reward, --特殊提成
       --预估收入-系数前
       --=【 (基本支付金额提成 + 有效新开门店数奖励 + 新开通门店账号奖励 + 拍口令提成 + 特殊提成 )  + GMV目标完成奖金包 - 提成扣款】 +  【底薪 -底薪扣款】
       --合计提成金额
       nvl(salary_summary.theoretical_commission_amt,0)
           +nvl(salary_summary.new_sign_commission_amt,0)
           +nvl(new_open.summary_reward,0)
           +nvl(secret_key.secret_key_commission_amt,0)
           +nvl(commission_plan.special_salary_reward,0)
           -nvl(salary_summary.commission_deduction,0)
                                                                                     as commission_amt ,
       --合计底薪
       nvl(salary_summary.base_salary,0)-nvl(salary_summary.base_salary_deduction,0) as base_salary_amt,
       --预估收入-系数后
       --当 是否拆分为 BD时,则【理论系数 * (基本支付金额提成 + 有效新开门店数奖励 + 新开通门店账号奖励 + 拍口令提成 + 特殊提成 )  + GMV目标完成奖金包 - 提成扣款】 +  【底薪 -底薪扣款】
       --当 是否拆分为 大BD 时,则为 【系数 * (基本支付金额提成 + 拍口令提成 )  + 特殊提成 + GMV目标完成奖金包  - 提成扣款】 + 【底薪 -底薪扣款 】
       --系数后合计提成金额
       case when salary_summary.is_split='BD' then (
                   nvl(salary_summary.real_coefficient,0)*(
                       nvl(salary_summary.theoretical_commission_amt,0)+nvl(salary_summary.new_sign_commission_amt,0)+nvl(new_open.summary_reward,0)+nvl(secret_key.secret_key_commission_amt,0)+nvl(commission_plan.special_salary_reward,0))
               -nvl(salary_summary.commission_deduction,0))
            else (nvl(salary_summary.real_coefficient,0)*(
                    nvl(salary_summary.theoretical_commission_amt,0)+nvl(secret_key.secret_key_commission_amt,0))
                      +nvl(commission_plan.special_salary_reward,0)
                -nvl(salary_summary.commission_deduction,0))
           end as coefficient_commission_amt

--基本提成
from salary_summary

--新开通门店账号奖励
left join (
    select service_user_id_freezed as service_user_id,
           summary_reward
    from dw_salary_new_open_reward_summary_d
    where dayid='$v_date'
) on salary_summary.service_user_id = new_open.service_user_id

--拍口令提成
left join (
    select user_id as service_user_id,
           theoretical_commission_amt as secret_key_commission_amt
    from dw_salary_secret_key_summary_d
    where  dayid='$v_date'
) secret_key on salary_summary.service_user_id = secret_key.service_user_id

--特殊提成
left join (
    SELECT grant_object_user_id,
           SUM(commission_reward) as special_salary_reward
    FROM (
        SELECT grant_object_user_id,
               sum(commission_reward) as commission_reward,
               planno
        FROM ytdw.dw_salary_forward_plan_sum_d
        WHERE dayid ='$v_date'
        and grant_object_user_id is not null
        AND commission_reward_type ='金额'
        group by grant_object_user_id,planno
    ) detail
    right JOIN (
        SELECT no as plan_no,
               subject_id,
               name as plan_name,
               month as plan_month,
               owner_type,
               biz_group_name
        FROM rtdw.ods_vf_bounty_plan
        WHERE 1 = 1
        AND is_deleted = 0
        AND status = 1 --方案状态为 正常
        AND month = '$v_op_month'
        ---这里改月份
        AND owner_type = 2  --方案归属类型. 1 为业务组 .2为销售部
    ) as config on config.plan_no = detail.planno
    GROUP BY detail.grant_object_user_id
) commission_plan on salary_summary.service_user_id = commission_plan.grant_object_user_id

)

select update_time,--更新时间
       service_user_id,
       service_user_name,
       service_department_id,
       service_department_name,
       is_split,
       coefficient_summary,--系数金额
       coefficient_goal, --系数目标
       real_coefficient_goal_rate,--理论目标完成率
       real_coefficient,--理论系数
       base_salary,--底薪
       base_salary_deduction,--底薪扣款
       commission_deduction,--提成扣款
       theoretical_commission_amt,--基本支付金额提成
       new_sign_commission_amt,--有效新开门店数奖励
       0 as gmv_taget_bonus_package,--GMV目标完成奖金包
       summary_reward,--新开通门店账号奖励
       secret_key_commission_amt,--拍口令提成
       special_salary_reward, --特殊提成
       (if(commission_amt<0,0,commission_amt)+if(base_salary_amt<0,0,base_salary_amt)) as estimate_salary,   --预估收入-系数前
       (if(coefficient_commission_amt<0,0,coefficient_commission_amt)+if(base_salary_amt<0,0,base_salary_amt)) as coefficient_estimate_salary   --预估收入-系数后
from t