--20190909 阿伟 新增today_b_gmv

create table if not exists ytdw.dw_shop_order_d(
  shop_id string comment '门店id',
  last_month_big_b_pure_gmv decimal(18,2) comment '上月B类实货净GMV（包含线下退款）',
  last_month_is_reach string comment '上月是否达标（包含线下退款）',
  last_month_reach_goal int comment '上月达标线',
  cur_month_big_b_pure_gmv decimal(18,2) comment '本月B类实货净GMV（包含线下退款）',
  cur_month_is_reach string comment '本月是否达标（包含线下退款）',
  cur_month_reach_goal int comment '本月达标线',
  cur_month_balance decimal(11,2) comment '本月达标差额',
  max_big_b_date string comment '最近支付B日期',
  shop_pay_status string comment '门店下单状态',
  last_month_max_big_g_pure_amount decimal(18,2) comment '上月最大日净支付金额',
  cur_month_max_big_g_pure_amount decimal(18,2) comment '本月最大日净支付金额',
  is_bd_top10 string comment '是否销售top10门店',
  update_time string comment '更新时间',
  today_b_gmv decimal(18,2) COMMENT '今日B类净GMV(库内,包含服务商)',
  today_exclude_sp_b_gmv decimal(18,2) COMMENT '今日B类净GMV(剔除服务商)',
  pre_month_exclude_sp_b_gmv decimal(18,2) COMMENT '上月B类净GMV(剔除服务商)',
  cur_month_exclude_sp_b_gmv decimal(18,2) COMMENT '本月B类净GMV(剔除服务商)'
)
comment '门店订单宽表'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc
location '/dw/ytdw/dw/dw_shop_order_d';

with order_tmp as (
   select order.order_id,
          order.shop_id,
          order.item_style,
          order.pay_day,
		      order.pay_time,
          order.pay_month,
          order.sp_id,
          order.total_pay_amount,
          order.pay_amount,
	        order.item_style_freezed ,
	        order.service_info,
          afs_refund.refund_status,
           nvl(afs_refund.pre_mnt_refund_actual_amount,0) as pre_mnt_refund_actual_amount,
          nvl(afs_refund.cur_mnt_refund_actual_amount,0) as cur_mnt_refund_actual_amount,
          nvl(afs_refund.refund_actual_amount,0) as refund_actual_amount,
          nvl(afs_refund.cur_day_refund_actual_amount,0) as cur_day_refund_actual_amount

   from (select order_id,
                shop_id,
                item_style,
				        pay_time,
                substr(pay_time,1,8) pay_day,
                substr(pay_time,1,6) pay_month,
                sp_id,
                total_pay_amount,
                pay_amount,
	            item_style_freezed,
	            service_info
         from ytdw.dw_order_d
         where dayid='$v_date'
               and pay_time is not null
               --and sp_id is null
               and bu_id=0
               --排除员工店
               and store_type not in (9,10)
               --卡券票、试用装、测试等类目
               and business_unit not in ('卡券票','其他')
			        --20200728 剔除贝莱订单
			         and sale_dc_id=-1) order
	left join(
	 select order_id
          ,refund_status
		      ,sum(case when substr(refund_end_time,1,8)='$v_date' then refund_actual_amount else 0 end) as cur_day_refund_actual_amount
          ,sum(case when substr(refund_end_time,1,6)='$v_pre_month' then refund_actual_amount else 0 end) as pre_mnt_refund_actual_amount
		      ,sum(case when substr(refund_end_time,1,6)='$v_cur_month' then refund_actual_amount else 0 end) as cur_mnt_refund_actual_amount
		      --实际退款金额
		      ,sum(refund_actual_amount) as refund_actual_amount --实际退款金额
           --,sum(refund_pickup_card_amount) as refund_pickup_card_amount --提货卡退款金额
      from dw_afs_order_refund_new_d
           where dayid='$v_date'
           and refund_status=9
           group by order_id,refund_status
	) afs_refund on order.order_id = afs_refund.order_id
)

insert overwrite table ytdw.dw_shop_order_d partition(dayid='$v_date')
select
  shop_base.shop_id,
  shop_order.last_month_big_b_pure_gmv,
  case when shop_order.last_month_big_b_pure_gmv>=cur_month_pro_mark_line.reach_shop_mark_line then '达标' else '否' end as last_month_is_reach,
  last_month_pro_mark_line.reach_shop_mark_line as last_month_reach_goal,

  shop_order.cur_month_big_b_pure_gmv,
  case when shop_order.cur_month_big_b_pure_gmv>=cur_month_pro_mark_line.reach_shop_mark_line then '达标' else '否' end as cur_month_is_reach,
  cur_month_pro_mark_line.reach_shop_mark_line as cur_month_reach_goal,
  nvl(shop_order.cur_month_big_b_pure_gmv,0)-cur_month_pro_mark_line.reach_shop_mark_line as cur_month_balance,

  shop_status.max_big_b_date,

  case
  when shop_status.a_or_small_b_max_date>='$v_60_days_ago' and shop_status.a_or_small_b_max_date<='$v_date' and shop_status.max_big_b_date is null then '未下过B近60天下过A'
  when shop_status.a_or_small_b_max_date is not null and shop_status.max_big_b_date is null then '未下过B下过A'
  when shop_status.max_big_b_date is not null then '下过B门店'
  else '未下单门店' end as shop_pay_status,

  shop_max_order.last_month_max_big_g_pure_amount,
  shop_max_order.cur_month_max_big_g_pure_amount,

  case when shop_top.shop_id is not null then 'BDtop10门店' else '否' end as is_bd_top10,
  from_unixtime(unix_timestamp()) as update_time,
   shop_status.today_b_gmv,
   today_exclude_sp_b_gmv,
   pre_month_exclude_sp_b_gmv,
   cur_month_exclude_sp_b_gmv
