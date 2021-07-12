use ytdw;
create table if not exists ads_salary_base_cur_month_order_d (
  --订单信息
  order_id                        bigint          comment '订单编号，外部生成',
  brand_id                        bigint          comment '品牌ID',
  brand_name                      string          comment '品牌名称',
  item_name                       string          comment '商品名称',
  category_id_first               bigint          comment '一级类目ID',
  category_id_first_name          string          comment '一级类目名称',
  category_id_second              bigint          comment '二级类目ID',
  category_id_second_name         string          comment '二级类目名称',
  item_style                      tinyint         comment '商品标签类型默认是0：A类1：B类',
  pay_amount                      decimal(11,2)   comment '实付款金额，包含了Hi卡的金额(元)',
  total_pay_amount                decimal(11,2)   comment 'gmv(pay_amount+coupon_amount)',
  sp_id                           bigint          comment '服务商id',
  service_info_freezed            string          comment '门店多职能冻结信息',
  business_unit                   string          comment '业务域',
  business_group_code             string          comment '业务组',
  business_group_name             string          comment '业务组名称',
  pay_time                         string         comment '支付时间',
  item_style_freezed              int             comment '冻结AB类型',
  pickup_card_amount              decimal(11,2)   COMMENT '提货hi卡支付金额' ,
  is_pickup_order                 int             COMMENT '是否通过提货hi卡支付 1 是 0 否',
  is_pickup_recharge_order        int             comment '是否为充值提货hi卡订单 1 是 0 否',
  pickup_brand_id                 bigint          comment '提货hi卡品牌',
  pickup_brand_name               string          comment '提货hi卡品牌名' ,
  pickup_category_id_first        bigint          comment '提货hi卡一级类目id',
  pickup_category_id_first_name   string          comment '提货hi卡一级类目名称',
  pickup_category_id_second       bigint          comment '提货hi卡二级类目id',
  pickup_category_id_second_name  string          comment '提货hi卡二级类目名称',
  --门店信息
  shop_id                         string          COMMENT '门店ID',
  shop_name                       string          COMMENT '门店名',
  store_type                      tinyint         comment '门店类型 1母婴 2港货/进口 3美妆 4药店 5商超 6便利店 7线上 8其他 9员工店 10EPS 11 伙伴店',
  shop_status                     string          COMMENT '门店状态',
  service_info                    string          comment '门店多职能信息',
  -- 薪资-特殊提点品牌业务（大客户专供品）
  is_spec_brand                   tinyint         COMMENT '是否特殊提点品牌,1是0否',
  -- 薪资-特殊订单
  is_spec_order                   tinyint         COMMENT '是否特殊订单,1是0否',
  -- 低端品牌标识
  is_celeron                      tinyint         comment '是否低端/超低端品牌，1是0否',
  -- 薪资-专属b
  is_exclusive_b                  tinyint         COMMENT '是否专属B,1是0否',
  category_id_third               bigint          comment '三级类目ID',
  category_id_third_name          string          comment '三级类目名称',
  pickup_category_id_third        bigint          comment '提货hi卡三级类目id',
  pickup_category_id_third_name   string          comment '提货hi卡三级类目名称'
)
comment '薪资基础层-本月正向下单大宽表（数仓基础订单宽表+薪资专属业务）'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;

