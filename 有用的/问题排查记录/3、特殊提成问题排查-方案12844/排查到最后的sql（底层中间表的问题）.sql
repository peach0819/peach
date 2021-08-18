
--订单表
with order1 as (
    select order_id,
           trade_no,
           business_unit,--业务域,
           brand_id,
           brand_name,--商品品牌,
           item_id,
           item_name,--商品名称,
           item_style,
           case when item_style = 0 then 'A' when item_style = 1 then 'B' else '其他' end as item_style_name,--ab类型,
           '否'                                                                          as is_sp_shop,--是否服务商订单
           case
               when ytdw.get_service_info('service_feature_id:4', service_info_freezed, 'service_user_id') is not null
                   then '是'
               else '否' end                                                             as is_bigbd_shop,--是否大BD门店
           substr(shop_item_sign_time, 1, 8)                                            as shop_item_sign_day,
           shop_item_sign_time,
           substr(shop_brand_sign_time, 1, 8)                                           as shop_brand_sign_day,
           shop_brand_sign_time,
           pay_time,
           pay_day,
           shop_id,
           shop_name,--门店名称,
           store_type,--门店类型,
           store_type_name,
           case
               when sale_team_name = 'BD部' then ytdw.get_service_info('service_job_name:BD', service_info_freezed,
                                                                      'service_user_id')
               when sale_team_name = '大客户部' then ytdw.get_service_info('service_job_name:大BD', service_info_freezed,
                                                                       'service_user_id')
               else null end                                                            as service_user_id_freezed,
           case
               when sale_team_name = 'BD部' then ytdw.get_service_info('service_job_name:BD', service_info_freezed,
                                                                      'service_department_id')
               when sale_team_name = '大客户部' then ytdw.get_service_info('service_job_name:大BD', service_info_freezed,
                                                                       'service_department_id')
               else null end                                                            as service_department_id_freezed,
           case
               when sale_team_name = 'BD部' then ytdw.get_service_info('service_job_name:BD', service_info_freezed,
                                                                      'service_user_name')
               when sale_team_name = '大客户部' then ytdw.get_service_info('service_job_name:大BD', service_info_freezed,
                                                                       'service_user_name')
               else null end                                                            as service_user_name_freezed,--冻结销售人员姓名,
           case
               when sale_team_name = 'BD部' then ytdw.get_service_info('service_job_name:BD', service_info_freezed,
                                                                      'service_feature_name')
               when sale_team_name = '大客户部' then ytdw.get_service_info('service_job_name:大BD', service_info_freezed,
                                                                       'service_feature_name')
               else null end                                                            as service_feature_name_freezed,--冻结销售人员职能,
           case
               when sale_team_name = 'BD部' then ytdw.get_service_info('service_job_name:BD', service_info_freezed,
                                                                      'service_job_name')
               when sale_team_name = '大客户部' then ytdw.get_service_info('service_job_name:大BD', service_info_freezed,
                                                                       'service_job_name')
               else null end                                                            as service_job_name_freezed,--冻结销售人员角色,
           case
               when sale_team_name = 'BD部' then ytdw.get_service_info('service_job_name:BD', service_info_freezed,
                                                                      'service_department_name')
               when sale_team_name = '大客户部' then ytdw.get_service_info('service_job_name:大BD', service_info_freezed,
                                                                       'service_department_name')
               else null end                                                            as service_department_name_freezed,--冻结销售人员部门,
           --默认指标--
           pay_amount,--实货支付金额
           gmv,--实货gmv,
           sale_team_name,
           sale_team_freezed_name,
           service_info_freezed
    from (
             select order_id,
                    trade_no,
                    business_unit,--业务域,
                    brand_id,
                    brand_name,--商品品牌,
                    item_id,
                    item_name,--商品名称,
                    item_style,
                    first_value(pay_time) over (partition by shop_id,item_id order by pay_time)  as shop_item_sign_time,
                    first_value(pay_time)
                                over (partition by shop_id,brand_id order by pay_time)           as shop_brand_sign_time,
                    pay_time,
                    pay_day,
                    shop_id,
                    shop_name,--门店名称,
                    store_type,--门店类型,
                    store_type_name,
                    service_info_freezed,
                    --默认指标--
                    pay_amount,--实货支付金额
                    total_pay_amount                                                             as gmv,--实货gmv
                    sale_team_name,
                    sale_team_freezed_name
             from dw_order_d
             where dayid = '$v_date'
               and pay_time is not null
               and bu_id = 0
               --剔除美妆、员工店、伙伴店
               -- and nvl(store_type,100) not in (3,9,11)
               -- and sale_dc_id=-1
               and sp_id is null --剔除服务商订单
               and business_unit not in ('卡券票', '其他')
               and item_style = 1
               AND shop_name IN ('五河县皇家宝贝母婴馆','明光女山湖皇家孕婴', '萌宝乐园母婴生活馆五河县城南店')
         ) order_mid
    where substr(shop_brand_sign_time, 1, 8) >= '$v_120_days_ago'
       or substr(shop_item_sign_time, 1, 8) >= '$v_120_days_ago'
),

--退款表
     refund as (
         select order_id,sum(refund_actual_amount) as refund_actual_amount,
                sum(case when multiple_refund=10 then refund_actual_amount else 0 end) as refund_retreat_amount
         from dw_afs_order_refund_new_d --（后期通过type识别清退金额）
         where dayid ='$v_date'
           and refund_status=9
         group by order_id
     )

select order1.order_id,
       order1.trade_no,
       business_unit,--业务域,
       item_id,
       item_name,--商品名称,
       shop_item_sign_day,
       shop_item_sign_time,
       shop_brand_sign_day,
       shop_brand_sign_time,
       order1.shop_id,
       shop_name,--门店名称,
       service_user_name_freezed,--冻结销售人员姓名,
       service_feature_name_freezed,--冻结销售人员职能,
       service_job_name_freezed,--冻结销售人员角色,
       service_department_name_freezed,--冻结销售人员部门,
       sale_team_name,
       sale_team_freezed_name,
       service_info_freezed
from order1
         left join refund on order1.order_id=refund.order_id
order by shop_name desc