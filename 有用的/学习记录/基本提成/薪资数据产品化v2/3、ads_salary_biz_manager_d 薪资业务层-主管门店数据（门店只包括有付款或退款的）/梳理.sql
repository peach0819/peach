
------------------------------------门店订单
--门店基础信息（门店的id，bd经理，省区，战区）
with shop_base as (
    select shop_id,
           shop_status,
           area_manager_id,
           area_manager_dep_name,
           bd_manager_id,
           war_zone_id ,
           war_zone_dep_name ,
           staff_id
    from dw_shop_base_d  --门店基础属性主题宽表
    where dayid ='$v_date'
    and inuse=1 and bu_id=0
    and nvl(store_type,100) not in (3,9,10,11)
),

--订单信息
--正向订单
forward_order as (
    select  order_id,
            null as salary_refund_type,
            0 as refund_actual_amount, --实际退款金额
            0 as refund_pickup_card_amount, --提货卡退款金额
            shop_id,
            category_id_first,
            category_id_first_name,
            category_id_second,
            category_id_second_name,
            brand_id,
            brand_name,
            case when is_pickup_recharge_order=1 then '1' else item_style end as item_style,
            case when ytdw.get_service_info('service_feature_id:4',service_info,'service_user_id') is not null then '是' else '否' end as is_bigbd_shop,--是否大BD门店
            business_unit,
            business_group_code,
            business_group_name,
            pay_time,
            total_pay_amount,
            pay_amount,
            pickup_category_id_first,
            pickup_category_id_first_name,
            pickup_category_id_second,
            pickup_category_id_second_name,
            pickup_brand_id,
            pickup_brand_name,
            is_pickup_order,
            is_pickup_recharge_order,
            pickup_card_amount,
            is_spec_brand,
            is_celeron
    from ads_salary_base_cur_month_order_d  --薪资基础层-本月正向下单大宽表（数仓基础订单宽表+薪资专属业务）
    where dayid='$v_date'
    and (business_unit not in ('卡券票','其他') or is_pickup_recharge_order = 1)        --剔除 业务域等 卡券票和其他
    and nvl(store_type,100) not in (3,9,10,11)        --剔除员工店，二批商，美妆店,伙伴店11
    and is_spec_order!=1  --  剔除薪资特殊订单
    and sp_id is null
),
backward_order as (
    select order_id,
           salary_refund_type,
           refund_actual_amount, --实际退款金额
           refund_pickup_card_amount, --提货卡退款金额
           shop_id,
           category_id_first,
           category_id_first_name,
           category_id_second,
           category_id_second_name,
           brand_id,
           brand_name,
           case when is_pickup_recharge_order=1 then '1' else item_style end as item_style,
           case when ytdw.get_service_info('service_feature_id:4',service_info,'service_user_id') is not null then '是' else '否' end as is_bigbd_shop,--是否大BD门店
           business_unit,
           business_group_code,
           business_group_name,
           pay_time,
           0 as total_pay_amount,
           0 as pay_amount,
           pickup_category_id_first,
           pickup_category_id_first_name,
           pickup_category_id_second,
           pickup_category_id_second_name,
           pickup_brand_id,
           pickup_brand_name,
           is_pickup_order,
           is_pickup_recharge_order,
           0 as pickup_card_amount,
           is_spec_brand,
           is_celeron
    from ads_salary_base_cur_month_refund_d  --薪资基础层-本月逆向退款大宽表（数仓基础退款宽表+薪资线下退款）
    where dayid='$v_date'
    and (business_unit not in ('卡券票','其他') or is_pickup_recharge_order = 1)        --剔除 业务域等 卡券票和其他
    and nvl(store_type,100) not in (3,9,10,11)        --剔除员工店，二批商，美妆店,伙伴店11
    and is_spec_order!=1  --  剔除薪资特殊订单
    and sp_id is null
),
order_info as (
-- 正向订单
select * from forward_order

union  all

-- 逆向订单
select * from backward_order
),

