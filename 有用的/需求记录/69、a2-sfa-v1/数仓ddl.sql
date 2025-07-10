CREATE TABLE IF NOT EXISTS ads_crm_shop_stats_d
(
    shop_id         STRING COMMENT '门店id',
    publicity_count BIGINT COMMENT '品宣次数',
    display_count   BIGINT COMMENT '陈列次数',
    has_duty        BIGINT COMMENT '是否有打卡 1:有 0:无',
    extra           STRING COMMENT '额外信息'
) PARTITIONED BY (dayid STRING);