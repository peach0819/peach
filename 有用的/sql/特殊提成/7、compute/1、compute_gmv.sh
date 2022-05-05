v_date=$1

source ../sql_variable.sh $v_date

sh /alidata/workspace/yt_bigdata/edp/data_special_salary/dw_salary_gmv_rule_public_mid_v2_d.sh $v_date &&

sh ./dw_salary_gmv_rule_public_forward_d.sh $v_date 0 0 '' &&
sh ./dw_salary_forward_plan_sum_gmv_rule_d.sh $v_date 0 0 '' &&

sh ./dw_salary_gmv_rule_public_backward_d.sh $v_date 0 0 '' &&
sh ./dw_salary_backward_plan_sum_mid_gmv_rule_d.sh $v_date 0 0 '' &&

exit 0