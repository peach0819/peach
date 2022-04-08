v_date=$1

source ../sql_variable.sh $v_date

sh ./dw_salary_backward_brand_shop_current_public_d.sh $v_date 0 0 '' &&
sh ./dw_salary_brand_shop_current_object_sum_d.sh $v_date 0 0 '' 'pre' &&
sh ./dw_salary_brand_shop_current_shop_sum_d.sh $v_date 0 0 '' 'pre' &&
sh ./dw_salary_brand_shop_sum_d.sh $v_date 0 0 '' 'pre' &&
sh ./dw_salary_backward_brand_shop_plan_sum_mid_d.sh $v_date 0 0 '' &&

exit 0