with sign_tmp as (
    select brand_id,
           brand_name,--商品品牌
           item_style,
           item_style_name,--ab类型
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
           service_user_id_freezed,
           service_department_id_freezed,
           service_user_name_freezed,--冻结销售人员姓名
           service_feature_name_freezed,--冻结销售人员职能
           service_job_name_freezed,--冻结销售人员角色
           service_department_name_freezed,--冻结销售人员部门
           min(pay_time)                                                as new_sign_time,--新签时间
           min(pay_day)                                                 as new_sign_day, --新签日期
           shop_brand_sign_day,--门店品牌新签时间
           --默认指标--
           sum(gmv_less_refund)                                         as gmv_less_refund, --实货gmv-退款
           sum(gmv)                                                     as gmv,--实货gmv
           sum(pay_amount)                                              as pay_amount,--实货支付金额
           sum(pay_amount_less_refund)                                  as pay_amount_less_refund,--实货支付金额-退款
           sum(refund_actual_amount)                                    as refund_actual_amount,--实货退款
           sum(refund_retreat_amount)                                   as refund_retreat_amount,--实货清退金额
           1600                                                         as new_sign_line,
           case when sum(gmv_less_refund) >= 1600 then '是' else '否' end as is_over_sign_line--是否满足新签门槛
           ---业务中间表
    from dw_salary_sign_rule_public_mid_v2_d big_tbl
         ---过滤条件中的 全局过滤条件
    where dayid = '$v_date'
      and shop_brand_sign_day between '20210801' and '20210831'
      and pay_day <= '20210831'

      and sale_team_id
        in ('2')
      and item_style_name
        in ('B')
      and category_id_first
        in ('12')
      and category_id_second
        in ('9764')
      and brand_id
        in ('12766')
      and war_zone_dep_id
        in ('1657')
      and area_manager_dep_id
        in ('38')
    group by brand_id,
             brand_name,--商品品牌
             item_style,
             item_style_name,--ab类型
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
             service_user_id_freezed,
             service_department_id_freezed,
             service_user_name_freezed,--冻结销售人员姓名
             service_feature_name_freezed,--冻结销售人员职能
             service_job_name_freezed,--冻结销售人员角色
             service_department_name_freezed,--冻结销售人员部门
             shop_brand_sign_day
),

sign_mid as (
    select brand_id,
           brand_name,--商品品牌
           item_style,
           item_style_name,--ab类型
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
           service_user_id_freezed,
           service_department_id_freezed,
           service_user_name_freezed,--冻结销售人员姓名
           service_feature_name_freezed,--冻结销售人员职能
           service_job_name_freezed,--冻结销售人员角色
           service_department_name_freezed,--冻结销售人员部门
           new_sign_time,--新签时间
           new_sign_day, --新签日期
           row_number()
                   over (partition by shop_id,brand_id,is_over_sign_line order by new_sign_time) as new_sign_rn,--新签时间排名达成
           shop_brand_sign_day,--门店品牌新签时间
           --默认指标--
           gmv_less_refund, --实货gmv-退款
           gmv,--实货gmv
           pay_amount,--实货支付金额
           pay_amount_less_refund,--实货支付金额-退款
           refund_actual_amount,--实货退款
           refund_retreat_amount,--实货清退金额
           is_over_sign_line,
           new_sign_line
    from sign_tmp
)

select brand_id,
       brand_name,--商品品牌
       item_style,
       item_style_name,--ab类型
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
       service_user_id_freezed,
       service_department_id_freezed,
       service_user_name_freezed,--冻结销售人员姓名
       service_feature_name_freezed,--冻结销售人员职能
       service_job_name_freezed,--冻结销售人员角色
       service_department_name_freezed,--冻结销售人员部门
       new_sign_time,--新签时间
       new_sign_day, --新签日期
       new_sign_rn,--新签时间排名达成
       shop_brand_sign_day,--门店品牌新签时间
       --默认指标--
       gmv_less_refund, --实货gmv-退款
       gmv,--实货gmv,
       pay_amount,--实货支付金额
       pay_amount_less_refund,--实货支付金额-退款
       refund_actual_amount,--实货退款
       refund_retreat_amount,--实货清退金额
       new_sign_line,
       is_over_sign_line,--是否满足新签门槛
       case when new_sign_rn = 1 then '是' else '否' end                                      as is_first_sign,--是否首次达成
       case when gmv_less_refund >= new_sign_line and new_sign_rn = 1 then '是' else '否' end as is_succ_sign,--是否新签成功
       '【岗位】BD'                                                                             as grant_object_type,
       --发放对象用户ID
       service_user_id_freezed                                                              as grant_object_user_id,
       --发放对象用户姓名
       service_user_name_freezed                                                            as grant_object_user_name,
       -- 发放对象部门ID
       service_department_id_freezed                                                        as grant_object_user_dep_id,
       service_department_name_freezed                                                      as grant_object_user_dep_name
from sign_mid
