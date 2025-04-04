#!/bin/sh

#加载环境变量
echo "start..."

#输入参数 日期
datadate=$1
today=$(date -d"$datadate" +%Y-%m-%d)

#环境配置 test_admin 、prod_admin
envdb=$2
echo "datadate=$datadate envdb=$envdb today=$today"

#加载相应变量
source ../export_db_config.sh $envdb
echo "HOSTNAME=$HOSTNAME PORT=$PORT DBNAME=$DBNAME"

#回流表名
target_table=sync_touch_vs_dkh_d
source_table=ads_touch_vs_dkh_d

#开始回流
hdfs_temp_dir='/tmp/'$target_table'_temp'
select_sql="[[QUERY_SQL]]"
hive -e "
use ytdw;
insert overwrite directory '${hdfs_temp_dir}'
select '' as id,
	     'etl' as creator,
	     'etl' as editor,
	     current_timestamp as create_time,
	     current_timestamp as edit_time,
	     0 as is_deleted,
	     dayid,
       shop_id,
       biz_value
from $source_table
where dayid='$1';
" &&
#删除目标表当天数据，避免重复回流
delete_sql="delete from $target_table where dayid = '$datadate';"
echo "delete_sql=$delete_sql"
sqoop eval \
	--connect jdbc:mysql://$HOSTNAME:$PORT/$DBNAME \
   --username $username \
   --password $password \
   -e "$delete_sql" &&

echo "连接成功"
#导出到MYSQL
sqoop export \
  --connect "jdbc:mysql://$HOSTNAME:$PORT/$DBNAME?tinyInt1isBit=false&useUnicode=true&characterEncoding=UTF-8" \
  --username $username \
  --password $password \
  --table $target_table  \
  --fields-terminated-by '\001' \
  --input-null-string '\\N' \
  --input-null-non-string '\\N' \
  --export-dir $hdfs_temp_dir &&
hadoop fs -rm -r $hdfs_temp_dir &&
exit 0