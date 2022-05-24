

use ytdw;

-- 当月明细
insert overwrite table dw_salary_gmv_rule_public_d partition (dayid='$v_date',planno='14473',pltype='cur')
select
   from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,--更新时间
   from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,--执行月份
   '当月方案' as plan_type ,--明细类型
   --方案基础信息,
   '202112' as plan_month,--方案月份
   '2021-12-01~2021-12-31' as plan_pay_time,--方案时间
   '12月奶粉组p0-安徽省区-小诸葛恩霈纳骼澳贝恩复购.' as plan_name,--方案名称
   '4' as plan_group_id, --归属业务组id
   'B类奶粉业务组' as plan_group_name, --归属业务组
   business_unit,--业务域,
   category_id_first,  --商品一级类目
   category_id_second, --商品二级类目
   category_id_first_name,
   category_id_second_name,
   brand_id,
   brand_name,--商品品牌
   item_id,
   item_name,--商品名称
   item_style,
   item_style_name,--ab类型,
   is_sp_shop,--是否服务商订单
   is_bigbd_shop,--是否大BD门店
   is_spec_order,--是否特殊订单
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
   bd_manager_dep_id,--主管区域ID
   bd_manager_dep_name 	,--区域
   sp_id,
   sp_name,--服务商名,
   sp_operator_name,--服务商经理名,
   service_user_names_freezed,--冻结销售人员姓名
   service_feature_names_freezed,--冻结销售人员职能
   service_job_names_freezed,--冻结销售人员角色
   service_department_names_freezed,--冻结销售人员部门
   service_info_freezed,
   service_info,
      --默认指标--
   gmv_less_refund,  --实货gmv-退款
   gmv,--实货gmv,
   pay_amount,--实货支付金额
   pay_amount_less_refund,--实货支付金额-退款
   refund_actual_amount,--实货退款
   refund_retreat_amount,--实货清退金额
   --发放对象--
   grant_object_type,--发放对象类型
   grant_object_user_id, --发放对象ID
   grant_object_user_name,--发放对象名称
   grant_object_user_dep_id,--发放对象部门ID
   grant_object_user_dep_name,--发放对象部门
   users.leave_time as leave_time,--发放对象离职时间
   case when users.leave_time is not null and pay_day>users.leave_time then '是' else '否' end as is_leave,--发放对象是否离职
    ---统计指标----
    --方案配置 无指标计算型 过滤条件
   '实货GMV(去退款)' as sts_target_name--统计指标名称

   ,case
    when (users.leave_time is null or pay_day<=users.leave_time)
        then

                    gmv_less_refund


            else 0 end as sts_target, --统计指标数值
    pay_day
 from
 (
select
   business_unit,--业务域,
   category_id_first,  --商品一级类目
   category_id_second, --商品二级类目
   category_id_first_name,
   category_id_second_name,
   brand_id,
   brand_name,--商品品牌
   item_id,
   item_name,--商品名称
   item_style,
   item_style_name,--ab类型
   is_sp_shop,--是否服务商订单
   is_bigbd_shop,--是否大BD门店
   is_spec_order,--是否特殊订单
   shop_id,
   shop_name,--门店名称
   store_type,--门店类型
   store_type_name,
   war_zone_id       , --战区经理ID
   war_zone_name     , --战区经理
   war_zone_dep_id   , --战区ID
   war_zone_dep_name , --战区
   area_manager_id     	,   --大区经理id
   area_manager_dep_id,--大区区域ID
   area_manager_name   	,   --大区经理
   area_manager_dep_name,   --大区
   bd_manager_id       	,--主管id
   bd_manager_name     	,--主管
   bd_manager_dep_id,--主管区域ID
   bd_manager_dep_name 	,--区域
   sp_id,
   sp_name,--服务商名
   sp_operator_name,--服务商经理名
   service_user_names_freezed,--冻结销售人员姓名
   service_feature_names_freezed,--冻结销售人员职能
   service_job_names_freezed,--冻结销售人员角色
   service_department_names_freezed,--冻结销售人员部门
   service_info_freezed,
   service_info,
   pay_day,
   --默认指标--
   gmv_less_refund,  --实货gmv-退款
   gmv,--实货gmv
   pay_amount,--实货支付金额
   pay_amount_less_refund,--实货支付金额-退款
   refund_actual_amount,--实货退款
   refund_retreat_amount,--实货清退金额
   --发放对象--
    '【岗位】BD' as grant_object_type,--发放对象类型
    ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_user_id') as grant_object_user_id,   --发放对象用户ID
    ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_user_name') as grant_object_user_name, --发放对象用户姓名
    ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_department_id') as grant_object_user_dep_id,-- 发放对象部门ID
    ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_department_name') as grant_object_user_dep_name  --发放对象部门名称
 from
 (
   select
           business_unit,--业务域
           category_id_first,  --商品一级类目
           category_id_second, --商品二级类目
           category_id_first_name,
           category_id_second_name,
	       brand_id,
	       brand_name,--商品品牌
           item_id,
		   item_name,--商品名称
		   item_style,
		   item_style_name,--ab类型
           is_sp_shop,--是否服务商订单
	       is_bigbd_shop,--是否大BD门店
           is_spec_order,--是否特殊订单
           shop_id,
		   shop_name,--门店名称
           store_type,--门店类型
           store_type_name,
		   war_zone_id       , --战区经理ID
           war_zone_name     , --战区经理
           war_zone_dep_id   , --战区ID
           war_zone_dep_name , --战区
           area_manager_id     	,   --大区经理id
           area_manager_dep_id,--大区区域ID
           area_manager_name   	,   --大区经理
           area_manager_dep_name,   --大区
		   bd_manager_id       	,--主管id
           bd_manager_name     	,--主管
           bd_manager_dep_id,--主管区域ID
           bd_manager_dep_name 	,--区域
		   sp_id,
           sp_name,--服务商名
		   sp_operator_name,--服务商经理名
		   service_user_names_freezed,--冻结销售人员姓名
		   service_feature_names_freezed,--冻结销售人员职能
		   service_job_names_freezed,--冻结销售人员角色
		   service_department_names_freezed,--冻结销售人员部门
           service_info_freezed,
           service_info,
		   --默认指标--
           sum(gmv_less_refund) as gmv_less_refund,  --实货gmv-退款
           sum(gmv) as gmv,--实货gmv
		   sum(pay_amount) as pay_amount,--实货支付金额
		   sum(pay_amount_less_refund) as pay_amount_less_refund,--实货支付金额-退款
           sum(refund_actual_amount) as refund_actual_amount,--实货退款
           sum(refund_retreat_amount) as refund_retreat_amount,--实货清退金额
           pay_day
    from
    ---业务中间表
      dw_salary_gmv_rule_public_mid_v2_d
   ---过滤条件中的 全局过滤条件
   where dayid ='$v_date'
   and pay_day between '20211201' and '20211231'
            and



                                sale_team_freezed_id
                        in ('2'  )
                and


            array_contains(split(shop_group,','), '15878')
                    and



                                item_style_name
                        in ('B'  )
                and



                                category_id_first
                        in ('12'  )
                and



                                brand_id
                        in ('15743' , '16241' , '17659'  )
                and



                                war_zone_dep_id
                        in ('1657'  )
                and



                                area_manager_dep_id
                        in ('38'  )
            group by
	       business_unit,--业务域
           category_id_first,  --商品一级类目
           category_id_second, --商品二级类目
           category_id_first_name,
           category_id_second_name,
	       brand_id,
	       brand_name,--商品品牌
           item_id,
		   item_name,--商品名称
		   item_style,
		   item_style_name,--ab类型
           is_sp_shop,--是否服务商订单
	       is_bigbd_shop,--是否大BD门店
           is_spec_order,--是否特殊订单
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
		   sp_id,
           sp_name,--服务商名
		   sp_operator_name,--服务商经理名(冻结)
		   service_user_names_freezed,--冻结销售人员姓名
		   service_feature_names_freezed,--冻结销售人员职能
		   service_job_names_freezed,--冻结销售人员角色
		   service_department_names_freezed,--冻结销售人员部门
           service_info_freezed,
           service_info,
           pay_day
) gmv_mid

) gmv_rule
left join
( select user_id, substr(leave_time,1,8) as leave_time from dwd_user_admin_d where dayid='$v_date'
) users on gmv_rule.grant_object_user_id =users.user_id
where gmv_rule.grant_object_user_id is not null;







