create table if not exists ads_salary_base_cur_month_refund_d (
  --退款信息
  order_id                        bigint          comment '订单编号，外部生成',
  salary_refund_type              string          comment '线上退款/线下退款',
  refund_actual_amount            decimal(11,2)   comment'实际退款金额',
  refund_pickup_card_amount       decimal(11,2)   comment '提货卡退款金额',
  --订单信息
  brand_id                        bigint          comment '品牌ID',
  brand_name                      string          comment '品牌名称',
  item_name                       string          comment '品牌名称',
  category_id_first               bigint          comment '一级类目ID',
  category_id_first_name          string          comment '一级类目名称',
  category_id_second              bigint          comment '二级类目ID',
  category_id_second_name         string          comment '二级类目名称',
  item_style                      tinyint         comment '商品标签类型默认是0：A类1：B类',
  sp_id                           bigint          comment '服务商id',
  service_info_freezed            string          comment '门店多职能冻结信息',
  business_unit                   string          comment '业务域',
  business_group_code             string          comment '业务组',
  business_group_name             string          comment '业务组名称',
  pay_time                         string         comment '支付时间',
  item_style_freezed              int             comment '冻结AB类型',
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
  pickup_category_id_third        bigint          comment '提货hi卡三级级类目id',
  pickup_category_id_third_name   string          comment '提货hi卡三级级类目名称'
)
comment '薪资基础层-本月逆向退款大宽表（数仓基础退款宽表+薪资线下退款）'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;