--门店订单基础信息 （一个门店月度的统计数据）
shop_order_base as (
    select shop_id,
           category_id_first,
           category_id_first_name,
           category_id_second,
           category_id_second_name,
           order_info.brand_id,
           brand_name,
           is_spec_brand,--是否特殊提点品牌
           item_style,
           is_bigbd_shop,--是否大BD门店
           business_unit,
           business_group_code,
           business_group_name,
           --B类净GMV-new 净GMV/净支付金额= GMV/支付金额(充值hi卡+实货) - 提货hi卡支付金额 - (实际退款金额 - 提货hi卡支付退款金额) - 线下退款
           nvl(sum(case when item_style=1 then total_pay_amount else 0 end),0)
           -nvl(sum(case when item_style=1 then refund_actual_amount else 0 end),0)
           -nvl(sum(case when item_style=1 then pickup_card_amount else 0 end),0)
           +nvl(sum(case when item_style=1 then refund_pickup_card_amount else 0 end),0)
           as pure_b_gmv,
           --B类净支付金额-new
           nvl(sum(case when item_style=1 then pay_amount else 0 end),0)
           -nvl(sum(case when item_style=1 then refund_actual_amount else 0 end),0)
           -nvl(sum(case when item_style=1 then pickup_card_amount else 0 end),0)
           +nvl(sum(case when item_style=1 then refund_pickup_card_amount else 0 end),0)
           as pure_b_pay_amount,
           --B类线下退款金额之和
           sum(case when item_style=1 and salary_refund_type='线下退款' then refund_actual_amount else 0 end) as pure_b_offline_refund,
           --B类线上退款金额之和
           sum(case when item_style=1 and salary_refund_type='线上退款' then refund_actual_amount else 0 end) as pure_b_refund,
           max(case when substr(pay_time,1,6)='$v_cur_month' then 1 else 0 end) as is_pay_shop,
           --新增提货卡字段
           pickup_category_id_first,
           pickup_category_id_first_name,
           pickup_category_id_second,
           pickup_category_id_second_name,
           pickup_brand_id,
           pickup_brand_name,
           is_pickup_order,
           is_pickup_recharge_order,
           --B类提货hi卡支付金额
           sum(pickup_card_amount) as pickup_card_amount,
           --B类提货hi卡退款金额 20200724 退款改造
           sum(refund_pickup_card_amount) as refund_pickup_card_amount,
           is_celeron,--是否低端/超低端品牌
           --B类GMV—退款 = GMV(实货)  - 当月实货订单实际退款金额 - 当月实货订单线下退款
           --business_unit not in ('卡券票','其他') 实货，待验证
           sum(case when item_style=1 and business_unit not in ('卡券票','其他') and substr(pay_time,1,6)='$v_cur_month' then (nvl(total_pay_amount,0)-nvl(refund_actual_amount,0)) else 0 end)  as cur_order_b_gmv,
             --B类当月退款:指所有的当月订单发生的退款之和（包括线上和线下退款）
           sum(case when item_style=1 and business_unit not in ('卡券票','其他') and substr(pay_time,1,6)='$v_cur_month' then (nvl(refund_actual_amount,0)) else 0 end) as cur_order_b_refund
    from order_info
    group by shop_id,
             category_id_first,
             category_id_first_name,
             category_id_second,
             category_id_second_name,
             order_info.brand_id,
             brand_name,
             item_style,
             is_spec_brand,
             is_bigbd_shop,
             business_unit,
             business_group_code,
             business_group_name,
             pickup_category_id_first,
             pickup_category_id_first_name,
             pickup_category_id_second,
             pickup_category_id_second_name,
             pickup_brand_id,
             pickup_brand_name,
             is_pickup_order,
             is_pickup_recharge_order,
             is_celeron
),

