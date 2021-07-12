use ytdw;
set hive.execution.engine=mr;

CREATE TABLE IF NOT EXISTS dw_salary_manager_data_d(
  shop_id string COMMENT '门店ID',
  shop_name string COMMENT '门店名',
  shop_pro_id string COMMENT '门店省ID',
  shop_pro_name string COMMENT '门店省名',
  shop_city_id string COMMENT '门店市ID',
  shop_city_name string COMMENT '门店市名',
  shop_area_id string COMMENT '门店区ID',
  shop_area_name string COMMENT '门店区名称',
  shop_address_id string COMMENT '门店街道ID',
  shop_address_name string COMMENT '门店街道名',
  service_user_id string COMMENT '库内销售人员 如果有多个,用逗号分隔',
  service_user_name string COMMENT '库内销售人员名称 如果有多个,用逗号分隔',
  service_feature_name string COMMENT '库内销售人员职能 如果有多个,用逗号分隔',
  area_manager_id string COMMENT '大区经理ID',
  area_manager_name string COMMENT '大区经理名',
  area_manager_dep_name string COMMENT '大区',
  bd_manager_id string COMMENT '主管ID',
  bd_manager_name string COMMENT '主管人名',
  bd_manager_dep_name string COMMENT '主管区域',
  category_id_first bigint COMMENT '一级类目ID',
  category_id_first_name string COMMENT '一级类目',
  category_id_second bigint COMMENT '二级类目ID',
  category_id_second_name string COMMENT '二级类目名',
  brand_id bigint COMMENT '品牌ID',
  brand_name string COMMENT '品牌',
  is_spec_brand string COMMENT '是否特殊提点品牌',
  item_style tinyint COMMENT '商品类型 库内AB类型',
  is_sp_shop string COMMENT '是否服务商订单',
  is_bigbd_shop string COMMENT '是否大BD门店 如果 库内销售人员包含 大BD, 则是.否则,否',
  business_unit string COMMENT '业务域',
  business_group_code string COMMENT '业务组code',
  business_group_name string COMMENT '业务组',
  pure_b_gmv decimal(11,2) COMMENT 'B类净GMV',
  pure_b_pay_amount decimal(11,2) COMMENT 'B类净支付金额',
  pure_b_offline_refund decimal(11,2) COMMENT 'B类线下退款金额之和',
  pure_b_refund decimal(18,2) COMMENT 'B类线上退款金额之和',
  class_number string COMMENT '销售提点分类序号',
  update_time string COMMENT '更新时间 指脚本的运行时间',
  shop_status string COMMENT '门店状态',
  is_pay_shop int COMMENT '是否支付门店',
  item_style_name string COMMENT '商品类型名称',
  class_number_info string COMMENT '分类信息',
  pickup_category_id_first bigint COMMENT '提货hi卡一级类目id',
  pickup_category_id_first_name string COMMENT '提货hi卡一级类目名',
  pickup_category_id_second bigint COMMENT '提货hi卡二级类目id',
  pickup_category_id_second_name string COMMENT '提货hi卡二级类目名',
  pickup_brand_id bigint COMMENT '提货hi卡品牌',
  pickup_brand_name string COMMENT '提货hi卡品牌名',
  is_pickup_order_name string COMMENT '是否通过提货hi卡支付 1 是 0 否',
  is_pickup_recharge_order_name string COMMENT '是否为充值提货hi卡订单 1 是 0 否',
  pickup_card_amount decimal(18,2) COMMENT '提货hi卡支付金额',
  refund_pickup_card_amount decimal(18,2) COMMENT '提货hi卡退款金额',
  war_zone_id string comment '战区经理ID',
  war_zone_name string comment '战区经理',
  war_zone_dep_id string comment '战区ID',
  war_zone_dep_name string comment '战区部门',
  staff_id string comment '参谋长ID',
  staff_name string comment '参谋长',

  cur_order_b_gmv decimal(11,2) COMMENT '当月订单B类GMV—退款',
  cur_order_b_refund decimal(11,2) COMMENT '当月订单B类退款之和'

  )
