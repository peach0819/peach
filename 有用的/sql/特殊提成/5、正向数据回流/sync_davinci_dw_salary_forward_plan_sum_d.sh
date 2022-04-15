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
 source ../sql_variable.sh $1

 echo "HOSTNAME=$HOSTNAME PORT=$PORT DBNAME=$DBNAME"

 #回流表名
 target_table=sync_davinci_dw_salary_forward_plan_sum_d
 source_table=dw_salary_forward_plan_sum_d

 #开始回流
 hdfs_temp_dir="/tmp/${target_table}_temp"
 select_sql="[[QUERY_SQL]]"
 hive -e "
 use ytdw;
 insert overwrite directory '${hdfs_temp_dir}'
 select
 '' as id,
     update_time,--更新时间
    update_month,--执行月份
   from_unixtime(unix_timestamp(plan_month,'yyyyMM'), 'yyyy-MM')  as plan_month,--方案月份
    plan_pay_time,--方案时间
	planno,--方案编号
    plan_name,--方案名称
    plan_group_id,--归属业务组ID
    plan_group_name,--归属业务组
    grant_object_type,--发放对象类型
    grant_object_user_id, --发放对象ID
    grant_object_user_name,--发放对象名称
	grant_object_user_dep_id,--发放对象部门ID
    grant_object_user_dep_name,--发放对象部门
    leave_time,--发放对象离职时间
    sts_target_name,
	sts_target,--统计指标数值
	real_coefficient_goal_rate,--发放对象的当月系数
    commission_cap,
    commission_plan_type,
    commission_reward_type,
    commission_reward,--提成
    dayid,
    planno,
    current_timestamp as create_time
from ytdw.dw_salary_forward_plan_sum_d
where dayid='$1'
and plan_name not like '%废弃%' and plan_name not like '%测试%'
  ;
 " &&
 #删除目标表当天数据，避免重复回流
delete_sql="delete from  $target_table where  substr(dayid,1,6)='$v_cur_month';"
echo "delete_sql=$delete_sql"
sqoop eval --connect jdbc:mysql://$HOSTNAME:$PORT/$DBNAME --username $username --password $password -e "$delete_sql" &&
 #导出到MYSQL
 sqoop export --connect "jdbc:mysql://$HOSTNAME:$PORT/$DBNAME?tinyInt1isBit=false&useUnicode=true&characterEncoding=UTF-8" --username $username --password $password --table $target_table  --fields-terminated-by '\001' --input-null-string '\\N' --input-null-non-string '\\N' --export-dir $hdfs_temp_dir &&
 hadoop fs -rm -r $hdfs_temp_dir &&
 exit 0