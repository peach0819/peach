v_date=$1

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;

create table if not exists ads_chat_tag_bind_d
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
    group_8_tag         string comment '门店线上销售渠道（多选）',
    union_id            string comment '客户unionid'
) comment '企微标签数据统计表'
partitioned by (dayid string)
stored as orc;

with a as (
    SELECT *
    FROM dwd_crm_chat_tag_bind_d
    WHERE dayid = '$v_date'
),

crm_chat_tag_bind as (
    SELECT a.qw_user_id,
           a.qw_external_user_id,
           a.version as tag_version,
           a.group_name,
           a.tag_name
    FROM a
    LEFT JOIN (
        SELECT max(version) as v FROM a WHERE version_type = 0
    ) temp ON 1=1
    WHERE a.version = temp.v
),

tag_group as (
    SELECT qw_user_id,
           qw_external_user_id,
           group_name,
           concat_ws(',' , collect_set(tag_name)) as tag
    FROM crm_chat_tag_bind
    group by qw_user_id,
             qw_external_user_id,
             group_name
),

crm_chat_bind as (
    SELECT *
    FROM dwd_crm_chat_bind_d
    WHERE dayid = '$v_date'
    order by id
),

relation as (
    SELECT *
    FROM dwd_crm_chat_relation_d
    WHERE dayid = '$v_date'
    AND is_deleted = 0
    AND qw_to_shop_status = 0
),

crm_chat as (
    SELECT *
    FROM dwd_crm_chat_d
    WHERE dayid = '$v_date'
),

crm_work_phone as (
    SELECT *
    FROM dwd_crm_work_phone_d
    WHERE dayid = '$v_date'
),

shop_pool_server as (
    SELECT *
    FROM dwd_shop_pool_server_d
    WHERE dayid = '$v_date'
),

user_admin as (
    SELECT user_id,
           user_real_name,
           dept_id
    FROM dim_hpc_pub_user_admin
),

department as (
    SELECT id,
           name,
           parent_id
    FROM dwd_department_d
    WHERE dayid = '$v_date'
),

linker as (
    SELECT *
    FROM dwd_linker_d
    WHERE dayid = '$v_date'
),

shop as (
    SELECT *
    FROM dwd_shop_d
    WHERE dayid = '$v_date'
)

insert overwrite table ads_chat_tag_bind_d partition(dayid='$v_date')
SELECT total.tag_version as data_version,
       shop.shop_id as shop_id,
       shop.shop_name as shop_name,
       linker.linker_id as linker_id,
       linker.linker_real_name as linker_real_name,
       case when linker.linker_type = 1 then '常用联系人'
            when linker.linker_type is not null then '非常用联系人'
            else null end as is_common,
       case when knShop.id is not null then '库内门店'
            when knShop.id is null and shop.shop_id is not null then '非库内门店'
            else null end as is_kn_shop,

       customer.qw_external_user_id as qw_external_user_id,
       customer.name as customer_name,
       customer.type as customer_type,

       xiaoer.qw_user_id as qw_user_id,
       xiaoer.name as qw_nick_name,
       parent_dept.name as dept_parent_name,
       dept.name as dept_name,
       user_admin.user_real_name as user_real_name,

       group1.tag as group_1_tag,
       group2.tag as group_2_tag,
       group3.tag as group_3_tag,
       group4.tag as group_4_tag,
       group5.tag as group_5_tag,
       group6.tag as group_6_tag,
       group7.tag as group_7_tag,
       group8.tag as group_8_tag,
       customer.union_id
FROM (
    SELECT qw_chat_id as chat_id,
           shop_chat_id as biz_id
    FROM relation
) xiaoer_bind

--小二面
INNER JOIN crm_chat xiaoer ON xiaoer.type = 2 AND xiaoer.id = xiaoer_bind.chat_id and xiaoer.is_deleted = 0
LEFT JOIN crm_work_phone phone ON phone.bind_qw_user_id = xiaoer.qw_user_id and phone.is_deleted = 0
LEFT JOIN user_admin user_admin ON user_admin.user_id = phone.bind_user_id
LEFT JOIN department dept ON dept.id = user_admin.dept_id
LEFT JOIN department parent_dept ON dept.parent_id = parent_dept.id

--客户面
INNER JOIN crm_chat customer ON customer.id = xiaoer_bind.biz_id and customer.is_deleted = 0
LEFT JOIN crm_chat_bind linker_bind ON customer.id = linker_bind.chat_id and linker_bind.is_deleted = 0
LEFT JOIN linker linker ON linker_bind.biz_id = linker.linker_id
LEFT JOIN shop shop ON linker.linker_obj_id = shop.shop_id

--库内面
LEFT JOIN (
    select user_id, shop_id, id
    from shop_pool_server
    where is_enabled=1
) knShop on knShop.user_id= phone.bind_user_id AND knShop.shop_id = shop.shop_id

--标签面
LEFT JOIN (
    SELECT distinct qw_user_id, qw_external_user_id, tag_version
    FROM crm_chat_tag_bind
) total ON total.qw_user_id = xiaoer.qw_user_id AND total.qw_external_user_id = customer.qw_external_user_id

LEFT JOIN tag_group group1 ON group1.qw_user_id = total.qw_user_id AND group1.qw_external_user_id = total.qw_external_user_id AND group1.group_name = '性别(单选)'
LEFT JOIN tag_group group2 ON group2.qw_user_id = total.qw_user_id AND group2.qw_external_user_id = total.qw_external_user_id AND group2.group_name = '代操作服务(单选)'
LEFT JOIN tag_group group3 ON group3.qw_user_id = total.qw_user_id AND group3.qw_external_user_id = total.qw_external_user_id AND group3.group_name = '对接人角色(单选)'
LEFT JOIN tag_group group4 ON group4.qw_user_id = total.qw_user_id AND group4.qw_external_user_id = total.qw_external_user_id AND group4.group_name = '开店形式(单选)'
LEFT JOIN tag_group group5 ON group5.qw_user_id = total.qw_user_id AND group5.qw_external_user_id = total.qw_external_user_id AND group5.group_name = '其他比价拿货平台(多选)'
LEFT JOIN tag_group group6 ON group6.qw_user_id = total.qw_user_id AND group6.qw_external_user_id = total.qw_external_user_id AND group6.group_name = '门店类型(多选)'
LEFT JOIN tag_group group7 ON group7.qw_user_id = total.qw_user_id AND group7.qw_external_user_id = total.qw_external_user_id AND group7.group_name = '门店提供的附加服务(多选)'
LEFT JOIN tag_group group8 ON group8.qw_user_id = total.qw_user_id AND group8.qw_external_user_id = total.qw_external_user_id AND group8.group_name = '门店线上销售渠道(多选)'
;
"