use ytdw;
create table if not exists dw_salary_brand_shop_current_public_d
(
    planno                        int comment '方案编号',
    plan_month                    string comment '方案月份',
    update_time                   string comment '更新时间',
    update_month                  string comment '执行月份',
    order_id                      string comment '订单id',
    trade_id                      string comment '交易id',
    pay_date                      string comment '支付日期',
    rfd_date                      string comment '退款日期',
    gmv                           decimal(18, 2) comment '实货gmv',
    refund                        decimal(18, 2) comment '退款',
    gmv_less_refund               decimal(18, 2) comment '实货gmv-退款',
    shop_id                       string comment '门店ID',
    shop_name                     string comment '门店名称',
    brand_id                      bigint comment '商品品牌id',
    brand_name                    string comment '商品品牌',
    category_1st_id               bigint comment '商品一级类目id',
    category_1st_name             string comment '商品一级类目',
    category_2nd_id               bigint comment '商品二级类目id',
    category_2nd_name             string comment '商品二级类目',
    item_id                       bigint comment '商品id',
    item_name                     string comment '商品名称',
    item_style                    tinyint comment 'AB类型',
    item_style_name               string comment 'AB类型名称',
    grant_object_user_id          string comment '发放对象id',
    current_total_gmv_less_refund decimal(18, 2) comment '截止当前订单的gmv-退款总和'
) comment '多品进店当前周期明细表'
partitioned by (dayid string, pltype string)
stored as orc;

create table if not exists dw_salary_brand_shop_compare_public_d
(
    planno            int comment '方案编号',
    plan_month        string comment '方案月份',
    update_time       string comment '更新时间',
    update_month      string comment '执行月份',
    order_id          string comment '订单id',
    trade_id          string comment '交易id',
    pay_date          string comment '支付日期',
    rfd_date          string comment '退款日期',
    gmv               decimal(18, 2) comment '实货gmv',
    refund            decimal(18, 2) comment '退款',
    gmv_less_refund   decimal(18, 2) comment '实货gmv-退款',
    shop_id           string comment '门店ID',
    shop_name         string comment '门店名称',
    brand_id          bigint comment '商品品牌id',
    brand_name        string comment '商品品牌',
    category_1st_id   bigint comment '商品一级类目id',
    category_1st_name string comment '商品一级类目',
    category_2nd_id   bigint comment '商品二级类目id',
    category_2nd_name string comment '商品二级类目',
    item_id           bigint comment '商品ID',
    item_name         string comment '商品名称',
    item_style        tinyint comment 'AB类型',
    item_style_name   string comment 'AB类型名称'
) comment '多品进店比对周期明细表'
partitioned by (dayid string)
stored as orc;

create table if not exists dw_salary_brand_shop_compare_shop_sum_d
(
    planno                int comment '方案编号',
    plan_month            string comment '方案月份',
    update_time           string comment '更新时间',
    update_month          string comment '执行月份',
    shop_id               string comment '门店ID',
    shop_name             string comment '门店名称',
    brand_id              bigint comment '商品品牌id',
    brand_name            string comment '商品品牌',
    total_gmv_less_refund decimal(18, 2) comment '实货gmv-退款',
    is_valid_brand        tinyint comment '是否满足有效门槛线'
) comment '多品进店比对周期门店粒度汇总表'
partitioned by (dayid string)
stored as orc;

create table if not exists dw_salary_brand_shop_current_object_sum_d
(
    planno                int comment '方案编号',
    plan_month            string comment '方案月份',
    update_time           string comment '更新时间',
    update_month          string comment '执行月份',
    shop_id               string comment '门店ID',
    shop_name             string comment '门店名称',
    brand_id              bigint comment '商品品牌id',
    brand_name            string comment '商品品牌',
    grant_object_user_id  string comment '发放对象id',
    total_gmv_less_refund decimal(18, 2) comment '实货gmv-退款',
    is_valid_brand        tinyint comment '是否满足有效门槛线',
    first_valid_date      string comment '最早达成有效门槛线的日期'
) comment '多品进店当前周期销售粒度汇总表'
partitioned by (dayid string, pltype string)
stored as orc;