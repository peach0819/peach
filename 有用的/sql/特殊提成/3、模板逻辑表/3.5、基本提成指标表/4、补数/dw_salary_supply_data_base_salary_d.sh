v_date=$1
supply_type=$2
forward_type='forward'

if [[ $supply_type != "" ]]
then
  forward_type=$supply_type
fi

source ../sql_variable.sh $v_date

function supply_forward() {
    supply_date=$1
    data_date=$2
    sh ./dw_salary_base_salary_forward_public_d.sh $data_date 0 0 $supply_date
    sh ./dw_salary_base_salary_forward_plan_sum_d.sh $data_date 0 0 $supply_date
}

IFS=";"

if [[ $forward_type = "forward" ]]
then
  forward_supply_date=$(apache-spark-sql -e "
    use ytdw;
    SELECT concat_ws('\;' , sort_array(collect_set(cast(need_supply_date as int))))
    FROM dw_bounty_plan_schedule_d
    lateral view explode(split(forward_date,',')) temp as need_supply_date
    WHERE bounty_rule_type = 5
    AND supply_date = '$v_date'
    AND need_supply_date < '$v_date'
  ")
  echo forward_supply_date: $forward_supply_date
  for data_date in ${forward_supply_date[@]}
  do
      supply_forward $v_date $data_date
  done
fi