create table if not exists st_eps_class_a_capacity_d
(
  user_id string comment '销售ID',
  indicator string comment '指标名称配置在TableView中',
  achievement decimal(18,2) comment '完成数值 单位/元'
)
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc
location '/dw/ytdw/st/st_eps_class_a_capacity_d';


with dw_order_tmp as (
  select a.shop_id
  ,a.order_id
  ,a.order_pay_time as pay_time
  ,a.order_total_amt as total_pay_amount
  ,a.category_1st_id as category_id_first
  ,a.business_unit
  ,a.bu_id
  ,a.item_style
  --,b.refund_end_time
  --,b.refund_status
  --,b.refund_actual_amount as refund_actual_amount
  ,a.dayid
  ,c.service_info
  ,a.sp_id
  ,a.shop_store_type as store_type
  from
    (select * from dw_trd_order_d
    where dayid='$v_date'
    and diz_type like '%old%'
    ) a
  left join
    (select * from dw_shop_pool_server_d where dayid = '$v_date') c
    on a.shop_id = c.shop_id

)
insert overwrite table st_eps_class_a_capacity_d partition (dayid='$v_date')

select
   ord.user_id,
  'class_a_capacity' as indicator,
  --库内净GMV
  sum(case when substr(ord.pay_time,1,6) = '$v_cur_month' then ord.total_pay_amount else 0 end) -
  sum(nvl(refund.refund_amt,0)) -
  nvl(sum(offline_refund.refund_actual_amount),0) as achievement
from
  (
        select
         ytdw.get_service_info('service_feature_name:EPS',  bd_service_info, 'service_user_id') as user_id,
         order_id,
          pay_time,
          total_pay_amount
        from dw_order_tmp
        lateral view explode(split(regexp_replace(ytdw.get_service_info('service_feature_name:EPS', service_info),'\},','\}\;'),'\;')) tmp as bd_service_info
        where dayid = '$v_date'
        and substr(pay_time,1,8) <= '$v_date'
        -- 海拍客业务
        and bu_id = 0
        --剔除服务商
        and sp_id is null
        --剔除 业务域等 卡券票和其他
        and business_unit not in ('卡券票','其他')
        --剔除员工店，二批商
        and store_type not in (9)
        -- 电销A类
        and item_style = 0
        and ytdw.get_service_info('service_feature_name:EPS', bd_service_info, 'service_user_id') is not null
) ord
      --线下退款(当月)
left join
      (
        select
          order_id,
          refund_actual_amount
        from ads_salary_base_offline_refund_order_d
        where dayid = '$v_date'

      ) offline_refund on offline_refund.order_id = ord.order_id
left join
  (select order_id
   ,sum(refund_actual_amount) as refund_amt
    from dw_afs_order_refund_new_d
    where dayid='$v_date'
    and multiple_refund=0
    and refund_status=9
    and substr(refund_end_time,1,6) = '$v_cur_month'
    group by order_id
    ) refund
  on ord.order_id=refund.order_id
      group by  ord.user_id



