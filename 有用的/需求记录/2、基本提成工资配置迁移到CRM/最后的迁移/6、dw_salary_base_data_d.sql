
use ytdw;
--num02_pure_b_pay_name后是无用字段
create table if not exists dw_salary_base_data_d(
  service_user_id string COMMENT '服务人员id',
  service_user_name string COMMENT '服务人员名称',
  service_department_id string COMMENT '服务人员部门id',
  service_department_name string COMMENT '服务人员部门名称',
  shop_id string COMMENT '门店id',
  shop_name string COMMENT '门店名称',
  shop_pro_name string COMMENT '门店省',
  shop_city_name string COMMENT '门店市',
  shop_area_name string COMMENT '门店区',
  is_leave string COMMENT '是否离职',
  service_feature_name string COMMENT '服务人员职能名称',
  service_feature_names string COMMENT '服务人员职能名称集合',
  item_style_name string COMMENT 'AB类型',
  business_unit string COMMENT '业务域',
  category_id_first_name string COMMENT '一级类目名称',
  category_id_second_name string COMMENT '二级类目名称',
  brand_name string COMMENT '品牌名称',
  gmv decimal(11,2) COMMENT '库内当月GMV',
  pay_amount decimal(11,2) COMMENT '库内当月支付金额',
  refund_actual_amount decimal(11,2) COMMENT '库内订单实际退款金额',
  refund_actual_amount_offline decimal(11,2) COMMENT '库内订单线下退款',
  pure_gmv decimal(11,2) COMMENT '库内净GMV',
  pure_pay_amount decimal(11,2) COMMENT '库内净支付金额',
  gmv_freezed decimal(11,2) COMMENT '冻结当月GMV',
  pay_amount_freezed decimal(18,2) COMMENT '冻结当月支付金额',
  pay_amount_freezed_not_hi_bill decimal(11,2) COMMENT '冻结当月非账期订单支付金额',
  pay_amount_freezed_hi_bill decimal(11,2) COMMENT '冻结当月账期支付金额',
  refund_actual_amount_freezed decimal(18,2) COMMENT '冻结当月订单实际退款金额',
  refund_actual_amount_offline_freezed decimal(11,2) COMMENT '冻结当月线下退款金额',
  last_month_pay_amount_freezed decimal(11,2) COMMENT '冻结上月账期支付金额',
  pre_last_month_pay_amount_freezed decimal(11,2) COMMENT '冻结上上月账期支付金额  ',
  pure_pay_amount_freezed decimal(11,2) COMMENT '冻结净支付金额',
  pure_pay_amount_hi_bill_freezed decimal(11,2) COMMENT '冻结净支付金额(包含账期)',
  a_pure_gmv decimal(11,2) COMMENT '库内A类净GMV',
  b_pure_gmv decimal(11,2) COMMENT '库内B类净GMV',
  big_b_pure_gmv decimal(11,2) COMMENT '库内大B净GMV',
  pure_gmv_hi_bill_freezed decimal(11,2) COMMENT '冻结全量净GMV(账期)',
  a_pure_pay_amount_hi_bill_freezed decimal(11,2) COMMENT '冻结A类净支付金额(账期)',
  b_pure_pay_amount_hi_bill_freezed decimal(11,2) COMMENT '冻结B类净支付金额(账期)',
  big_b_pure_pay_amount_hi_bill_freezed decimal(11,2) COMMENT '冻结大B净支付金额(账期)',
  exclusive_b_pure_pay_amount_hi_bill_freezed decimal(11,2) COMMENT '冻结专属B净支付金额(账期)',
  pure_gmv_freezed decimal(11,2) COMMENT '冻结全量净GMV',
  a_pure_gmv_freezed decimal(11,2) COMMENT '冻结A类净GMV',
  b_pure_gmv_freezed decimal(11,2) COMMENT '冻结B类净GMV',
  big_b_pure_gmv_freezed decimal(11,2) COMMENT '冻结大B净GMV',
  exclusive_b_pure_gmv_freezed decimal(11,2) COMMENT '冻结专属B净GMV',
  a_pure_pay_amount_freezed decimal(11,2) COMMENT '冻结A类净支付金额',
  b_pure_pay_amount_freezed decimal(11,2) COMMENT '冻结B类净支付金额',
  big_b_pure_pay_amount_freezed decimal(11,2) COMMENT '冻结大B净支付金额',
  exclusive_b_pure_pay_amount_freezed decimal(11,2) COMMENT '冻结专属B净支付金额',
  is_split string COMMENT '销售是否拆分',
  is_coefficient string COMMENT '是否有系数',
  coefficient_logical string COMMENT '系数逻辑',
  commission_logical string COMMENT '提成逻辑',
  coefficient_actual_amount decimal(11,2) COMMENT '系数实际值',
  commission_actual_amount decimal(11,2) COMMENT '提成实际值',
  reason string COMMENT '无法求值原因',
  update_time string COMMENT '更新时间',
  category_id_first bigint COMMENT '一级类目ID',
  category_id_second bigint COMMENT '二级类目ID',
  class_number string COMMENT '提成分类序号',
  class_number_info string COMMENT '分类信息',
  pickup_category_id_first bigint COMMENT '提货hi卡一级类目id',
  pickup_category_id_first_name string COMMENT '提货hi卡一级类目名',
  pickup_category_id_second bigint COMMENT '提货hi卡二级类目id',
  pickup_category_id_second_name string COMMENT '提货hi卡二级类目名',
  pickup_brand_id bigint COMMENT '提货hi卡品牌',
  pickup_brand_name string COMMENT '提货hi卡品牌名',
  is_pickup_order_name string COMMENT '是否通过提货hi卡支付',
  is_pickup_recharge_order_name string COMMENT '是否为充值提货hi卡订单',
  pickup_card_amount decimal(18,2) COMMENT '库内当月提货hi卡支付金额',
  refund_pickup_card_amount decimal(18,2) COMMENT '库内当月提货hi卡退款金额',
  pickup_card_amount_freezed decimal(18,2) COMMENT '冻结当月提货hi卡支付金额',
  refund_pickup_card_amount_freezed  decimal(18,2) COMMENT '冻结提货hi卡退款金额',
  num01_pure_b_pay_name string COMMENT '分类01提成名称',
  num02_pure_b_pay_name string COMMENT '分类02提成名称',
  num03_pure_b_pay_name string COMMENT '分类03提成名称',
  num04_pure_b_pay_name string COMMENT '分类04提成名称',
  num05_pure_b_pay_name string COMMENT '分类05提成名称',
  num06_pure_b_pay_name string COMMENT '分类06提成名称',
  num07_pure_b_pay_name string COMMENT '分类07提成名称',
  num08_pure_b_pay_name string COMMENT '分类08提成名称',
  category_id_third bigint COMMENT '三级类目ID',
  category_id_third_name string COMMENT '三级类目名称',
  pickup_category_id_third bigint COMMENT '提货hi卡三级类目id',
  pickup_category_id_third_name string COMMENT '提货hi卡三级类目名称',
  brand_id bigint COMMENT '品牌id'
)
comment '销售薪资基础明细数据(包含提货卡)'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc
;

set hive.execution.engine=mr;
set mapred.max.split.size=512000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;
set hive.exec.reducers.bytes.per.reducer=512000000;
set hive.map.aggr=true;

