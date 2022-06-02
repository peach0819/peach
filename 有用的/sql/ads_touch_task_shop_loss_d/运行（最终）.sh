v_date=$1

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;

create table if not exists ads_touch_task_shop_loss_d
(
    shop_id             string comment '门店id',
    shop_name           string comment '门店名',
    linker_id           string comment '联系人id',
    linker_real_name    string comment '联系人名',
    customer_name       string comment '客户微信昵称',
    customer_remark     string comment '客户微信备注',
    qw_user_id          string comment '添加人帐号',
    qw_nick_name        string comment '添加人企微昵称',
    user_real_name      string comment '添加人真实小二',
    dept_name           string comment '添加人组名',
    dept_parent_name    string comment '添加人大区',
    loss_type           string comment '客户流失类型'
) comment '触达中心客户流失数据统计表'
partitioned by (dayid string)
stored as orc;

insert overwrite table ads_touch_task_shop_loss_d partition(dayid='$v_date')
SELECT
    detail.shop_id,
    shop.shop_name,
    detail.linker_id,
    linker.linker_real_name,
    customer.name as customer_name,
    customer_bind.remark as customer_remark,
    xiaoer.qw_user_id as qw_user_id,
    xiaoer.name as qw_nick_name,
    concat(admin.user_real_name, '(', admin.official_name,')') as user_real_name,
    dept.name as dept_name,
    dept.parent_name as dept_parent_name,
    case when detail.fail_type = 14 then '拉黑' else '删好友' end as loss_type
FROM (
    SELECT distinct shop_id, linker_id, admin_chat_id, shop_chat_id, fail_type
    FROM (SELECT * FROM dwd_touch_task_detail_d WHERE dayid = '$v_date') t
    WHERE detail_status = 3
    AND fail_type IN (14,15)
    AND substr(create_time,1,8)='$v_date'
) detail
LEFT JOIN (SELECT * FROM dwd_shop_d WHERE dayid = '$v_date') shop ON detail.shop_id = shop.shop_id
LEFT JOIN (SELECT * FROM dwd_linker_d WHERE dayid = '$v_date') linker ON linker.linker_id = detail.linker_id

LEFT JOIN (SELECT * FROM dwd_crm_chat_d WHERE dayid = '$v_date') xiaoer ON xiaoer.id = detail.admin_chat_id
LEFT JOIN (SELECT * FROM dwd_crm_work_phone_d WHERE dayid = '$v_date') phone ON xiaoer.qw_user_id = phone.bind_qw_user_id
LEFT JOIN (SELECT * FROM dim_hpc_pub_user_admin) admin ON phone.bind_user_id = admin.user_id
LEFT JOIN (
    SELECT dept_id as id,
           dept_name as name,
           dept_parent_id as parent_id,
           dept_parent_name as parent_name
    FROM dim_hpc_pub_dept
) dept ON dept.id = admin.dept_id

LEFT JOIN (SELECT * FROM dwd_crm_chat_d WHERE dayid = '$v_date') customer ON customer.id = detail.shop_chat_id
LEFT JOIN (SELECT * FROM dwd_crm_chat_relation_d WHERE dayid = '$v_date') customer_bind ON customer.id = customer_bind.shop_chat_id AND customer_bind.qw_chat_id = xiaoer.id
;
"