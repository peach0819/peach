use ytdw;

-- 历史明细
insert overwrite table dw_salary_gmv_rule_public_d partition (dayid = '$v_date', planno = '12381', pltype = 'pre')
select from_unixtime(unix_timestamp(), 'yyyy-MM-dd HH:mm:ss')                                      as update_time,--更新时间
       from_unixtime(unix_timestamp(), 'yyyy-MM')                                                  as update_month,--执行月份
       '历史方案'                                                                                      as plan_type,--明细类型
       --方案基础信息,
       '202106'                                                                                    as plan_month,--方案月份
       '2021-06-01~2021-06-30'                                                                     as plan_pay_time,--方案时间
       '6月商品2组家清用品P0打面to主管彼德露虎先生梦想味道'                                                              as plan_name,--方案名称
       '3'                                                                                         as plan_group_id, --归属业务组id
       'B类食品用品组'                                                                                   as plan_group_name, --归属业务组
       business_unit,--业务域,
       category_id_first, --商品一级类目
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
       war_zone_id, --战区经理ID
       war_zone_name, --战区经理
       war_zone_dep_id, --战区ID
       war_zone_dep_name, --战区
       area_manager_id, --大区经理id
       area_manager_name, --大区经理
       area_manager_dep_id,--大区区域ID
       area_manager_dep_name, --大区
       bd_manager_id,--主管id
       bd_manager_name,--主管
       bd_manager_dep_id,--主管区域ID
       bd_manager_dep_name,--区域
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
       gmv_less_refund, --实货gmv-退款
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
       users.leave_time                                                                            as leave_time,--发放对象离职时间
       case when users.leave_time is not null and pay_day > users.leave_time then '是' else '否' end as is_leave,--发放对象是否离职
       ---统计指标----
       --方案配置 无指标计算型 过滤条件
       '实货GMV(去退款)'                                                                                as sts_target_name--统计指标名称

        ,
       case
           when (users.leave_time is null or pay_day <= users.leave_time)
               then
               gmv_less_refund
           else 0 end                                                                              as sts_target, --统计指标数值
       pay_day
