#!/bin/sh
#**************************************************************************************************
# ** 脚本名称 dwd_salary_offline_refund_d
# ** 功能描述：dwd_salary_offline_refund_d用于清洗源表数据ods_salary_offline_refund_d
# **
# ** 创建者：chenchen.zheng@hipac.cn
# ** 创建日期：2019-09-29 16:18:05
# ** 修改日志：
# ** 修改日期 修改人 修改内容
# ** -----------------------------------------------------------------------------------------------
# ** All Rights Reserved.
#***************************************************************************************************
sleep 1m
datadate=$1
sh /alidata/workspace/yt_bigdata/edp/salary_data_prodcut/ods_salary_offline_refund_d.sh $1 prod_slave_cloudatlas &&
source ../sql_variable.sh $1
#初始化表名
source_table=salary_offline_refund
ods_source_table=ods_${source_table}_d
target_table=dwd_${source_table/#t_/}_d
echo "ods_source_table=$ods_source_table  target_table=$target_table"
#ods->dwd
echo "datadate=$1"
create_sql="create table if not exists $target_table
(
id bigint comment '',
order_num string comment '订单编号',
refund_amount double comment '金额',
creator string comment '提交人',
create_time string comment '创建时间',
editor string comment '修改人',
edit_time string comment '修改时间',
is_deleted tinyint comment '已删除')
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc
location '/dw/ytdw/dwd/$target_table';"
echo create_sql=$create_sql

select_sql="select
id,
order_num,
refund_amount,
creator,
from_unixtime(unix_timestamp(create_time),'yyyyMMddHHmmss') as create_time,
editor,
from_unixtime(unix_timestamp(edit_time),'yyyyMMddHHmmss') as edit_time,
is_deleted
 from $ods_source_table
where dayid='$datadate';"
echo select_sql=$select_sql


#ETL
hive -e "
set hive.exec.compress.intermediate=true;
set hive.exec.compress.output=true;
use ytdw;
$create_sql
insert overwrite table ${target_table}  partition(dayid='$1')
$select_sql
;

insert overwrite table ytdw.dw_offline_refund_d partition(dayid='$v_date')
select
order_num as trade_no,
refund_amount as refund_actual_amount,
from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time
from ytdw.dwd_salary_offline_refund_d where dayid='$v_date'
;

insert overwrite table dw_order_offline_refund_d partition (dayid='$v_date')
 select
          order_shop.order_id,order_shop.trade_id,offline_refund.trade_no,
          offline_refund.refund_actual_amount*(order_shop.item_actual_amount/trade_shop_total.item_actual_amount) refund_actual_amount
        from
        (
        select trade_no,sum(refund_actual_amount) refund_actual_amount from ytdw.dw_offline_refund_d where dayid='$v_date' group by trade_no
        ) offline_refund
        left join
        (
        select * from ytdw.dwd_trade_shop_d where dayid='$v_date' and is_deleted=0
        ) trade_shop on trade_shop.trade_no=offline_refund.trade_no
        left join
        (
        select * from ytdw.dwd_order_shop_d where dayid='$v_date' and is_deleted=0
        ) order_shop on order_shop.trade_id=trade_shop.trade_id
        left join
        (
        select trade_id,sum(item_actual_amount) item_actual_amount
          from ytdw.dwd_order_shop_d where dayid='$v_date' and is_deleted=0
        group by trade_id
        ) trade_shop_total on trade_shop_total.trade_id=order_shop.trade_id
        ;

"
exit 0