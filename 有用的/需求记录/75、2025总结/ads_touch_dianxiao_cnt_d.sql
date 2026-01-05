CREATE TABLE IF NOT EXISTS ads_touch_dianxiao_cnt_d
(
    shop_cnt           INT  ,
    open_shop_cnt         INT  ,
    order_shop_cnt         INT  ,
    order_gmv          DECIMAL(10, 2),
    order_profit          DECIMAL(10, 2),
    before_order_gmv        DECIMAL(10, 2),
    before_order_profit        DECIMAL(10, 2)
) PARTITIONED BY (dayid STRING);