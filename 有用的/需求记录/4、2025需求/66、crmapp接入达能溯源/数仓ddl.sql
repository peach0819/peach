CREATE TABLE IF NOT EXISTS ads_crm_shop_brand_index_d
(
    shop_id         STRING COMMENT '门店id',
    index_value     STRING COMMENT '指标值'
) PARTITIONED BY (dayid STRING);