create table if not exists dw_salary_gmv_rule_public_mid_v2_d
(
    data_version        int comment '数据版本',
    shop_id             string comment '门店id',
    shop_name           string comment '门店名',
    linker_id           string comment '联系人id',
    linker_real_name    string comment '联系人名',
    is_common           string comment '联系人是否常用',
    is_kn_shop          string comment '是否库内门店',
    qw_external_user_id string comment '客户企微外部id',
    customer_name       string comment '客户微信昵称',
    customer_type       int comment '客户微信类型',
    qw_user_id          string comment '添加人帐号',
    qw_nick_name        string comment '添加人企微昵称',
    dept_parent_name    string comment '添加人大区',
    dept_name           string comment '添加人组名',
    user_real_name      string comment '添加人真实小二',
    group_1_tag         string comment '性别（单选）',
    group_2_tag         string comment '代操作服务（单选）',
    group_3_tag         string comment '对接人角色（单选）',
    group_4_tag         string comment '开店形式（单选）',
    group_5_tag         string comment '其他比价拿货平台（多选）',
    group_6_tag         string comment '门店类型（多选）',
    group_7_tag         string comment '门店提供的附加服务（多选）',
    group_8_tag         string comment '门店线上销售渠道（多选）'
) comment '企微标签数据统计表'
partitioned by (dayid string)
stored as orc;