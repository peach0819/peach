insert overwrite table ytdw.dw_trd_order_d partition(dayid='$v_date')
select
order_shop.order_id
,order_shop.order_no
,order_shop.order_status
,coalesce(enum2.enum_value,'未知') as order_status_name
,order_shop.biz_id
,order_shop.biz_type
,coalesce(enum1.enum_value,'未知') as biz_type_name
,order_shop.sale_dc_id
,if(order_shop.sale_dc_id is null,null,nvl(enum_sale_dc_id.enum_value,'未知')) as sale_dc_id_name
,order_shop.bu_id as bu_id
,if(order_shop.sale_dc_id is null,null,nvl(enum_bu_id.enum_value,'未知')) as bu_id_name
,order_shop.create_time as order_place_time--下单时间
,order_shop.pay_time       as order_pay_time
--支付天
,substr(order_shop.pay_time,1,8) as order_pay_date
--支付月
,substr(order_shop.pay_time,1,6) as order_pay_ym
,order_shop.accept_time    as order_accept_time
,order_shop.stock_out_time as order_stock_out_time
,order_shop.delivery_time  as order_delivery_time  --订单状态为已发货的时间
,if(order_shop.order_status in (2,3),order_shop.end_time,null) as order_finish_time--结束时间
,order_shop.tags          as order_tags
,if(hi_pickup.hi_card_type = 1,1,0) as is_pickup_recharge_order --是否为充值提货卡订单 1 是 0 否
,if(order_shop.pickup_card_amount >0,1,0) as is_pickup_pay_order   --是否提货卡支付订单
,if(order_shop.hi_amount >0,1,0) as is_hi_pay_order                --是否hi卡支付订单

--trade维度
,order_shop.trade_id            -- 交易ID
,trade_shop.trade_no            -- 交易编号(展示使用)
,trade_shop.parent_trade_id     -- 父交易ID
,trade_shop.trade_type          -- 交易类型 0:普通订单 1:卡券订单 2:补差价
,coalesce(enum9.enum_value,'未知') as trade_type_name -- 交易类型翻译
,trade_shop.trade_source        -- 交易来源 1:线下实体 2:淘宝店铺 3:微信 4:微信自助下单
,coalesce(enum8.enum_value,'未知') as trade_source_name
,trade_shop.is_cart   as is_cart_trade    --是否购物车订单
,trade_shop.trade_status        -- 交易状态 0:待支付  1:已支付  3:交易成功  4:交易关闭
,coalesce(enum6.enum_value,'未知') as trade_status_name -- '交易状态翻译0:待支付1:已支付3:交易成功4:交易关闭'
,trade_shop.tags as trade_tags  -- 交易打标



--门店维度
,order_shop.shop_id            -- 店铺ID
,shop.shop_name                -- 店铺名称
,shop.shop_prov_id             -- 省份ID
,shop.shop_prov_name
,shop.shop_city_id             -- 城市ID
,shop.shop_city_name
,shop.shop_area_id             -- 区域ID
,shop.shop_area_name
,shop.shop_street_id           -- 街道ID
,shop.shop_street_name
,shop.shop_open_time                -- '门店开通时间'
,shop.shop_store_type               -- '门店类型'
,shop.shop_store_type_name          -- '门店类型名称'
,shop.shop_acc_type                    -- '连锁类型'
,shop.shop_acc_type_name       -- '连锁类型名称'
,shop.shop_apply_type               -- '门店来源ID'
,shop.shop_apply_type_name          -- '门店来源名称'

--供应商维
,order_shop.supply_id               -- 供应商id
,supply.supply_name as supply_name  -- 供应商名称

