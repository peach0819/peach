v_date=$1

source ./dw_salary_supply_data_variable.sh $1

gmv_pre_month_where=/tmp/gmv_pre_month_where_${file_timestamp}.txt
gmv_pre_pre_month_where=/tmp/gmv_pre_pre_month_where_${file_timestamp}.txt
gmv_forward_pre_pre_month_where=/tmp/gmv_forward_pre_pre_month_where_${file_timestamp}.txt

echo pre_month_last_day: $pre_month_last_day
echo pre_pre_month_last_day: $pre_pre_month_last_day
echo file_timestamp: $file_timestamp
echo pre_month_where: $pre_month_where
echo pre_pre_month_where: $pre_pre_month_where
echo pre_types: $pre_types
echo pre_pre_types: $pre_pre_types
echo gmv_pre_month_where: $gmv_pre_month_where
echo gmv_pre_pre_month_where: $gmv_pre_pre_month_where
echo gmv_forward_pre_pre_month_where: $gmv_forward_pre_pre_month_where

## 存量GMV（上月）
cat > ${gmv_pre_month_where} <<_EOF_
$pre_month_where
and bounty_rule_type = 1
_EOF_

## 存量GMV（上上月）
cat > ${gmv_pre_pre_month_where} <<_EOF_
$pre_pre_month_where
and bounty_rule_type = 1
_EOF_

## 正向存量GMV（上上月），只跑与方案月份一致的
cat > ${gmv_forward_pre_pre_month_where} <<_EOF_
$pre_pre_month_where
and bounty_rule_type = 1
and month = date_format(from_unixtime(unix_timestamp('$pre_pre_month_last_day', 'yyyyMMdd')), 'yyyy-MM')
_EOF_

# 正向gmv补数
function gmv_forward_supply_data() {
  # 表 dw_salary_gmv_rule_public_d -> dw_salary_forward_plan_sum_d
  curr_date=$1
  where_condition=$2
  echo "【正向】GMV明细表${comment}补数-${curr_date}"
  echo "./dw_salary_gmv_rule_public_forward_d.sh ${curr_date} 0 0 1 ${where_condition}"
  sh ./dw_salary_gmv_rule_public_forward_d.sh $curr_date 0 0 1 $where_condition
  echo "【正向】GMV汇总表${comment}补数-${curr_date}"
  echo "./dw_salary_forward_plan_sum_gmv_rule_d.sh $curr_date 0 0 1 $where_condition"
  sh ./dw_salary_forward_plan_sum_gmv_rule_d.sh $curr_date 0 0 1 $where_condition
}
# 逆向gmv补数
function gmv_backward_supply_data() {
  # 表 dw_salary_gmv_rule_public_d -> dw_salary_backward_plan_sum_mid_d -> dw_salary_backward_plan_sum_d
  curr_date=$1
  where_condition=$2
  echo "【逆向】GMV明细表${comment}补数-${curr_date}"
  echo "./dw_salary_gmv_rule_public_backward_d.sh ${curr_date} 0 0 1 ${where_condition}"
  sh ./dw_salary_gmv_rule_public_backward_d.sh $curr_date 0 0 1 $where_condition
  echo "【逆向】GMV逆向中间汇总${comment}补数-${curr_date}"
  echo "./dw_salary_backward_plan_sum_mid_gmv_rule_d.sh ${curr_date} 0 0 1 ${where_condition}"
  sh ./dw_salary_backward_plan_sum_mid_gmv_rule_d.sh $curr_date 0 0 1 $where_condition
}

# 所有正向补数上月
if [[ $pre_types =~ "1" ]]
then
  gmv_forward_supply_data $pre_month_last_day $gmv_pre_month_where '上月'
fi

# 所有正向补数上上月
if [[ $pre_types =~ "1" && $pre_pre_types =~ "1" ]]
then
  gmv_forward_supply_data $pre_pre_month_last_day $gmv_forward_pre_pre_month_where '上上月'
fi
#############################################################################

# 所有逆向上上月
if [[ $pre_types =~ "1" && $pre_pre_types =~ "1" ]]
then
  gmv_backward_supply_data $pre_pre_month_last_day $gmv_pre_pre_month_where '上上月'
fi

# 所有逆向上月， 上月依赖上上月
if [[ $pre_types =~ "1" ]]
then
  gmv_backward_supply_data $pre_month_last_day $gmv_pre_month_where '上月'
fi

exit 0