from (
         select business_unit,--业务域,
                category_id_first, --商品一级类目
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
                war_zone_id, --战区经理ID
                war_zone_name, --战区经理
                war_zone_dep_id, --战区ID
                war_zone_dep_name, --战区
                area_manager_id, --大区经理id
                area_manager_dep_id,--大区区域ID
                area_manager_name, --大区经理
                area_manager_dep_name, --大区
                bd_manager_id,--主管id
                bd_manager_name,--主管
                bd_manager_dep_id,--主管区域ID
                bd_manager_dep_name,--区域
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
                gmv_less_refund, --实货gmv-退款
                gmv,--实货gmv
                pay_amount,--实货支付金额
                pay_amount_less_refund,--实货支付金额-退款
                refund_actual_amount,--实货退款
                refund_retreat_amount,--实货清退金额
                --发放对象--
                '【辖区】BD主管'          as grant_object_type,--发放对象类型
                bd_manager_id       as grant_object_user_id, --发放对象用户ID
                bd_manager_name     as grant_object_user_name, --发放对象用户姓名
                bd_manager_dep_id   as grant_object_user_dep_id,-- 发放对象部门ID
                bd_manager_dep_name as grant_object_user_dep_name --发放对象部门名称
         from (
                  select business_unit,--业务域,
                         category_id_first, --商品一级类目,
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
                         shop_id,
                         shop_name,--门店名称,
                         store_type,--门店类型,
                         store_type_name,
                         war_zone_id, --战区经理ID
                         war_zone_name, --战区经理
                         war_zone_dep_id, --战区ID
                         war_zone_dep_name, --战区
                         area_manager_id, --大区经理id
                         area_manager_name, --大区经理
                         area_manager_dep_id,--大区区域ID
                         area_manager_dep_name, --大区
                         bd_manager_id,--主管id
                         bd_manager_name,--主管
                         bd_manager_dep_id,--主管区域ID
                         bd_manager_dep_name,--区域
                         sp_id,
                         sp_name,--服务商名,
                         sp_operator_name,--服务商经理名,
                         service_user_names_freezed,--冻结销售人员姓名,
                         service_feature_names_freezed,--冻结销售人员职能,
                         service_job_names_freezed,--冻结销售人员角色,
                         service_department_names_freezed,--冻结销售人员部门,
                         service_info_freezed,
                         service_info,
                         --默认指标--
                         sum(gmv_less_refund)        as gmv_less_refund, --实货gmv-退款,
                         sum(gmv)                    as gmv,--实货gmv,
                         sum(pay_amount)             as pay_amount,--实货支付金额
                         sum(pay_amount_less_refund) as pay_amount_less_refund,--实货支付金额-退款
                         sum(refund_actual_amount)   as refund_actual_amount,--实货退款,
                         sum(refund_retreat_amount)  as refund_retreat_amount,--实货清退金额
                         pay_day
                  from
                      ---业务中间表
                      (
                          select business_unit,--业务域,
                                 category_id_first, --商品一级类目,
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
                                 shop_id,
                                 shop_name,--门店名称,
                                 store_type,--门店类型,
                                 store_type_name,
                                 war_zone_id, --战区经理ID
                                 war_zone_name, --战区经理
                                 war_zone_dep_id, --战区ID
                                 war_zone_dep_name, --战区
                                 area_manager_id, --大区经理id
                                 area_manager_name, --大区经理
                                 area_manager_dep_id, --大区区域ID
                                 area_manager_dep_name, --大区
                                 bd_manager_id,--主管id
                                 bd_manager_name,--主管
                                 bd_manager_dep_id,--主管区域ID
                                 bd_manager_dep_name,--区域
                                 sp_id,
                                 sp_name,--服务商名,
                                 sp_operator_name,--服务商经理名,
                                 service_user_names_freezed,--冻结销售人员姓名,
                                 service_feature_names_freezed,--冻结销售人员职能,
                                 service_job_names_freezed,--冻结销售人员角色,
                                 service_department_names_freezed,--冻结销售人员部门,
                                 service_info_freezed,
                                 service_info,
                                 --默认指标--
                                 case
                                     when business_unit not in ('卡券票', '其他')
                                         then order.gmv - nvl(refund.refund_actual_amount, 0)
                                     else 0 end                                                                as gmv_less_refund, --实货gmv-退款,
                                 case
                                     when business_unit not in ('卡券票', '其他') then order.pay_amount
                                     else 0 end                                                                as pay_amount,--实货支付金额
                                 case
                                     when business_unit not in ('卡券票', '其他')
                                         then order.pay_amount - nvl(refund.refund_actual_amount, 0)
                                     else 0 end                                                                as pay_amount_less_refund,--实货支付金额-退款
                                 case when business_unit not in ('卡券票', '其他') then order.gmv else 0 end        as gmv,--实货gmv,
                                 case
                                     when business_unit not in ('卡券票', '其他') then nvl(refund.refund_actual_amount, 0)
                                     else 0 end                                                                as refund_actual_amount,--实货退款,
                                 case
                                     when business_unit not in ('卡券票', '其他') then nvl(refund.refund_retreat_amount, 0)
                                     else 0 end                                                                as refund_retreat_amount,--实货清退金额
                                 pay_day
                          from
                              --订单表
                              (select *
                               from dw_salary_gmv_rule_public_mid_v2_d
                               where dayid = '20210630'
                                 and pay_day between '20210601' and '20210630'
                                 and sale_team_freezed_id
                                   in ('2')
                                 and category_id_first
                                   in ('2711', '2794')
                                 and brand_id
                                   in ('6498', '14700', '15510')
                                 and war_zone_dep_id
                                   in ('612')
                                 and area_manager_dep_id
                                   in ('1649')
                              )
                          order
                              --退款表
                              left join
                              (select order_id, sum(refund_actual_amount) as refund_actual_amount,
                              sum(case when multiple_refund=10 then refund_actual_amount else 0 end) as refund_retreat_amount
                              from dw_afs_order_refund_new_d --（后期通过type识别清退金额）
                              where dayid ='$v_date'
                              and refund_status=9
                              group by order_id
                              ) refund
                          on
                          order.order_id=refund.order_id
                      ) big_tbl
                  group by business_unit,--业务域,
                           category_id_first, --商品一级类目,
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
                           shop_id,
                           shop_name,--门店名称,
                           store_type,--门店类型,
                           store_type_name,
                           war_zone_id, --战区经理ID
                           war_zone_name, --战区经理
                           war_zone_dep_id, --战区ID
                           war_zone_dep_name, --战区
                           area_manager_id, --大区经理id
                           area_manager_name, --大区经理
                           area_manager_dep_id,--大区区域ID
                           area_manager_dep_name, --大区
                           bd_manager_id,--主管id
                           bd_manager_name,--主管
                           bd_manager_dep_id,--主管区域ID
                           bd_manager_dep_name,--区域
                           sp_id,
                           sp_name,--服务商名,
                           sp_operator_name,--服务商经理名(冻结),
                           service_user_names_freezed,--冻结销售人员姓名,
                           service_feature_names_freezed,--冻结销售人员职能,
                           service_job_names_freezed,--冻结销售人员角色,
                           service_department_names_freezed,--冻结销售人员部门,
                           service_info_freezed,
                           service_info,
                           pay_day
              ) gmv_mid
     ) gmv_rule
         left join
     (select user_id, substr(leave_time, 1, 8) as leave_time from dwd_user_admin_d where dayid = '20210630'
     ) users on gmv_rule.grant_object_user_id = users.user_id
where gmv_rule.grant_object_user_id is not null;



insert overwrite table dw_salary_backward_plan_sum_mid_d partition (dayid = '$v_date', planno = '12381')
select from_unixtime(unix_timestamp(), 'yyyy-MM-dd HH:mm:ss') as update_time,--更新时间
       from_unixtime(unix_timestamp(), 'yyyy-MM')             as update_month,--执行月份
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
       concat('grant_object_rk:', nvl(case when '累计阶梯返点' = '排名返现' then grant_object_rk else null end, ''), '\;',
              'grant_object_underling_cnt:', '')              as real_coefficient_goal_rate,
       null                                                   as commission_cap,
       --提成方案类型
       '累计阶梯返点'                                               as commission_plan_type,
       --提成奖品类型
       '金额'                                                   as commission_reward_type
       --无系数
       --根据统计指标数值及提成上限 换算出 提成奖品
       --累计阶梯逻辑
       --判断必须从大到小

       -- 累计返点
        ,
       case
           when
               sts_target >= 0
               then round(sts_target * 0.010000, 4)
           else '0' end                                       as commission_reward --提成奖品
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
             --发放对象的当月系数
             sts_target,
             if(sts_target > 0, rank() over (order by sts_target desc ), null) as grant_object_rk
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
                      --发放对象的当月系数
                      sum(sts_target) as sts_target
                  from dw_salary_gmv_rule_public_d
                  where dayid = '$v_date'
                    and pltype = 'pre'
                    and planno = '12381'
                  group by plan_month,--方案月份
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