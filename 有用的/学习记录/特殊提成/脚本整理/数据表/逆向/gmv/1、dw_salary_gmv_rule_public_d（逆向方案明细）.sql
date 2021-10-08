insert overwrite table dw_salary_gmv_rule_public_d partition (dayid = '$v_date', planno = '13165', pltype = 'pre')
select from_unixtime(unix_timestamp(), 'yyyy-MM-dd HH:mm:ss')                                      as update_time,--更新时间
       from_unixtime(unix_timestamp(), 'yyyy-MM')                                                  as update_month,--执行月份
       '历史方案'                                                                                      as plan_type,--明细类型
       --方案基础信息,
       '202109'                                                                                    as plan_month,--方案月份
       '2021-09-01~2021-09-30'                                                                     as plan_pay_time,--方案时间
       '9月家清洗护-GMV奖励-主管.'                                                                          as plan_name,--方案名称
       '3'                                                                                         as plan_group_id, --归属业务组id
       'B类用品组'                                                                                     as plan_group_name, --归属业务组
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
       '实货支付金额(去优惠券去退款)'                                                                           as sts_target_name--统计指标名称

        ,
       case
           when (users.leave_time is null or pay_day <= users.leave_time)
               then
               pay_amount_less_refund
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
                               where dayid = '20210930'
                                 and pay_day between '20210901' and '20210930'
                                 and sale_team_freezed_id
                                   in ('2')
                                 and item_style_name
                                   in ('B')
                                 and category_id_first
                                   in ('2711', '2794')
                                 and brand_id
                                   in ('6498', '10056')
                                 and war_zone_dep_id
                                   in ('610')
                                 and area_manager_dep_id
                                   in ('444', '1847')
                              )
                          order
                              --退款表
                              left join
    (select order_id,sum(refund_actual_amount) as refund_actual_amount,
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
     (select user_id, substr(leave_time, 1, 8) as leave_time from dwd_user_admin_d where dayid = '20210930'
     ) users on gmv_rule.grant_object_user_id = users.user_id
where gmv_rule.grant_object_user_id is not null;