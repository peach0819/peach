insert overwrite table dw_salary_backward_plan_sum_mid_d partition (dayid='$v_date',planno='13677')
select

    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,--更新时间
    from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,--执行月份
    --方案基础信息
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
    sts_target_name,
	sts_target,--统计指标数值
    --方案扩展字段
    concat('grant_object_rk:',nvl(case when '累计阶梯单价返点' ='排名返现' then grant_object_rk else null end,'),'\;','grant_object_underling_cnt:',nvl(case when sts_target_name in ('人均新签品牌门店数','人均新签GMV','人均新签支付金额')  then  grant_object_underling_cnt else null end,')) as real_coefficient_goal_rate
    --提成上限
            ,null as commission_cap
        --提成方案类型
            ,'累计阶梯单价返点' as commission_plan_type,
        --提成奖品类型
            '金额' as commission_reward_type

                -- 累计返点
                                    -- 累计阶梯单价返点
            ,case
                    when
                        sts_target  >=  1
                                                    then round(sts_target * 30, 2)
                        else '0' end as commission_reward --提成奖品
                     from
 (
select
    --方案基础信息
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
    sts_target_name,--统计指标名称
    sts_target,---统计指标----
    grant_object_underling_cnt,
    if(sts_target>0,rank()over(order by sts_target desc ),null) as grant_object_rk
 from (
select
    --方案基础信息
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
    sts_target_name,--统计指标名称
    max(nvl(underling_cnt,1)) as grant_object_underling_cnt,
	---统计指标----

            --统计指标名称为新签品牌门店数'
    count(distinct case  when  is_leave='否' and is_succ_sign='是' then concat('_',shop_id,brand_id)  else null end ) as sts_target--统计指标数值
                            from
    (
    select *
        from dw_salary_sign_brand_rule_public_d
        where dayid ='$v_date' and pltype='cur' and planno='13677'
    ) t
    left join
    ( select user_id,underling_cnt
        from dws_usr_bd_manager_underling_d
        where dayid ='20211031'
    ) t1 on t.grant_object_user_id=t1.user_id
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
	) forward_plan_tmp
) forward_plan
;