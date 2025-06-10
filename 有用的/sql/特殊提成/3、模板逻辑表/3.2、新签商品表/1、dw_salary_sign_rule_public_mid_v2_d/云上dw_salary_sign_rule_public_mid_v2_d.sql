with ord_base as (
    SELECT *
    FROM ytdw.dw_order_d
    WHERE dayid = '${v_date}'
    and substr(pay_time, 1, 8) <= '${v_date}'
    and pay_time is not null
    and bu_id=0
    and sp_id is null --剔除服务商订单
    and business_unit not in ('卡券票','其他')
),

item as (
    SELECT item_id,
           brand_id,
           brand_series_id,
           brand_series_name
    FROM ytdw.dim_ytj_itm_item_d
    WHERE dayid = '${v_date}'
    AND business_unit not in ('卡券票','其他')
),

--商品维度新签时间
item_sign_day as (
    select shop_id,
           item_id,
           min_pay_time as sign_time
    from ytdw.dws_hpc_shop_item_new_sign_d
    where dayid = '${v_date}'
    and substr(min_pay_time, 1, 8) <= '${v_date}'
),

--品牌维度新签时间
brand_sign_day as (
    select item_sign_day.shop_id,
           item.brand_id,
           min(item_sign_day.sign_time) as sign_time
    FROM item_sign_day
    INNER JOIN item ON item_sign_day.item_id = item.item_id
    group by item_sign_day.shop_id,
             item.brand_id
),

--品牌系列维度新签时间
brand_series_sign_day as (
    select item_sign_day.shop_id,
           item.brand_id,
           item.brand_series_id,
           min(item_sign_day.sign_time) as sign_time
    FROM item_sign_day
    INNER JOIN item ON item_sign_day.item_id = item.item_id
    group by item_sign_day.shop_id,
             item.brand_id,
             item.brand_series_id
),

order_mid as (
    select ord_base.order_id,
           ord_base.trade_no,
           ord_base.business_unit,--业务域,
           ord_base.category_id_first,  --商品一级类目,
           ord_base.category_id_second, --商品二级类目,
           ord_base.category_id_first_name,
           ord_base.category_id_second_name,
           ord_base.category_id_third,
           ord_base.category_id_third_name,
           ord_base.brand_id,
           ord_base.brand_name,--商品品牌,
           ord_base.item_id,
           ord_base.item_name,--商品名称,
           ord_base.item_style,
           ord_base.pay_time,
           ord_base.pay_day,
           ord_base.shop_id,
           ord_base.shop_name,--门店名称,
           ord_base.store_type,--门店类型,
           ord_base.store_type_name,
    	   ord_base.service_info_freezed,

           --默认指标--
           ord_base.pay_amount,--实货支付金额
           ord_base.total_pay_amount as gmv,--实货gmv
    	   ord_base.sale_team_name,
    	   ord_base.sale_team_freezed_name,

           --品牌系列
           item.brand_series_id,
           item.brand_series_name,

           --新签时间
           item_sign_day.sign_time as shop_item_sign_time,
           brand_sign_day.sign_time as shop_brand_sign_time,
           brand_series_sign_day.sign_time as shop_brand_series_sign_time
    from ord_base
    LEFT JOIN item ON ord_base.item_id = item.item_id
    LEFT JOIN item_sign_day ON ord_base.shop_id = item_sign_day.shop_id and ord_base.item_id = item_sign_day.item_id
    LEFT JOIN brand_sign_day ON ord_base.shop_id = brand_sign_day.shop_id and ord_base.brand_id = brand_sign_day.brand_id
    LEFT JOIN brand_series_sign_day ON ord_base.shop_id = brand_series_sign_day.shop_id and ord_base.brand_id = brand_series_sign_day.brand_id and item.brand_series_id = brand_series_sign_day.brand_series_id
)

insert overwrite table dw_salary_sign_rule_public_mid_v2_d partition (dayid='${v_date}')
select order.order_id,
       order.trade_no,
       business_unit,--业务域,
       category_id_first,  --商品一级类目,
       category_id_second, --商品二级类目,
       category_id_first_name,
       category_id_second_name,
       order.brand_id,
       brand_name,--商品品牌,
       order.item_id,
       item_name,--商品名称,
       item_style,
       item_style_name,--ab类型,
       is_sp_shop,--是否服务商订单
       is_bigbd_shop,--是否大BD门店
       case when spec_order.trade_no is not null then '是' else '否' end as is_spec_order,--是否特殊订单,
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
       nvl(refund.refund_retreat_amount,0) as refund_retreat_amount,--实货清退金额
       sale_team_name,
       sale_team_freezed_name,
       case when sale_team_name='电销部' then 1 when sale_team_name='BD部' then 2 when sale_team_name='大客户部' then 3 when sale_team_name='服务商部' then 4
       		 when sale_team_name='美妆销售团队' then 5 else null end as sale_team_id,
       case when sale_team_freezed_name='电销部' then 1 when sale_team_freezed_name='BD部' then 2 when sale_team_freezed_name='大客户部' then 3 when sale_team_freezed_name='服务商部' then 4
       		 when sale_team_freezed_name='美妆销售团队' then 5 else null end as sale_team_freezed_id,
       null as shop_group,
       category_id_third,
       category_id_third_name,

       --品牌标签
       item.item_brand_tag_code,
       item.item_brand_tag_name,

       --品牌类型 大包小包
       if(big_pack.brand_id is not null, '大包', '小包') as brand_type,

       --品牌系列
       order.brand_series_id,
       order.brand_series_name,
       order.shop_brand_series_sign_day,
       order.shop_brand_series_sign_time
