v_date=$1

source ./dw_salary_supply_data_variable.sh $1

pre_month_where=/tmp/pre_month_where_${file_timestamp}.txt
pre_pre_month_where=/tmp/pre_pre_month_where_${file_timestamp}.txt

cat > ${pre_month_where} <<_EOF_
$pre_month_where
_EOF_

cat > ${pre_pre_month_where} <<_EOF_
$pre_pre_month_where
_EOF_

echo pre_month_last_day: $pre_month_last_day
echo pre_pre_month_last_day: $pre_pre_month_last_day
echo file_timestamp: $file_timestamp
echo pre_month_where: $pre_month_where
echo pre_pre_month_where: $pre_pre_month_where
echo pre_types: $pre_types
echo pre_pre_types: $pre_pre_types
echo pre_month_where: $pre_month_where
echo pre_pre_month_where: $pre_pre_month_where


### 最终汇总上上月
if [[ $pre_pre_types != "" ]]
then
  sh ./dw_salary_backward_plan_sum_d.sh $pre_pre_month_last_day $pre_pre_month_where
fi

### 最终汇总上月
if [[ $pre_types != "" ]]
then
  sh ./dw_salary_backward_plan_sum_d.sh $pre_month_last_day $pre_month_where
fi

exit 0