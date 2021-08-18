use ytdw;

create table if not exists dw_salary_shop_silent_d
(
    shop_id string ,
    max_last_b_date string  comment '本月之前的最近冻结B类下单日期',
	all_beforel_ast_month_b_gmv decimal(18,2) comment '本月之前的历史冻结B类净GMV(含线下退款)',
	is_silent string comment '静默/无效门店',
	is_silent_type string comment '激活状态',
	cur_month_min_b_pay_day string comment '静默无效激活日期',
	service_user_id string comment '静默无效激活人user_id',
	service_user_name string  comment '静默无效激活人',
	service_department_name string,
	min_b_date string comment '门店冻结B类首次支付日期',
	b_pure_pay_amount  decimal(18,2) comment '满足静默激活成功的支付金额-退款',
	is_brand_shop string comment '可否多品进店',
	is_brand_shop_type string comment '多品进店状态',
	brand_name string comment '多品进店品牌',
	is_brand_pay_day string comment '多品进店日期',
	is_brand_service_user_id string comment '多品进店激活人',
	is_brand_service_user_name  string comment '多品进店激活人名',
	is_brand_pure_pay_amount decimal(18,2) comment '多品进店首次满足条件的支付金额-退款'

    ) comment '静默无效门店表'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;


with order_tmp as (
     select order.order_id,
	        order.shop_id,
			order.brand_name,
			order.pay_day,
			order.pay_time,
			order.service_info_freezed,
			order.pay_amount ,
			order.total_pay_amount,
			afs_refund.refund_status,
			nvl(afs_refund.refund_actual_amount,0) as refund_actual_amount,
			nvl(afs_refund.last_mnt_before_refund_actual_amount,0) as last_mnt_before_refund_actual_amount

     from (
		  select order_id,shop_id,brand_name,
                 pay_day,pay_time,service_info_freezed,pay_amount,total_pay_amount
           from ytdw.dw_order_d
           where dayid='$v_date'
                 and pay_day<='$v_date'
                 --服务商数据
                 and sp_id is null
                 and bu_id=0
                 --排除员工店
                 and store_type not in (9,10)
                 --卡券票、试用装、测试等类目
                 and business_unit not in ('卡券票','其他')
                 and item_style_freezed=1
				 --20200728剔除贝莱订单
				 and sale_dc_id=-1 ) order
		 left join (--20200728 退款改造
		    select order_id
                  ,refund_status
                  --,substr(refund_end_time,1,6) as refund_end_mth
                  ,sum(refund_actual_amount) as refund_actual_amount --实际退款金额
				  ,sum(case when substr(refund_end_time,1,6)<'$v_cur_month' then refund_actual_amount else 0 end) as last_mnt_before_refund_actual_amount
                  --,sum(refund_pickup_card_amount) as refund_pickup_card_amount --提货卡退款金额
                  from dw_afs_order_refund_new_d
                  where dayid='$v_date'
                  and refund_status=9
                  --and substr(refund_end_time,1,6)='$v_cur_month'
                  group by order_id,refund_status
		   ) afs_refund on order.order_id=afs_refund.order_id
        )

