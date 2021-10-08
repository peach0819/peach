

v_date=$1

source ../sql_variable.sh $v_date
hive -v -e "


use ytdw;

insert overwrite table dw_salary_sign_item_rule_public_d partition (dayid='$v_date',planno='13492',pltype='pre')
select
   from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,--更新时间
   from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,--执行月份
   '历史方案' as plan_type ,--明细类型
   --方案基础信息,
   '202109' as plan_month,--方案月份
   '2021-09-01~2021-09-30' as plan_pay_time,--方案时间
   '9月-京津冀省区加码-尿不湿-乖乖时光-1W档' as plan_name,--方案名称
   '2' as plan_group_id, --归属业务组id
   'B类尿不湿组' as plan_group_name, --归属业务组
   item_id,
   item_name,
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
           area_manager_id     	,   --大区经理id
           area_manager_name   	,   --大区经理
           area_manager_dep_id,--大区区域ID
           area_manager_dep_name,   --大区
		   bd_manager_id       	,--主管id
           bd_manager_name     	,--主管
           bd_manager_dep_id ,--主管区域ID
           bd_manager_dep_name 	,--区域
		   service_user_id_freezed,
           service_department_id_freezed,
		   service_user_name_freezed,--冻结销售人员姓名
		   service_feature_name_freezed,--冻结销售人员职能
		   service_job_name_freezed,--冻结销售人员角色
		   service_department_name_freezed,--冻结销售人员部门
		   new_sign_time,--新签时间
		   new_sign_day, --新签日期
           new_sign_rn,--新签时间排名达成
           shop_item_sign_day,--门店品牌新签时间
		   --默认指标--
           gmv_less_refund,  --实货gmv-退款
           gmv,--实货gmv,
		   pay_amount,--实货支付金额
		   pay_amount_less_refund,--实货支付金额-退款
           refund_actual_amount,--实货退款
           refund_retreat_amount,--实货清退金额
		   new_sign_line,
		   is_over_sign_line,--是否满足新签门槛
           is_first_sign,--是否首次达成
 		   is_succ_sign,--是否新签成功
            grant_object_type ,
            grant_object_user_id ,
            grant_object_user_name ,
            grant_object_user_dep_id ,
            grant_object_user_dep_name ,
   users.leave_time as leave_time,--发放对象离职时间
   case when users.leave_time is not null and new_sign_day > users.leave_time then '是' else '否' end as is_leave,--发放对象是否离职
   --统计指标名称
   '新签商品门店数' as sts_target_name
 from
 (
select
           item_id,
           item_name,
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
           area_manager_id     	,   --大区经理id
           area_manager_name   	,   --大区经理
           area_manager_dep_id,--大区区域ID
           area_manager_dep_name,   --大区
		   bd_manager_id       	,--主管id
           bd_manager_name     	,--主管
           bd_manager_dep_id ,--主管区域ID
           bd_manager_dep_name 	,--区域
		   service_user_id_freezed,
           service_department_id_freezed,
		   service_user_name_freezed,--冻结销售人员姓名
		   service_feature_name_freezed,--冻结销售人员职能
		   service_job_name_freezed,--冻结销售人员角色
		   service_department_name_freezed,--冻结销售人员部门
		   new_sign_time,--新签时间
		   new_sign_day, --新签日期
           new_sign_rn,--新签时间排名达成
           shop_item_sign_day,--门店品牌新签时间
		   --默认指标--
           gmv_less_refund,  --实货gmv-退款
           gmv,--实货gmv,
		   pay_amount,--实货支付金额
		   pay_amount_less_refund,--实货支付金额-退款
           refund_actual_amount,--实货退款
           refund_retreat_amount,--实货清退金额
            new_sign_line,
            is_over_sign_line,
            case when new_sign_rn=1 then '是' else '否' end as is_first_sign,--是否首次达成
            case when gmv_less_refund >= new_sign_line  and new_sign_rn=1 then '是' else '否' end as is_succ_sign,--是否新签成功

            '【岗位】BD' as grant_object_type,--发放对象类型
            --发放对象用户ID
                            service_user_id_freezed as grant_object_user_id,
                        --发放对象用户姓名
                            service_user_name_freezed as grant_object_user_name,
                            -- 发放对象部门ID
                            service_department_id_freezed as grant_object_user_dep_id,
                                            service_department_name_freezed as grant_object_user_dep_name
                 from
(
select       item_id,
             item_name,
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
           area_manager_id     	,   --大区经理id
           area_manager_name   	,   --大区经理
           area_manager_dep_id,--大区区域ID
           area_manager_dep_name,   --大区
		   bd_manager_id       	,--主管id
           bd_manager_name     	,--主管
           bd_manager_dep_id ,--主管区域ID
           bd_manager_dep_name 	,--区域
		   service_user_id_freezed,
           service_department_id_freezed,
		   service_user_name_freezed,--冻结销售人员姓名
		   service_feature_name_freezed,--冻结销售人员职能
		   service_job_name_freezed,--冻结销售人员角色
		   service_department_name_freezed,--冻结销售人员部门
		   new_sign_time,--新签时间
		   new_sign_day, --新签日期
		   row_number()over(partition by shop_id,item_id,is_over_sign_line order by new_sign_time) as new_sign_rn,--新签时间排名达成
           shop_item_sign_day,--门店商品新签时间
		   --默认指标--
           gmv_less_refund,  --实货gmv-退款
           gmv,--实货gmv
		   pay_amount,--实货支付金额
		   pay_amount_less_refund,--实货支付金额-退款
           refund_actual_amount,--实货退款
           refund_retreat_amount,--实货清退金额
            new_sign_line,
            is_over_sign_line
 from
 (
--
   select
           item_id,
           item_name,
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
           area_manager_id     	,   --大区经理id
           area_manager_name   	,   --大区经理
           area_manager_dep_id,--大区区域ID
           area_manager_dep_name,   --大区
		   bd_manager_id       	,--主管id
           bd_manager_name     	,--主管
           bd_manager_dep_id ,--主管区域ID
           bd_manager_dep_name 	,--区域
		   service_user_id_freezed,
           service_department_id_freezed,
		   service_user_name_freezed,--冻结销售人员姓名
		   service_feature_name_freezed,--冻结销售人员职能
		   service_job_name_freezed,--冻结销售人员角色
		   service_department_name_freezed,--冻结销售人员部门
		   min(pay_time) as new_sign_time,--新签时间
		   min(pay_day) as new_sign_day, --新签日期
           shop_item_sign_day,--门店商品新签时间
		   --默认指标--
           sum(gmv_less_refund) as gmv_less_refund,  --实货gmv-退款
           sum(gmv) as gmv,--实货gmv,
		   sum(pay_amount) as pay_amount,--实货支付金额
		   sum(pay_amount_less_refund) as pay_amount_less_refund,--实货支付金额-退款
           sum(refund_actual_amount) as refund_actual_amount,--实货退款
           sum(refund_retreat_amount) as refund_retreat_amount,--实货清退金额


                                    10000 as new_sign_line,
                    case when sum(gmv_less_refund) >= 10000 then '是' else '否' end as is_over_sign_line--是否满足新签门槛
                            	   ---业务中间表
	   from
	   (
	   select
	           order.order_id,order.trade_no,
               business_unit,--业务域,
               category_id_first,  --商品一级类目,
               category_id_second, --商品二级类目,
               category_id_first_name,
               category_id_second_name,
               brand_id,
               brand_name,--商品品牌,
               item_id,
               item_name,--商品名称,
               item_style,
               item_style_name,--ab类型,
               is_sp_shop,--是否服务商订单
               is_bigbd_shop,--是否大BD门店
               is_spec_order,--是否特殊订单,
               shop_item_sign_day,
               shop_item_sign_time,
               shop_brand_sign_day,
               shop_brand_sign_time,
               pay_time,
               pay_day,
               order.shop_id,
               shop_name,--门店名称,
               store_type,--门店类型,
               store_type_name,
               war_zone_id       , --战区经理ID
               war_zone_name     , --战区经理
               war_zone_dep_id   , --战区ID
               war_zone_dep_name , --战区
               area_manager_id     	,   --大区经理id
               area_manager_name   	,   --大区经理
               area_manager_dep_id, --大区区域ID
               area_manager_dep_name,   --大区
               bd_manager_id       	,--主管id
               bd_manager_name     	,--主管
               bd_manager_dep_id ,--主管区域ID
               bd_manager_dep_name 	,--区域
               service_user_id_freezed,
               service_department_id_freezed,
               service_user_name_freezed,--冻结销售人员姓名,
               service_feature_name_freezed,--冻结销售人员职能,
               service_job_name_freezed,--冻结销售人员角色,
               service_department_name_freezed,--冻结销售人员部门,
               --默认指标--
               --默认指标--
               order.gmv - nvl(refund.refund_actual_amount,0) as gmv_less_refund,  --实货gmv-退款,
               order.pay_amount,--实货支付金额
               order.pay_amount - nvl(refund.refund_actual_amount,0)  as pay_amount_less_refund,--实货支付金额-退款
               gmv,--实货gmv,
               nvl(refund.refund_actual_amount,0) as refund_actual_amount,--实货退款,
               nvl(refund.refund_retreat_amount,0) as refund_retreat_amount--实货清退金额
	     from
	   (
	   select *
	     from dw_salary_sign_rule_public_mid_v2_d
         ---过滤条件中的 全局过滤条件
         where dayid='20210930'
          and shop_item_sign_day between '20210901' and '20210930'
          and pay_day <='20210930'


          and


                                sale_team_id
                        in ('2'  )

          and


                                item_style_name
                        in ('B'  )

          and


                                category_id_first
                        in ('10'  )

          and


                                brand_id
                        in ('17221'  )

          and


                                war_zone_dep_id
                        in ('1657'  )

          and


                                area_manager_dep_id
                        in ('1659'  )
              	   ) order
   --退款表
    left join
    (select order_id,sum(refund_actual_amount) as refund_actual_amount,
        sum(case when multiple_refund=10 then refund_actual_amount else 0 end) as refund_retreat_amount
	   from dw_afs_order_refund_new_d --（后期通过type识别清退金额）
       where dayid ='$v_date'
	   and refund_status=9
       group by order_id
     ) refund on order.order_id=refund.order_id
	 ) big_tbl
    group by
           item_id,
           item_name,
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
           area_manager_id     	,   --大区经理id
           area_manager_name   	,   --大区经理
           area_manager_dep_id,--大区区域ID
           area_manager_dep_name,   --大区
		   bd_manager_id       	,--主管id
           bd_manager_name     	,--主管
           bd_manager_dep_id ,--主管区域ID
           bd_manager_dep_name 	,--区域
		   service_user_id_freezed,
           service_department_id_freezed,
		   service_user_name_freezed,--冻结销售人员姓名
		   service_feature_name_freezed,--冻结销售人员职能
		   service_job_name_freezed,--冻结销售人员角色
		   service_department_name_freezed,--冻结销售人员部门
		   shop_item_sign_day
	) sign_tmp
) sign_mid

) sign_rule
left join
( select user_id, substr(leave_time,1,8) as leave_time from dwd_user_admin_d where dayid='20210930'
) users on sign_rule.grant_object_user_id =users.user_id
where sign_rule.grant_object_user_id is not null
;





