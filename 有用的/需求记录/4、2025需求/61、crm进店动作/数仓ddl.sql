CREATE TABLE IF NOT EXISTS ads_crm_visit_action_d
(
    shop_id         STRING COMMENT '门店id',
    job_id          INT COMMENT '岗位id',
    action_id       INT COMMENT '动作id',
    brand_id        INT COMMENT '品牌id',
    brand_series_id INT COMMENT '品牌系列id',
    brand_category  STRING COMMENT '品牌类目',
    faq_doc_id      STRING COMMENT '知识库idjson',
    content_id      STRING COMMENT '关联内容idjson'
) PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_visit_strategy_chenlie_d
(
    shop_id         STRING COMMENT '门店id',
    brand_id        INT COMMENT '品牌id'
) PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_visit_action_brand_d
(
    brand_id STRING COMMENT '品牌id',
	brand_name STRING COMMENT '品牌名称',
	brand_category STRING COMMENT '品牌类目'
) PARTITIONED BY (dayid STRING);