insert overwrite table dw_salary_shop_silent_d partition (dayid='$v_date')
select    shop_silent.shop_id,
          shop_silent.max_last_b_date,
		  shop_silent.all_beforel_ast_month_b_gmv as all_before_last_month_b_gmv,
		  case when new_sign_shop.shop_id is null then shop_silent.is_silent else null end as is_silent,
		  case when new_sign_shop.shop_id is null then shop_silent.is_silent_type else null end as is_silent_type,
		  case when new_sign_shop.shop_id is null then shop_silent.cur_month_min_b_pay_day else null end as cur_month_min_b_pay_day,
		  case when new_sign_shop.shop_id is null then shop_silent.service_user_id else null end as service_user_id,
		  case when new_sign_shop.shop_id is null then shop_silent.service_user_name else null end as service_user_name,
		  case when new_sign_shop.shop_id is null then shop_silent.service_department_name else null end as service_department_name,
		  case when new_sign_shop.shop_id is null then shop_silent.min_b_date else null end as min_b_date,
		  case when new_sign_shop.shop_id is null then shop_silent.b_pure_pay_amount else null end as b_pure_pay_amount,
		  case when nvl(is_silent_type,'失败') !='激活成功' and shop_silent.shop_id is not null then  '可以多品进店' else '无法多品进店'  end as is_brand_shop,--可否多品进店
		  case when brand_shop.shop_id is not null and nvl(is_silent_type,'失败') !='激活成功' then '多品进店成功' else null end as is_brand_shop_type,--是否多品进店成功
		  case when brand_shop.brand_name is not null and nvl(is_silent_type,'失败') !='激活成功' then brand_name else null end as brand_name, --多品进店品牌
		  case when brand_shop.pay_day is not null and nvl(is_silent_type,'失败') !='激活成功' then pay_day else null end as is_brand_pay_day,--多品进店日期
		  case when brand_shop.service_user_id is not null and nvl(is_silent_type,'失败') !='激活成功' then brand_shop.service_user_id else null end as is_brand_service_user_id,--多品进店激活人
		  case when brand_shop.service_user_name is not null and nvl(is_silent_type,'失败') !='激活成功' then brand_shop.service_user_name else null end as is_brand_service_user_name,--多品进店激活人名
		  case when brand_shop.pure_pay_amount is not null and nvl(is_silent_type,'失败') !='激活成功' then brand_shop.pure_pay_amount else null end as is_brand_pure_pay_amount	 --多品进店首次满足条件的支付金额-退款
  from
  (
   select shop_id,
        max_last_b_date,--本月之前的最近冻结B类下单日期
		all_beforel_ast_month_b_gmv,--本月之前的历史冻结B类净GMV(含线下退款)
		is_silent,--静默/无效门店
		case when is_silent is not null and  cur_month_min_b_pay_day is not null then '激活成功' else null end as is_silent_type, --激活状态
		case when is_silent is not null and  cur_month_min_b_pay_day is not null then cur_month_min_b_pay_day else null end as cur_month_min_b_pay_day,--静默无效激活日期
		case when is_silent is not null and  cur_month_min_b_pay_day is not null then service_user_id else null end as service_user_id,--静默无效激活人user_id
		case when is_silent is not null and  cur_month_min_b_pay_day is not null then service_user_name else null end as service_user_name,--静默无效激活人
		case when is_silent is not null and  cur_month_min_b_pay_day is not null then service_department_name else null end as service_department_name,
        min_b_date ,--门店冻结B类首次支付日期
		b_pure_pay_amount --当月某一天的支付金额-退款
  from
  (
  select shop_order.shop_id,
         max_last_b_date,--本月之前的最近冻结B类下单日期
		 all_beforel_ast_month_b_gmv,--本月之前的历史冻结B类净GMV(含线下退款)
        case when substr(max_last_b_date,1,6) < substr('$v_3_months_ago',1,6) then '静默门店'
			  when substr(min_b_date,1,6)<'$v_cur_month' and all_beforel_ast_month_b_gmv<=200 then '无效门店'
			  else null end is_silent,--静默/无效门店
		cur_month_min_b_pay_day,--静默无效激活日期
        service_user_id,--静默无效激活人user_id
		service_user_name,--静默无效激活人
		service_department_name,
        min_b_date,	--门店冻结B类首次支付日期
		b_pure_pay_amount --当月某一天的支付金额-退款
  from
  --门店订单
  (
   select
      shop_id,
  	  max(case when substr(pay_day,1,6)<'$v_cur_month' then pay_day else null end) as max_last_b_date,
      min(pay_day) as min_b_date,
	  sum(case when substr(pay_time,1,6)<'$v_cur_month' then total_pay_amount else 0 end)-
       nvl(sum(case when refund_status=9 --and substr(refund_end_time,1,6)<'$v_cur_month' then order.refund_actual_amount
	           then last_mnt_before_refund_actual_amount
	           else 0 end),0)-
      nvl(sum(nvl(offline_refund.refund_actual_amount,0)),0) as all_beforel_ast_month_b_gmv
      --20200728 退款改造
	  from (select * from order_tmp) as order
    --(
    --  select
    --    shop_id,
    --    pay_day,
	--	order_id,pay_time,total_pay_amount,refund_end_time,refund_status,refund_actual_amount
    --  from dw_order_d
    --  where dayid='$v_date'
	--  and pay_day<='$v_date'
    --  and pay_time is not null
    --  and sp_id is null
    --  and bu_id=0
    --  --排除员工店
    --  and store_type not in (9,10)
    --  --卡券票、试用装、测试等类目
    --  and business_unit not in ('卡券票','其他')
    --  and item_style_freezed=1
    --) order
      --线下退款(排除当月订单)
      left join
      (
		  select order_id,refund_actual_amount
	      from ads_salary_base_offline_refund_order_d
		  where (dayid='$v_date' or dayid='20190831' or dayid='20190731' or dayid='20190630' or dayid='20190531' or dayid='20190430')
		  and substr(dayid,1,6) <'$v_cur_month'
      ) offline_refund on offline_refund.order_id=order.order_id
	 group by order.shop_id
  ) shop_order
	 --门店激活信息判断
	 left join
	 (
	 select shop_id,pay_day as cur_month_min_b_pay_day,service_user_id,service_user_name,service_department_name,b_pure_pay_amount,
	        row_number()over(partition by shop_id order by pay_day asc,b_pure_pay_amount desc) as rn
	   from
	   (
	   select shop_id,pay_day,
	         coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_id')) as service_user_id,
             coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_name')) as service_user_name,
	  	     coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_department_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_department_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_department_name')) as service_department_name,
			  sum(pay_amount)-nvl(sum(case when refund_status=9 then refund_actual_amount else 0 end),0) as b_pure_pay_amount
	  --20200728 退款改造
	  from order_tmp
	  where substr(pay_day,1,6)='$v_cur_month'
	   --from dw_order_d
	   --where dayid='$v_date'
	   --and substr(pay_day,1,6)='$v_cur_month'
       --and pay_time is not null
       --and sp_id is null
       --and bu_id=0
       ----排除员工店
       --and store_type not in (9,10)
       ----卡券票、试用装、测试等类目
       --and business_unit not in ('卡券票','其他')
       --and item_style_freezed=1
	   group by shop_id,pay_day,
	   coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_id')) ,
       coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_name')) ,
	   coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_department_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_department_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_department_name'))
	    ) t
		where b_pure_pay_amount>=1000
	 ) shop_service_user on shop_service_user.shop_id=shop_order.shop_id  and rn=1
where substr(min_b_date,1,6) < '$v_cur_month'
) shop
) shop_silent
--多品进店
  left join
  (
    select
      shop_id,
      brand_name,
      pay_day,
      service_user_id,
      salary_user.user_name as service_user_name,
      pure_pay_amount,
      row_number() over(partition by shop_id order by pay_day) rn
      from
      (
        select
          shop_id,
          brand_name,
          pay_day,
		  coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_id')) as service_user_id,
          coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_name')) as service_user_name,
          sum(pay_amount)-nvl(sum(case when refund_status=9 then refund_actual_amount else 0 end),0) pure_pay_amount,
          first_value(pay_day)over(partition by shop_id,brand_name order by pay_day) as shop_brand_sign_day
		--20200728 退款改造
		from order_tmp
           --from ytdw.dw_order_d
           --where dayid='$v_date'
           --      and pay_day<='$v_date'
           --      --服务商数据
           --      and sp_id is null
           --      and bu_id=0
           --      --排除员工店
           --      and store_type not in (9,10)
           --      --卡券票、试用装、测试等类目
           --      and business_unit not in ('卡券票','其他')
           --      and item_style_freezed=1) order

        group by
          shop_id,
          brand_name,
          pay_day,
		  coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_id')) ,
          coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_name'))
      ) orders
      left join
      (
        select * from ytdw.ads_salary_base_user_d where dayid='$v_date' and is_split='新签'
      ) salary_user on salary_user.user_name=orders.service_user_name
      where substr(shop_brand_sign_day,1,6)='$v_cur_month' and pure_pay_amount>=1000 and salary_user.user_name is not null
  ) brand_shop on shop_silent.shop_id=brand_shop.shop_id and rn=1
  	 --过滤有效新开
	left join
	  (
	  select  shop_id
	     from dw_salary_shop_data_d
		 where (dayid ='$v_date' or dayid='20190731' or dayid='20190831' or dayid='20190630' or dayid='20190531' or dayid ='20190430' )
		 and substr(dayid,1,6)>='$v_today_3_months_ago_m'
		 group by shop_id
	  ) new_sign_shop on new_sign_shop.shop_id=shop_silent.shop_id