--商品维
,order_shop.item_id                 -- 商品id
,item.item_name
,item.brand_id    as brand_id
,item.brand_name  as brand_name
,item.business_unit
,item.item_type
,item.item_type_name
,item.category_1st_id as category_1st_id
,item.category_1st_name as category_1st_name
,item.category_2nd_id as  category_2nd_id
,item.category_2nd_name as category_2nd_name
,item.category_3rd_id as category_3rd_id
,item.category_3rd_name as category_3rd_name
,item.category_4th_id
,item.category_4th_name
,item.item_style
,item.item_style_name
,item.item_barcode       --商品条形码
,item.item_business_group_code    --业务组
,item.item_business_group_name
,item.performance_category_1st_id as performance_category_1st_id
,item.performance_category_1st_name as performance_category_1st_name
,item.performance_category_2nd_id as performance_category_2nd_id
,item.performance_category_2nd_name as performance_category_2nd_name
,item.performance_category_3rd_id as performance_category_3rd_id
,item.performance_category_3rd_name as performance_category_3rd_name
,item.performance_brand_id as performance_brand_id
,item.performance_brand_name as performance_brand_name
,order_shop.spec as item_spec_frez       --商品规格
,order_shop.sku_id as item_sku_id_frez   --skuid
,order_shop.spu_feature   as item_spu_feature_frez   --商品spu特性(json串)
,order_shop.origin_single_item_amount/100 as item_org_price  -- 商品原始价格(元) ，未优惠前供价的规格单价

--批次
,order_shop.batch_id
,order_shop.batch_version
,spec_scd.pre_tax_price/100 as pre_tax_price --税前采购价
--服务商
,sp_order.sp_id
,sp_order.sp_name_frez                  --冻结服务商名称
,sp_order.shop_area_id_frez             --冻结服务商服务地域
,sp_order.sp_brand_id_frez              --冻结服务商授权品牌
,sp_order.sp_operator_id_frez           --冻结服务商经理ID
,operator_user.sp_operator_name_frez    --冻结服务商经理名称

--优惠券维度
,order_shop.coupon_owner_id as coupon_owner_id_platform     -- '平台优惠券持有者id',
,order_shop.coupon_owner_id_store                   -- '店铺优惠券标识id',
,coupon.coupon_id                                   -- '优惠券模板id',
,coupon.coupon_title as coupon_title_platform       -- '优惠券标题',
,coupon.coupon_type as coupon_type_platform         -- '平台优惠券类型'
,coalesce(enum4.enum_value,'未知') as coupon_type_name_platform --优惠券类型
,coupon.coupon_first_sector_name     as coupon_first_dept_name              -- '优惠券海拍客费用归属一级部门',
,coupon.coupon_secondary_sector_name as coupon_second_dept_name             -- '优惠券海拍客费用归属二级部门',
--物流配送
,order_shop.logistic_type as logi_type                -- 配送类型
,coalesce(enum3.enum_value,'未知')  as logi_type_name
,order_shop.logistic_pay_type as logi_pay_type
,coalesce(enum5.enum_value,'未知') as logi_pay_type_name	  --运费支付类型
--度量
,order_shop.pay_amount/100                        as order_amt                               --实付款金额，包含了Hi卡的金额(元)
,order_shop.coupon_amount/100                     as order_coupon_amt                        --订单优惠券金额，均摊的金额
,(order_shop.pay_amount + order_shop.coupon_amount)/100  as order_total_amt              -- gmv
,order_shop.hi_amount/100                     as order_hi_amt	                        --hi卡支付金额
,order_shop.pickup_card_amount/100            as order_pickup_card_amt	                --提货卡支付金额
,order_shop.coupon_amount_platform/100        as order_coupon_amt_platform               --平台优惠券金额,均摊
,order_shop.coupon_amount_store/100           as order_coupon_amt_store                  --店铺优惠券金额,均摊
,order_shop.tax_amount/100                    as order_tax_amt               -- 税额(元)
,order_shop.item_count     as item_cnt                       -- 商品的数量(件数*规格)
,order_shop.item_actual_amount/100 as item_actual_amt        -- 商品的总金额(件数*规格金额)元
,order_shop.item_count/order_shop.spec as item_spec_cnt      --商品件数
,order_shop.customer_amount/100 as customer_amt              -- 微信下单消费者付款货品金额(元)
,order_shop.logistic_amount/100  as logi_amt             -- 运费金额
,order_shop.batch_spec_price/100 as batch_spec_price     --总采购货款价格
,order_shop.batch_spec_price/100.00*(order_shop.item_count/order_shop.spec) as per_batch_spec_price--单件商品采购货款金额
,order_shop.is_deleted
,order_shop.spec_desc as item_spec_desc_frez      --冻结商品规格描述
,trade_shop.trade_user_id  --订单用户ID
,order_shop.item_snapshot_version--商品快照版本
,item_snapshot.item_style_frez      --商品冻结AB类型
,item_snapshot.item_style_name_frez --商品冻结AB类型名称
,order_shop.diz_type
,spec_scd.spec_scd_id as spec_scd_id
,item_dc_id
,ytdw.getValueFromJson(promotion_attr,2,'bizId') as flash_activity_id --聚划算活动id，订单对应活动为一对多,promotion_attr中的 bizType=2对应的bizId就是 聚划算活动id
from
(select *
   ,concat(case when item_dc_id=0 and is_deleted=0 then 'old'
                else ''
                end
           ,case  when item_dc_id=0 and is_deleted=0 and bu_id=0 then ',hipac'
                else ''
                end
          ) as diz_type --业务类型，old为兼容历史模式
   from dwd_order_shop_full_d
	 where dayid = '$v_date'
	 and substr(create_time,1,8) <='$v_date'
	 and is_deleted=0
    ) order_shop
