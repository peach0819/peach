v_date=$1

source ../sql_variable.sh $v_date

sh /alidata/workspace/yt_bigdata/edp/data_offline_backup/ods_bounty_plan_d.sh $v_date 'prod_slave_cloudatlas' &&
sh /alidata/workspace/yt_bigdata/edp/data_offline_backup/dwd_bounty_plan_d.sh $v_date &&
sh /alidata/workspace/yt_bigdata/edp/data_special_salary_new/dw_bounty_plan_d.sh $v_date &&
sh /alidata/workspace/yt_bigdata/edp/data_special_salary_new/dw_bounty_plan_schedule_d.sh $v_date &&

exit 0