COMMENT 'BD主管/大区经理薪资基础表(包含提货卡)'
PARTITIONED BY (dayid string)
row format delimited fields terminated by '\001'
stored as orc;

insert overwrite table dw_salary_manager_data_d partition (dayid='$v_date')
select
        shop_base.shop_id,
        shop_name,
		shop_pro_id,
		shop_pro_name,
		shop_city_id,
		shop_city_name,
		shop_area_id,
		shop_area_name,
		shop_address_id,
		shop_address_name,
		service_user_id,
		service_user_name,
		service_feature_name,
		area_manager_id,
		area_manager_name,
		area_manager_dep_name,
		bd_manager_id,
		bd_manager_name,
		bd_manager_dep_name,
		category_id_first,
		category_id_first_name,
		category_id_second,
		category_id_second_name,
		brand_id,
		brand_name,
		is_spec_brand,--是否特殊提点品牌
		item_style,
	    is_sp_shop,--是否服务商订单
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
        case when is_pickup_recharge_order=0 and is_spec_brand='否'  then (
             case when (category_id_first='10' and is_celeron='是') or category_id_second ='2807' or category_id_second ='8012' then '分类01'
		       when (category_id_first ='542' or category_id_first ='13' or category_id_first='4' or category_id_first='6098' or category_id_first='2794') then '分类02'
			   when  category_id_first='12' then '分类03'
		     else '分类04' end)
	--提货卡、 非专供品（特殊提点品牌）
            when is_pickup_recharge_order=1 and  is_spec_brand='否'  then (
	        case when (pickup_category_id_first='10' and is_celeron='是') or pickup_category_id_second ='2807' or pickup_category_id_second ='8012' then '分类01'
		       when (pickup_category_id_first ='542' or pickup_category_id_first ='13' or pickup_category_id_first='4' or pickup_category_id_first='6098' or pickup_category_id_first='2794') then '分类02'
			   when pickup_category_id_first='12' then '分类03'
		    else '分类04' end)

            when is_pickup_recharge_order=0 and is_spec_brand='是'  then (
            case when (category_id_first='10' and is_celeron='是') or category_id_second ='2807' or category_id_second ='8012' then '分类05'
		       when (category_id_first ='542' or category_id_first ='13' or category_id_first='4' or category_id_first='6098' or category_id_first='2794') then '分类06'
			   when  category_id_first='12' then '分类07'
		    else '分类08' end)
	--提货卡、 专供品（特殊提点品牌）
	        when is_pickup_recharge_order=1 and is_spec_brand='是'  then (
	        case when (pickup_category_id_first='10' and is_celeron='是') or pickup_category_id_second ='2807' or pickup_category_id_second ='8012' then '分类05'
		       when (pickup_category_id_first ='542' or pickup_category_id_first ='13' or pickup_category_id_first='4' or pickup_category_id_first='6098' or pickup_category_id_first='2794') then '分类06'
			   when pickup_category_id_first='12' then '分类07'
		    else '分类08' end)
	    end as class_number,

		from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
			  shop_status,
			  is_pay_shop,
			  case when item_style=1 then 'B' when item_style=0 then 'A' else null end as item_style_name,
		'分类01：低端，超低端尿不湿,洗衣液,纸巾（BD和大BD通用）\；分类02：营养品,辅食,服纺，婴童洗护 （BD和大BD通用）\；分类03：奶粉（BD和大BD通用）\；分类04：其他（BD和大BD通用）\;分类05：低端，超低端尿不湿,洗衣液,纸巾（大BD专供，BD不计提成）\；分类06：营养品,辅食,服纺，婴童洗护 （大BD专供，BD不计提成）\；分类07：奶粉（大BD专供，BD不计提成）\；分类08：其他（大BD专供，BD不计提成）\;' as class_number_info,
		--新增提货卡字段
	    pickup_category_id_first,
	    pickup_category_id_first_name,
	    pickup_category_id_second,
	    pickup_category_id_second_name,
	    pickup_brand_id,
	    pickup_brand_name,
	    case when is_pickup_order=1 then '是' else '否' end as is_pickup_order_name,
	    case when is_pickup_recharge_order=1 then '是' else '否' end as is_pickup_recharge_order_name,
        nvl(pickup_card_amount,0) as pickup_card_amount,
        nvl(refund_pickup_card_amount,0) as refund_pickup_card_amount,
		war_zone_id ,
        war_zone_name ,
        war_zone_dep_id ,
        war_zone_dep_name ,
        staff_id ,
        staff_name,
		--20200724
		nvl(shop_order.cur_order_b_gmv,0) as cur_order_b_gmv,
        nvl(shop_order.cur_order_b_refund,0) as cur_order_b_refund

  from