left join
     (select trade_id, trade_no,            -- 交易编号(展示使用)
             parent_trade_id,     -- 父交易ID
             trade_type,          -- 交易类型 0:普通订单 1:卡券订单 2:补差价
             trade_source,        -- 交易来源 1:线下实体 2:淘宝店铺 3:微信 4:微信自助下单
             trade_status,        -- 交易状态 0:待支付  1:已支付  3:交易成功  4:交易关闭
             tags,   -- 交易打标
			 is_cart , --是否购物车订单
			 user_id as trade_user_id
      from dwd_trade_shop_d where dayid = '$v_date'
	  and substr(create_time,1,8)<='$v_date'
    ) trade_shop
      on trade_shop.trade_id = order_shop.trade_id
left join --活动订单类型
     (select
       table_name,enum_key,enum_value,status
     from ytdw.dwd_enum_info_d
     where dayid = '$v_date'
     and table_name = 'ods_pt_order_shop_d'
     and enum_name = 'biz_type' and status = 1
    ) enum1
     on order_shop.biz_type = enum1.enum_key
left join --订单商品行状态
    (select
        table_name,enum_key,enum_value,status
    from ytdw.dwd_enum_info_d
    where dayid = '$v_date'
    and table_name ='ods_pt_order_shop_d'
    and enum_name = 'order_status' and status = 1
  ) enum2
    on order_shop.order_status = enum2.enum_key
left join --运费类型
    (select
        table_name,enum_key,enum_value,status
    from ytdw.dwd_enum_info_d
    where dayid = '$v_date'
    and table_name ='ods_pt_order_shop_d'
    and enum_name = 'logistic_type' and status = 1
    ) enum3
    on order_shop.logistic_type = enum3.enum_key
left join --门店维度
    (select *
     from dim_shp_shop_d
     where  dayid = '$v_date'
     ) shop
on order_shop.shop_id = shop.shop_id
left join --商品维度
    (select * from dim_itm_item_d where dayid = '$v_date'
    ) item
on order_shop.item_id = item.item_id
left join --供应商维度
    (select supply_id,supply_name from dim_sup_supply_d where dayid = '$v_date') supply
on order_shop.supply_id = supply.supply_id
--商品冻结信息
left join
   (
     select item_id_frez
            ,item_snapshot_version
            ,item_name_frez
            ,item_type_frez
            ,item_type_name_frez
            ,item_style_frez
            ,item_style_name_frez
	 from ytdw.dim_itm_item_snapshot_d where dayid='$v_date'
   ) item_snapshot on item_snapshot.item_id_frez=order_shop.item_id and item_snapshot.item_snapshot_version=order_shop.item_snapshot_version
