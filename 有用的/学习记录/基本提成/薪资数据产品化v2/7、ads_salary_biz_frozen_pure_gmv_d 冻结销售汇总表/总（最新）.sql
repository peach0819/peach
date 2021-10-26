use ytdw;

CREATE TABLE IF NOT EXISTS ads_salary_biz_frozen_pure_gmv_d
(
    service_user_id                                string COMMENT '服务人员id',
    commission_summary                             decimal(11, 2) COMMENT '提成总和',
    milk_commission_summary                        decimal(11, 2) COMMENT '奶粉提成',
    diaper_commission_summary                      decimal(11, 2) COMMENT '尿不湿提成',
    shampoo_commission_summary                     decimal(11, 2) COMMENT '洗衣液提成',
    other_commission_summary                       decimal(11, 2) COMMENT '其他提成',
    num01_pure_b_pay_amount                        decimal(18, 2) COMMENT '分类01 提成',
    num02_pure_b_pay_amount                        decimal(18, 2) COMMENT '分类02 提成',
    num03_pure_b_pay_amount                        decimal(18, 2) COMMENT '分类03 提成',
    num04_pure_b_pay_amount                        decimal(18, 2) COMMENT '分类04 提成',
    num05_pure_b_pay_amount                        decimal(18, 2) COMMENT '分类05 提成',
    num06_pure_b_pay_amount                        decimal(18, 2) COMMENT '分类06 提成',
    num07_pure_b_pay_amount                        decimal(18, 2) COMMENT '分类07 提成',
    num08_pure_b_pay_amount                        decimal(18, 2) COMMENT '分类08 提成',
    pickup_card_commission_summary                 decimal(18, 2) COMMENT '提货卡充值提成总和',
    goods_commission_summary                       decimal(18, 2) COMMENT '实货支付提成总和',
    num01_pure_b_pay_name                          string COMMENT '分类01提成名称',
    num02_pure_b_pay_name                          string COMMENT '分类02提成名称',
    num03_pure_b_pay_name                          string COMMENT '分类03提成名称',
    num04_pure_b_pay_name                          string COMMENT '分类04提成名称',
    num05_pure_b_pay_name                          string COMMENT '分类05提成名称',
    num06_pure_b_pay_name                          string COMMENT '分类06提成名称',
    num07_pure_b_pay_name                          string COMMENT '分类07提成名称',
    num08_pure_b_pay_name                          string COMMENT '分类08提成名称',
    num09_pure_b_pay_amount                        decimal(18, 2) COMMENT '分类09 提成',
    num09_pure_b_pay_name                          string COMMENT '分类09提成名称',
    b_pure_pay_amount_freezed_not_pickup_to_shihuo decimal(18, 2) COMMENT '冻结实货支付(非提货卡支付)',
    b_pure_pay_amount_freezed_pickup_to_shihuo     decimal(18, 2) COMMENT '冻结B类净支付金额(提货卡转实货)'
)
comment '销售汇总数据'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;

insert overwrite table ads_salary_biz_frozen_pure_gmv_d partition (dayid = '$v_date')
select service_user_id,
       sum(commission_actual_amount) as commission_summary,
       sum(case when category_id_first_name = '奶粉' then commission_actual_amount else 0 end) as milk_commission_summary,
       sum(case when category_id_first_name = '尿不湿' then commission_actual_amount else 0 end) as diaper_commission_summary,
       sum(case when category_id_second_name in ('衣物清洁护理', '纸巾') then commission_actual_amount else 0 end) as shampoo_commission_summary,
       sum(case when category_id_first_name not in ('奶粉', '尿不湿')
                     and nvl(category_id_second_name, '未知') not in ('衣物清洁护理', '纸巾') then commission_actual_amount
               else 0 end) as other_commission_summary,
       sum(case when class_number = '分类01' then commission_actual_amount else 0 end) as        num01_pure_b_pay_amount,
       sum(case when class_number = '分类02' then commission_actual_amount else 0 end) as        num02_pure_b_pay_amount,
       sum(case when class_number = '分类03' then commission_actual_amount else 0 end) as        num03_pure_b_pay_amount,
       sum(case when class_number = '分类04' then commission_actual_amount else 0 end) as        num04_pure_b_pay_amount,
       sum(case when class_number = '分类05' then commission_actual_amount else 0 end) as        num05_pure_b_pay_amount,
       sum(case when class_number = '分类06' then commission_actual_amount else 0 end) as        num06_pure_b_pay_amount,
       sum(case when class_number = '分类07' then commission_actual_amount else 0 end) as        num07_pure_b_pay_amount,
       sum(case when class_number = '分类08' then commission_actual_amount else 0 end) as        num08_pure_b_pay_amount,
       sum(case when is_pickup_recharge_order = 1 then commission_actual_amount else 0 end) as   pickup_card_commission_summary,--提货卡充值提成总和
       sum(case when is_pickup_recharge_order = 0 then commission_actual_amount else 0 end) as   goods_commission_summary,--实货支付提成总和
       max(case when class_number = '分类01' then class_number_info else '' end) as              num01_pure_b_pay_name,
       max(case when class_number = '分类02' then class_number_info else '' end) as              num02_pure_b_pay_name,
       max(case when class_number = '分类03' then class_number_info else '' end) as              num03_pure_b_pay_name,
       max(case when class_number = '分类04' then class_number_info else '' end) as              num04_pure_b_pay_name,
       max(case when class_number = '分类05' then class_number_info else '' end) as              num05_pure_b_pay_name,
       max(case when class_number = '分类06' then class_number_info else '' end) as              num06_pure_b_pay_name,
       max(case when class_number = '分类07' then class_number_info else '' end) as              num07_pure_b_pay_name,
       max(case when class_number = '分类08' then class_number_info else '' end) as              num08_pure_b_pay_name,
       sum(case when class_number = '分类09' then commission_actual_amount else 0 end) as        num09_pure_b_pay_amount,
       max(case when class_number = '分类09' then class_number_info else '' end) as              num09_pure_b_pay_name,
       sum(b_pure_pay_amount_freezed_not_pickup_to_shihuo) as                                  b_pure_pay_amount_freezed_not_pickup_to_shihuo,
       sum(b_pure_pay_amount_freezed_pickup_to_shihuo) as                                      b_pure_pay_amount_freezed_pickup_to_shihuo
from (
    select service_user_id,
           is_pickup_recharge_order,
           is_split,
           category_id_first_name,
           category_id_second_name,
           commission_actual_amount,
           class_number,
           class_number_info,
           b_pure_pay_amount_freezed_not_pickup_to_shihuo,
           b_pure_pay_amount_freezed_pickup_to_shihuo
    from ads_salary_biz_frozen_pure_gmv_detail_d
    where dayid = '$v_date'
) salary_item
group by service_user_id