--门店订单信息结果集 门店信息 &&订单信息小宽表
shop_order_result as (
    select
      shop_base.shop_id,
      shop_status,
      area_manager_id,
      area_manager_dep_name,
      bd_manager_id,
      war_zone_id ,
      war_zone_dep_name ,
      staff_id ,
      category_id_first,
      category_id_first_name,
      category_id_second,
      category_id_second_name,
      brand_id,
      brand_name,
      is_spec_brand,--是否特殊提点品牌
      item_style,
      is_bigbd_shop,--是否大BD门店
      business_unit,
      business_group_code,
      business_group_name,
      nvl(pure_b_gmv,0) as pure_b_gmv,
      nvl(pure_b_pay_amount,0) as pure_b_pay_amount,
      nvl(pure_b_offline_refund,0) as pure_b_offline_refund,
      nvl(pure_b_refund,0) as pure_b_refund,
      --二级类目 2807 衣物清洁护理  8012 干纸巾
      --一级类目 10 尿不湿  12 奶粉 542 婴幼儿营养品 13 婴童辅食 4 婴童服纺  6098 婴童零食
      --20200505
      case  when is_pickup_recharge_order=0 and is_spec_brand=0 then (
              case  when (category_id_first='10' and is_celeron=1) or category_id_second ='2807' or category_id_second ='8012' then '分类01'
                    when (category_id_first ='542' or category_id_first ='13' or category_id_first='4' or category_id_first='6098' or category_id_first='2794') then '分类02'
                    when  category_id_first='12' then '分类03'
                    else '分类04' end)
            --提货卡、 非专供品（特殊提点品牌）
            when is_pickup_recharge_order=1 and  is_spec_brand=0 then (
              case  when (pickup_category_id_first='10' and is_celeron=1) or pickup_category_id_second ='2807' or pickup_category_id_second ='8012' then '分类01'
                    when (pickup_category_id_first ='542' or pickup_category_id_first ='13' or pickup_category_id_first='4' or pickup_category_id_first='6098' or pickup_category_id_first='2794') then '分类02'
                    when pickup_category_id_first='12' then '分类03'
                    else '分类04' end)
            when is_pickup_recharge_order=0 and is_spec_brand=1 then (
              case  when (category_id_first='10' and is_celeron=1) or category_id_second ='2807' or category_id_second ='8012' then '分类05'
                    when (category_id_first ='542' or category_id_first ='13' or category_id_first='4' or category_id_first='6098' or category_id_first='2794') then '分类06'
                    when  category_id_first='12' then '分类07'
                    else '分类08' end)
            --提货卡、 专供品（特殊提点品牌）
            when is_pickup_recharge_order=1 and is_spec_brand=1 then (
              case  when (pickup_category_id_first='10' and is_celeron=1) or pickup_category_id_second ='2807' or pickup_category_id_second ='8012' then '分类05'
                    when (pickup_category_id_first ='542' or pickup_category_id_first ='13' or pickup_category_id_first='4' or pickup_category_id_first='6098' or pickup_category_id_first='2794') then '分类06'
                    when pickup_category_id_first='12' then '分类07'
                    else '分类08' end)
      end as class_number,
      is_pay_shop,
      '分类01：低端，超低端尿不湿,洗衣液,纸巾（BD和大BD通用）\；分类02：营养品,辅食,服纺，婴童洗护 （BD和大BD通用）\；分类03：奶粉（BD和大BD通用）\；分类04：其他（BD和大BD通用）\;分类05：低端，超低端尿不湿,洗衣液,纸巾（大BD专供，BD不计提成）\；分类06：营养品,辅食,服纺，婴童洗护 （大BD专供，BD不计提成）\；分类07：奶粉（大BD专供，BD不计提成）\；分类08：其他（大BD专供，BD不计提成）\;' as class_number_info,
      --新增提货卡字段
      pickup_category_id_first,
      pickup_category_id_first_name,
      pickup_category_id_second,
      pickup_category_id_second_name,
      pickup_brand_id,
      pickup_brand_name,
      nvl(pickup_card_amount,0) as pickup_card_amount,
      nvl(refund_pickup_card_amount,0) as refund_pickup_card_amount,
      nvl(shop_order_base.cur_order_b_gmv,0) as cur_order_b_gmv,
      nvl(shop_order_base.cur_order_b_refund,0) as cur_order_b_refund
    from shop_base
    left join shop_order_base on shop_order_base.shop_id=shop_base.shop_id
    where (nvl(pure_b_gmv,0) != 0 or nvl(pure_b_pay_amount,0) != 0 or nvl(pure_b_offline_refund,0) !=0 or nvl(pure_b_refund,0) !=0)
),