left join --服务商快照订单
    (select order_id,
            sp_id,
			      sp_name as sp_name_frez,
    		    operator_id as sp_operator_id_frez, --'冻结服务商经理ID'
    		    sp_area_id as sp_area_id_frez, -- '冻结服务商服务地域',
            brand_id as sp_brand_id_frez, -- '冻结服务商授权品牌',
            shop_area_id as shop_area_id_frez
    from dwd_sp_order_snapshot_d where dayid='$v_date' and is_deleted=0
    group by order_id,sp_id,sp_name,operator_id,sp_area_id,brand_id,shop_area_id
    ) sp_order
   on sp_order.order_id=order_shop.order_id
left join --服务商经理
    (select user_id,user_real_name as sp_operator_name_frez
     from dim_usr_user_d
	 where dayid='$v_date' and is_internal_user=1 --小二用户
    ) operator_user
   on operator_user.user_id = (case when sp_order.sp_operator_id_frez is null then concat('hive',rand()) else sp_order.sp_operator_id_frez end)
left join --优惠券维度
    (select coupon_owner_id,  -- '门店优惠券持有者id',
          coupon_id,                                   -- '门店优惠券模板id',
          coupon_title,      -- '优惠券标题',
          coupon_type,       -- '平台优惠券类型'
          coupon_first_sector_name,              -- '优惠券海拍客费用归属一级部门',
          coupon_secondary_sector_name from dw_prm_coupon_owner_info_d where dayid = '$v_date'
	) coupon
on coupon.coupon_owner_id = case when order_shop.coupon_owner_id is null then -9999+rand(1000) else order_shop.coupon_owner_id end
left join --优惠券类型
  (select
    table_name,enum_key,enum_value,status
  from ytdw.dwd_enum_info_d
  where dayid = '$v_date'
  and table_name ='ods_t_coupon_d'
  and enum_name = 'coupon_type' and status = 1
  ) enum4
on coupon.coupon_type = enum4.enum_key
left join --运费支付类型
    (select
        table_name,enum_key,enum_value,status
    from ytdw.dwd_enum_info_d
    where dayid = '$v_date'
    and table_name ='ods_pt_order_shop_d'
    and enum_name = 'logistic_pay_type' and status = 1
    ) enum5
    on order_shop.logistic_type = enum5.enum_key
left join
  (select *
    from ytdw.dwd_enum_info_d
    where dayid = '$v_date'
    and table_name = 'ods_pt_trade_shop_d'
    and enum_name = 'trade_status' and status = 1
  ) enum6
on trade_shop.trade_status=enum6.enum_key
left join
  (select *
    from ytdw.dwd_enum_info_d
    where dayid = '$v_date'
    and table_name = 'ods_pt_trade_shop_d'
    and enum_name = 'trade_source' and status = 1
  ) enum8
on trade_shop.trade_source=enum8.enum_key
left join
  (select *
    from ytdw.dwd_enum_info_d
    where dayid = '$v_date'
    and table_name = 'ods_pt_trade_shop_d'
    and enum_name = 'trade_type' and status = 1
  ) enum9
on trade_shop.trade_type=enum9.enum_key
left join
(select   trade_id,hi_card_type
 from dim_trd_hi_pickup_card_category_d
where dayid='$v_date'
) hi_pickup
on hi_pickup.trade_id = order_shop.trade_id
left join
  (select *
    from ytdw.dwd_enum_info_d
    where dayid = '$v_date'
    and table_name = 'dwd_order_shop_d'
    and enum_name = 'sale_dc_id'
    and status = 1
  ) enum_sale_dc_id
on order_shop.sale_dc_id=enum_sale_dc_id.enum_key
left join
  (select *
    from ytdw.dwd_enum_info_d
    where dayid = '$v_date'
    and table_name = 'dwd_order_shop_d'
    and enum_name = 'bu_id'
    and status = 1
  ) enum_bu_id
on order_shop.bu_id=enum_bu_id.enum_key
left join
  (select *
   ,row_number() over(partition by item_id,batch_id,batch_version,item_spec_frez order by spec_id) as spec_rank
   from dim_itm_item_batch_spec_scd_d
   where dayid='$v_date'
  ) spec_scd
on spec_scd.spec_rank=1
and order_shop.item_id=spec_scd.item_id
and order_shop.batch_id=spec_scd.batch_id
and order_shop.batch_version=spec_scd.batch_version
and order_shop.spec=spec_scd.item_spec_frez
;