--订单表
from (
    select order_id,
           trade_no,
           business_unit,--业务域,
           category_id_first,  --商品一级类目,
           category_id_second, --商品二级类目,
           category_id_first_name,
           category_id_second_name,
           category_id_third,
           category_id_third_name,
           brand_id,
           brand_name,--商品品牌,
           item_id,
           item_name,--商品名称,
           item_style,
      	   case when item_style=0 then 'A' when item_style=1 then 'B' else '其他' end as item_style_name,--ab类型,
           '否' as is_sp_shop,--是否服务商订单
           case when yt_crm.get_service_info('service_feature_id:4',service_info_freezed,'service_user_id') is not null then '是' else '否' end as is_bigbd_shop,--是否大BD门店
           substr(shop_item_sign_time,1,8) as shop_item_sign_day,
           shop_item_sign_time,
           substr(shop_brand_sign_time,1,8) as shop_brand_sign_day,
           shop_brand_sign_time,
           substr(shop_brand_series_sign_time,1,8) as shop_brand_series_sign_day,
           shop_brand_series_sign_time,
           pay_time,
           pay_day,
           shop_id,
           shop_name,--门店名称,
           store_type,--门店类型,
           store_type_name,
      	   case when sale_team_name ='BD部' then yt_crm.get_service_info('service_job_name:BD;service_job_freezed_name:BD',service_info_freezed,'service_user_id')
      	        when sale_team_name ='大客户部' then yt_crm.get_service_info('service_job_name:大BD',service_info_freezed,'service_user_id')
      	        else null end as service_user_id_freezed,
           case when sale_team_name ='BD部' then yt_crm.get_service_info('service_job_name:BD;service_job_freezed_name:BD',service_info_freezed,'service_department_id')
      	        when sale_team_name ='大客户部' then yt_crm.get_service_info('service_job_name:大BD',service_info_freezed,'service_department_id')
      	        else null end as service_department_id_freezed,
           case when sale_team_name ='BD部' then yt_crm.get_service_info('service_job_name:BD;service_job_freezed_name:BD',service_info_freezed,'service_user_name')
      	        when sale_team_name ='大客户部' then yt_crm.get_service_info('service_job_name:大BD',service_info_freezed,'service_user_name')
      	        else null end as service_user_name_freezed,--冻结销售人员姓名,
           case when sale_team_name ='BD部' then yt_crm.get_service_info('service_job_name:BD;service_job_freezed_name:BD',service_info_freezed,'service_feature_name')
      	        when sale_team_name ='大客户部' then yt_crm.get_service_info('service_job_name:大BD',service_info_freezed,'service_feature_name')
      	        else null end as service_feature_name_freezed,--冻结销售人员职能,
           case when sale_team_name ='BD部' then yt_crm.get_service_info('service_job_name:BD;service_job_freezed_name:BD',service_info_freezed,'service_job_name')
      	        when sale_team_name ='大客户部' then yt_crm.get_service_info('service_job_name:大BD',service_info_freezed,'service_job_name')
      	        else null end as service_job_name_freezed,--冻结销售人员角色,
           case when sale_team_name ='BD部' then yt_crm.get_service_info('service_job_name:BD;service_job_freezed_name:BD',service_info_freezed,'service_department_name')
      	        when sale_team_name ='大客户部' then yt_crm.get_service_info('service_job_name:大BD',service_info_freezed,'service_department_name')
      	        else null end as service_department_name_freezed,--冻结销售人员部门,
           --默认指标--
           pay_amount,--实货支付金额
           gmv,--实货gmv,
           sale_team_name,
      	   sale_team_freezed_name,

           --品牌系列
           brand_series_id,
           brand_series_name
    from order_mid
    where substr(shop_brand_sign_time,1,8) >= '${v_120_days_ago}'
    or substr(shop_item_sign_time,1,8) >= '${v_120_days_ago}'
    or substr(shop_brand_series_sign_time,1,8) >= '${v_120_days_ago}'
) order

--退款表
left join (
    select order_id,
           sum(refund_actual_amount) as refund_actual_amount,
           sum(case when multiple_refund=10 then refund_actual_amount else 0 end) as refund_retreat_amount
    from ytdw.dw_afs_order_refund_new_d --（后期通过type识别清退金额）
    where dayid ='${v_date}'
    and refund_status=9
    group by order_id
) refund on order.order_id=refund.order_id

--特殊订单表
left join (
    select trade_no
    from yt_crm.ads_salary_base_special_order_d
    where dayid ='${v_date}'
) spec_order on order.trade_no= spec_order.trade_no

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
) shop on order.shop_id=shop.shop_id

--商品表
LEFT JOIN (
    SELECT item_id,
           item_brand_tag_code,
           item_brand_tag_name
    FROM ytdw.dim_ytj_itm_item_d
    WHERE dayid = '${v_date}'
) item ON order.item_id = item.item_id

-- 大包品
LEFT JOIN (
    SELECT brand_id
    FROM yt_crm.ads_salary_base_big_package_brand_d
    WHERE dayid = '${v_date}'
) big_pack ON big_pack.brand_id = order.brand_id

where spec_order.trade_no is null --过滤特殊订单