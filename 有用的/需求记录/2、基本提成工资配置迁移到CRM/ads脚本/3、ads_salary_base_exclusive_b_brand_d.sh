sleep 1m
v_date=$1
sh /alidata/workspace/yt_bigdata/edp/data_offline_backup_two/ods_crm_t_salary_exclusive_b_brand_d.sh $v_date prod_slave_crm &&
sh /alidata/workspace/yt_bigdata/edp/data_offline_backup_two/dwd_crm_salary_exclusive_b_brand_d.sh $v_date &&
source ../sql_variable.sh $v_date

hive -v -e "
use ytdw;
create table if not exists ytdw.ads_salary_base_exclusive_b_brand_d (
  brand_id string comment '专属Bid',
  brand_name string comment '专属B名称',
  update_time string comment '更新时间',
  data_month string comment '数据月份'
)
comment '专属B名单'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;

with source_table as (
  select *
  from dwd_crm_salary_exclusive_b_brand_d
  where dayid='$v_date'
  and is_deleted=0
)
insert overwrite table ads_salary_base_exclusive_b_brand_d partition (dayid='$v_date')
select
  brand_id,
  brand_name,
  from_unixtime(unix_timestamp(edit_time,'yyyyMMddHHmmss'),'yyyy-MM-dd HH:mm:ss') as update_time,
  data_month
from source_table
inner join (
  select max(data_month) as max_month
  from source_table
  where data_month <= substr('$v_date',0,6)
) max_month_data ON source_table.data_month = max_month_data.max_month
" &&

exit 0