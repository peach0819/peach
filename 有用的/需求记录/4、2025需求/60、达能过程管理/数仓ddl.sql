CREATE TABLE IF NOT EXISTS ads_crm_danone_shop_brand_d
(
    shop_id          STRING COMMENT '门店id',
    danone_shop_code STRING COMMENT '达能门店编码',
    order_brand_list STRING COMMENT '来源订单的品牌集合',
    sign_brand_list  STRING COMMENT '工单开通品牌集合',
    total_brand_list STRING COMMENT '总品牌集合'
) PARTITIONED BY (dayid STRING);

create table if not exists ads_crm_danone_shop_item_sku_d
(
    shop_id          STRING COMMENT '门店id',
    danone_shop_code STRING COMMENT '达能门店编码',
    danone_sku_id    STRING COMMENT '达能sku id',
    danone_item_name STRING COMMENT '达能商品名称',
    danone_brand_series STRING COMMENT '达能系列'
) PARTITIONED BY (dayid STRING);

create table if not exists ads_crm_danone_shop_photo_d
(
    shop_id          STRING COMMENT '门店id',
    danone_shop_code STRING COMMENT '达能门店编码',
    photo_qualified  INT COMMENT '陈列是否合格 1合格 0不合格',
    last_photo       STRING COMMENT '上次陈列信息'
) PARTITIONED BY (dayid STRING);

create table if not exists ads_crm_danone_shop_spc_duty_d
(
    shop_id            STRING COMMENT '门店id',
    danone_shop_code   STRING COMMENT '达能门店编码',
    spc_duty_qualified INT COMMENT 'SPC考勤是否合格 1合格 0不合格',
    spc_duty           STRING COMMENT 'SPC打卡信息'
) PARTITIONED BY (dayid STRING);

create table if not exists ads_crm_danone_shop_pos_inventory_d
(
    shop_id                 STRING COMMENT '门店id',
    danone_shop_code        STRING COMMENT '达能门店编码',
    pos_inventory_qualified INT COMMENT 'POS库存是否需要补货 1合格（不需要补货） 0不合格（需要补货）',
    pos_inventory           STRING COMMENT 'POS库存信息'
) PARTITIONED BY (dayid STRING);

create table if not exists ads_crm_danone_shop_pos_order_d
(
    shop_id             STRING COMMENT '门店id',
    danone_shop_code    STRING COMMENT '达能门店编码',
    pos_order_qualified INT COMMENT 'POS未售是否合格 1合格（无未售） 0不合格（有未售）',
    pos_order           STRING COMMENT 'POS未售信息'
) PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_danone_shop_notice_d
(
    data_month              STRING COMMENT '数据所属月份',
    shop_id                 STRING COMMENT '门店id',
    danone_shop_code        STRING COMMENT '达能门店编码',
    photo_qualified         INT COMMENT '陈列是否合格 1合格 0不合格',
    spc_duty_qualified      INT COMMENT 'SPC考勤是否合格 1合格 0不合格',
    pos_inventory_qualified INT COMMENT 'POS库存是否需要补货 1合格（不需要补货） 0不合格（需要补货）',
    pos_order_qualified     INT COMMENT 'POS未售是否合格 1合格（无未售） 0不合格（有未售）',
    extra                   STRING COMMENT '额外信息'
) PARTITIONED BY (dayid STRING);