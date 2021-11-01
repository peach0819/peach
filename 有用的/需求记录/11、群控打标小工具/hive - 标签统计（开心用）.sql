with a as (
    SELECT *
    FROM dwd_crm_chat_tag_bind_d
    WHERE dayid = '$v_date'
),

crm_chat_tag_bind as (
    SELECT a.*
    FROM a
    LEFT JOIN (
        SELECT max(version) as v FROM a WHERE version_type = 0
    ) ON 1=1
    WHERE a.version = version.v
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
    SELECT *
    FROM dim_hpc_pub_user_admin
),

department as (
    SELECT dept_id as id,
           dept_name as name,
           dept_parent_id as parent_id,
           dept_parent_name as parent_name
    FROM dim_hpc_pub_dept
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

SELECT crm_chat_tag_bind.version as data_version,
       shop.shop_id as shop_id, --`门店id`,
       shop.shop_name as shop_name, --`门店名`,
       linker.linker_id as linker_id, --`联系人id`,
       linker.linker_real_name as linker_real_name, --`联系人名`,
       case when linker.linker_type = 1 then '常用联系人'
            when linker.linker_type is not null then '非常用联系人'
            else null end as is_common, --`联系人是否常用`,
       case when knShop.id is not null then '库内门店'
            when knShop.id is null and shop.shop_id is not null then '非库内门店'
            else null end as is_kn_shop, --`是否库内门店`,

       customer.qw_external_user_id as qw_external_user_id, --`客户企微外部id`,
       customer.name as customer_name, --`客户微信昵称`,
       case when customer.type = 1 then '个微客户' else '企微客户' end as customer_type, --`客户微信类型`,

       xiaoer.qw_user_id as qw_user_id, --`添加人帐号`,
       xiaoer.name as qw_nick_name, --`添加人企微昵称`,
       dept.parent_name as dept_parent_name, --`添加人大区`,
       dept.name as dept_name, --`添加人组名`,
       user_admin.user_real_name as user_real_name, --`添加人真实小二`,

       group1.tag as group_1_tag, --`性别（单选）`,
       group2.tag as group_2_tag, --`代操作服务（单选）`,
       group3.tag as group_3_tag, --`对接人角色（单选）`,
       group4.tag as group_4_tag, --`开店形式（单选）`,
       group5.tag as group_5_tag, --`其他比价拿货平台（多选）`,
       group6.tag as group_6_tag, --`门店类型（多选）`,
       group7.tag as group_7_tag, --`门店提供的附加服务（多选）`,
       group8.tag as group_8_tag  --`门店线上销售渠道（多选）`
FROM (
    SELECT chat_id, biz_id
    FROM crm_chat_bind
    WHERE is_deleted = 0
    AND type = 1
    order by id
) xiaoer_bind

--小二面
INNER JOIN crm_chat xiaoer ON xiaoer.type = 2 AND xiaoer.id = xiaoer_bind.chat_id and xiaoer.is_deleted = 0
INNER JOIN crm_work_phone phone ON phone.bind_qw_user_id = xiaoer.qw_user_id and phone.is_deleted = 0
LEFT JOIN user_admin user_admin ON user_admin.user_id = phone.bind_user_id
LEFT JOIN department dept ON dept.id = user_admin.dept_id

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
    SELECT distinct qw_user_id, qw_external_user_id
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