from
(
  select
    shop_id,
    shop_pro_id
  from ytdw.dw_shop_base_d where dayid='$v_date' and shop_status not in (6)
) shop_base

--门店交易信息
left join
(
  select
    shop_id,

    sum(case when substr(pay_time,1,6)='$v_pre_month' then total_pay_amount else 0 end)-
    --sum(case when substr(refund_end_time,1,6)='$v_pre_month' and refund_status=9 then refund_actual_amount else 0 end)-
	  sum(pre_mnt_refund_actual_amount)-
    nvl(sum(nvl(offline_refund.last_month_refund_actual_amount,0)),0) as last_month_big_b_pure_gmv,

    sum(case when substr(pay_time,1,6)='$v_cur_month' then total_pay_amount else 0 end)-
    --sum(case when substr(refund_end_time,1,8)>='$v_first_day' and  substr(refund_end_time,1,8)<='$v_date' and refund_status=9 then refund_actual_amount else 0 end)-
	  sum(cur_mnt_refund_actual_amount)-
    nvl(sum(nvl(offline_refund.cur_month_refund_actual_amount,0)),0) as cur_month_big_b_pure_gmv
  from
  (
    select * from order_tmp
	where item_style=1
  ) order
  --线下退款
  left join
  (
    select
      order_shop.order_id,
      cur_month_offline_refund.refund_actual_amount*(order_shop.item_actual_amount/trade_shop_total.item_actual_amount) cur_month_refund_actual_amount,
      last_month_offline_refun.refund_actual_amount*(order_shop.item_actual_amount/trade_shop_total.item_actual_amount) last_month_refund_actual_amount
    from
    (
      select * from ytdw.dwd_order_shop_d where dayid='$v_date' and is_deleted=0
    ) order_shop
    left join
    (
      select * from ytdw.dwd_trade_shop_d where dayid='$v_date' and is_deleted=0
    ) trade_shop on trade_shop.trade_id=order_shop.trade_id
    left join
    (
      select trade_id,sum(item_actual_amount) item_actual_amount
        from ytdw.dwd_order_shop_d where dayid='$v_date' and is_deleted=0
      group by trade_id
    ) trade_shop_total on trade_shop_total.trade_id=order_shop.trade_id
    left join
    (
      select trade_no,sum(refund_actual_amount) refund_actual_amount from ytdw.ads_salary_base_offline_refund_d where dayid='$v_date' group by trade_no
    ) cur_month_offline_refund on cur_month_offline_refund.trade_no=trade_shop.trade_no
    left join
    (
      select trade_no,sum(refund_actual_amount) refund_actual_amount from ytdw.ads_salary_base_offline_refund_d where dayid='$v_pre_month_last_day' group by trade_no
    ) last_month_offline_refun on last_month_offline_refun.trade_no=trade_shop.trade_no
  ) offline_refund on offline_refund.order_id=order.order_id
  --where
  --pay_time is not null
  ----and sp_id is null
  --and bu_id=0
  ----排除员工店
  --and store_type not in (9,10)
  ----卡券票、试用装、测试等类目
  --and business_unit not in ('卡券票','其他')
  --and item_style=1
  group by shop_id
) shop_order on shop_order.shop_id=shop_base.shop_id

left join
(
  select * from ytdw.ads_salary_base_pro_mark_line_d where dayid='$v_pre_month_last_day'
) last_month_pro_mark_line on last_month_pro_mark_line.shop_pro_id=shop_base.shop_pro_id

left join
(
  select * from ytdw.ads_salary_base_pro_mark_line_d where dayid='$v_date'
) cur_month_pro_mark_line on cur_month_pro_mark_line.shop_pro_id=shop_base.shop_pro_id

