--薪资项
with salary_item as (
select
    service_user_id,
    is_pickup_recharge_order,
    is_split,
    category_id_first_name,
    category_id_second_name,
    commission_actual_amount,
    class_number,
    class_number_info
  from ads_salary_biz_frozen_pure_gmv_detail_d
  where dayid='$v_date'
)

insert overwrite table ads_salary_biz_frozen_pure_gmv_d partition(dayid='$v_date')
select
  service_user_id,
  sum(commission_actual_amount) as commission_summary,
  sum(case when category_id_first_name='奶粉' then commission_actual_amount else 0 end) as milk_commission_summary,
  sum(case when category_id_first_name='尿不湿' then commission_actual_amount else 0 end) as diaper_commission_summary,
  sum(case when category_id_second_name in ('衣物清洁护理','纸巾') then commission_actual_amount else 0 end) as shampoo_commission_summary,
  sum(case when category_id_first_name not in ('奶粉','尿不湿') and nvl(category_id_second_name,'未知') not in ('衣物清洁护理','纸巾') then commission_actual_amount else 0 end) as other_commission_summary,
  sum(case when class_number='分类01' then commission_actual_amount else 0 end) as num01_pure_b_pay_amount,
  sum(case when class_number='分类02' then commission_actual_amount else 0 end) as num02_pure_b_pay_amount,
  sum(case when class_number='分类03' then commission_actual_amount else 0 end) as num03_pure_b_pay_amount,
  sum(case when class_number='分类04' then commission_actual_amount else 0 end) as num04_pure_b_pay_amount,
  sum(case when class_number='分类05' then commission_actual_amount else 0 end) as num05_pure_b_pay_amount,
  sum(case when class_number='分类06' then commission_actual_amount else 0 end) as num06_pure_b_pay_amount,
  sum(case when class_number='分类07' then commission_actual_amount else 0 end) as num07_pure_b_pay_amount,
  sum(case when class_number='分类08' then commission_actual_amount else 0 end) as num08_pure_b_pay_amount,
  sum(case when is_pickup_recharge_order=1 then commission_actual_amount else 0 end) as pickup_card_commission_summary,--提货卡充值提成总和
  sum(case when is_pickup_recharge_order=0 then commission_actual_amount else 0 end) as goods_commission_summary,--实货支付提成总和
  max(case when class_number='分类01' then class_number_info else '' end) as num01_pure_b_pay_name,
  max(case when class_number='分类02' then class_number_info else '' end) as num02_pure_b_pay_name,
  max(case when class_number='分类03' then class_number_info else '' end) as num03_pure_b_pay_name,
  max(case when class_number='分类04' then class_number_info else '' end) as num04_pure_b_pay_name,
  max(case when class_number='分类05' then class_number_info else '' end) as num05_pure_b_pay_name,
  max(case when class_number='分类06' then class_number_info else '' end) as num06_pure_b_pay_name,
  max(case when class_number='分类07' then class_number_info else '' end) as num07_pure_b_pay_name,
  max(case when class_number='分类08' then class_number_info else '' end) as num08_pure_b_pay_name,
  sum(case when class_number='分类09' then commission_actual_amount else 0 end) as num09_pure_b_pay_amount,
  max(case when class_number='分类09' then class_number_info else '' end) as num09_pure_b_pay_name
from salary_item
group by service_user_id