v_date=$1

source ./dw_salary_supply_data_variable.sh $1

brand_forward_pre_month_where=/tmp/brand_forward_pre_month_where_${file_timestamp}.txt
brand_forward_pre_pre_month_where=/tmp/brand_forward_pre_pre_month_where_${file_timestamp}.txt

brand_backward_pre_month_where=/tmp/brand_backward_pre_month_where_${file_timestamp}.txt
brand_backward_pre_pre_month_where=/tmp/brand_backward_pre_pre_month_where_${file_timestamp}.txt

echo pre_month_last_day: $pre_month_last_day
echo pre_pre_month_last_day: $pre_pre_month_last_day
echo file_timestamp: $file_timestamp
echo pre_month_where: $pre_month_where
echo pre_pre_month_where: $pre_pre_month_where
echo pre_types: $pre_types
echo pre_pre_types: $pre_pre_types

echo brand_forward_pre_month_where: $brand_forward_pre_month_where
echo brand_forward_pre_pre_month_where: $brand_forward_pre_pre_month_where

echo brand_backward_pre_month_where: $brand_backward_pre_month_where
echo brand_backward_pre_pre_month_where: $brand_backward_pre_pre_month_where

## 正向品牌（上上月），只跑与方案月份一致的
cat > ${brand_forward_pre_pre_month_where} <<_EOF_
$pre_pre_month_where
and bounty_rule_type = 3
and month = date_format(from_unixtime(unix_timestamp('$pre_pre_month_last_day', 'yyyyMMdd')), 'yyyy-MM')
_EOF_

## 正向品牌（上上月），只跑与方案月份一致的
cat > ${brand_forward_pre_pre_month_where} <<_EOF_
$pre_pre_month_where
and bounty_rule_type = 3
and month = date_format(from_unixtime(unix_timestamp('$pre_pre_month_last_day', 'yyyyMMdd')), 'yyyy-MM')
_EOF_

## 新签商品（上月）
cat > ${brand_backward_pre_month_where} <<_EOF_
$pre_month_where
and bounty_rule_type = 3
_EOF_

## 新签商品（上上月）
cat > ${brand_backward_pre_pre_month_where} <<_EOF_
$pre_pre_month_where
and bounty_rule_type = 3
_EOF_

#########################
# 正向新签品牌
function sign_brand_forward_supply_data() {
  curr_date=$1
  where_condition=$2
  comment=$3
  echo "【正向】品牌明细表${comment}补数-${curr_date}"
  echo "./dw_salary_sign_brand_rule_public_forward_d.sh ${curr_date} 0 0 1 ${where_condition}"
  sh ./dw_salary_sign_brand_rule_public_forward_d.sh $curr_date 0 0 1 $where_condition
  echo "【正向】品牌汇总表${comment}补数-${curr_date}"
  echo "./dw_salary_forward_plan_sum_sign_brand_rule_d.sh ${curr_date} 0 0 1 ${where_condition}"
  sh ./dw_salary_forward_plan_sum_sign_brand_rule_d.sh $curr_date 0 0 1 $where_condition
}
# 逆向新签品牌
function sign_brand_backward_supply_data() {
  curr_date=$1
  where_condition=$2
  comment=$3
  echo "【逆向】品牌明细表${comment}补数-${curr_date}"
  echo "./dw_salary_sign_brand_rule_public_backward_d.sh ${curr_date} 0 0 1 ${where_condition}"
  sh ./dw_salary_sign_brand_rule_public_backward_d.sh $curr_date 0 0 1 $where_condition

  echo "【逆向】品牌逆向中间汇总${comment}补数-${curr_date}"
  echo "./dw_salary_backward_plan_sum_mid_sign_brand_rule_d.sh ${curr_date} 0 0 1 ${where_condition}"
  sh ./dw_salary_backward_plan_sum_mid_sign_brand_rule_d.sh $curr_date 0 0 1 $where_condition
}
# 所有正向补数上月
if [[ $pre_types =~ "3" ]]
then
  sign_brand_forward_supply_data $pre_month_last_day $brand_pre_month_where '上月'
fi

# 所有正向补数上上月

if [[ $pre_types =~ "3" && $pre_pre_types =~ "3" ]]
then
  sign_brand_forward_supply_data $pre_pre_month_last_day $brand_forward_pre_pre_month_where '上上月'
fi

#############################################################################

# 所有逆向上上月
if [[ $pre_types =~ "3" && $pre_pre_types =~ "3" ]]
then
  sign_brand_backward_supply_data $pre_pre_month_last_day $brand_pre_pre_month_where '上上月'
fi

# 所有逆向上月， 上月依赖上上月
if [[ $pre_types =~ "3" ]]
then
  sign_brand_backward_supply_data $pre_month_last_day $brand_pre_month_where '上月'
fi

exit 0
