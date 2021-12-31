v_date=$1

source ../sql_variable.sh $v_date

function supply_forward() {
    supply_date=$1
    data_date=$2
    sh ./dw_salary_forward_brand_shop_current_public_d.sh $data_date $supply_date
    sh ./dw_salary_brand_shop_current_object_sum_d.sh $data_date 'cur' $supply_date
    sh ./dw_salary_brand_shop_current_shop_sum_d.sh $data_date 'cur' $supply_date
    sh ./dw_salary_brand_shop_sum_d.sh $data_date 'cur' $supply_date
    sh ./dw_salary_forward_brand_shop_plan_sum_d.sh $data_date $supply_date
}

function supply_backward() {
    supply_date=$1
    data_date=$2
    sh ./dw_salary_backward_brand_shop_current_public_d.sh $data_date $supply_date
    sh ./dw_salary_brand_shop_current_object_sum_d.sh $data_date 'pre' $supply_date
    sh ./dw_salary_brand_shop_current_shop_sum_d.sh $data_date 'pre' $supply_date
    sh ./dw_salary_brand_shop_sum_d.sh $data_date 'pre' $supply_date
    sh ./dw_salary_backward_brand_shop_plan_sum_mid_d.sh $data_date $supply_date
}

forward_supply_date=$(apache-spark-sql -e "
    use ytdw;
    SELECT concat_ws('\;' , sort_array(collect_set(cast(need_supply_date as int))))
    FROM dw_bounty_plan_schedule_d
    lateral view explode(split(forward_date,',')) temp as need_supply_date
    WHERE dayid = '$v_date'
    AND bounty_rule_type = 4
    AND supply_date = '$v_date'
    AND need_supply_date < '$v_date'
")

backward_supply_date=$(apache-spark-sql -e "
    use ytdw;
    SELECT concat_ws('\;' , sort_array(collect_set(cast(need_supply_date as int))))
    FROM dw_bounty_plan_schedule_d
    lateral view explode(split(backward_date,',')) temp as need_supply_date
    WHERE dayid = '$v_date'
    AND bounty_rule_type = 4
    AND supply_date = '$v_date'
    AND need_supply_date < '$v_date'
")

echo forward_supply_date: $forward_supply_date
echo backward_supply_date: $backward_supply_date

IFS=";"
for data_date in ${forward_supply_date[@]}
do
    supply_forward $v_date $data_date
done

for data_date in ${backward_supply_date[@]}
do
    supply_backward $v_date $data_date
done