with order_base as (
        select dw_order_d.*
        from dw_order_d
        left join (
           select shop_id as douyin_shop_id, id as douyin_shop_mapping_id
           from dwd_shop_data_cluster_mapping_d
           where dayid = '$v_date'
           and inuse = 1
           and cluster_id in (1750) --167是长尾BD. 1750是对外合作门店
        ) douyin_shop_mapping ON dw_order_d.shop_id = douyin_shop_mapping.douyin_shop_id
        where dayid='$v_date'
        and substr(pay_time,1,8)<='$v_date'
        and bu_id=0
        --剔除服务商
        and sp_id is null
        --剔除 业务域等 卡券票和其他
        and (business_unit not in ('卡券票','其他') or is_pickup_recharge_order = 1)
                --20200504
        --剔除员工店，二批商,美妆店,伙伴店11
        and nvl(store_type,100) not in (3,9,10,11)
        and sale_dc_id=-1
        -- 剔除抖音直播店
        and douyin_shop_mapping.douyin_shop_mapping_id is null
),
order1 as (
      select
          order_id,
          trade_no,
          brand_id,
          bd_service_info,
          shop_id,
          shop_name,
          shop_pro_name,
          shop_city_name,
          shop_area_name,
          pay_time,
          service_info,
          service_info_freezed,
          item_style,
          item_sub_style,
          business_unit,
          category_id_first, --新增类目id
          category_id_second,
          category_id_first_name,
          category_id_second_name,
          category_id_third,
          category_id_third_name,
          brand_name,
          total_pay_amount,
          pay_amount,
          pickup_card_amount,
          pickup_category_id_first,
          pickup_category_id_first_name,
          pickup_category_id_second,
          pickup_category_id_second_name,
          pickup_category_id_third,
          pickup_category_id_third_name,
          pickup_brand_id,
          pickup_brand_name,
          is_pickup_order,
          is_pickup_recharge_order
        from order_base
        lateral view explode(split(regexp_replace(ytdw.get_service_info('service_type:销售',service_info),'\},','\}\;'),'\;')) tmp as bd_service_info
),
order2 as (
      select
          order_id,
          trade_no,
          brand_id,
          bd_service_info,
          shop_id,
          shop_name,
          shop_pro_name,
          shop_city_name,
          shop_area_name,
          pay_time,
          service_info,
          service_info_freezed,
          item_style,
          item_sub_style,
          business_unit,
          category_id_first, --新增类目id
          category_id_second,
          category_id_first_name,
          category_id_second_name,
          category_id_third,
          category_id_third_name,
          brand_name,
          total_pay_amount,
          pay_amount,
          pickup_card_amount,
          pickup_category_id_first,
          pickup_category_id_first_name,
          pickup_category_id_second,
          pickup_category_id_second_name,
          pickup_category_id_third,
          pickup_category_id_third_name,
          pickup_brand_id,
          pickup_brand_name,
          is_pickup_order,
          is_pickup_recharge_order
        from order_base
        lateral view explode(split(regexp_replace(ytdw.get_service_info('service_type:销售',service_info_freezed),'\},','\}\;'),'\;')) tmp as bd_service_info
)

insert overwrite table ytdw.dw_salary_base_data_d partition(dayid='$v_date')
select service_user_id,
  service_user_name,
  service_department_id,
  service_department_name,
  shop_id,
  shop_name,
  shop_pro_name,
  shop_city_name,
  shop_area_name,
  is_leave,
  service_feature_name,
  service_feature_names,
  item_style_name,
  business_unit,
  category_id_first_name,
  category_id_second_name,
  brand_name,
  gmv,
  pay_amount,
  refund_actual_amount,
  refund_actual_amount_offline,
  pure_gmv,
  pure_pay_amount,
  gmv_freezed,
  pay_amount_freezed,
  pay_amount_freezed_not_hi_bill,
  pay_amount_freezed_hi_bill,
  refund_actual_amount_freezed,
  refund_actual_amount_offline_freezed,
  last_month_pay_amount_freezed,
  pre_last_month_pay_amount_freezed,
  pure_pay_amount_freezed,
  pure_pay_amount_hi_bill_freezed,
  a_pure_gmv,
  b_pure_gmv,
  big_b_pure_gmv,
  pure_gmv_hi_bill_freezed,
  a_pure_pay_amount_hi_bill_freezed,
  b_pure_pay_amount_hi_bill_freezed,
  big_b_pure_pay_amount_hi_bill_freezed,
  exclusive_b_pure_pay_amount_hi_bill_freezed,
  pure_gmv_freezed,
  a_pure_gmv_freezed,
  b_pure_gmv_freezed,
  big_b_pure_gmv_freezed,
  exclusive_b_pure_gmv_freezed,
  a_pure_pay_amount_freezed,
  b_pure_pay_amount_freezed,
  big_b_pure_pay_amount_freezed,
  exclusive_b_pure_pay_amount_freezed,
  is_split,
  is_coefficient,
  coefficient_logical,
  commission_logical,
  coefficient_actual_amount,
  commission_actual_amount,
  reason,
  update_time,
  category_id_first,
  category_id_second,
  class_number,
  class_number_info,
  --新增提货卡字段
  pickup_category_id_first,
  pickup_category_id_first_name,
  pickup_category_id_second,
  pickup_category_id_second_name,
  pickup_brand_id,
  pickup_brand_name,
  is_pickup_order_name,
  is_pickup_recharge_order_name,
  pickup_card_amount,
  refund_pickup_card_amount,
  pickup_card_amount_freezed,
  refund_pickup_card_amount_freezed,
  ( case  when  class_number='分类01' and (is_split='大BD' or is_split='BD') then '低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（通用品）（元）'
          when  class_number='分类02' and (is_split='大BD' or is_split='BD') then '营养品，用品玩具，服纺，洗护（通用品）（元）'
          when  class_number='分类03' and (is_split='大BD' or is_split='BD') then '奶粉及面包/蛋糕(元)（通用品）'
          when  class_number='分类04' and (is_split='大BD' or is_split='BD') then '中端和高端尿不湿，辅食，其他品类（通用品）'
          when  class_number='分类05' and (is_split='大BD' or is_split='BD') then '低端和超低端尿不湿，洗衣液，干湿纸巾（大BD专供品）'
          when  class_number='分类06' and (is_split='大BD' or is_split='BD') then '营养品，用品玩具，服纺，洗护 （大BD专供品）'
          when  class_number='分类07' and (is_split='大BD' or is_split='BD') then '奶粉及面包/蛋糕(元)（大BD专供品）'
          when  class_number='分类08' and (is_split='大BD' or is_split='BD') then '中端和高端尿不湿，辅食，其他品类（大BD专供品）'
          when  class_number='分类09' and (is_split='大BD' or is_split='BD') then '纽瑞优系列（元），佑伉力'
    else '' end)  as num01_pure_b_pay_name,
  '' as num02_pure_b_pay_name,
  '' as num03_pure_b_pay_name,
  '' as num04_pure_b_pay_name,
  '' as num05_pure_b_pay_name,
  '' as num06_pure_b_pay_name,
  '' as num07_pure_b_pay_name,
  '' as num08_pure_b_pay_name,
  category_id_third,
  category_id_third_name,
  pickup_category_id_third,
  pickup_category_id_third_name,
  brand_id
