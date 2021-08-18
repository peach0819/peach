use ytdw;

CREATE TABLE IF NOT EXISTS ads_salary_biz_frozen_pure_gmv_detail_d (
  service_user_id                 string          comment '用户id',
  service_user_name               string          comment '用户id',
  is_split                        string          comment '销售拆分',
  leave_time                      string          comment '离职时间',
  pay_time                        string          comment '支付时间',
  is_leave                        string          comment '是否算离职订单',
  shop_id                         string          COMMENT '门店ID',
  shop_name                       string          COMMENT '门店名',
  order_id                        bigint          comment '订单编号，外部生成',
  item_name                       string          comment '商品名称',
  item_style                      tinyint         comment '商品标签类型默认是0：A类1：B类',
  brand_id                        bigint          comment '品牌ID',
  brand_name                      string          comment '品牌名称',
  category_id_first               bigint          comment '一级类目ID',
  category_id_first_name          string          comment '一级类目名称',
  category_id_second              bigint          comment '二级类目ID',
  category_id_second_name         string          comment '二级类目名称',
  pickup_brand_id                 bigint          comment '提货hi卡品牌',
  pickup_brand_name               string          comment '提货hi卡品牌名' ,
  pickup_category_id_first        bigint          comment '提货hi卡一级类目id',
  pickup_category_id_first_name   string          comment '提货hi卡一级类目名',
  pickup_category_id_second       bigint          comment '提货hi卡二级类目id',
  pickup_category_id_second_name  string          comment '提货hi卡二级类目名',
  is_celeron                      tinyint         comment '是否低端/超低端品牌，1是0否',
  is_pickup_recharge_order        int             comment '是否为充值提货hi卡订单 1 是 0 否',
  is_spec_brand                   tinyint         COMMENT '是否特殊提点品牌,1是0否',
  class_number                    string          COMMENT '分类',
  class_number_info               string          comment '分类信息',
  commission_actual_amount        decimal(11,2)   COMMENT '提成金额',
  remark                          string          comment '备注字段，分类全信息',
  category_id_third               bigint          comment '三级类目ID',
  category_id_third_name          string          comment '三级类目名称',
  pickup_category_id_third        bigint          comment '提货hi卡三级类目id',
  pickup_category_id_third_name   string          comment '提货hi卡三级类目名'
)
comment '冻结B类净支付金额指标明细数据'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;

