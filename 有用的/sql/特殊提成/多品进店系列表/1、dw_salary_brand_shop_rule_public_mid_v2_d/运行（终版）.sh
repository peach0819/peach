v_date=$1

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;
create table if not exists dw_salary_brand_shop_rule_public_mid_v2_d
(
    order_id                         string comment '子订单id',
    trade_id                         string comment '交易id',
    category_1st_id                  bigint comment '商品一级类目id',
    category_1st_name                string comment '商品一级类目',
    category_2nd_id                  bigint comment '商品二级类目id',
    category_2nd_name                string comment '商品二级类目',
    brand_id                         bigint comment '商品品牌id',
    brand_name                       string comment '商品品牌',
    item_id                          bigint comment '商品ID',
    item_name                        string comment '商品名称',
    item_style                       tinyint comment 'AB类型',
    item_style_name                  string comment 'AB类型名称',
    shop_id                          string comment '门店ID',
    shop_name                        string comment '门店名称',
    store_type                       string comment '门店类型',
    store_type_name                  string comment '门店类型名称',
    war_zone_id                      string comment '战区经理ID',
    war_zone_name                    string comment '战区经理',
    war_zone_dep_id                  string comment '战区ID',
    war_zone_dep_name                string comment '战区',
    area_manager_id                  string comment '大区经理id',
    area_manager_name                string comment '大区经理',
    area_manager_dep_id              string comment '大区区域ID',
    area_manager_dep_name            string comment '大区',
    bd_manager_id                    string comment '主管id',
    bd_manager_name                  string comment '主管',
    bd_manager_dep_id                string comment '主管区域ID',
    bd_manager_dep_name              string comment '区域',
    shop_group                       string comment '门店分组信息',
    pay_date                         string comment '支付日期',
    rfd_date                         string comment '退款日期',
    gmv                              decimal(18, 2) comment '实货gmv',
    refund                           decimal(18, 2) comment '退款',
    gmv_less_refund                  decimal(18, 2) comment '实货gmv-退款',
    sale_team_id                     int comment '销售团队标识ID',
    sale_team_name                   string comment '销售团队标识 1:电销部 2:BD部 3:大客户部 4:服务商部 5:美妆销售团队',
    sale_team_freezed_id             int comment '冻结销售团队标识ID',
    sale_team_freezed_name           string comment '冻结销售团队标识 1:电销部 2:BD部 3:大客户部 4:服务商部 5:美妆销售团队',
    frozen_sale_user_id              string comment '冻结销售',
    newest_sale_user_id              string comment '库内销售'
) comment 'gmv规则通用方案中间表'
partitioned by (dayid string)
stored as orc;

with user_admin as (
    SELECT user_id, job_name
    FROM dim_ytj_pub_user_admin_m
    WHERE dayid = '$v_cur_month'
)

insert overwrite table dw_salary_brand_shop_rule_public_mid_v2_d partition(dayid='$v_date')
select ord.order_id,
       ord.trade_id,

       --商品信息
       ord.category_1st_id,
       ord.category_1st_name,
       ord.category_2nd_id,
       ord.category_2nd_name,
       ord.brand_id,
       ord.brand_name,
       ord.item_id,
       ord.item_name,
       ord.item_style,
       ord.item_style_name,

       --门店信息
       ord.shop_id,
       ord.shop_name,
       ord.shop_store_type as store_type,
       ord.shop_store_type_name as store_type_name,
       shop.war_zone_id,
       shop.war_zone_name,
       shop.war_zone_dep_id,
       shop.war_zone_dep_name,
       shop.area_manager_id,
       shop.area_manager_name,
       shop.area_manager_dep_id,
       shop.area_manager_dep_name,
       shop.bd_manager_id,
       shop.bd_manager_name,
       shop.bd_manager_dep_id,
       shop.bd_manager_dep_name,
       shop_group_mapping.group_id as shop_group,

       --订单信息
       ord.pay_date,
       ord.rfd_date,
       ord.act_pay_total_amt_1d as gmv, --gmv
       ord.act_rfd_amt_1d as refund, --退款
       ord.act_net_pay_total_amt_1d as gmv_less_refund, --gmv-退款

       --销售团队信息
       ord_seller.sale_team_id,
       ord_seller.sale_team_name,
       ord_seller.sale_team_freezed_id,
       ord_seller.sale_team_freezed_name,

       --订单归属信息
       if(user_admin_kn.job_name = 'BD', frozen_trade.trade_service_bd_id_frez, null) as frozen_sale_user_id,
       if(user_admin_frozen.job_name = 'BD', rule_center.newest_user_id, null) as newest_sale_user_id
--订单表
from (
    SELECT order_id,
           trade_id,
           category_1st_id,
           category_1st_name,
           category_2nd_id,
           category_2nd_name,
           brand_id,
           brand_name,
           item_id,
           item_name,
           item_style,
           item_style_name,
           shop_id,
           shop_name,
           shop_store_type,
           shop_store_type_name,

           pay_date,
           rfd_date,
           act_pay_total_amt_1d, --gmv
           act_rfd_amt_1d, --退款
           act_net_pay_total_amt_1d --gmv-退款
    FROM dws_hpc_trd_act_detail_d
    WHERE dayid = '$v_date'
    -- 保留200天的订单数据
    AND pay_date >= replace(date_add('$v_op_time', -200), '-', '')
) ord

--门店表
left join (
    select shop_id,
           war_zone_id       , --战区经理ID
           war_zone_name     , --战区经理
           war_zone_dep_id   , --战区ID
           war_zone_dep_name , --战区
           area_manager_id     	,   --大区经理id
           area_manager_name   	,   --大区经理
           area_manager_dep_id,--大区区域ID
           area_manager_dep_name,   --大区
           bd_manager_id       	,--主管id
           bd_manager_name     	,--主管
           bd_manager_dep_id ,--主管区域ID
           bd_manager_dep_name 	--区域
    from dw_shop_base_d
    where dayid ='$v_date'
) shop on ord.shop_id=shop.shop_id

--门店分组表
LEFT JOIN (
    SELECT shop_id,
           concat_ws(',' , sort_array(collect_set(cast(group_id as string)))) as group_id
    FROM ads_hpc_shop_group_rule_inuse_mapping_d
    WHERE dayid='$v_date'
    group by shop_id
) shop_group_mapping ON ord.shop_id=shop_group_mapping.shop_id

--订单销售团队表
LEFT JOIN (
    SELECT order_id,
           sale_team_id,
           sale_team_name,
           sale_team_freezed_id,
           sale_team_freezed_name
    FROM dim_hpc_trd_ord_seller_d
    WHERE dayid = '$v_date'
) ord_seller ON ord.order_id = ord_seller.order_id

--规则中心数据
LEFT JOIN (
    SELECT order_id,
           newest_user_id
    FROM dim_hpc_ord_finance_order_ascription_d
    WHERE dayid = '$v_date'
) rule_center ON ord.order_id = rule_center.order_id
LEFT JOIN (SELECT * FROM user_admin) user_admin_kn ON rule_center.newest_user_id = user_admin_kn.user_id

--冻结数据
LEFT JOIN (
    SELECT trade_id,
           trade_service_bd_id_frez
    FROM dim_hpc_trd_trade_service_d
    WHERE dayid = '$v_date'
) frozen_trade ON frozen_trade.trade_id = ord.trade_id
LEFT JOIN (SELECT * FROM user_admin) user_admin_frozen ON frozen_trade.trade_service_bd_id_frez = user_admin_frozen.user_id

;
"