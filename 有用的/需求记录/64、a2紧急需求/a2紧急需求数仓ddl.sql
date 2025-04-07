CREATE TABLE IF NOT EXISTS ads_crm_a2_subject_scope_d
(
    subject_id         INT COMMENT '项目id',
    need_stats         INT COMMENT '是否需要在机会门店列表统计，0否 1是',
    shop_type          INT COMMENT '项目门店类型 1机会门店 2优质门店',
    subject_type       STRING COMMENT '项目类型 新签/复购'
) PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_a2_subject_base_d
(
    subject_id         INT COMMENT '项目id',
    subject_name       STRING COMMENT '项目名',
    subject_desc       STRING COMMENT '项目描述',
    subject_status     INT COMMENT '项目状态，0待发布 1进行中 2已结束 3已终止',
    subject_type       STRING COMMENT '项目类型 新签/复购',
    subject_month      STRING COMMENT '项目月份',
    subject_start_time STRING COMMENT '项目开始时间',
    subject_end_time   STRING COMMENT '项目结束时间',
    dmp_id             INT COMMENT '项目关联的DMP',
    need_stats         INT COMMENT '是否需要在机会门店列表统计，0否 1是',
    shop_type          INT COMMENT '项目门店类型 1机会门店 2优质门店',
    feature_type       INT COMMENT '项目职能类型，1BD 2电销'
) PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_a2_subject_shop_base_d
(
    subject_id      INT COMMENT '项目id',
    subject_type    STRING COMMENT '项目类型 新签/复购',
    subject_type_id INT COMMENT '项目类型id，1新签 2复购',
    subject_month   STRING COMMENT '项目月份',
    need_stats      INT COMMENT '是否需要在机会门店列表统计，0否 1是',
    shop_type       INT COMMENT '项目门店类型 1机会门店 2优质门店',
    shop_id         STRING COMMENT '门店id',
    shop_code       STRING COMMENT '门店编码',
    shop_name       STRING COMMENT '门店名',
    province_id     BIGINT COMMENT '省id',
    province_name   STRING COMMENT '省名',
    city_id         BIGINT COMMENT '市id',
    city_name       STRING COMMENT '市名',
    area_id         BIGINT COMMENT '区id',
    area_name       STRING COMMENT '区名',
    street_id       BIGINT COMMENT '街道id',
    street_name     STRING COMMENT '街道名',
    sale_id         STRING COMMENT '关联销售id',
    sale_name       STRING COMMENT '关联销售名',
    sale_user_id    BIGINT COMMENT '关联销售的user_id',
    has_visit       INT COMMENT '是否存在拜访（覆盖）0否 1是',
    has_valid_visit INT COMMENT '是否存在有效拜访（有效覆盖）0否 1是',
    has_order       INT COMMENT '是否下单（转化）0否 1是',
    offtake         INT COMMENT '下单罐数，下单罐数统计为 imf_offtake 口径',
    last_visit_time STRING COMMENT '最近一次拜访时间'
) PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_a2_subject_shop_base_sync_d
(
    subject_id      INT COMMENT '项目id',
    subject_type    STRING COMMENT '项目类型 新签/复购',
    subject_type_id INT COMMENT '项目类型id，1新签 2复购',
    subject_month   STRING COMMENT '项目月份',
    shop_id         STRING COMMENT '门店id',
    shop_code       STRING COMMENT '门店编码',
    shop_name       STRING COMMENT '门店名',
    province_id     BIGINT COMMENT '省id',
    province_name   STRING COMMENT '省名',
    city_id         BIGINT COMMENT '市id',
    city_name       STRING COMMENT '市名',
    area_id         BIGINT COMMENT '区id',
    area_name       STRING COMMENT '区名',
    street_id       BIGINT COMMENT '街道id',
    street_name     STRING COMMENT '街道名',
    sale_id         STRING COMMENT '关联销售id',
    sale_name       STRING COMMENT '关联销售名',
    sale_user_id    BIGINT COMMENT '关联销售的user_id',
    has_visit       INT COMMENT '是否存在拜访（覆盖）0否 1是',
    has_valid_visit INT COMMENT '是否存在有效拜访（有效覆盖）0否 1是',
    has_order       INT COMMENT '是否下单（转化）0否 1是',
    offtake         INT COMMENT '下单罐数，下单罐数统计为 imf_offtake 口径',
    last_visit_time DATETIME COMMENT '最近一次拜访时间'
) PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_a2_subject_d
(
    subject_id      INT COMMENT '项目id',
    subject_name    STRING COMMENT '项目名',
    subject_desc    STRING COMMENT '项目描述',
    subject_status  INT COMMENT '项目状态，0待发布 1进行中 2已结束 3已终止',
    subject_type    STRING COMMENT '项目类型 新签/复购',
    subject_type_id INT COMMENT '项目类型id，1新签 2复购',
    subject_month   STRING COMMENT '项目月份',
    subject_start_time STRING COMMENT '项目开始时间',
    subject_end_time STRING COMMENT '项目结束时间',
    shop_type       INT COMMENT '项目门店类型 1机会门店 2优质门店',
    shop_count      INT COMMENT '机会门店数',
    visit_shop_count INT COMMENT '覆盖门店数',
    valid_visit_shop_count INT COMMENT '有效覆盖门店数',
    order_shop_count INT COMMENT '转化门店数',
    visit_shop_rate decimal(18, 2) COMMENT '拜访覆盖率'
) PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_a2_subject_shop_d
(
    shop_id         STRING COMMENT '门店id',
    shop_code       STRING COMMENT '门店编码',
    shop_name       STRING COMMENT '门店名',
    province_id     BIGINT COMMENT '省id',
    province_name   STRING COMMENT '省名',
    city_id         BIGINT COMMENT '市id',
    city_name       STRING COMMENT '市名',
    area_id         BIGINT COMMENT '区id',
    area_name       STRING COMMENT '区名',
    street_id       BIGINT COMMENT '街道id',
    street_name     STRING COMMENT '街道名',
    sale_id         STRING COMMENT '关联销售id',
    sale_name       STRING COMMENT '关联销售名',
    sale_user_id    BIGINT COMMENT '关联销售的user_id',
    has_visit       INT COMMENT '是否存在拜访（覆盖）0否 1是',
    has_valid_visit INT COMMENT '是否存在有效拜访（有效覆盖）0否 1是',
    has_order       INT COMMENT '是否下单（转化）0否 1是',
    shop_count      INT COMMENT '机会门店数',
    quantity_shop_count INT COMMENT '优质门店数',
    is_new_sign     INT COMMENT '是否新签门店 0否 1是',
    is_repurchase   INT COMMENT '是否复购门店 0否 1是'
) PARTITIONED BY (dayid STRING);