insert overwrite table ads_salary_base_cur_month_order_d partition(dayid='$v_date')
select
  cur_month_order.order_id,
  cur_month_order.brand_id,
  cur_month_order.brand_name,
  cur_month_order.item_name,
  cur_month_order.category_id_first,
  cur_month_order.category_id_first_name,
  cur_month_order.category_id_second,
  cur_month_order.category_id_second_name,
  cur_month_order.item_style,
  cur_month_order.pay_amount,
  cur_month_order.total_pay_amount,
  cur_month_order.sp_id,
  cur_month_order.service_info_freezed,
  cur_month_order.business_unit,
  cur_month_order.business_group_code,
  cur_month_order.business_group_name,
  cur_month_order.pay_time,
  cur_month_order.item_style_freezed,
  cur_month_order.pickup_card_amount,
  cur_month_order.is_pickup_order,
  cur_month_order.is_pickup_recharge_order,
  cur_month_order.pickup_brand_id,
  cur_month_order.pickup_brand_name,
  cur_month_order.pickup_category_id_first,
  cur_month_order.pickup_category_id_first_name,
  cur_month_order.pickup_category_id_second,
  cur_month_order.pickup_category_id_second_name,
  shop_info.shop_id,
  shop_info.shop_name,
  shop_info.store_type,
  shop_info.shop_status,
  shop_info.service_info,
  case when spec_brand.brand_id is not null then 1 else 0 end as is_spec_brand,
  case when spec_order.trade_no is not null then 1 else 0 end as is_spec_order,
  case when celeron.id is not null then 1 else 0 end as is_celeron,
  case when exclusive_b_brand.brand_id is not null then 1 else 0 end as is_exclusive_b,
  cur_month_order.category_id_third,
  cur_month_order.category_id_third_name,
  cur_month_order.pickup_category_id_third,
  cur_month_order.pickup_category_id_third_name
from
(
  select
    trade_no,
    order_id,
    brand_id,
    brand_name,
    item_name,
    category_id_first,
    category_id_first_name,
    category_id_second,
    category_id_second_name,
    category_id_third,
    category_id_third_name,
    item_style,
    nvl(pay_amount,0) as pay_amount,
    nvl(total_pay_amount,0) as total_pay_amount,
    sp_id,
    service_info_freezed,
    business_unit,
    business_group_code,
    business_group_name,
    pay_time,
    item_style_freezed,
    nvl(pickup_card_amount,0) as pickup_card_amount,
    is_pickup_order,
    is_pickup_recharge_order,
    pickup_brand_id,
    pickup_brand_name,
    pickup_category_id_first,
    pickup_category_id_first_name,
    pickup_category_id_second,
    pickup_category_id_second_name,
    pickup_category_id_third,
    pickup_category_id_third_name,
    shop_id-- 用于后续联表查询
  from dw_order_d
  left join (
     select shop_id as douyin_shop_id, id as douyin_shop_mapping_id
     from dwd_shop_data_cluster_mapping_d
     where dayid = '$v_date'
     and inuse = 1
     and cluster_id in (1750) --167是长尾BD. 1750是对外合作门店
  ) douyin_shop_mapping ON dw_order_d.shop_id = douyin_shop_mapping.douyin_shop_id
  where dayid='$v_date'
  and substr(pay_time,1,6)='$v_cur_month'
  and bu_id=0
  and sale_dc_id=-1   --分销渠道过滤
  and substr(pay_time,1,8)<='$v_date'
  -- 剔除抖音直播店
  and douyin_shop_mapping.douyin_shop_mapping_id is null
)cur_month_order
left join
(
  select
    shop_id,
    shop_name,
    store_type,
    shop_status,
    service_info
  from dw_shop_base_d
  where dayid ='$v_date'
)shop_info on cur_month_order.shop_id=shop_info.shop_id
--特殊订单表
left join
(select trade_no from ads_salary_base_special_order_d where dayid ='$v_date' group by trade_no)spec_order on spec_order.trade_no=cur_month_order.trade_no
--专属b
left join(select brand_id from ytdw.ads_salary_base_exclusive_b_brand_d where dayid='$v_date' group by brand_id) exclusive_b_brand on exclusive_b_brand.brand_id=cur_month_order.brand_id
--特殊提点品牌表
left join
(select brand_id from ads_salary_base_special_brand_d  where dayid ='$v_date' group by brand_id)spec_brand on spec_brand.brand_id=cur_month_order.brand_id
--低端品牌标识
left join
( SELECT id
  FROM dwd_brand_d
  where dayid='$v_date'
  and (array_contains(split(tags,','),'42') or array_contains(split(tags,','),'41'))
) celeron on celeron.id=cur_month_order.brand_id