--门店订单信息
--门店类型
left join
(
  select
    shop_id,
    --最近a+小b时间
    max(case when item_style=0 then pay_day else null end) as a_or_small_b_max_date,
    --最近大b时间
    max(case when item_style=1 and sp_id is null then pay_day else null end) as max_big_b_date,  --20201016 剔除服务商
    sum(case when item_style=1 and pay_day ='$v_date' then total_pay_amount else 0 end)-
    sum(case when item_style=1 then cur_day_refund_actual_amount else 0 end) as today_b_gmv,
    sum(case when item_style=1 and sp_id is null and pay_day ='$v_date' then total_pay_amount else 0 end)-
    sum(case when item_style=1 and sp_id is null then cur_day_refund_actual_amount  else 0 end) as today_exclude_sp_b_gmv,--今日B类净gmv 不包含服务商
	  sum(case when item_style=1 and sp_id is null and substr(pay_time,1,6)='$v_pre_month' then total_pay_amount else 0 end)-
    sum(case when item_style=1 and sp_id is null then  pre_mnt_refund_actual_amount  else 0 end) as pre_month_exclude_sp_b_gmv,--上月B类净gmv 不包含服务商
	  sum(case when item_style=1 and sp_id is null and substr(pay_time,1,6)='$v_cur_month' then total_pay_amount else 0 end)-
    sum(case when item_style=1 and sp_id is null then  cur_mnt_refund_actual_amount  else 0 end) as cur_month_exclude_sp_b_gmv--本月B类净gmv 不包含服务商
	from order_tmp
  --from ytdw.dw_order_d where dayid='$v_date'
  --  and pay_time is not null
  --  --and sp_id is null
  --  and bu_id=0
  --  --排除员工店
  --  and store_type not in (9,10)
  --  --卡券票、试用装、测试等类目
  --  and business_unit not in ('卡券票','其他')
  group by shop_id
) shop_status on shop_status.shop_id=shop_base.shop_id

--月最多B日
left join
(
select
  shop_id,
  sum(case when pay_month='$v_pre_month' then pure_pay_amount else 0 end) as last_month_max_big_g_pure_amount,
  sum(case when pay_month='$v_cur_month' then pure_pay_amount else 0 end) as cur_month_max_big_g_pure_amount
from
  (
  select
  shop_id,
  pay_day,
  pay_month,
  pure_pay_amount,
  row_number() over(partition by shop_id,pay_month order by pure_pay_amount desc) rn
  from
    (
    select
    shop_id,
    substr(pay_time,1,8) pay_day,
    substr(pay_time,1,6) pay_month,
    sum(pay_amount)-nvl(sum(case when refund_status=9 then refund_actual_amount else 0 end),0) pure_pay_amount
	from order_tmp
	where item_style_freezed=1
	and substr(pay_time,1,6)>='$v_pre_month'
    --from ytdw.dw_order_d
    --where dayid='$v_date'
    --and pay_time is not null
    --and sp_id is null
    --and bu_id=0
    ----排除员工店
    --and store_type not in (9,10)
    --and business_unit not in ('卡券票','其他')
    --B
    --and item_style_freezed=1
    group by shop_id,substr(pay_time,1,8),substr(pay_time,1,6)
    ) tmp1
  ) tmp2 where rn=1
  --and pay_month>='$v_pre_month'
  group by shop_id
) shop_max_order on shop_max_order.shop_id=shop_base.shop_id

--
--门店top10
left join
(
select
  shop_id
from
  (
  select
   shop_id,
   bd_user_id,
   row_number() over(partition by bd_user_id order by b_pure_gmv_04 desc) rn
  from
    (
    select
     shop_id,
     coalesce(ytdw.get_service_info('service_feature_id:1',service_info,'service_user_id'),ytdw.get_service_info('service_feature_id:4',service_info,'service_user_id'),ytdw.get_service_info('service_feature_id:5',service_info,'service_user_id')) as bd_user_id,
     sum(case when substr(pay_time,1,6)='$v_pre_month' then total_pay_amount else 0 end)-
     --sum(case when substr(refund_end_time,1,6)='$v_pre_month' and refund_status=9 then refund_actual_amount else 0 end)
     nvl(sum(pre_mnt_refund_actual_amount),0)  as b_pure_gmv_04
	 --没有使用，考虑删除
     --sum(case when substr(pay_time,1,8)>='$v_first_day' and substr(pay_time,1,8)<='$v_date' then total_pay_amount else 0 end)-
     ----sum(case when substr(refund_end_time,1,8)>='$v_first_day' and  substr(refund_end_time,1,8)<='$v_date' and refund_status=9 then refund_actual_amount else 0 end)
     --sum(nvl(cur_mnt_refund_actual_amount,0))	 as b_pure_gmv_05
	 from order_tmp
	 where item_style=1
    --from ytdw.dw_order_d where dayid='$v_date'
    --and pay_time is not null
    ----and sp_id is null
    --and bu_id=0
    ----排除员工店
    --and store_type not in (9,10)
    ----卡券票、试用装、测试等类目
    --and business_unit not in ('卡券票','其他')
    --and item_style=1
    group by shop_id,
    coalesce(ytdw.get_service_info('service_feature_id:1',service_info,'service_user_id'),ytdw.get_service_info('service_feature_id:4',service_info,'service_user_id'),ytdw.get_service_info('service_feature_id:5',service_info,'service_user_id'))
    ) tmp
  ) tmp2 where rn<=10
) shop_top on shop_top.shop_id=shop_base.shop_id