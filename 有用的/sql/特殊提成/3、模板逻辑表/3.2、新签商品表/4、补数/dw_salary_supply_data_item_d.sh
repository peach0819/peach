v_date=$1
supply_type=$2
forward_type='forward'
backward_type='backward'

if [[ $supply_type != "" ]]
then
  forward_type=$supply_type
  backward_type=$supply_type
fi

source ../sql_variable.sh $v_date

function supply_forward() {
    supply_date=$1
    data_date=$2
    sh ./dw_salary_sign_item_rule_public_forward_d.sh $data_date 0 0 $supply_date
    sh ./dw_salary_forward_plan_sum_sign_item_rule_d.sh $data_date 0 0 $supply_date
}

function supply_backward() {
    supply_date=$1
    data_date=$2
    sh ./dw_salary_sign_item_rule_public_backward_d.sh $data_date 0 0 $supply_date
    sh ./dw_salary_backward_plan_sum_mid_sign_item_rule_d.sh $data_date 0 0 $supply_date
}

IFS=";"

if [[ $forward_type = "forward" ]]
then
  forward_supply_date=$(apache-spark-sql -e "
    use ytdw;
    SELECT concat_ws('\;' , sort_array(collect_set(cast(need_supply_date as int))))
    FROM dw_bounty_plan_schedule_d
    lateral view explode(split(forward_date,',')) temp as need_supply_date
    WHERE bounty_rule_type = 2
    AND supply_date = '$v_date'
    AND need_supply_date < '$v_date'
  ")
  echo forward_supply_date: $forward_supply_date
  for data_date in ${forward_supply_date[@]}
  do
      supply_forward $v_date $data_date
  done
fi

if [[ $backward_type = "backward" ]]
then
  backward_supply_date=$(apache-spark-sql -e "
    use ytdw;
    SELECT concat_ws('\;' , sort_array(collect_set(cast(need_supply_date as int))))
    FROM dw_bounty_plan_schedule_d
    lateral view explode(split(backward_date,',')) temp as need_supply_date
    WHERE bounty_rule_type = 2
    AND supply_date = '$v_date'
    AND need_supply_date < '$v_date'
  ")
  echo backward_supply_date: $backward_supply_date
  for data_date in ${backward_supply_date[@]}
  do
      supply_backward $v_date $data_date
  done
fi