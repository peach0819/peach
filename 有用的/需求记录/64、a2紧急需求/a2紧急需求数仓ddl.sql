CREATE TABLE IF NOT EXISTS ads_crm_a2_subject_shop_d
(
    shop_id         STRING COMMENT '门店id',
    province_id     INT COMMENT '省id',
    province_name   STRING COMMENT '省名',
    city_id         INT COMMENT '市id',
    city_name       STRING COMMENT '市名',
    area_id         INT COMMENT '区id',
    area_name       STRING COMMENT '区名',
    street_id       INT COMMENT '街道id',
    street_name     STRING COMMENT '街道名',
    sale_id         STRING COMMENT '关联销售id',
    sale_name       STRING COMMENT '关联销售名',
    sale_user_id    INT COMMENT '关联销售的user_id',
    has_visit       STRING COMMENT '是否存在拜访（覆盖）0否 1是',
    has_order       STRING COMMENT '是否下单（转化）0否 1是',
    shop_count      INT COMMENT '机会门店数',
    is_new_sign     INT COMMENT '是否新签门店 0否 1是',
    is_repurchase   INT COMMENT '是否复购门店 0否 1是'
) PARTITIONED BY (dayid STRING);