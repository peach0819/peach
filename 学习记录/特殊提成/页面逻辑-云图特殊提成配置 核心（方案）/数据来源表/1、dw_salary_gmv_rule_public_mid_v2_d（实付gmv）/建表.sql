create table if not exists dw_salary_gmv_rule_public_mid_v2_d
(
    business_unit                    string comment '业务域',
    category_id_first                bigint comment '商品一级类目id',
    category_id_second               bigint comment '商品二级类目id',
    category_id_first_name           string comment '商品一级类目',
    category_id_second_name          string comment '商品二级类目',
    brand_id                         bigint comment '商品品牌id',
    brand_name                       string comment '商品品牌',
    item_id                          bigint comment '商品ID',
    item_name                        string comment '商品名称',
    item_style                       tinyint comment 'AB类型',
    item_style_name                  string comment 'AB类型名称',
    is_sp_shop                       string comment '是否服务商订单',
    is_bigbd_shop                    string comment '是否大BD门店',
    is_spec_order                    string comment '是否特殊订单',
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
    sp_id                            bigint comment '服务商ID',
    sp_name                          string comment '服务商名',
    sp_operator_name                 string comment '服务商经理名',
    service_user_names_freezed       string comment '冻结销售人员姓名',
    service_feature_names_freezed    string comment '冻结销售人员职能',
    service_job_names_freezed        string comment '冻结销售人员角色',
    service_department_names_freezed string comment '冻结销售人员部门',
    service_info_freezed             string,
    service_info                     string,
    gmv_less_refund                  decimal(18, 2) comment '实货gmv-退款',
    gmv                              decimal(18, 2) comment '实货gmv',
    pay_amount                       decimal(18, 2) comment '实货支付金额',
    pay_amount_less_refund           decimal(18, 2) comment '实货支付金额-退款',
    refund_actual_amount             decimal(18, 2) comment '实货退款',
    refund_retreat_amount            decimal(18, 2) comment '实货清退金额',
    pay_day                          string comment '支付日期',
    order_id                         string comment '子订单id',
    sale_team_name                   string comment '销售团队标识 1:电销部 2:BD部 3:大客户部 4:服务商部 5:美妆销售团队',
    sale_team_freezed_name           string comment '冻结销售团队标识 1:电销部 2:BD部 3:大客户部 4:服务商部 5:美妆销售团队',
    sale_team_id                     int comment '销售团队标识ID',
    sale_team_freezed_id             int comment '冻结销售团队标识ID'
) comment 'gmv规则通用方案中间表'
    partitioned by (dayid string)
    row format delimited fields terminated by '\001'
    stored as orc;