insert overwrite table ads_salary_biz_frozen_pure_gmv_detail_d partition(dayid='$v_date')
select
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_user_id') as service_user_id,
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_user_name') as service_user_name,
  is_split,
  leave_time,
  pay_time,
  is_leave,
  shop_id,
  shop_name,
  order_id,
  item_name,
  item_style,
  brand_id,
  brand_name,
  category_id_first, --新增类目id
  category_id_first_name,
  category_id_second,
  category_id_second_name,
  --新增提货卡字段
  pickup_brand_id,
  pickup_brand_name,
  pickup_category_id_first,
  pickup_category_id_first_name,
  pickup_category_id_second,
  pickup_category_id_second_name,
  is_celeron,
  is_pickup_recharge_order,
  is_spec_brand,
  --20200504
  --二级类目 2807,2721 衣物清洁护理  8012 干纸巾
  --一级类目 10 尿不湿 12 奶粉  542 婴幼儿营养品 13 婴童辅食 4 婴童服纺  6098 婴童零食 2794 婴童洗护
  --20200724
  --spec_brand.brand_name is null 非专供品（特殊提点品牌）
  --is_pickup_recharge_order=0 非提货卡
  --is_pickup_recharge_order=1 提货卡
  --一级类目为 尿不湿 且品牌标签为低端，超低端 category_id_first='10' and is_celeron=1
        --大BD/BD、非提货卡、非专供品（特殊提点品牌）
  case  when (is_split='大BD' or is_split='BD') and is_pickup_recharge_order=0 and is_spec_brand=0 then (
          case when (category_id_first=10 and is_celeron=1)
                    or category_id_first in (7999)
                    or category_id_second in (2807,2721,2712,6820)
                    or brand_id = 13818 then '分类01'
  	           when (category_id_first=542 and brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (category_id_first in (4,11543,11544,11545,11546,2794,2627,8,2681,11,2560,2750,5) and category_id_second not in (6820,2807)) then '分类02'
  		         when category_id_first=12 or category_id_third=11191 then '分类03'
  		         when brand_id in (2068,7324,10726,9566,7888) then '分类09'
  	           else '分类04' end)
        --大BD/BD、提货卡、 非专供品（特殊提点品牌）
        when (is_split='大BD' or is_split='BD') and is_pickup_recharge_order=1 and  is_spec_brand=0 then (
          case when (pickup_category_id_first=10 and is_celeron=1)
                    or pickup_category_id_first in (7999)
                    or pickup_category_id_second in (2807,2721,2712,6820)
                    or pickup_brand_id = 13818 then '分类01'
  	           when (pickup_category_id_first=542 and pickup_brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (pickup_category_id_first in (4,11543,11544,11545,11546,11543,11544,11545,11546,11543,11544,11545,11546,2794,2627,8,2681,11,2560,2750,5) and pickup_category_id_second not in (6820,2807))then '分类02'
  		         when pickup_category_id_first=12 or pickup_category_id_third=11191 then '分类03'
  		         when pickup_brand_id in (2068,7324,10726,9566,7888) then '分类09'
  	           else '分类04' end)
        --大BD/BD、非提货卡、 专供品（特殊提点品牌）
        when is_split='大BD' and is_pickup_recharge_order=0 and is_spec_brand=1 then (
          case when (category_id_first=10 and is_celeron=1)
                    or category_id_first in (7999)
                    or category_id_second in (2807,2721,2712,6820) then '分类05'
      	       when (category_id_first=542 and brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (category_id_first in (4,11543,11544,11545,11546,2794,2627,8,2681,11,2560,2750,5) and category_id_second not in (6820,2807)) then '分类06'
      		     when category_id_first=12 or category_id_third=11191 then '分类07'
      	       else '分类08' end)
        --大BD/BD、提货卡、 专供品（特殊提点品牌）
        when is_split='大BD' and is_pickup_recharge_order=1 and is_spec_brand=1 then (
          case when (pickup_category_id_first=10 and is_celeron=1)
                    or pickup_category_id_first in (7999)
                    or pickup_category_id_second in (2807,2721,2712,6820) then '分类05'
        	     when (pickup_category_id_first=542 and pickup_brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (pickup_category_id_first in (4,11543,11544,11545,11546,2794,2627,8,2681,11,2560,2750,5) and pickup_category_id_second not in (6820,2807)) then '分类06'
        		   when pickup_category_id_first=12 or pickup_category_id_third=11191 then '分类07'
        	     else '分类08' end)
        else ''
  end as class_number,
  case  when (is_split='大BD' or is_split='BD') and is_pickup_recharge_order=0 and is_spec_brand=0 then (
          case when (category_id_first=10 and is_celeron=1)
                    or category_id_first in (7999)
                    or category_id_second in (2807,2721,2712,6820)
                    or brand_id = 13818 then '低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（通用品）（元）'
  	           when (category_id_first=542 and brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and category_id_second not in (6820,2807)) then '营养品（除纽瑞优系列、BuffX品牌、佑伉力），用品玩具，服纺，洗护（通用品）（元）'
  		         when category_id_first=12 or category_id_third=11191 then '奶粉及面包/蛋糕（通用品）（元）'
  		         when brand_id in (2068,7324,10726,9566,7888) then '纽瑞优系列，佑伉力（通用品）（元）'
  	           else '中端和高端尿不湿，辅食，其他品类（通用品）' end)
        --大BD/BD、提货卡、 非专供品（特殊提点品牌）
        when (is_split='大BD' or is_split='BD') and is_pickup_recharge_order=1 and  is_spec_brand=0 then (
          case when (pickup_category_id_first=10 and is_celeron=1)
                    or pickup_category_id_first in (7999)
                    or pickup_category_id_second in (2807,2721,2712,6820)
                    or pickup_brand_id = 13818 then '低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（通用品）（元）'
  	           when (pickup_category_id_first=542 and pickup_brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (pickup_category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and pickup_category_id_second not in (6820,2807))then '营养品（除纽瑞优系列、BuffX品牌、佑伉力），用品玩具，服纺，洗护（通用品）（元）'
  		         when pickup_category_id_first=12 or pickup_category_id_third=11191 then '奶粉及面包/蛋糕（通用品）(元)'
  		         when pickup_brand_id in (2068,7324,10726,9566,7888) then '纽瑞优系列，佑伉力（通用品）（元）'
  	           else '中端和高端尿不湿，辅食，其他品类（通用品）' end)
        --大BD/BD、非提货卡、 专供品（特殊提点品牌）
        when is_split='大BD' and is_pickup_recharge_order=0 and is_spec_brand=1 then (
          case when (category_id_first=10 and is_celeron=1)
                    or category_id_first in (7999)
                    or category_id_second in (2807,2721,2712,6820) then '低端和超低端尿不湿，洗衣液，干湿纸巾（大BD专供品）'
      	       when (category_id_first=542 and brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and category_id_second not in (6820,2807)) then '营养品（除纽瑞优系列、BuffX品牌、佑伉力），用品玩具，服纺，洗护（大BD专供品）'
      		     when category_id_first=12 or category_id_third=11191 then '奶粉及面包/蛋糕(元)（大BD专供品）'
      	       else '中端和高端尿不湿，辅食，其他品类（大BD专供品）' end)
        --大BD/BD、提货卡、 专供品（特殊提点品牌）
        when is_split='大BD' and is_pickup_recharge_order=1 and is_spec_brand=1 then (
          case when (pickup_category_id_first=10 and is_celeron=1)
                    or pickup_category_id_first in (7999)
                    or pickup_category_id_second in (2807,2721,2712,6820) then '低端和超低端尿不湿，洗衣液，干湿纸巾（大BD专供品）'
        	     when (pickup_category_id_first=542 and pickup_brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (pickup_category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and pickup_category_id_second not in (6820,2807)) then '营养品（除纽瑞优系列、BuffX品牌、佑伉力），用品玩具，服纺，洗护（大BD专供品）'
        		   when pickup_category_id_first=12 or pickup_category_id_third=11191 then '奶粉及面包/蛋糕(元)（大BD专供品）'
        	     else '中端和高端尿不湿，辅食，其他品类（大BD专供品）' end)
        else ''
  end as class_number_info,
    case
    when is_leave=1 then 0
    when commission_logical='0' then 0
    when commission_logical='冻结B类净支付金额' then b_pure_pay_amount_freezed
  else 0 end as commission_actual_amount,
  case  when is_split='BD' then  '分类01：低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（通用品）（元）\；分类02：营养品，用品玩具，服纺，洗护（通用品）\；分类03奶粉及面包/蛋糕(元)（通用品）\；分类04：中端和高端尿不湿，辅食，其他品类（通用品）\；分类09：纽瑞优系列，佑伉力（元）'
        when is_split='大BD' then  '分类01：低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（通用品）（元）\；分类02：营养品，用品玩具，服纺，洗护（通用品）\；分类03奶粉及面包/蛋糕(元)（通用品）\；分类04：中端和高端尿不湿，辅食，其他品类（通用品）\；分类05：低端和超低端尿不湿，洗衣液，干湿纸巾（大BD专供品）\；分类06：营养品，用品玩具，服纺，洗护 （大BD专供品）\；分类07：奶粉及面包/蛋糕(元)（大BD专供品）\；分类08：中端和高端尿不湿，辅食，其他品类（大BD专供品）\；分类09：纽瑞优系列，佑伉力（元）'
        else ''
  end as remark,
  category_id_third,
  category_id_third_name,
  pickup_category_id_third,
  pickup_category_id_third_name
from
(
  select
    cur_month_order.order_id,
    cur_month_order.bd_service_info,
    cur_month_order.service_info_freezed,
    user.leave_time,
    cur_month_order.shop_id,
    cur_month_order.shop_name,
    cur_month_order.item_name,
    cur_month_order.item_style,
    cur_month_order.brand_id,
    cur_month_order.brand_name,
    cur_month_order.pay_time,
    case when substr(cur_month_order.pay_time,1,8)  > substr(user.leave_time,1,8) then 1 else 0 end as is_leave,
    cur_month_order.category_id_first,
    cur_month_order.category_id_second,
    cur_month_order.category_id_third,
    cur_month_order.category_id_first_name,
    cur_month_order.category_id_second_name,
    cur_month_order.category_id_third_name,
    salary_user.is_split,
    salary_logical_scene.commission_logical,
    cur_month_order.pickup_brand_id,
    cur_month_order.pickup_brand_name,
    cur_month_order.pickup_category_id_first,
    cur_month_order.pickup_category_id_first_name,
    cur_month_order.pickup_category_id_second,
    cur_month_order.pickup_category_id_second_name,
    cur_month_order.pickup_category_id_third,
    cur_month_order.pickup_category_id_third_name,
    cur_month_order.is_celeron,
    cur_month_order.is_pickup_recharge_order,
    cur_month_order.is_spec_brand,
    (case when cur_month_order.item_style=1 then cur_month_order.pay_amount else 0 end)
          -nvl((case when cur_month_order.item_style=1 then cur_month_order.refund_actual_amount else 0 end),0)
          -nvl((case when cur_month_order.item_style=1 then cur_month_order.pickup_card_amount else 0 end),0)
          +nvl((case when cur_month_order.item_style=1 then cur_month_order.refund_pickup_card_amount else 0 end),0)
    as b_pure_pay_amount_freezed
  from
  (
    select
      order_id,
      shop_id,
      shop_name,
      item_name,
      brand_id,
      brand_name,
      0 as refund_actual_amount,
      0 as refund_pickup_card_amount,
      bd_service_info,
      service_info_freezed,
      pay_time,
      case when is_pickup_recharge_order=1 then '1' else item_style end as item_style, --修改提货卡充值订单的商品类型为1
      category_id_first,
      category_id_second,
      category_id_third,
      category_id_first_name,
      category_id_second_name,
      category_id_third_name,
      total_pay_amount,
      pay_amount,
      nvl(pickup_card_amount,0) as pickup_card_amount,
      pickup_brand_id,
      pickup_brand_name,
      pickup_category_id_first,
      pickup_category_id_first_name,
      pickup_category_id_second,
      pickup_category_id_second_name,
      pickup_category_id_third,
      pickup_category_id_third_name,
      is_celeron,
      is_pickup_recharge_order,
      is_spec_brand
    from ads_salary_base_cur_month_order_d
    lateral view explode(split(regexp_replace(ytdw.get_service_info('service_type:销售',service_info_freezed),'\},','\}\;'),'\;')) tmp as bd_service_info
    where dayid='$v_date'
          and sp_id is null         --剔除服务商
          and (business_unit not in ('卡券票','其他') or is_pickup_recharge_order = 1)        --剔除 业务域等 卡券票和其他
          and nvl(store_type,100) not in (3,9,10,11)        --剔除员工店，二批商，美妆店,伙伴店11
          and is_spec_order!=1  --  剔除薪资特殊订单

    union all

    select
      order_id,
      shop_id,
      shop_name,
      item_name,
      brand_id,
      brand_name,
      refund_actual_amount,
      refund_pickup_card_amount,
      bd_service_info,
      service_info_freezed,
      pay_time,
      case when is_pickup_recharge_order=1 then '1' else item_style end as item_style, --修改提货卡充值订单的商品类型为1
      category_id_first,
      category_id_second,
      category_id_third,
      category_id_first_name,
      category_id_second_name,
      category_id_third_name,
      0 as total_pay_amount,
      0 as pay_amount,
      0 as pickup_card_amount,
      pickup_brand_id,
      pickup_brand_name,
      pickup_category_id_first,
      pickup_category_id_first_name,
      pickup_category_id_second,
      pickup_category_id_second_name,
      pickup_category_id_third,
      pickup_category_id_third_name,
      is_celeron,
      is_pickup_recharge_order,
      is_spec_brand
    from ads_salary_base_cur_month_refund_d
    lateral view explode(split(regexp_replace(ytdw.get_service_info('service_type:销售',service_info_freezed),'\},','\}\;'),'\;')) tmp as bd_service_info
    where dayid='$v_date'
          and sp_id is null         --剔除服务商
          and (business_unit not in ('卡券票','其他') or is_pickup_recharge_order = 1)        --剔除 业务域等 卡券票和其他
          and nvl(store_type,100) not in (3,9,10,11)        --剔除员工店，二批商，美妆店,伙伴店11
          and is_spec_order!=1  --  剔除薪资特殊订单
	) cur_month_order
  -- 员工离职信息
  left join
  (select user_id,leave_time from  dim_usr_user_d where dayid='$v_date') user
  on user.user_id=ytdw.get_service_info('service_type:销售',cur_month_order.bd_service_info,'service_user_id')
  --销售是否拆分，是否有系数
  left join
  (select user_name,is_split,is_coefficient from ads_salary_base_user_d where dayid='$v_date') salary_user
  on salary_user.user_name=ytdw.get_service_info('service_type:销售',cur_month_order.bd_service_info,'service_user_name')
  --逻辑场景
  left join
  (
    select
      is_split,
      service_feature_names,
      service_feature_name,
      commission_logical
    from ads_salary_base_logical_scene_d where dayid='$v_date'
  ) salary_logical_scene
  on salary_logical_scene.is_split=salary_user.is_split
    and salary_logical_scene.service_feature_names=concat_ws(',',ytdw.get_service_info('service_type:销售',cur_month_order.service_info_freezed,'service_feature_name'),ytdw.get_service_info('service_type:电销',cur_month_order.service_info_freezed,'service_feature_name'))
    and salary_logical_scene.service_feature_name=ytdw.get_service_info('service_type:销售',cur_month_order.bd_service_info,'service_feature_name')
)salary_item



