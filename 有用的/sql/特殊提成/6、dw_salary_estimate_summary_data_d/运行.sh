v_date=$1

source ../sql_variable.sh $v_date

apache-spark-sql -e "
--1、依赖于特殊提成（现在是8点调起，大概跑到9点），故依赖设置为定时9:30
--2、1-4号不进行调度. 属于业务的调整时间. 所以从5号开始调度
use ytdw;
CREATE TABLE IF NOT EXISTS dw_salary_estimate_summary_data_d (
    update_time                 string COMMENT '更新时间',
    service_user_id             string COMMENT '服务人员id',
    service_user_name           string COMMENT '服务人员名称',
    service_department_id       string COMMENT '服务人员部门id',
    service_department_name     string COMMENT '服务人员部门名称',
    is_split                    string COMMENT '销售是否拆分',
    coefficient_summary         decimal(18, 2) COMMENT '系数金额',
    coefficient_goal            bigint COMMENT '系数目标',
    real_coefficient_goal_rate  string comment '理论目标完成率',
    real_coefficient            decimal(18, 4) comment '理论系数',
    base_salary                 decimal(18, 2) COMMENT '底薪',
    base_salary_deduction       decimal(18, 2) COMMENT '底薪扣款',
    commission_deduction        decimal(18, 2) COMMENT '提成扣款',
    theoretical_commission_amt  decimal(18, 2) COMMENT '基本支付金额提成',--基本支付金额提成
    new_sign_commission_amt     decimal(18, 2) COMMENT '有效新开门店数奖励',--有效新开门店数奖励
    gmv_taget_bonus_package     decimal(18, 2) COMMENT 'GMV目标完成奖金包',--GMV目标完成奖金包
    summary_reward              decimal(18, 2) COMMENT '新开通门店账号奖励',--新开通门店账号奖励
    secret_key_commission_amt   decimal(18, 2) COMMENT '拍口令提成',--拍口令提成
    special_salary_reward       decimal(18, 2) COMMENT '特殊提成', --特殊提成
    estimate_salary             decimal(18, 2) COMMENT '预估收入-系数前',
    coefficient_estimate_salary decimal(18, 2) COMMENT '预估收入-系数后'
)
comment '销售薪资预估收入汇总表'
partitioned by (dayid string)
stored as orc;

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

           --理论系数
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
                else 0 end as real_coefficient,

           theoretical_commission_amt,--基本支付金额提成
           if(is_split='BD',new_sign_commission_amt,0) as new_sign_commission_amt, --有效新开门店数奖励金额
           case when is_split='BD' then 3000 else 4000 end as base_salary,--底薪底薪未配置化 如果是否拆分为 BD,则默认为 3000. 如果是否拆分为 大BD.则默认为 4000.
           0 as base_salary_deduction,--底薪扣款
           0 as commission_deduction --提成扣款
    from ads_salary_result_sale_d
    where dayid='$v_date'
    and is_split in ('BD','大BD')
),

--新开通门店账号奖励
new_open as (
    select service_user_id_freezed as service_user_id,
           summary_reward
    from dw_salary_new_open_reward_summary_d
    where dayid='$v_date'
),

--拍口令提成
secret_key as (
    select user_id as service_user_id,
           theoretical_commission_amt as secret_key_commission_amt
    from dw_salary_secret_key_summary_d
    where dayid='$v_date'
),

--特殊提成
commission_plan as (
    SELECT grant_object_user_id,
           SUM(commission_reward) as special_salary_reward
    FROM (
        SELECT no
        FROM dw_bounty_plan_schedule_d
        WHERE name not like '%废弃%'
        AND name not like '%测试%'
        AND name not like '%test%'
        AND substr(reverse(split(reverse(forward_date),',')[0]), 1, 6) = '$v_cur_month'
    ) config
    LEFT JOIN (
        SELECT grant_object_user_id,
               sum(commission_reward) as commission_reward,
               planno
        FROM dw_salary_forward_plan_sum_d
        WHERE dayid ='$v_date'
        and grant_object_user_id is not null
        AND commission_reward_type ='金额'
        group by grant_object_user_id, planno
    ) detail on config.no = detail.planno
    GROUP BY detail.grant_object_user_id
),

t as (
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
     from salary_summary --基本提成
     left join new_open on salary_summary.service_user_id = new_open.service_user_id  --新开门店
     left join secret_key on salary_summary.service_user_id = secret_key.service_user_id   --拍口令提成
     left join commission_plan on salary_summary.service_user_id = commission_plan.grant_object_user_id  --特殊提成
)

insert overwrite table dw_salary_estimate_summary_data_d partition(dayid='$v_date')
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
;
"