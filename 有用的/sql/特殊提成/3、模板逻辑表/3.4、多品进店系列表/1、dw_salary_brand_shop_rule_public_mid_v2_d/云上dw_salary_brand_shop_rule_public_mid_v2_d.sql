with user_admin as (
    SELECT user_id, job_id, job_name
    FROM ytdw.dim_ytj_pub_user_admin_m
    WHERE dayid = '${v_cur_month}'
)

insert overwrite table dw_salary_brand_shop_rule_public_mid_v2_d partition(dayid='${v_date}')
select ord.order_id,
       ord.trade_id,

       --商品信息
       ord.category_1st_id,
       ord.category_1st_name,
       ord.category_2nd_id,
       ord.category_2nd_name,
       ord.brand_id,
       ord.brand_name,
       ord.item_id,
       ord.item_name,
       ord.item_style,
       ord.item_style_name,

       --门店信息
       ord.shop_id,
       ord.shop_name,
       ord.shop_store_type as store_type,
       ord.shop_store_type_name as store_type_name,
       shop.war_zone_id,
       shop.war_zone_name,
       shop.war_zone_dep_id,
       shop.war_zone_dep_name,
       shop.area_manager_id,
       shop.area_manager_name,
       shop.area_manager_dep_id,
       shop.area_manager_dep_name,
       shop.bd_manager_id,
       shop.bd_manager_name,
       shop.bd_manager_dep_id,
       shop.bd_manager_dep_name,
       null as shop_group,

       --订单信息
       ord.pay_date,
       ord.rfd_date,
       ord.act_pay_total_amt_1d as gmv, --gmv
       ord.act_rfd_amt_1d as refund, --退款
       ord.act_net_pay_total_amt_1d as gmv_less_refund, --gmv-退款

       --销售团队信息
       ord_seller.sale_team_id,
       ord_seller.sale_team_name,
       ord_seller.sale_team_freezed_id,
       ord_seller.sale_team_freezed_name,

       --订单归属信息
       frozen_trade.trade_service_bd_id_frez as frozen_sale_user_id,
       rule_center.newest_user_id as newest_sale_user_id,

       --三级类目
       ord.category_3rd_id,
       ord.category_3rd_name
--订单表
from (
    SELECT order_id,
           trade_id,
           category_1st_id,
           category_1st_name,
           category_2nd_id,
           category_2nd_name,
           category_3rd_id,
           category_3rd_name,
           if(brand_id IN (15472, 19284), 19284, brand_id) as brand_id,
           if(brand_id IN (15472, 19284), '棉之悦', brand_name) as brand_name,
           item_id,
           item_name,
           item_style,
           item_style_name,
           shop_id,
           shop_name,
           shop_store_type,
           shop_store_type_name,

           pay_date,
           rfd_date,
           act_pay_total_amt_1d, --gmv
           act_rfd_amt_1d, --退款
           act_net_pay_total_amt_1d --gmv-退款
    FROM ytdw.dws_hpc_trd_act_detail_d
    WHERE dayid = '${v_date}'
    -- 保留500天的订单数据
    AND pay_date >= '${v_500_days_ago}'
) ord

--门店表
left join (
    select shop_id,
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
           bd_manager_dep_name 	--区域
    from ytdw.dw_shop_base_d
    where dayid ='${v_date}'
) shop on ord.shop_id=shop.shop_id

--订单销售团队表
LEFT JOIN (
    SELECT order_id,
           sale_team_id,
           sale_team_name,
           sale_team_freezed_id,
           sale_team_freezed_name
    FROM ytdw.dim_hpc_trd_ord_seller_d
    WHERE dayid = '${v_date}'
) ord_seller ON ord.order_id = ord_seller.order_id

--规则中心数据
LEFT JOIN (
    SELECT order_id,
           if(user_admin.job_id = 8, r.newest_user_id, null) as newest_user_id
    FROM ytdw.dim_hpc_ord_finance_order_ascription_d r
    LEFT JOIN user_admin ON r.newest_user_id = user_admin.user_id
    WHERE dayid = '${v_date}'
) rule_center ON ord.order_id = rule_center.order_id

--冻结数据
LEFT JOIN (
    SELECT trade_id,
           if(user_admin.job_id = 8, f.trade_service_bd_id_frez, null) as trade_service_bd_id_frez
    FROM ytdw.dim_hpc_trd_trade_service_d f
    LEFT JOIN user_admin ON f.trade_service_bd_id_frez = user_admin.user_id
    WHERE dayid = '${v_date}'
) frozen_trade ON frozen_trade.trade_id = ord.trade_id