(
  select shop_id,
        shop_name,
		shop_pro_id,
		shop_pro_name,
		shop_city_id,
		shop_city_name,
		shop_area_id,
		shop_area_name,
		shop_address_id,
		shop_address_name,
		concat_ws(',', collect_set(string(ytdw.get_service_info('service_type:销售',service_info,'service_user_id'))))as service_user_id,
		concat_ws(',', collect_set(string(ytdw.get_service_info('service_type:销售',service_info,'service_user_name'))))as service_user_name,
		concat_ws(',', collect_set(string(ytdw.get_service_info('service_type:销售',service_info,'service_feature_name'))))as service_feature_name,
		area_manager_id,
		area_manager_name,
		area_manager_dep_name,
		bd_manager_id,
		bd_manager_name,
		bd_manager_dep_name,
		shop_status,
		war_zone_id ,
        war_zone_name ,
        war_zone_dep_id ,
        war_zone_dep_name ,
        staff_id ,
        staff_name
  from dw_shop_base_d
  where dayid ='$v_date'
  and inuse=1 and bu_id =0
  --员工店 二批商 伙伴店11
  and nvl(store_type,100) not in (3,9,10,11)
  group by shop_id,
        shop_name,
		shop_pro_id,
		shop_pro_name,
		shop_city_id,
		shop_city_name,
		shop_area_id,
		shop_area_name,
		shop_address_id,
		shop_address_name,
		area_manager_id,
		area_manager_name,
		area_manager_dep_name,
		bd_manager_id,
		bd_manager_name,
		bd_manager_dep_name,
		shop_status,
		war_zone_id ,
        war_zone_name ,
        war_zone_dep_id ,
        war_zone_dep_name ,
        staff_id ,
        staff_name
  ) shop_base
  left join
  (  select shop_id,
            category_id_first,
			category_id_first_name,
			category_id_second,
			category_id_second_name,
			shop_order1.brand_id,
			brand_name,
			case when spec_brand.brand_id is not null or pickup_spec_brand.brand_id is not null then '是' else '否' end as is_spec_brand,--是否特殊提点品牌
			item_style,
	        is_sp_shop,--是否服务商订单
	        is_bigbd_shop,--是否大BD门店
	        business_unit,
			business_group_code,
			business_group_name,
			--20200724 退款改造
			--B类净GMV-new 净GMV/净支付金额= GMV/支付金额(充值hi卡+实货) - 提货hi卡支付金额 - (实际退款金额 - 提货hi卡支付退款金额) - 线下退款
		    nvl(sum(case when item_style=1 and substr(pay_time,1,6)='$v_cur_month' then total_pay_amount else 0 end),0) -
			     --实际退款金额（改造）
			nvl(sum(case when item_style=1 and afs_refund.refund_end_mth = '$v_cur_month' and afs_refund.refund_status=9 then afs_refund.refund_actual_amount else 0 end),0)-
      nvl(sum(case when item_style=1 then offline_refund.refund_actual_amount else 0 end),0)-
			nvl(sum(case when item_style=1 and substr(pay_time,1,6)='$v_cur_month' then pickup_card_amount else 0 end),0) +
			     --提货卡退款改造
			nvl(sum(case when item_style=1 and afs_refund.refund_end_mth = '$v_cur_month' and afs_refund.refund_status=9  then afs_refund.refund_pickup_card_amount else 0 end),0) as pure_b_gmv,
			--20200724 退款改造
			--B类净支付金额-new
		    nvl(sum(case when item_style=1 and substr(pay_time,1,6)='$v_cur_month' then pay_amount else 0 end),0) -
			       --实际退款金额（改造）
            nvl(sum(case when item_style=1 and afs_refund.refund_end_mth = '$v_cur_month' and afs_refund.refund_status=9 then afs_refund.refund_actual_amount else 0 end),0)-
            nvl(sum(case when item_style=1 then offline_refund.refund_actual_amount else 0 end),0)-
	        nvl(sum(case when item_style=1 and substr(pay_time,1,6)='$v_cur_month' then pickup_card_amount else 0 end),0) +
			       --提货卡退款改造
            nvl(sum(case when item_style=1 and afs_refund.refund_end_mth = '$v_cur_month' and afs_refund.refund_status=9  then afs_refund.refund_pickup_card_amount else 0 end),0) as pure_b_pay_amount,
			--B类线下退款金额之和	指单独的那张线下退款的表的金额
 			sum(case when item_style=1 then offline_refund.refund_actual_amount else 0 end) as pure_b_offline_refund,
			--20200724 （退款改造）
            --B类线上退款金额之和	指线上的订单表里的退款金额
			sum(case when item_style=1 and afs_refund.refund_end_mth = '$v_cur_month' and afs_refund.refund_status=9 then afs_refund.refund_actual_amount else 0 end) as pure_b_refund,
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
	        sum(case when substr(pay_time,1,6)='$v_cur_month' then pickup_card_amount else 0 end) as pickup_card_amount,
            --B类提货hi卡退款金额 20200724 退款改造
	        sum(case when afs_refund.refund_end_mth ='$v_cur_month' and afs_refund.refund_status=9 then afs_refund.refund_pickup_card_amount else 0 end) as refund_pickup_card_amount,
			case when celeron.id is not null or pickup_celeron.id is not null then '是' else '否' end as is_celeron,--是否低端/超低端品牌
			--20200724 新增
			--B类GMV—退款 = GMV(实货)  - 当月实货订单实际退款金额 - 当月实货订单线下退款
			--business_unit not in ('卡券票','其他') 实货，待验证
			sum(case when item_style=1 and business_unit not in ('卡券票','其他') and substr(pay_time,1,6)='$v_cur_month' then (nvl(total_pay_amount,0)-nvl(afs_refund.refund_actual_amount,0)-nvl(offline_refund.refund_actual_amount,0)) else 0 end)  as cur_order_b_gmv,
            --B类当月退款:指所有的当月订单发生的退款之和（包括线上和线下退款）
 			sum(case when item_style=1 and business_unit not in ('卡券票','其他') and substr(pay_time,1,6)='$v_cur_month' then (nvl(offline_refund.refund_actual_amount,0)+nvl(afs_refund.refund_actual_amount,0)) else 0 end) as cur_order_b_refund

       from
	   (select order_id,
	           trade_no,
	           shop_id,
            category_id_first,
			category_id_first_name,
			category_id_second,
			category_id_second_name,
			brand_id,
			brand_name,
			case when is_pickup_recharge_order=1 then '1' else item_style end as item_style,
	        case when sp_id is not null then '是' else '否' end as is_sp_shop,--是否服务商订单
	        case when ytdw.get_service_info('service_feature_id:4',service_info,'service_user_id') is not null then '是' else '否' end as is_bigbd_shop,--是否大BD门店
	        business_unit,
			business_group_code,
			business_group_name,
			pay_time,
			total_pay_amount,
			pay_amount,
			--refund_end_time,
			--refund_status,
			--refund_actual_amount,
	        pickup_category_id_first,
	        pickup_category_id_first_name,
	        pickup_category_id_second,
	        pickup_category_id_second_name,
	        pickup_brand_id,
	        pickup_brand_name,
	        is_pickup_order,
	        is_pickup_recharge_order,
	        nvl(pickup_card_amount,0) as pickup_card_amount
            --nvl(refund_pickup_card_amount,0) as refund_pickup_card_amount
      from dw_order_d
                left join (
     select shop_id as douyin_shop_id, id as douyin_shop_mapping_id
     from dwd_shop_data_cluster_mapping_d
     where dayid = '$v_date'
     and inuse = 1
     and cluster_id in (1750) --167是长尾BD. 1750是对外合作门店
  ) douyin_shop_mapping ON dw_order_d.shop_id = douyin_shop_mapping.douyin_shop_id
	  where dayid ='$v_date'
	  and bu_id=0
	  and pay_day <='$v_date'
      --排除员工店 二批商 伙伴店11 20200505
      and nvl(store_type,100) not in (3,9,10,11)
	  and sale_dc_id=-1
      --卡券票、试用装、测试等类目
      and (business_unit not in ('卡券票','其他') or is_pickup_recharge_order = 1)
      -- 剔除抖音直播店
      and douyin_shop_mapping.douyin_shop_mapping_id is null
	  ) shop_order1
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
	  ) afs_refund on afs_refund.order_id = shop_order1.order_id
	  --特殊订单表
	  left join
	  ( select trade_no from dw_offline_spec_refund_d where dayid ='$v_date'
		) spec_order on spec_order.trade_no=shop_order1.trade_no
	  --线下退款
	  left join
	  ( select order_id,refund_actual_amount
	      from ads_salary_base_offline_refund_order_d
		  where dayid='$v_date'
      ) offline_refund on offline_refund.order_id=shop_order1.order_id
	  --特殊提点品牌表
	  left join
       ( select brand_id from ads_salary_base_special_brand_d  where dayid ='$v_date' group by brand_id
        ) spec_brand on spec_brand.brand_id=shop_order1.brand_id
	  --提货卡品牌名关联特殊品牌表
	  left join
       ( select brand_id from ads_salary_base_special_brand_d  where dayid ='$v_date' group by brand_id
        ) pickup_spec_brand on pickup_spec_brand.brand_id=shop_order1.pickup_brand_id
	    --20200505
     --低端品牌标识
       left join
       ( SELECT id,name
          FROM dwd_brand_d
          where dayid = '$v_date'
          and (array_contains(split(tags,','),'42')  or  array_contains(split(tags,','),'41'))
        ) celeron on celeron.id=shop_order1.brand_id
     --提货卡低端品牌标识
        left join
        ( SELECT id,name
          FROM dwd_brand_d
          where dayid = '$v_date'
          and (array_contains(split(tags,','),'42')  or  array_contains(split(tags,','),'41'))
        ) pickup_celeron on pickup_celeron.id=shop_order1.pickup_brand_id
	 where spec_order.trade_no is  null
	 group by shop_id,category_id_first,category_id_first_name,category_id_second,category_id_second_name,shop_order1.brand_id,brand_name,item_style,
	            case when spec_brand.brand_id is not null or pickup_spec_brand.brand_id is not null then '是' else '否' end,
	            is_sp_shop,is_bigbd_shop,business_unit,business_group_code, business_group_name,
		        pickup_category_id_first,
		        pickup_category_id_first_name,
		        pickup_category_id_second,
		        pickup_category_id_second_name,
		        pickup_brand_id,
		        pickup_brand_name,
		        is_pickup_order,
		        is_pickup_recharge_order,
				case when celeron.id is not null or pickup_celeron.id is not null then '是' else '否' end
  ) shop_order on shop_order.shop_id=shop_base.shop_id
  where ( nvl(pure_b_gmv,0) != 0 or nvl(pure_b_pay_amount,0) != 0 or nvl(pure_b_offline_refund,0) !=0 or nvl(pure_b_refund,0) !=0)