insert overwrite table dw_salary_forward_plan_sum_d partition (dayid='$v_date',planno='14473')
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
    concat('grant_object_rk:',nvl(case when '累计阶梯返点' ='排名返现' then grant_object_rk else null end,''),'\;','grant_object_underling_cnt:',nvl(case when sts_target_name in ('人均实货支付金额(去优惠券去退款)','人均实货GMV(去退款)') then grant_object_underling_cnt else null end,'')) as real_coefficient_goal_rate,
            null as commission_cap,
        --提成方案类型
            '累计阶梯返点' as commission_plan_type,
        --提成奖品类型
            '金额' as commission_reward_type
        --无系数
    --根据统计指标数值及提成上限 换算出 提成奖品
    --累计阶梯逻辑
    --判断必须从大到小

                                -- 累计返点
            ,case
                    when
                        sts_target  >=  10000
                                                    then round(sts_target * 0.040000, 4)
                            when
                        sts_target  >=  8000
                 and                         sts_target  <  10000
                                                    then round(sts_target * 0.030000, 4)
                            when
                        sts_target  >=  5000
                 and                         sts_target  <  8000
                                                    then round(sts_target * 0.020000, 4)
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
        grant_object_user_name,--发放对象名称
        grant_object_user_dep_id,--发放对象部门ID
        grant_object_user_dep_name,--发放对象部门
        leave_time,--发放对象离职时间
        --统计指标名称
        sts_target_name,
        --发放对象的当月系数
        sts_target,
        grant_object_underling_cnt,
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
            grant_object_user_name,--发放对象名称
            grant_object_user_dep_id,--发放对象部门ID
            grant_object_user_dep_name,--发放对象部门
            leave_time,--发放对象离职时间
            --统计指标名称
            sts_target_name,
            max(nvl(underling_cnt,1)) as grant_object_underling_cnt,

            --发放对象的当月系数
                        --统计指标为非人均指标
            sum(sts_target) as sts_target
                    from (
            select *
            from dw_salary_gmv_rule_public_d
            where dayid ='$v_date' and pltype='cur' and planno='14473'
        ) t
        left join (
            select user_id,underling_cnt
            from dws_usr_bd_manager_underling_d
            where dayid ='$v_date'
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
            grant_object_user_name,--发放对象名称,
            grant_object_user_dep_id,--发放对象部门ID
            grant_object_user_dep_name,--发放对象部门
            leave_time,--发放对象离职时间
            --统计指标名称
            sts_target_name
         ) forward_plan_tmp
	) forward_plan
;