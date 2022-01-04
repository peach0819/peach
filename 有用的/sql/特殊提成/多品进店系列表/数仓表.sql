
--比对周期明细表
dw_salary_brand_shop_compare_public_d

--比对周期汇总表
dw_salary_brand_shop_compare_shop_sum_d

--当前周期明细表
dw_salary_brand_shop_current_public_d (正逆分区)
(dw_salary_forward_brand_shop_current_public_d)
(dw_salary_backward_brand_shop_current_public_d)

--当前周期销售粒度汇总表
dw_salary_brand_shop_current_object_sum_d (正逆分区)

--当前周期门店粒度汇总表
dw_salary_brand_shop_current_shop_sum_d (正逆分区)

--多品进店门店维度汇总表
dw_salary_brand_shop_sum_d (正逆分区)

--特殊提成正向汇总表
dw_salary_forward_plan_sum_d
(dw_salary_forward_brand_shop_plan_sum_d)

--特殊提成逆向汇总表
dw_salary_backward_plan_sum_mid_d
(dw_salary_backward_brand_shop_plan_sum_mid_d)

--特殊提成逆向比对汇总表
dw_salary_backward_plan_sum_d