from (
  select
    service_user_id,
    service_user_name,
    service_department_id,
    service_department_name,
    shop_id,
    shop_name,
    shop_pro_name,
    shop_city_name,
    shop_area_name,
    is_leave,
    service_feature_name,
    service_feature_names,
    item_style_name,
    business_unit,
    category_id_first_name,
    category_id_second_name,
    category_id_third_name,
    salary_base.brand_id,
    salary_base.brand_name,
    gmv,
    pay_amount,
    refund_actual_amount,
    refund_actual_amount_offline,
    pure_gmv,
    pure_pay_amount,
    gmv_freezed,
    pay_amount_freezed,
    pay_amount_freezed_not_hi_bill,
    pay_amount_freezed_hi_bill,
    refund_actual_amount_freezed,
    refund_actual_amount_offline_freezed,
    last_month_pay_amount_freezed,
    pre_last_month_pay_amount_freezed,
    pure_pay_amount_freezed,
    pure_pay_amount_hi_bill_freezed,
    a_pure_gmv,
    b_pure_gmv,
    big_b_pure_gmv,
    pure_gmv_hi_bill_freezed,
    a_pure_pay_amount_hi_bill_freezed,
    b_pure_pay_amount_hi_bill_freezed,
    big_b_pure_pay_amount_hi_bill_freezed,
    exclusive_b_pure_pay_amount_hi_bill_freezed,
    pure_gmv_freezed,
    a_pure_gmv_freezed,
    b_pure_gmv_freezed,
    big_b_pure_gmv_freezed,
    exclusive_b_pure_gmv_freezed,
    a_pure_pay_amount_freezed,
    b_pure_pay_amount_freezed,
    big_b_pure_pay_amount_freezed,
    exclusive_b_pure_pay_amount_freezed,
    is_split,
    is_coefficient,
    coefficient_logical,
    commission_logical,
    coefficient_actual_amount,
    commission_actual_amount,
    reason,
    update_time,
    category_id_first,
    category_id_second,
    category_id_third,
    --一级类目 10 尿不湿 12 奶粉  542 婴幼儿营养品 13 婴童辅食 4 婴童服纺  6098 婴童零食 2794 婴童洗护
    --二级类目 2807,2721 衣物清洁护理  8012 干纸巾
    --spec_brand.brand_name is null 非专供品（特殊提点品牌）
    --is_pickup_recharge_order=0 非提货卡
    --is_pickup_recharge_order=1 提货卡
    --品牌标签为低端，超低端 celeron.name is not null

    --大BD/BD、非提货卡、非专供品（特殊提点品牌）
    case  when  (is_split='大BD' or is_split='BD') and is_pickup_recharge_order=0 and spec_brand.brand_name is null then (
          case  when  (category_id_first=10 and celeron.name is not null)
                      or category_id_first in (7999)
                      or category_id_second in (2807,2721,2712,6820)
                      or salary_base.brand_id = 13818 then '分类01'
                when  (category_id_first=542 and salary_base.brand_id not in (13818,2068,7324,10726,9566,7888))
                      or (category_id_first in (4,2794,2627,8,2681,11,2560,2750,5,11543,11544,11545,11546) and category_id_second not in (6820,2807)) then '分类02'
                when  category_id_first=12 or category_id_third=11191 then '分类03'
                when  salary_base.brand_id in (2068,7324,10726,9566,7888) then '分类09'
                else  '分类04' end)
    --大BD/BD、提货卡、 非专供品（特殊提点品牌）
          when  (is_split='大BD' or is_split='BD') and is_pickup_recharge_order=1 and pickup_spec_brand.brand_name is null then (
          case  when  (pickup_category_id_first=10 and pickup_celeron.name is not null)
                      or pickup_category_id_first in (7999)
                      or pickup_category_id_second in (2807,2721,2712,6820)
                      or pickup_brand_id = 13818 then '分类01' --20200915 去掉另外两个分类
                when  (pickup_category_id_first=542 and pickup_brand_id not in (13818,2068,7324,10726,9566,7888))--增加佑伉力 7888
                      or (pickup_category_id_first in (4,2794,2627,8,2681,11,2560,2750,5,11543,11544,11545,11546) and pickup_category_id_second not in (6820,2807)) then '分类02'
                when  pickup_category_id_first=12 or pickup_category_id_third=11191 then '分类03'
                when  pickup_brand_id in (2068,7324,10726,9566,7888) then '分类09'--增加佑伉力 7888
                else  '分类04' end)
    --大BD/BD、非提货卡、 专供品（特殊提点品牌）
          when  (is_split='大BD') and is_pickup_recharge_order=0 and spec_brand.brand_name is not null then (
          case  when  (category_id_first=10 and celeron.name is not null)
                      or category_id_first in (7999)
                      or category_id_second in (2807,2721,2712,6820) then '分类05'
                when  (category_id_first=542 and salary_base.brand_id not in (13818,2068,7324,10726,9566,7888))
                      or (category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and category_id_second not in (6820,2807)) then '分类06'
                when  category_id_first=12 or category_id_third=11191 then '分类07'
                else  '分类08' end)
    --大BD/BD、提货卡、 专供品（特殊提点品牌）
          when  (is_split='大BD') and is_pickup_recharge_order=1 and pickup_spec_brand.brand_name is not null then (
          case  when  (pickup_category_id_first=10 and pickup_celeron.name is not null)
                      or pickup_category_id_first in (7999)
                      or pickup_category_id_second in (2807,2721,2712,6820) then '分类05'--20200915 增加2721
                when  (pickup_category_id_first=542 and pickup_brand_id not in (13818,2068,7324,10726,9566,7888))
                      or (pickup_category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and pickup_category_id_second not in (6820,2807)) then '分类06'
                when  pickup_category_id_first=12 or pickup_category_id_third=11191 then '分类07'
                else  '分类08' end)
          end as class_number,
    case
      when (is_split='大BD') then  '分类01：低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（通用品）（元）\；分类02：营养品，用品玩具，服纺，洗护（通用品）\；分类03奶粉及面包/蛋糕(元)（通用品）\；分类04：中端和高端尿不湿，辅食，其他品类（通用品）\；分类05：低端和超低端尿不湿，洗衣液，干湿纸巾（大BD专供品）\；分类06：营养品，用品玩具，服纺，洗护 （大BD专供品）\；分类07：奶粉及面包/蛋糕(元)（大BD专供品）\；分类08：中端和高端尿不湿，辅食，其他品类（大BD专供品）\；分类09：纽瑞优系列(元），佑伉力'
      when (is_split='BD') then '分类01：低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（通用品）（元）\；分类02：营养品，用品玩具，服纺，洗护（通用品）\；分类03奶粉及面包/蛋糕(元)（通用品）\；分类04：中端和高端尿不湿，辅食，其他品类（通用品）\；分类09：纽瑞优系列(元），佑伉力'
    else '' end as class_number_info,
    --新增提货卡字段
    pickup_category_id_first,
    pickup_category_id_first_name,
    pickup_category_id_second,
    pickup_category_id_second_name,
    pickup_category_id_third,
    pickup_category_id_third_name,
    pickup_brand_id,
    pickup_brand_name,
    case when is_pickup_order=1 then '是' else '否' end as is_pickup_order_name,
    case when is_pickup_recharge_order=1 then '是' else '否' end as is_pickup_recharge_order_name,
    pickup_card_amount,
    refund_pickup_card_amount,
    pickup_card_amount_freezed,
    refund_pickup_card_amount_freezed
  from
(
select
  service_user_id,
  service_user_name,
  service_department_id,
  service_department_name,
  shop_id,
  shop_name,
  shop_pro_name,
  shop_city_name,
  shop_area_name,
  is_leave,
  service_feature_name,
  service_feature_names,
  item_style_name,
  business_unit,
  category_id_first, --新增类目id
  category_id_second,
  category_id_third,
  category_id_first_name,
  category_id_second_name,
  category_id_third_name,
  brand_id,
  brand_name,
  sum(gmv) as gmv,
  sum(pay_amount) pay_amount,
  sum(refund_actual_amount) refund_actual_amount,
  sum(refund_actual_amount_offline) refund_actual_amount_offline,
  sum(pure_gmv) pure_gmv,
  sum(pure_pay_amount) pure_pay_amount,
  sum(gmv_freezed) gmv_freezed,
  sum(pay_amount_freezed) pay_amount_freezed,
  sum(pay_amount_freezed_not_hi_bill) pay_amount_freezed_not_hi_bill,
  sum(pay_amount_freezed_hi_bill) pay_amount_freezed_hi_bill,
  sum(refund_actual_amount_freezed) refund_actual_amount_freezed,
  sum(refund_actual_amount_offline_freezed) refund_actual_amount_offline_freezed,
  sum(last_month_pay_amount_freezed) last_month_pay_amount_freezed,
  sum(pre_last_month_pay_amount_freezed) pre_last_month_pay_amount_freezed,
  sum(pure_pay_amount_freezed) pure_pay_amount_freezed,
  sum(pure_pay_amount_hi_bill_freezed) pure_pay_amount_hi_bill_freezed,
  sum(a_pure_gmv) a_pure_gmv,
  sum(b_pure_gmv) b_pure_gmv,
  sum(big_b_pure_gmv) big_b_pure_gmv,
  sum(pure_gmv_hi_bill_freezed) pure_gmv_hi_bill_freezed,
  sum(a_pure_pay_amount_hi_bill_freezed) a_pure_pay_amount_hi_bill_freezed,
  sum(b_pure_pay_amount_hi_bill_freezed) b_pure_pay_amount_hi_bill_freezed,
  sum(big_b_pure_pay_amount_hi_bill_freezed) big_b_pure_pay_amount_hi_bill_freezed,
  sum(exclusive_b_pure_pay_amount_hi_bill_freezed) exclusive_b_pure_pay_amount_hi_bill_freezed,
  sum(pure_gmv_freezed) pure_gmv_freezed,
  sum(a_pure_gmv_freezed) a_pure_gmv_freezed,
  sum(b_pure_gmv_freezed) b_pure_gmv_freezed,
  sum(big_b_pure_gmv_freezed) big_b_pure_gmv_freezed,
  sum(exclusive_b_pure_gmv_freezed) exclusive_b_pure_gmv_freezed,
  sum(a_pure_pay_amount_freezed) a_pure_pay_amount_freezed,
  sum(b_pure_pay_amount_freezed) b_pure_pay_amount_freezed,
  sum(big_b_pure_pay_amount_freezed) big_b_pure_pay_amount_freezed,
  sum(exclusive_b_pure_pay_amount_freezed) exclusive_b_pure_pay_amount_freezed,
  is_split,
  is_coefficient,
  coefficient_logical,
  commission_logical,
  sum(case when is_leave=0 then coefficient_actual_amount else 0 end) coefficient_actual_amount,
  sum(case when is_leave=0 then commission_actual_amount else 0 end) commission_actual_amount,
  reason,
  from_unixtime(unix_timestamp()) as update_time,
  pickup_category_id_first,
  pickup_category_id_first_name,
  pickup_category_id_second,
  pickup_category_id_second_name,
  pickup_category_id_third,
  pickup_category_id_third_name,
  pickup_brand_id,
  pickup_brand_name,
  is_pickup_order,
  is_pickup_recharge_order,
  sum(pickup_card_amount) pickup_card_amount,
  sum(refund_pickup_card_amount) refund_pickup_card_amount,
  sum(pickup_card_amount_freezed) pickup_card_amount_freezed,
  sum(refund_pickup_card_amount_freezed) refund_pickup_card_amount_freezed
from
(
  select
    service_user_id,
    service_user_name,
    service_department_id,
    service_department_name,
    shop_id,
    shop_name,
    shop_pro_name,
    shop_city_name,
    shop_area_name,
    is_leave,
    service_feature_name,
    service_feature_names,
    item_style_name,
    business_unit,
    category_id_first, --新增类目id
    category_id_second,
    category_id_third,
    category_id_first_name,
    category_id_second_name,
    category_id_third_name,
    brand_id,
    brand_name,
    gmv,
    pay_amount,
    refund_actual_amount,
    refund_actual_amount_offline,
    pure_gmv,
    pure_pay_amount,
    gmv_freezed,
    pay_amount_freezed,
    pay_amount_freezed_not_hi_bill,
    pay_amount_freezed_hi_bill,
    refund_actual_amount_freezed,
    refund_actual_amount_offline_freezed,
    last_month_pay_amount_freezed,
    pre_last_month_pay_amount_freezed,
    pure_pay_amount_freezed,
    pure_pay_amount_hi_bill_freezed,
    a_pure_gmv,
    b_pure_gmv,
    big_b_pure_gmv,
    pure_gmv_hi_bill_freezed,
    a_pure_pay_amount_hi_bill_freezed,
    b_pure_pay_amount_hi_bill_freezed,
    big_b_pure_pay_amount_hi_bill_freezed,
    exclusive_b_pure_pay_amount_hi_bill_freezed,
    pure_gmv_freezed,
    a_pure_gmv_freezed,
    b_pure_gmv_freezed,
    big_b_pure_gmv_freezed,
    exclusive_b_pure_gmv_freezed,
    a_pure_pay_amount_freezed,
    b_pure_pay_amount_freezed,
    big_b_pure_pay_amount_freezed,
    exclusive_b_pure_pay_amount_freezed,
    is_split,
    is_coefficient,
    coefficient_logical,
    commission_logical,
    case
    when coefficient_logical='0' then 0
    when coefficient_logical='库内全量净GMV' then pure_gmv
    when coefficient_logical='冻结全量净GMV' then pure_gmv_freezed
    when coefficient_logical='库内B类净GMV' then b_pure_gmv
    when coefficient_logical='冻结B类净GMV' then b_pure_gmv_freezed
    when coefficient_logical='冻结全量净支付金额' then pure_pay_amount_freezed
    when coefficient_logical='冻结B类净支付金额' then b_pure_pay_amount_freezed
    when coefficient_logical='冻结大B净支付金额(账期) - 冻结专属B净支付金额(账期)' then big_b_pure_pay_amount_hi_bill_freezed - exclusive_b_pure_pay_amount_hi_bill_freezed
    when coefficient_logical='冻结大B净支付金额 - 冻结专属B净支付金额' then big_b_pure_pay_amount_freezed - exclusive_b_pure_pay_amount_freezed
    when coefficient_logical='冻结大B净支付金额(账期)' then big_b_pure_pay_amount_hi_bill_freezed
    when coefficient_logical='冻结专属B净支付金额(账期)' then exclusive_b_pure_pay_amount_hi_bill_freezed
    when coefficient_logical='冻结大B净支付金额' then big_b_pure_pay_amount_freezed
    when coefficient_logical='冻结专属B净支付金额' then exclusive_b_pure_pay_amount_freezed
    when coefficient_logical='冻结B类净支付金额(账期)' then b_pure_pay_amount_hi_bill_freezed
    when coefficient_logical='冻结B类净支付金额 - 冻结专属B净支付金额' then b_pure_pay_amount_freezed - exclusive_b_pure_pay_amount_freezed
    when coefficient_logical='冻结B类净支付金额(账期) - 冻结专属B净支付金额(账期)' then b_pure_pay_amount_hi_bill_freezed - exclusive_b_pure_pay_amount_hi_bill_freezed
    else 0 end as coefficient_actual_amount,
    case
    when commission_logical='0' then 0
    when commission_logical='库内全量净GMV' then pure_gmv
    when commission_logical='冻结全量净GMV' then pure_gmv_freezed
    when commission_logical='库内B类净GMV' then b_pure_gmv
    when commission_logical='冻结B类净GMV' then b_pure_gmv_freezed
    when commission_logical='冻结全量净支付金额' then pure_pay_amount_freezed
    when commission_logical='冻结B类净支付金额' then b_pure_pay_amount_freezed
    when commission_logical='冻结大B净支付金额(账期) - 冻结专属B净支付金额(账期)' then big_b_pure_pay_amount_hi_bill_freezed - exclusive_b_pure_pay_amount_hi_bill_freezed
    when commission_logical='冻结大B净支付金额 - 冻结专属B净支付金额' then big_b_pure_pay_amount_freezed - exclusive_b_pure_pay_amount_freezed
    when commission_logical='冻结大B净支付金额(账期)' then big_b_pure_pay_amount_hi_bill_freezed
    when commission_logical='冻结专属B净支付金额(账期)' then exclusive_b_pure_pay_amount_hi_bill_freezed
    when commission_logical='冻结大B净支付金额' then big_b_pure_pay_amount_freezed
    when commission_logical='冻结专属B净支付金额' then exclusive_b_pure_pay_amount_freezed
    when commission_logical='冻结B类净支付金额(账期)' then b_pure_pay_amount_hi_bill_freezed
    when commission_logical='冻结B类净支付金额 - 冻结专属B净支付金额' then b_pure_pay_amount_freezed - exclusive_b_pure_pay_amount_freezed
    when commission_logical='冻结B类净支付金额(账期) - 冻结专属B净支付金额(账期)' then b_pure_pay_amount_hi_bill_freezed - exclusive_b_pure_pay_amount_hi_bill_freezed
    else 0 end as commission_actual_amount,
    case
    when is_split is null or is_coefficient is null then '不存在于人员名单中'
    when coefficient_logical is null or commission_logical is null then '不存在于订单场景'
    else null end as reason,
        --新增提货卡字段
        pickup_category_id_first,
        pickup_category_id_first_name,
        pickup_category_id_second,
        pickup_category_id_second_name,
	      pickup_category_id_third,
	      pickup_category_id_third_name,
        pickup_brand_id,
        pickup_brand_name,
        is_pickup_order,
        is_pickup_recharge_order,
        pickup_card_amount,
    refund_pickup_card_amount,
        pickup_card_amount_freezed,
    refund_pickup_card_amount_freezed
  from
  (
    select
      ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_id') as service_user_id,
      ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_name') as service_user_name,
      ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_department_id') as service_department_id,
      ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_department_name') as service_department_name,
      order.shop_id,
      order.shop_name,
      order.shop_pro_name,
      order.shop_city_name,
      order.shop_area_name,
      case
      when user.leave_time is null or substr(order.pay_time,1,8) <= substr(user.leave_time,1,8) then 0
      when substr(order.pay_time,1,8)  > substr(user.leave_time,1,8) then 1
      else '' end as is_leave,
      ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_feature_name') as service_feature_name,
      concat_ws(',',ytdw.get_service_info('service_type:销售',order.service_info,'service_feature_name'),ytdw.get_service_info('service_type:电销',order.service_info,'service_feature_name')) as service_feature_names,
      case when order.item_style=0 then 'A' when order.item_style=1 then 'B' else '其他' end as item_style_name,
      order.business_unit,
          order.category_id_first, --新增类目id
      order.category_id_second,
      order.category_id_first_name,
      order.category_id_second_name,
      order.category_id_third,
      order.category_id_third_name,
      order.brand_id,
      order.brand_name,

      --库内当月GMV
      sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) as gmv,
      --库内当月支付金额
      sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.pay_amount else 0 end) as pay_amount,
      --库内订单实际退款金额
          sum(case when substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end) as refund_actual_amount,
      --库内订单线下退款
      nvl(sum(offline_refund.refund_actual_amount),0) as refund_actual_amount_offline,
      --库内净GMV-new 净GMV/净支付金额= GMV/支付金额(充值hi卡+实货) - 提货hi卡支付金额 - (实际退款金额 - 提货hi卡支付退款金额) - 线下退款
      sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) -
      sum(case when substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end) -
      nvl(sum(offline_refund.refund_actual_amount),0)-
          sum(case when substr(order.pay_time,1,6)='$v_cur_month' then nvl(order.pickup_card_amount,0) else 0 end) +
      sum(case when substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then nvl(order.refund_pickup_card_amount,0) else 0 end) as pure_gmv,
      --库内净支付金额-new
      sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.pay_amount else 0 end) -
      sum(case when substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
      nvl(sum(offline_refund.refund_actual_amount),0)-
          sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
      sum(case when substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as pure_pay_amount,
      0 as gmv_freezed,
      0 as pay_amount_freezed,
      0 as pay_amount_freezed_not_hi_bill,
      0 as pay_amount_freezed_hi_bill,
      0 as refund_actual_amount_freezed,
      0 as refund_actual_amount_offline_freezed,
      0 as last_month_pay_amount_freezed,
      0 as pre_last_month_pay_amount_freezed,
      0 as pure_pay_amount_freezed,
      0 as pure_pay_amount_hi_bill_freezed,
      --A类库内净GMV-new
      sum(case when order.item_style=0 and substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) -
      sum(case when order.item_style=0 and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
      nvl(sum(case when order.item_style=0 then offline_refund.refund_actual_amount else 0 end),0) -
          sum(case when order.item_style=0 and substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
      sum(case when order.item_style=0 and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9  then order.refund_pickup_card_amount else 0 end) as a_pure_gmv,
      --B类库内净GMV-new
      sum(case when order.item_style=1 and substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) -
      sum(case when order.item_style=1 and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
      nvl(sum(case when order.item_style=1 then offline_refund.refund_actual_amount else 0 end),0)-
          sum(case when order.item_style=1 and substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
      sum(case when order.item_style=1 and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9  then order.refund_pickup_card_amount else 0 end) as b_pure_gmv,
      --B类库内净GMV-new
      sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null and substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) -
      sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
      nvl(sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null then offline_refund.refund_actual_amount else 0 end),0)-
          sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null and substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
      sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9  then order.refund_pickup_card_amount else 0 end) as big_b_pure_gmv,
      0 as pure_gmv_hi_bill_freezed,
      0 as a_pure_pay_amount_hi_bill_freezed,
      0 as b_pure_pay_amount_hi_bill_freezed,
      0 as big_b_pure_pay_amount_hi_bill_freezed,
      0 as exclusive_b_pure_pay_amount_hi_bill_freezed,
      0 as pure_gmv_freezed,
      0 as a_pure_gmv_freezed,
      0 as b_pure_gmv_freezed,
      0 as big_b_pure_gmv_freezed,
      0 as exclusive_b_pure_gmv_freezed,
      0 as a_pure_pay_amount_freezed,
      0 as b_pure_pay_amount_freezed,
      0 as big_b_pure_pay_amount_freezed,
      0 as exclusive_b_pure_pay_amount_freezed,
      salary_user.is_split,
      salary_user.is_coefficient,
      salary_logical_scene.coefficient_logical,
      salary_logical_scene.commission_logical,
          --新增提货卡字段
          order.pickup_category_id_first,
          order.pickup_category_id_first_name,
          order.pickup_category_id_second,
          order.pickup_category_id_second_name,
	        order.pickup_category_id_third,
	        order.pickup_category_id_third_name,
          order.pickup_brand_id,
          order.pickup_brand_name,
          order.is_pickup_order,
          order.is_pickup_recharge_order,
          --库内当月提货hi卡支付金额
          sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) as pickup_card_amount,
      --库内当月提货hi卡退款金额
          sum(case when substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as refund_pickup_card_amount,
          --冻结当月提货hi卡支付金额
          0 as pickup_card_amount_freezed,
          --冻结当月提货hi卡退款金额
          0 as refund_pickup_card_amount_freezed

      from
      (
          select order1.order_id,
                order1.brand_id,
                order1.bd_service_info,
            order1.shop_id,
            order1.shop_name,
            order1.shop_pro_name,
            order1.shop_city_name,
            order1.shop_area_name,
            order1.pay_time,
            order1.service_info,
            case when order1.is_pickup_recharge_order=1 then '1' else order1.item_style end as item_style, --修改提货卡充值订单的商品类型为1
            order1.business_unit,
            order1.category_id_first, --新增类目id
            order1.category_id_second,
            order1.category_id_first_name,
            order1.category_id_second_name,
            order1.category_id_third,
            order1.category_id_third_name,
            order1.brand_name,
            order1.total_pay_amount,
            order1.pay_amount,
            afs_refund.refund_end_mth as refund_end_time,
                afs_refund.refund_status,
                nvl(afs_refund.refund_actual_amount,0) as refund_actual_amount,
            nvl(order1.pickup_card_amount,0) as pickup_card_amount,
            nvl(afs_refund.refund_pickup_card_amount,0) as refund_pickup_card_amount,
                order1.pickup_category_id_first,
                order1.pickup_category_id_first_name,
                order1.pickup_category_id_second,
                order1.pickup_category_id_second_name,
                order1.pickup_category_id_third,
                order1.pickup_category_id_third_name,
                order1.pickup_brand_id,
                order1.pickup_brand_name,
                order1.is_pickup_order,
                order1.is_pickup_recharge_order
            from order1
                --退款改造 20200724
                left join (
                 select order_id
               --,refund_num
               ,refund_status
               ,substr(refund_end_time,1,6) as refund_end_mth
               ,sum(refund_actual_amount) as refund_actual_amount --实际退款金额
               ,sum(refund_pickup_card_amount) as refund_pickup_card_amount --提货卡退款金额
          from dw_afs_order_refund_new_d
           where dayid='$v_date'
           and refund_status=9
           and substr(refund_end_time,1,6)='$v_cur_month'
           group by order_id,refund_status,substr(refund_end_time,1,6)
                ) afs_refund on order1.order_id = afs_refund.order_id
                --排除特殊订单
                left join
                ( select * from dw_offline_spec_refund_d where dayid ='$v_date'
                ) spec_order on order1.trade_no=spec_order.trade_no
                where spec_order.trade_no is null
      ) order
      --线下退款
      left join
      (
            select order_id,refund_actual_amount
              from ads_salary_base_offline_refund_order_d
                  where dayid='$v_date'
      ) offline_refund on offline_refund.order_id=order.order_id
      --离职人员
      left join
      (
        select user_id,leave_time from  ytdw.dim_usr_user_d where dayid='$v_date' and diz_type like '%old%'
      ) user on user.user_id=ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_id')
      --专属b
      left join
      (
        select * from ytdw.ads_salary_base_exclusive_b_brand_d where dayid='$v_date'
      ) exclusive_b_brand on exclusive_b_brand.brand_id=order.brand_id
      --销售是否拆分，是否有系数
      left join
      (
        select * from ytdw.ads_salary_base_user_d where dayid='$v_date'
      ) salary_user on salary_user.user_name=ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_name')
      --逻辑场景
      left join
      (
        select * from ytdw.ads_salary_base_logical_scene_d where dayid='$v_date'
      ) salary_logical_scene on salary_logical_scene.is_split=salary_user.is_split and salary_logical_scene.service_feature_names=concat_ws(',',ytdw.get_service_info('service_type:销售',order.service_info,'service_feature_name'),ytdw.get_service_info('service_type:电销',order.service_info,'service_feature_name'))
        and salary_logical_scene.service_feature_name=ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_feature_name')
      group by
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_id'),
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_name'),
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_department_id'),
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_department_name'),
        order.shop_id,
        order.shop_name,
        order.shop_pro_name,
        order.shop_city_name,
        order.shop_area_name,
        case
        when user.leave_time is null or substr(order.pay_time,1,8) <= substr(user.leave_time,1,8) then 0
        when substr(order.pay_time,1,8)  > substr(user.leave_time,1,8) then 1
        else '' end,
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_feature_name'),
        concat_ws(',',ytdw.get_service_info('service_type:销售',order.service_info,'service_feature_name'),ytdw.get_service_info('service_type:电销',order.service_info,'service_feature_name')),
        case when order.item_style=0 then 'A' when order.item_style=1 then 'B' else '其他' end,
        order.business_unit,
        order.category_id_first, --新增类目id
        order.category_id_second,
        order.category_id_third,
        order.category_id_first_name,
        order.category_id_second_name,
        order.category_id_third_name,
        order.brand_id,
        order.brand_name,
        salary_user.is_split,
        salary_user.is_coefficient,
        salary_logical_scene.coefficient_logical,
        salary_logical_scene.commission_logical,
        order.pickup_category_id_first,
        order.pickup_category_id_first_name,
        order.pickup_category_id_second,
        order.pickup_category_id_second_name,
        order.pickup_category_id_third,
        order.pickup_category_id_third_name,
        order.pickup_brand_id,
        order.pickup_brand_name,
        order.is_pickup_order,
        order.is_pickup_recharge_order
  ) table1

union all

  select
    service_user_id,
    service_user_name,
    service_department_id,
    service_department_name,
    shop_id,
    shop_name,
    shop_pro_name,
    shop_city_name,
    shop_area_name,
    is_leave,
    service_feature_name,
    service_feature_names,
    item_style_name,
    business_unit,
    category_id_first, --新增类目id
    category_id_second,
    category_id_third,
    category_id_first_name,
    category_id_second_name,
    category_id_third_name,
    brand_id,
    brand_name,
    gmv,
    pay_amount,
    refund_actual_amount,
    refund_actual_amount_offline,
    pure_gmv,
    pure_pay_amount,
    gmv_freezed,
    pay_amount_freezed,
    pay_amount_freezed_not_hi_bill,
    pay_amount_freezed_hi_bill,
    refund_actual_amount_freezed,
    refund_actual_amount_offline_freezed,
    last_month_pay_amount_freezed,
    pre_last_month_pay_amount_freezed,
    pure_pay_amount_freezed,
    pure_pay_amount_hi_bill_freezed,
    a_pure_gmv,
    b_pure_gmv,
    big_b_pure_gmv,
    pure_gmv_hi_bill_freezed,
    a_pure_pay_amount_hi_bill_freezed,
    b_pure_pay_amount_hi_bill_freezed,
    big_b_pure_pay_amount_hi_bill_freezed,
    exclusive_b_pure_pay_amount_hi_bill_freezed,
    pure_gmv_freezed,
    a_pure_gmv_freezed,
    b_pure_gmv_freezed,
    big_b_pure_gmv_freezed,
    exclusive_b_pure_gmv_freezed,
    a_pure_pay_amount_freezed,
    b_pure_pay_amount_freezed,
    big_b_pure_pay_amount_freezed,
    exclusive_b_pure_pay_amount_freezed,
    is_split,
    is_coefficient,
    coefficient_logical,
    commission_logical,
    case
    when coefficient_logical='0' then 0
    when coefficient_logical='库内全量净GMV' then pure_gmv
    when coefficient_logical='冻结全量净GMV' then pure_gmv_freezed
    when coefficient_logical='库内B类净GMV' then b_pure_gmv
    when coefficient_logical='冻结B类净GMV' then b_pure_gmv_freezed
    when coefficient_logical='冻结全量净支付金额' then pure_pay_amount_freezed
    when coefficient_logical='冻结B类净支付金额' then b_pure_pay_amount_freezed
    when coefficient_logical='冻结大B净支付金额(账期) - 冻结专属B净支付金额(账期)' then big_b_pure_pay_amount_hi_bill_freezed - exclusive_b_pure_pay_amount_hi_bill_freezed
    when coefficient_logical='冻结大B净支付金额 - 冻结专属B净支付金额' then big_b_pure_pay_amount_freezed - exclusive_b_pure_pay_amount_freezed
    when coefficient_logical='冻结大B净支付金额(账期)' then big_b_pure_pay_amount_hi_bill_freezed
    when coefficient_logical='冻结专属B净支付金额(账期)' then exclusive_b_pure_pay_amount_hi_bill_freezed
    when coefficient_logical='冻结大B净支付金额' then big_b_pure_pay_amount_freezed
    when coefficient_logical='冻结专属B净支付金额' then exclusive_b_pure_pay_amount_freezed
    when coefficient_logical='冻结B类净支付金额(账期)' then b_pure_pay_amount_hi_bill_freezed
    when coefficient_logical='冻结B类净支付金额 - 冻结专属B净支付金额' then b_pure_pay_amount_freezed - exclusive_b_pure_pay_amount_freezed
    when coefficient_logical='冻结B类净支付金额(账期) - 冻结专属B净支付金额(账期)' then b_pure_pay_amount_hi_bill_freezed - exclusive_b_pure_pay_amount_hi_bill_freezed
    else 0 end as coefficient_actual_amount,
    case
    when commission_logical='0' then 0
    when commission_logical='库内全量净GMV' then pure_gmv
    when commission_logical='冻结全量净GMV' then pure_gmv_freezed
    when commission_logical='库内B类净GMV' then b_pure_gmv
    when commission_logical='冻结B类净GMV' then b_pure_gmv_freezed
    when commission_logical='冻结全量净支付金额' then pure_pay_amount_freezed
    when commission_logical='冻结B类净支付金额' then b_pure_pay_amount_freezed
    when commission_logical='冻结大B净支付金额(账期) - 冻结专属B净支付金额(账期)' then big_b_pure_pay_amount_hi_bill_freezed - exclusive_b_pure_pay_amount_hi_bill_freezed
    when commission_logical='冻结大B净支付金额 - 冻结专属B净支付金额' then big_b_pure_pay_amount_freezed - exclusive_b_pure_pay_amount_freezed
    when commission_logical='冻结大B净支付金额(账期)' then big_b_pure_pay_amount_hi_bill_freezed
    when commission_logical='冻结专属B净支付金额(账期)' then exclusive_b_pure_pay_amount_hi_bill_freezed
    when commission_logical='冻结大B净支付金额' then big_b_pure_pay_amount_freezed
    when commission_logical='冻结专属B净支付金额' then exclusive_b_pure_pay_amount_freezed
    when commission_logical='冻结B类净支付金额(账期)' then b_pure_pay_amount_hi_bill_freezed
    when commission_logical='冻结B类净支付金额 - 冻结专属B净支付金额' then b_pure_pay_amount_freezed - exclusive_b_pure_pay_amount_freezed
    when commission_logical='冻结B类净支付金额(账期) - 冻结专属B净支付金额(账期)' then b_pure_pay_amount_hi_bill_freezed - exclusive_b_pure_pay_amount_hi_bill_freezed
    else 0 end as commission_actual_amount,
    case
    when is_split is null or is_coefficient is null then '不存在于人员名单中'
    when coefficient_logical is null or commission_logical is null then '不存在于订单场景'
    else null end as reason,
    --新增提货卡字段
    pickup_category_id_first,
    pickup_category_id_first_name,
    pickup_category_id_second,
    pickup_category_id_second_name,
    pickup_category_id_third,
    pickup_category_id_third_name,
    pickup_brand_id,
    pickup_brand_name,
    is_pickup_order,
    is_pickup_recharge_order,
    pickup_card_amount,
    refund_pickup_card_amount,
    pickup_card_amount_freezed,
    refund_pickup_card_amount_freezed
    from
    (
      select
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_id') as service_user_id,
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_name') as service_user_name,
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_department_id') as service_department_id,
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_department_name') as service_department_name,
        order.shop_id,
        order.shop_name,
        order.shop_pro_name,
        order.shop_city_name,
        order.shop_area_name,
        case
        when user.leave_time is null or substr(order.pay_time,1,8) <= substr(user.leave_time,1,8) then 0
        when substr(order.pay_time,1,8)  > substr(user.leave_time,1,8) then 1
        else '' end as is_leave,
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_feature_name') as service_feature_name,
        concat_ws(',',ytdw.get_service_info('service_type:销售',order.service_info_freezed,'service_feature_name'),ytdw.get_service_info('service_type:电销',order.service_info_freezed,'service_feature_name')) as service_feature_names,
        case when order.item_style=0 then 'A' when order.item_style=1 then 'B' else '其他' end as item_style_name,
        order.business_unit,
        order.category_id_first, --新增类目id
        order.category_id_second,
        order.category_id_third,
        order.category_id_first_name,
        order.category_id_second_name,
        order.category_id_third_name,
        order.brand_id,
        order.brand_name,
        0 as gmv,
        0 as pay_amount,
        0 as refund_actual_amount,
        0 as refund_actual_amount_offline,
        0 as pure_gmv,
        0 as pure_pay_amount,
        --冻结当月GMV
        sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) as gmv_freezed,
        --冻结当月支付金额
        sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.pay_amount else 0 end) as pay_amount_freezed,
        --冻结当月非账期订单支付金额
        0 as pay_amount_freezed_not_hi_bill,
        --冻结当月账期支付金额
        0 as pay_amount_freezed_hi_bill,
        --冻结当月订单实际退款金额
        sum(case when substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end) as refund_actual_amount_freezed,
        --冻结当月线下退款金额
        nvl(sum(offline_refund.refund_actual_amount),0) as refund_actual_amount_offline_freezed,
        --冻结上月账期支付金额
        0 as last_month_pay_amount_freezed,
        --冻结上上月账期支付金额
        0 as pre_last_month_pay_amount_freezed,
        --冻结净支付金额
        sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.pay_amount else 0 end) -
        sum(case when substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
        nvl(sum(offline_refund.refund_actual_amount),0) -
              sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
        sum(case when substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as pure_pay_amount_freezed,
        --冻结净支付金额(包含账期)
        0 as pure_pay_amount_hi_bill_freezed,
        0 as a_pure_gmv,
        0 as b_pure_gmv,
        0 as big_b_pure_gmv,
        --冻结净gmv(账期)
        0 as pure_gmv_hi_bill_freezed,
        --A类冻结净支付金额(账期)
        0 as a_pure_pay_amount_hi_bill_freezed,
        --B类冻结净支付金额(账期)
        0 as b_pure_pay_amount_hi_bill_freezed,
        --大B类冻结净支付金额(账期)
        0 as big_b_pure_pay_amount_hi_bill_freezed,
        --专属B类冻结净支付金额(账期)
        0 as exclusive_b_pure_pay_amount_hi_bill_freezed,
        --冻结净gmv-new
        sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) -
        sum(case when substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
        nvl(sum(offline_refund.refund_actual_amount),0)-
            sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
        sum(case when substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as pure_gmv_freezed,
        --a冻结净gmv-new
        sum(case when order.item_style=0 and substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) -
        sum(case when order.item_style=0 and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
        nvl(sum(case when order.item_style=0 then offline_refund.refund_actual_amount else 0 end),0) -
                sum(case when order.item_style=0 and substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
        sum(case when order.item_style=0 and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as a_pure_gmv_freezed,
        --b冻结净gmv-new
        sum(case when order.item_style=1 and substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) -
        sum(case when order.item_style=1 and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
        nvl(sum(case when order.item_style=1 then offline_refund.refund_actual_amount else 0 end),0) -
                sum(case when order.item_style=1 and substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
        sum(case when order.item_style=1 and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as b_pure_gmv_freezed,
        --大b冻结净gmv-new
        sum(case when order.item_sub_style='大B' and substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) -
        sum(case when order.item_sub_style='大B' and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
        nvl(sum(case when order.item_sub_style='大B' then offline_refund.refund_actual_amount else 0 end),0) -
                sum(case when order.item_sub_style='大B' and substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
        sum(case when order.item_sub_style='大B' and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as big_b_pure_gmv_freezed,
        --专属b冻结净gmv-new
        sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null and substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) -
        sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
        nvl(sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null then offline_refund.refund_actual_amount else 0 end),0)-
                sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null and substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
        sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as exclusive_b_pure_gmv_freezed,
        --a冻结净支付金额-new
        sum(case when order.item_style=0 and substr(order.pay_time,1,6)='$v_cur_month' then order.pay_amount else 0 end) -
        sum(case when order.item_style=0 and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
        nvl(sum(case when order.item_style=0 then offline_refund.refund_actual_amount else 0 end),0)-
                sum(case when order.item_style=0 and substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
        sum(case when order.item_style=0 and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as a_pure_pay_amount_freezed,
        --b冻结净支付金额-new
        sum(case when order.item_style=1 and substr(order.pay_time,1,6)='$v_cur_month' then order.pay_amount else 0 end) -
        sum(case when order.item_style=1 and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
        nvl(sum(case when order.item_style=1 then offline_refund.refund_actual_amount else 0 end),0) -
                sum(case when order.item_style=1 and substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
        sum(case when order.item_style=1 and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as b_pure_pay_amount_freezed,
        --大b冻结净支付金额-new
        sum(case when order.item_sub_style='大B' and substr(order.pay_time,1,6)='$v_cur_month' then order.pay_amount else 0 end) -
        sum(case when order.item_sub_style='大B' and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
        nvl(sum(case when order.item_sub_style='大B' then offline_refund.refund_actual_amount else 0 end),0) -
                sum(case when order.item_sub_style='大B' and substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
        sum(case when order.item_sub_style='大B' and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as big_b_pure_pay_amount_freezed,
        --专属b冻结净支付金额-new
        sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null and substr(order.pay_time,1,6)='$v_cur_month' then order.pay_amount else 0 end) -
        sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_actual_amount else 0 end)-
        nvl(sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null then offline_refund.refund_actual_amount else 0 end),0) -
                sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null and substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) +
        sum(case when order.item_style=1 and exclusive_b_brand.brand_id is not null and substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as exclusive_b_pure_pay_amount_freezed,
        salary_user.is_split,
        salary_user.is_coefficient,
        salary_logical_scene.coefficient_logical,
        salary_logical_scene.commission_logical,
        --新增提货卡字段
        order.pickup_category_id_first,
        order.pickup_category_id_first_name,
        order.pickup_category_id_second,
        order.pickup_category_id_second_name,
        order.pickup_category_id_third,
        order.pickup_category_id_third_name,
        order.pickup_brand_id,
        order.pickup_brand_name,
        order.is_pickup_order,
        order.is_pickup_recharge_order,
        --库内当月提货hi卡支付金额
        0 as pickup_card_amount,
        --库内当月提货hi卡退款金额
        0 as refund_pickup_card_amount,
                --冻结当月提货hi卡支付金额
            sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.pickup_card_amount else 0 end) as pickup_card_amount_freezed,
        --冻结当月提货hi卡退款金额
            sum(case when substr(order.refund_end_time,1,6)='$v_cur_month' and order.refund_status=9 then order.refund_pickup_card_amount else 0 end) as refund_pickup_card_amount_freezed
      from
      (
          select  order2.order_id,
                 order2.brand_id,
            order2.bd_service_info,
            order2.shop_id,
            order2.shop_name,
            order2.shop_pro_name,
            order2.shop_city_name,
            order2.shop_area_name,
            order2.pay_time,
            order2.service_info_freezed,
            case when order2.is_pickup_recharge_order=1 then '1' else order2.item_style end as item_style, --修改提货卡充值订单的商品类型为1
            order2.item_sub_style,
            order2.business_unit,
            order2.category_id_first, --新增类目id
            order2.category_id_second,
            order2.category_id_third,
            order2.category_id_first_name,
            order2.category_id_second_name,
            order2.category_id_third_name,
            order2.brand_name,
            order2.total_pay_amount,
            order2.pay_amount,
            afs_refund.refund_end_mth as refund_end_time,
            afs_refund.refund_status,
            afs_refund.refund_actual_amount,
            nvl(order2.pickup_card_amount,0) as pickup_card_amount,
            nvl(afs_refund.refund_pickup_card_amount,0) as refund_pickup_card_amount,
            order2.pickup_category_id_first,
            order2.pickup_category_id_first_name,
            order2.pickup_category_id_second,
            order2.pickup_category_id_second_name,
            order2.pickup_category_id_third,
            order2.pickup_category_id_third_name,
            order2.pickup_brand_id,
            order2.pickup_brand_name,
            order2.is_pickup_order,
            order2.is_pickup_recharge_order
            from order2
                left join (
                --20200724 退款改造
                   select order_id
                 --,refund_num
                 ,refund_status
                 ,substr(refund_end_time,1,6) as refund_end_mth
                 ,sum(refund_actual_amount) as refund_actual_amount --实际退款金额
                 ,sum(refund_pickup_card_amount) as refund_pickup_card_amount --提货卡退款金额
           from dw_afs_order_refund_new_d
            where dayid='$v_date'
            and refund_status=9
            and substr(refund_end_time,1,6)='$v_cur_month'
            group by order_id,refund_status,substr(refund_end_time,1,6)
                ) afs_refund on order2.order_id = afs_refund.order_id
                --排除特殊订单
                left join
                ( select * from dw_offline_spec_refund_d where dayid ='$v_date'
                ) spec_order on order2.trade_no=spec_order.trade_no
                where spec_order.trade_no is null
      ) order
      --线下退款
      left join
    (
            select order_id,refund_actual_amount
              from ads_salary_base_offline_refund_order_d
                  where dayid='$v_date'
      ) offline_refund on offline_refund.order_id=order.order_id
      --离职人员
      left join
      (
        select user_id,leave_time from  ytdw.dim_usr_user_d where dayid='$v_date' and diz_type like '%old%'
      ) user on user.user_id=ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_id')
      --专属b
      left join
      (
        select * from ytdw.ads_salary_base_exclusive_b_brand_d where dayid='$v_date'
      ) exclusive_b_brand on exclusive_b_brand.brand_id=order.brand_id
      --销售是否拆分，是否有系数
      left join
      (
        select * from ytdw.ads_salary_base_user_d where dayid='$v_date'
      ) salary_user on salary_user.user_name=ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_name')
      --逻辑场景
      left join
      (
        select * from ytdw.ads_salary_base_logical_scene_d where dayid='$v_date'
      ) salary_logical_scene on salary_logical_scene.is_split=salary_user.is_split and salary_logical_scene.service_feature_names=concat_ws(',',ytdw.get_service_info('service_type:销售',order.service_info_freezed,'service_feature_name'),ytdw.get_service_info('service_type:电销',order.service_info_freezed,'service_feature_name'))
       and salary_logical_scene.service_feature_name=ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_feature_name')
      group by
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_id'),
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_name'),
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_department_id'),
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_department_name'),
        order.shop_id,
        order.shop_name,
        order.shop_pro_name,
        order.shop_city_name,
        order.shop_area_name,
        case
        when user.leave_time is null or substr(order.pay_time,1,8) <= substr(user.leave_time,1,8) then 0
        when substr(order.pay_time,1,8)  > substr(user.leave_time,1,8) then 1
        else '' end,
        ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_feature_name'),
        concat_ws(',',ytdw.get_service_info('service_type:销售',order.service_info_freezed,'service_feature_name'),ytdw.get_service_info('service_type:电销',order.service_info_freezed,'service_feature_name')),
        case when order.item_style=0 then 'A' when order.item_style=1 then 'B' else '其他' end,
        order.business_unit,
        order.category_id_first, --新增类目id
        order.category_id_second,
        order.category_id_third,
        order.category_id_first_name,
        order.category_id_second_name,
        order.category_id_third_name,
        order.brand_id,
        order.brand_name,
        salary_user.is_split,
        salary_user.is_coefficient,
        salary_logical_scene.coefficient_logical,
        salary_logical_scene.commission_logical,
        order.pickup_category_id_first,
        order.pickup_category_id_first_name,
        order.pickup_category_id_second,
        order.pickup_category_id_second_name,
        order.pickup_category_id_third,
        order.pickup_category_id_third_name,
        order.pickup_brand_id,
        order.pickup_brand_name,
        order.is_pickup_order,
        order.is_pickup_recharge_order
    ) table2
) table3
where (gmv !=0 or pay_amount !=0 or refund_actual_amount !=0 or refund_actual_amount_offline !=0 or pure_gmv !=0 or pure_pay_amount !=0 or gmv_freezed !=0 or pay_amount_freezed !=0 or
       pay_amount_freezed_not_hi_bill !=0 or pay_amount_freezed_hi_bill !=0 or refund_actual_amount_freezed !=0 or refund_actual_amount_offline_freezed !=0 or last_month_pay_amount_freezed !=0 or
       pre_last_month_pay_amount_freezed !=0 or pure_pay_amount_freezed !=0 or pure_pay_amount_hi_bill_freezed !=0 or a_pure_gmv !=0 or b_pure_gmv !=0 or big_b_pure_gmv !=0 or pure_gmv_hi_bill_freezed !=0 or
       a_pure_pay_amount_hi_bill_freezed !=0 or b_pure_pay_amount_hi_bill_freezed !=0 or big_b_pure_pay_amount_hi_bill_freezed !=0 or exclusive_b_pure_pay_amount_hi_bill_freezed !=0 or pure_gmv_freezed !=0 or
       a_pure_gmv_freezed !=0 or b_pure_gmv_freezed !=0 or big_b_pure_gmv_freezed !=0 or exclusive_b_pure_gmv_freezed !=0 or a_pure_pay_amount_freezed !=0 or b_pure_pay_amount_freezed !=0 or
       big_b_pure_pay_amount_freezed !=0 or exclusive_b_pure_pay_amount_freezed !=0 or coefficient_actual_amount !=0 or commission_actual_amount !=0)
 and service_user_id is not null
group by
service_user_id,
  service_user_name,
  service_department_id,
  service_department_name,
  shop_id,
  shop_name,
  shop_pro_name,
  shop_city_name,
  shop_area_name,
  is_leave,
  service_feature_name,
  service_feature_names,
  item_style_name,
  business_unit,
  category_id_first, --新增类目id
  category_id_second,
  category_id_third,
  category_id_first_name,
  category_id_second_name,
  category_id_third_name,
  brand_id,
  brand_name,
  is_split,
  is_coefficient,
  coefficient_logical,
  commission_logical,
  reason,
  pickup_category_id_first,
  pickup_category_id_first_name,
  pickup_category_id_second,
  pickup_category_id_second_name,
  pickup_category_id_third,
  pickup_category_id_third_name,
  pickup_brand_id,
  pickup_brand_name,
  is_pickup_order,
  is_pickup_recharge_order
  ) salary_base
--特殊提点品牌表
  left join
  ( select brand_name from ads_salary_base_special_brand_d  where dayid ='$v_date' group by brand_name
   ) spec_brand on spec_brand.brand_name=salary_base.brand_name
--提货卡品牌名关联特殊品牌表
   left join
   ( select brand_name from ads_salary_base_special_brand_d  where dayid ='$v_date' group by brand_name
   ) pickup_spec_brand on pickup_spec_brand.brand_name=salary_base.pickup_brand_name
   --20200504
--低端品牌标识
  left join
  ( SELECT id,name
     FROM dwd_brand_d
     where dayid = '$v_date'
     and (array_contains(split(tags,','),'42')  or  array_contains(split(tags,','),'41'))
   ) celeron on celeron.name=salary_base.brand_name
--提货卡低端品牌标识
   left join
   ( SELECT id,name
     FROM dwd_brand_d
     where dayid = '$v_date'
     and (array_contains(split(tags,','),'42')  or  array_contains(split(tags,','),'41'))
   ) pickup_celeron on pickup_celeron.name=salary_base.pickup_brand_name
  ) total

