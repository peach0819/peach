v_date=$1

source ../sql_variable.sh $v_date

function supply_backward() {
    supply_date=$1
    data_date=$2
    sh ./dw_salary_backward_plan_sum_d.sh $data_date 0 0 $supply_date
}

backward_supply_date=$(apache-spark-sql -e "
    use ytdw;
    SELECT concat_ws('\;' , sort_array(collect_set(cast(need_supply_date as int))))
    FROM dw_bounty_plan_schedule_d
    lateral view explode(split(backward_date,',')) temp as need_supply_date
    WHERE supply_date = '$v_date'
    AND need_supply_date < '$v_date'
")

echo backward_supply_date: $backward_supply_date

IFS=";"
for data_date in ${backward_supply_date[@]}
do
    supply_backward $v_date $data_date
done