insert overwrite table dw_salary_backward_plan_sum_mid_d partition (dayid='$v_date',planno='13492')
select
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,--更新时间
    from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,--执行月份
    --方案基础信息,
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
    concat('grant_object_rk:',nvl(case when '累计阶梯单价返点' ='排名返现' then grant_object_rk else null end,''),'\;','grant_object_underling_cnt:','') as real_coefficient_goal_rate

    --提成上限
            ,null as commission_cap
        --提成方案类型
            ,'累计阶梯单价返点' as commission_plan_type,
        --提成奖品类型
            '金额' as commission_reward_type

                                                -- 累计阶梯单价返点
            ,case
                    when
                        sts_target  >=  1
                                                    then round(sts_target * 90, 2)
                        else '0' end as commission_reward --提成奖品
                     from
 (
    select
        --方案基础信息,
        plan_month,--方案月份
        plan_pay_time,--方案时间
        planno,--方案编号
        plan_name,--方案名称
        plan_group_id,--归属业务组ID
        plan_group_name,--归属业务组
        ---以下为个性化的配置信息---
        grant_object_type,--发放对象类型
        grant_object_user_id, --发放对象ID
        grant_object_user_name,--发放对象名称,
        grant_object_user_dep_id,--发放对象部门ID
        grant_object_user_dep_name,--发放对象部门
        leave_time,--发放对象离职时间
        sts_target_name,--统计指标名称
        sts_target,---统计指标----
        if(sts_target>0,rank()over(order by sts_target desc ),null) as grant_object_rk
    from (
select
    --方案基础信息,
    plan_month,--方案月份
    plan_pay_time,--方案时间
	planno,--方案编号
    plan_name,--方案名称
    plan_group_id,--归属业务组ID
    plan_group_name,--归属业务组
     ---以下为个性化的配置信息---
    grant_object_type,--发放对象类型
    grant_object_user_id, --发放对象ID
    grant_object_user_name,--发放对象名称,
	grant_object_user_dep_id,--发放对象部门ID
    grant_object_user_dep_name,--发放对象部门
    leave_time,--发放对象离职时间
    sts_target_name,--统计指标名称
	---统计指标----


        --统计指标名称为新签商品门店数'
    count(distinct case  when is_leave='否' and is_succ_sign='是' then concat('_',shop_id,item_id)  else null end ) as sts_target--统计指标数值


        from dw_salary_sign_item_rule_public_d
	where dayid ='$v_date' and pltype='pre' and planno='13492'
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

    "
    if [ "202109" -ne "$v_cur_month" ]; then
    hive -e "

use ytdw;
insert overwrite table dw_salary_backward_plan_sum_d partition (dayid='$v_date',planno='13492')
select
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,--更新时间
    from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,--执行月份
    --方案基础信息,
    pre_plan.plan_month,--方案月份
    pre_plan.plan_pay_time,--方案时间
	pre_plan.planno,--方案编号
    pre_plan.plan_name,--方案名称
    ---以下为个性化的配置信息---
    pre_plan.plan_group_id,--归属业务组ID
    pre_plan.plan_group_name,--归属业务组
    pre_plan.grant_object_type,--发放对象类型
    pre_plan.grant_object_user_id, --发放对象ID
    pre_plan.grant_object_user_name,--发放对象名称,
    pre_plan.grant_object_user_dep_id,--发放对象部门ID
    pre_plan.grant_object_user_dep_name,--发放对象部门
    pre_plan.leave_time,--发放对象离职时间
    --统计指标名称
    pre_plan.sts_target_name,
	pre_plan.sts_target,--统计指标数值
    cur_plan.real_coefficient_goal_rate, --方案扩展字段
	pre_plan.commission_cap,--提成上限
    pre_plan.commission_plan_type,--提成方案类型
    pre_plan.commission_reward_type,--提成奖品类型
    case when pre_plan.commission_plan_type='排名返现' and cur_plan.commission_reward>pre_plan.commission_reward
    then pre_plan.commission_reward else cur_plan.commission_reward end as cur_commission_reward,--当前统计的提成奖品
	pre_plan.commission_reward as pre_commission_reward,--上一月份的提成奖品
    case when pre_plan.commission_reward_type='金额' then round(case when pre_plan.commission_plan_type='排名返现' and cur_plan.commission_reward>pre_plan.commission_reward
then pre_plan.commission_reward else cur_plan.commission_reward end - pre_plan.commission_reward, 2)
    when pre_plan.commission_reward_type='实物'
        and cur_plan.commission_reward!= pre_plan.commission_reward
        then concat_ws('-',cur_plan.commission_reward,pre_plan.commission_reward)
	else null end as commission_reward_change --提成奖品变化
 from
 (
   select  * from dw_salary_backward_plan_sum_mid_d
    where dayid ='$v_pre_month_last_day' and plan_no='13492'
	) pre_plan

    left join
	( select  * from dw_salary_backward_plan_sum_mid_d
      where dayid ='$v_date'  and plan_no='13492'
	) cur_plan on pre_plan.plan_no=cur_plan.plan_no
    and pre_plan.grant_object_user_id=cur_plan.grant_object_user_id
;

"
fi
echo 'ok' &&
exit 0