--------------------------------------------------- bd主管统计数据
--bd主管
--bd主管来源订单的统计信息
bd_manager as (
    select
        bd_manager_id,
        concat_ws(',', collect_set(string(area_manager_dep_name)))as area_manager_dep_name,--归属大区
        count(distinct case when shop_status in (1,2,3,4,5) then shop_id else null end ) as shop_cnt,--库内门店数
        count(distinct case when is_pay_shop =1 and item_style=1 then shop_id else null end ) as b_pay_shop_cnt ,--B类下单门店数  不含服务商
        sum(pure_b_gmv) as pure_b_gmv,--B类净GMV  不含服务商
        sum(pure_b_pay_amount) as pure_b_pay_amount,--B类净支付金额  不含服务商
        sum(pure_b_offline_refund) as pure_b_offline_refund,--B类线下退款金额之和    指单独的那张线下退款的表的金额
        sum(pure_b_refund) as pure_b_refund, --B类线上退款金额之和   指线上的订单表里的退款金额,
        sum(case when class_number='分类01' then pure_b_pay_amount else 0 end) as num01_pure_b_pay_amount,
        sum(case when class_number='分类02' then pure_b_pay_amount else 0 end) as num02_pure_b_pay_amount,
        sum(case when class_number='分类03' then pure_b_pay_amount else 0 end) as num03_pure_b_pay_amount,
        sum(case when class_number='分类04' then pure_b_pay_amount else 0 end) as num04_pure_b_pay_amount,
        sum(case when class_number='分类05' then pure_b_pay_amount else 0 end) as num05_pure_b_pay_amount,
        sum(case when class_number='分类06' then pure_b_pay_amount else 0 end) as num06_pure_b_pay_amount,
        count(distinct case when shop_status in (1,2,3,4,5) and is_bigbd_shop='否' then shop_id else null end ) as shop_cnt_not_bigbd,--库内门店数 非大BD门店
        count(distinct case when is_pay_shop =1 and is_bigbd_shop='否' and item_style=1 then shop_id else null end ) as b_pay_shop_cnt_not_bigbd ,--B类下单门店数  不含服务商
        sum(case when is_bigbd_shop='否' then pure_b_gmv else 0 end) as pure_b_gmv_not_bigbd,--B类净GMV    不含服务商
        sum(case when is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as pure_b_pay_amount_not_bigbd,--B类净支付金额  不含服务商
        sum(case when is_bigbd_shop='否' then pure_b_offline_refund else 0 end) as pure_b_offline_refund_not_bigbd,--B类线下退款金额之和  指单独的那张线下退款的表的金额
        sum(case when is_bigbd_shop='否' then pure_b_refund else 0 end) as pure_b_refund_not_bigbd, --B类线上退款金额之和 指线上的订单表里的退款金额,
        sum(case when class_number='分类01' and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num01_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类02' and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num02_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类03' and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num03_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类04' and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num04_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类05' and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num05_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类06' and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num06_pure_b_pay_amount_not_bigbd,
        max(class_number_info) as class_number_info,
        concat_ws(',', collect_set(string(war_zone_dep_name)))as war_zone_dep_name,--战区
        sum(case when class_number='分类07' then pure_b_pay_amount else 0 end) as num07_pure_b_pay_amount,
        sum(case when class_number='分类08' then pure_b_pay_amount else 0 end) as num08_pure_b_pay_amount,
        sum(case when class_number='分类07' and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num07_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类08' and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num08_pure_b_pay_amount_not_bigbd
    from shop_order_result
    group by bd_manager_id
),

--bd主管 当月满500支付的门店数统计 user_id -> 门店数
--门店订单总GMV合计
bd_shop_order_sum as (
    select bd_manager_id,
           shop_id,
           sum(cur_order_b_gmv) as cur_order_b_gmv
    from shop_order_result
    group by bd_manager_id,shop_id
),
bd_manager_shop_cnt as (
    select bd_manager_id,
        --当月满500支付门店数 20200724
       count(distinct case when cur_order_b_gmv >=500 then shop_id else null end)  as cur_b_gmv_shop_cnt
     from bd_shop_order_sum
     group by bd_manager_id
),

--BD主管结果集数据  基础统计信息&&大于500门店数
bd_manager_info as (
    select
    'BD主管' as user_type_subdivide,
    bd_manager.bd_manager_id as user_id,
    area_manager_dep_name,--归属大区
    shop_cnt,--库内门店数
    b_pay_shop_cnt ,--B类下单门店数  不含服务商
    pure_b_gmv,--B类净GMV  不含服务商
    pure_b_pay_amount,--B类净支付金额  不含服务商
    pure_b_offline_refund,--B类线下退款金额之和    指单独的那张线下退款的表的金额
    pure_b_refund, --B类线上退款金额之和   指线上的订单表里的退款金额,
    num01_pure_b_pay_amount,
    num02_pure_b_pay_amount,
    num03_pure_b_pay_amount,
    num04_pure_b_pay_amount,
    num05_pure_b_pay_amount,
    num06_pure_b_pay_amount,
    shop_cnt_not_bigbd,--库内门店数 非大BD门店
    b_pay_shop_cnt_not_bigbd ,--B类下单门店数  不含服务商
    pure_b_gmv_not_bigbd,--B类净GMV    不含服务商
    pure_b_pay_amount_not_bigbd,--B类净支付金额  不含服务商
    pure_b_offline_refund_not_bigbd,--B类线下退款金额之和  指单独的那张线下退款的表的金额
    pure_b_refund_not_bigbd, --B类线上退款金额之和 指线上的订单表里的退款金额,
    num01_pure_b_pay_amount_not_bigbd,
    num02_pure_b_pay_amount_not_bigbd,
    num03_pure_b_pay_amount_not_bigbd,
    num04_pure_b_pay_amount_not_bigbd,
    num05_pure_b_pay_amount_not_bigbd,
    num06_pure_b_pay_amount_not_bigbd,
    class_number_info,
    war_zone_dep_name,--战区
    num07_pure_b_pay_amount,
    num08_pure_b_pay_amount,
    num07_pure_b_pay_amount_not_bigbd,
    num08_pure_b_pay_amount_not_bigbd,
    bd_manager_shop_cnt.cur_b_gmv_shop_cnt as cur_b_gmv_shop_cnt
    from bd_manager
    left join bd_manager_shop_cnt on bd_manager.bd_manager_id = bd_manager_shop_cnt.bd_manager_id
),

------------------------------------------  大区经理数据
--大区经理 订单统计数据
area_manager as (
    select area_manager_id,
           concat_ws(',', collect_set(string(area_manager_dep_name)))as area_manager_dep_name,--归属大区
           count(distinct case when shop_status in (1,2,3,4,5) then shop_id else null end ) as shop_cnt,--库内门店数
           count(distinct case when is_pay_shop =1 and item_style=1 then shop_id else null end ) as b_pay_shop_cnt ,--B类下单门店数  不含服务商
           sum(pure_b_gmv) as pure_b_gmv,--B类净GMV  不含服务商
           sum(pure_b_pay_amount) as pure_b_pay_amount,--B类净支付金额  不含服务商
           sum(pure_b_offline_refund) as pure_b_offline_refund,--B类线下退款金额之和    指单独的那张线下退款的表的金额
           sum(pure_b_refund) as pure_b_refund ,--B类线上退款金额之和   指线上的订单表里的退款金额,
           sum(case when class_number='分类01' then pure_b_pay_amount else 0 end) as num01_pure_b_pay_amount,
           sum(case when class_number='分类02' then pure_b_pay_amount else 0 end) as num02_pure_b_pay_amount,
           sum(case when class_number='分类03' then pure_b_pay_amount else 0 end) as num03_pure_b_pay_amount,
           sum(case when class_number='分类04' then pure_b_pay_amount else 0 end) as num04_pure_b_pay_amount,
           sum(case when class_number='分类05' then pure_b_pay_amount else 0 end) as num05_pure_b_pay_amount,
           sum(case when class_number='分类06' then pure_b_pay_amount else 0 end) as num06_pure_b_pay_amount,
           count(distinct case when shop_status in (1,2,3,4,5) and is_bigbd_shop='否' then shop_id else null end ) as shop_cnt_not_bigbd,--库内门店数
           count(distinct case when is_pay_shop =1 and is_bigbd_shop='否' and item_style=1  then shop_id else null end ) as b_pay_shop_cnt_not_bigbd ,--B类下单门店数 不含服务商
           sum(case when is_bigbd_shop='否' then pure_b_gmv else 0 end) as pure_b_gmv_not_bigbd,--B类净GMV    不含服务商
           sum(case when is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as pure_b_pay_amount_not_bigbd,--B类净支付金额  不含服务商
           sum(case when is_bigbd_shop='否' then pure_b_offline_refund else 0 end) as pure_b_offline_refund_not_bigbd,--B类线下退款金额之和  指单独的那张线下退款的表的金额
           sum(case when is_bigbd_shop='否' then pure_b_refund else 0 end) as pure_b_refund_not_bigbd, --B类线上退款金额之和 指线上的订单表里的退款金额,
           sum(case when class_number='分类01'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num01_pure_b_pay_amount_not_bigbd,
           sum(case when class_number='分类02'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num02_pure_b_pay_amount_not_bigbd,
           sum(case when class_number='分类03'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num03_pure_b_pay_amount_not_bigbd,
           sum(case when class_number='分类04'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num04_pure_b_pay_amount_not_bigbd,
           sum(case when class_number='分类05'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num05_pure_b_pay_amount_not_bigbd,
           sum(case when class_number='分类06'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num06_pure_b_pay_amount_not_bigbd,
           max(class_number_info) as class_number_info,
           concat_ws(',', collect_set(string(war_zone_dep_name)))as war_zone_dep_name,--战区
           --20200505
           sum(case when class_number='分类07' then pure_b_pay_amount else 0 end) as num07_pure_b_pay_amount,
           sum(case when class_number='分类08' then pure_b_pay_amount else 0 end) as num08_pure_b_pay_amount,
           sum(case when class_number='分类07'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num07_pure_b_pay_amount_not_bigbd,
           sum(case when class_number='分类08'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num08_pure_b_pay_amount_not_bigbd
    from shop_order_result
    group by area_manager_id
),

--当月满500支付门店数
area_shop_order_sum as (
    select area_manager_id,
           shop_id,
           sum(cur_order_b_gmv) as cur_order_b_gmv
    from shop_order_result
    group by area_manager_id,shop_id
),
area_manager_shop_cnt as (
    select area_manager_id,
            --当月满500支付门店数 20200724
           count(distinct case when cur_order_b_gmv >=500 then shop_id else null end)  as cur_b_gmv_shop_cnt
    from area_shop_order_sum
    group by area_manager_id
),

--大区经理统计数据结果集 基础统计信息&&当月满500支付门店数
area_manager_info as (
    select '大区经理' as user_type_subdivide,
           area_manager.area_manager_id as user_id,
           area_manager_dep_name,--归属大区
           shop_cnt,--库内门店数
           b_pay_shop_cnt ,--B类下单门店数  不含服务商
           pure_b_gmv,--B类净GMV  不含服务商
           pure_b_pay_amount,--B类净支付金额  不含服务商
           pure_b_offline_refund,--B类线下退款金额之和    指单独的那张线下退款的表的金额
           pure_b_refund, --B类线上退款金额之和   指线上的订单表里的退款金额,
           num01_pure_b_pay_amount,
           num02_pure_b_pay_amount,
           num03_pure_b_pay_amount,
           num04_pure_b_pay_amount,
           num05_pure_b_pay_amount,
           num06_pure_b_pay_amount,
           shop_cnt_not_bigbd,--库内门店数 非大BD门店
           b_pay_shop_cnt_not_bigbd ,--B类下单门店数  不含服务商
           pure_b_gmv_not_bigbd,--B类净GMV    不含服务商
           pure_b_pay_amount_not_bigbd,--B类净支付金额  不含服务商
           pure_b_offline_refund_not_bigbd,--B类线下退款金额之和  指单独的那张线下退款的表的金额
           pure_b_refund_not_bigbd, --B类线上退款金额之和 指线上的订单表里的退款金额,
           num01_pure_b_pay_amount_not_bigbd,
           num02_pure_b_pay_amount_not_bigbd,
           num03_pure_b_pay_amount_not_bigbd,
           num04_pure_b_pay_amount_not_bigbd,
           num05_pure_b_pay_amount_not_bigbd,
           num06_pure_b_pay_amount_not_bigbd,
           class_number_info,
           war_zone_dep_name,--战区
           num07_pure_b_pay_amount,
           num08_pure_b_pay_amount,
           num07_pure_b_pay_amount_not_bigbd,
           num08_pure_b_pay_amount_not_bigbd,
           area_manager_shop_cnt.cur_b_gmv_shop_cnt as cur_b_gmv_shop_cnt
    from area_manager
    left join area_manager_shop_cnt on area_manager.area_manager_id=area_manager_shop_cnt.area_manager_id
),


---------------------------------------------战区经理数据
--战区经理基础统计信息
war_zone as (
    select
        war_zone_id,
        concat_ws(',', collect_set(string(area_manager_dep_name)))as area_manager_dep_name,--归属大区
        count(distinct case when shop_status in (1,2,3,4,5) then shop_id else null end ) as shop_cnt,--库内门店数
        count(distinct case when is_pay_shop =1 and item_style=1 then shop_id else null end ) as b_pay_shop_cnt ,--B类下单门店数  不含服务商
        sum(pure_b_gmv) as pure_b_gmv,--B类净GMV  不含服务商
        sum(pure_b_pay_amount) as pure_b_pay_amount,--B类净支付金额  不含服务商
        sum(pure_b_offline_refund) as pure_b_offline_refund,--B类线下退款金额之和    指单独的那张线下退款的表的金额
        sum(pure_b_refund) as pure_b_refund ,--B类线上退款金额之和   指线上的订单表里的退款金额,
        sum(case when class_number='分类01' then pure_b_pay_amount else 0 end) as num01_pure_b_pay_amount,
        sum(case when class_number='分类02' then pure_b_pay_amount else 0 end) as num02_pure_b_pay_amount,
        sum(case when class_number='分类03' then pure_b_pay_amount else 0 end) as num03_pure_b_pay_amount,
        sum(case when class_number='分类04' then pure_b_pay_amount else 0 end) as num04_pure_b_pay_amount,
        sum(case when class_number='分类05' then pure_b_pay_amount else 0 end) as num05_pure_b_pay_amount,
        sum(case when class_number='分类06' then pure_b_pay_amount else 0 end) as num06_pure_b_pay_amount,
        count(distinct case when shop_status in (1,2,3,4,5) and is_bigbd_shop='否' then shop_id else null end ) as shop_cnt_not_bigbd,--库内门店数
        count(distinct case when is_pay_shop =1 and is_bigbd_shop='否' and item_style=1  then shop_id else null end ) as b_pay_shop_cnt_not_bigbd ,--B类下单门店数 不含服务商
        sum(case when is_bigbd_shop='否' then pure_b_gmv else 0 end) as pure_b_gmv_not_bigbd,--B类净GMV    不含服务商
        sum(case when is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as pure_b_pay_amount_not_bigbd,--B类净支付金额  不含服务商
        sum(case when is_bigbd_shop='否' then pure_b_offline_refund else 0 end) as pure_b_offline_refund_not_bigbd,--B类线下退款金额之和  指单独的那张线下退款的表的金额
        sum(case when is_bigbd_shop='否' then pure_b_refund else 0 end) as pure_b_refund_not_bigbd, --B类线上退款金额之和 指线上的订单表里的退款金额,
        sum(case when class_number='分类01'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num01_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类02'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num02_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类03'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num03_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类04'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num04_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类05'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num05_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类06'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num06_pure_b_pay_amount_not_bigbd,
        max(class_number_info) as class_number_info,
        concat_ws(',', collect_set(string(war_zone_dep_name)))as war_zone_dep_name,--战区
      --20200505
        sum(case when class_number='分类07' then pure_b_pay_amount else 0 end) as num07_pure_b_pay_amount,
        sum(case when class_number='分类08' then pure_b_pay_amount else 0 end) as num08_pure_b_pay_amount,
        sum(case when class_number='分类07'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num07_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类08'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num08_pure_b_pay_amount_not_bigbd
      from shop_order_result
      group by war_zone_id
),

--战区当月满500支付的统计信息
war_shop_order_sum as (
    select
      war_zone_id,
      shop_id,
      sum(cur_order_b_gmv) as cur_order_b_gmv
    from shop_order_result
    group by war_zone_id,shop_id
),
war_zone_shop_cnt as (
    select war_zone_id,
            --当月满500支付门店数 20200724
           count(distinct case when cur_order_b_gmv >=500 then shop_id else null end)  as cur_b_gmv_shop_cnt
    from tmp
    group by war_zone_id
),


war_zone_manager_info as (
    select
      '战区经理' as user_type_subdivide,
      war_zone.war_zone_id as user_id,
      area_manager_dep_name,--归属大区
      shop_cnt,--库内门店数
      b_pay_shop_cnt ,--B类下单门店数  不含服务商
      pure_b_gmv,--B类净GMV  不含服务商
      pure_b_pay_amount,--B类净支付金额  不含服务商
      pure_b_offline_refund,--B类线下退款金额之和    指单独的那张线下退款的表的金额
      pure_b_refund, --B类线上退款金额之和   指线上的订单表里的退款金额,
      num01_pure_b_pay_amount,
      num02_pure_b_pay_amount,
      num03_pure_b_pay_amount,
      num04_pure_b_pay_amount,
      num05_pure_b_pay_amount,
      num06_pure_b_pay_amount,
      shop_cnt_not_bigbd,--库内门店数 非大BD门店
      b_pay_shop_cnt_not_bigbd ,--B类下单门店数  不含服务商
      pure_b_gmv_not_bigbd,--B类净GMV    不含服务商
      pure_b_pay_amount_not_bigbd,--B类净支付金额  不含服务商
      pure_b_offline_refund_not_bigbd,--B类线下退款金额之和  指单独的那张线下退款的表的金额
      pure_b_refund_not_bigbd, --B类线上退款金额之和 指线上的订单表里的退款金额,
      num01_pure_b_pay_amount_not_bigbd,
      num02_pure_b_pay_amount_not_bigbd,
      num03_pure_b_pay_amount_not_bigbd,
      num04_pure_b_pay_amount_not_bigbd,
      num05_pure_b_pay_amount_not_bigbd,
      num06_pure_b_pay_amount_not_bigbd,
      class_number_info,
      war_zone_dep_name,--战区
      num07_pure_b_pay_amount,
      num08_pure_b_pay_amount,
      num07_pure_b_pay_amount_not_bigbd,
      num08_pure_b_pay_amount_not_bigbd,
      war_zone_shop_cnt.cur_b_gmv_shop_cnt as cur_b_gmv_shop_cnt
    from war_zone
    left join war_zone_shop_cnt on war_zone.war_zone_id=war_zone_shop_cnt.war_zone_id
),

------------------------------------------- 参谋长数据
--参谋长基础统计信息
staff as (
    select
        staff_id,
        concat_ws(',', collect_set(string(area_manager_dep_name)))as area_manager_dep_name,--归属大区
        count(distinct case when shop_status in (1,2,3,4,5) then shop_id else null end ) as shop_cnt,--库内门店数
        count(distinct case when is_pay_shop =1 and item_style=1 then shop_id else null end ) as b_pay_shop_cnt ,--B类下单门店数  不含服务商
        sum(pure_b_gmv) as pure_b_gmv,--B类净GMV  不含服务商
        sum(pure_b_pay_amount) as pure_b_pay_amount,--B类净支付金额  不含服务商
        sum(pure_b_offline_refund) as pure_b_offline_refund,--B类线下退款金额之和    指单独的那张线下退款的表的金额
        sum(pure_b_refund) as pure_b_refund ,--B类线上退款金额之和   指线上的订单表里的退款金额,
        sum(case when class_number='分类01' then pure_b_pay_amount else 0 end) as num01_pure_b_pay_amount,
        sum(case when class_number='分类02' then pure_b_pay_amount else 0 end) as num02_pure_b_pay_amount,
        sum(case when class_number='分类03' then pure_b_pay_amount else 0 end) as num03_pure_b_pay_amount,
        sum(case when class_number='分类04' then pure_b_pay_amount else 0 end) as num04_pure_b_pay_amount,
        sum(case when class_number='分类05' then pure_b_pay_amount else 0 end) as num05_pure_b_pay_amount,
        sum(case when class_number='分类06' then pure_b_pay_amount else 0 end) as num06_pure_b_pay_amount,
        count(distinct case when shop_status in (1,2,3,4,5) and is_bigbd_shop='否' then shop_id else null end ) as shop_cnt_not_bigbd,--库内门店数
        count(distinct case when is_pay_shop =1 and is_bigbd_shop='否' and item_style=1  then shop_id else null end ) as b_pay_shop_cnt_not_bigbd ,--B类下单门店数 不含服务商
        sum(case when is_bigbd_shop='否' then pure_b_gmv else 0 end) as pure_b_gmv_not_bigbd,--B类净GMV    不含服务商
        sum(case when is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as pure_b_pay_amount_not_bigbd,--B类净支付金额  不含服务商
        sum(case when is_bigbd_shop='否' then pure_b_offline_refund else 0 end) as pure_b_offline_refund_not_bigbd,--B类线下退款金额之和  指单独的那张线下退款的表的金额
        sum(case when is_bigbd_shop='否' then pure_b_refund else 0 end) as pure_b_refund_not_bigbd, --B类线上退款金额之和 指线上的订单表里的退款金额,
        sum(case when class_number='分类01'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num01_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类02'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num02_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类03'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num03_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类04'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num04_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类05'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num05_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类06'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num06_pure_b_pay_amount_not_bigbd,
        max(class_number_info) as class_number_info,
        concat_ws(',', collect_set(string(war_zone_dep_name)))as war_zone_dep_name,--战区
        --20200505
        sum(case when class_number='分类07' then pure_b_pay_amount else 0 end) as num07_pure_b_pay_amount,
        sum(case when class_number='分类08' then pure_b_pay_amount else 0 end) as num08_pure_b_pay_amount,
        sum(case when class_number='分类07'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num07_pure_b_pay_amount_not_bigbd,
        sum(case when class_number='分类08'  and is_bigbd_shop='否' then pure_b_pay_amount else 0 end) as num08_pure_b_pay_amount_not_bigbd
      from shop_order_result
      group by staff_id
),

--参谋长大于500支付订单数
staff_shop_order_sum as (
    select
      staff_id,
      shop_id,
      sum(cur_order_b_gmv) as cur_order_b_gmv
    from shop_order_result
    group by staff_id,shop_id
),
staff_shop_cnt as (
    select
      staff_id,
       --当月满500支付门店数 20200724
      count(distinct case when cur_order_b_gmv >=500 then shop_id else null end)  as cur_b_gmv_shop_cnt
    from tmp
    group by staff_id
),

staff_info as (
    select
      '参谋长' as user_type_subdivide,
      staff.staff_id as user_id,
      area_manager_dep_name,--归属大区
      shop_cnt,--库内门店数
      b_pay_shop_cnt ,--B类下单门店数  不含服务商
      pure_b_gmv,--B类净GMV  不含服务商
      pure_b_pay_amount,--B类净支付金额  不含服务商
      pure_b_offline_refund,--B类线下退款金额之和    指单独的那张线下退款的表的金额
      pure_b_refund, --B类线上退款金额之和   指线上的订单表里的退款金额,
      num01_pure_b_pay_amount,
      num02_pure_b_pay_amount,
      num03_pure_b_pay_amount,
      num04_pure_b_pay_amount,
      num05_pure_b_pay_amount,
      num06_pure_b_pay_amount,
      shop_cnt_not_bigbd,--库内门店数 非大BD门店
      b_pay_shop_cnt_not_bigbd ,--B类下单门店数  不含服务商
      pure_b_gmv_not_bigbd,--B类净GMV    不含服务商
      pure_b_pay_amount_not_bigbd,--B类净支付金额  不含服务商
      pure_b_offline_refund_not_bigbd,--B类线下退款金额之和  指单独的那张线下退款的表的金额
      pure_b_refund_not_bigbd, --B类线上退款金额之和 指线上的订单表里的退款金额,
      num01_pure_b_pay_amount_not_bigbd,
      num02_pure_b_pay_amount_not_bigbd,
      num03_pure_b_pay_amount_not_bigbd,
      num04_pure_b_pay_amount_not_bigbd,
      num05_pure_b_pay_amount_not_bigbd,
      num06_pure_b_pay_amount_not_bigbd,
      class_number_info,
      war_zone_dep_name,--战区
      num07_pure_b_pay_amount,
      num08_pure_b_pay_amount,
      num07_pure_b_pay_amount_not_bigbd,
      num08_pure_b_pay_amount_not_bigbd,
      staff_shop_cnt.cur_b_gmv_shop_cnt as cur_b_gmv_shop_cnt
    from staff
    left join staff_shop_cnt on staff.staff_id=staff_shop_cnt.staff_id
)


insert overwrite table ads_salary_biz_manager_d partition (dayid='$v_date')
--bd主管数据
select * from bd_manager_info

union all

--大区经理数据
select * from area_manager_info

union all

--战区经理数据
select * from war_zone_manager_info

union all

--参谋长数据
select * from staff_info