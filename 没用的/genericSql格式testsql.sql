create table if not exists ytdw.dw_salary_shop_data_d (
                                                          shop_id string comment '门店id',
                                                          shop_name string comment '门店名称',
                                                          shop_pro_name string comment '门店省',
                                                          shop_city_name string comment '门店市',
                                                          shop_area_name string comment '门店区',
                                                          service_user_id string comment 'B有效新开销售id',
                                                          service_user_name string comment 'B有效新开销售名',
                                                          service_department_name string comment 'B有效新开销售组',
                                                          min_pay_month string comment '门店B首次下单月份',
                                                          min_pay_day string comment '门店B首次下单日期',
                                                          new_sign_pay_day string comment '门店B有效新开日期',
                                                          new_sign_pure_pay_amount string comment '门店有效新开当日支付金额-订单退款',
                                                          new_sign_pay_amount string comment '门店有效新开当日支付金额',
                                                          new_sign_refund_actual_amount string comment '门店新开当日订单退款金额',
                                                          service_info_freezed string comment '冻结服务人员信息',
                                                          store_type_name string comment '门店类型',
                                                          approve_status_name string comment '门店质审核状态',
                                                          update_time string comment '更新时间'
)
    comment '销售薪资门店数据'
    partitioned by (dayid string)
    stored as orc;



insert overwrite table ytdw.dw_salary_shop_data_d partition(dayid='$v_date')
select
    table1.shop_id,
    table1.shop_name,
    table1.shop_pro_name,
    table1.shop_city_name,
    table1.shop_area_name,
    table2.service_user_id,
    table2.service_user_name,
    table2.service_department_name,
    substr(table3.min_pay_day,1,6) as min_pay_month,
    table3.min_pay_day,
    table2.pay_day,
    table2.pure_pay_amount,
    table2.pay_amount,
    table2.refund_actual_amount,
    table2.service_info_freezed,
    table1.store_type_name,
    table1.approve_status_name,
    from_unixtime(unix_timestamp()) as update_time
from


---有效新开数据

(
    select
        shop_id,
        service_user_id,
        service_user_name,
        service_department_name,
        service_info_freezed,
        pay_day,
        pay_amount,
        refund_actual_amount,
        pure_pay_amount
    from
        (
            select
                shop_id,
                service_user_id,
                service_user_name,
                service_department_name,
                service_info_freezed,
                pay_day,
                pay_amount,
                refund_actual_amount,
                pure_pay_amount,
                row_number() over(partition by shop_id order by pay_day,pure_pay_amount desc) rn
            from
                (
                    select
                        shop_id,
                        shop_pro_id,
                        coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_id')) as service_user_id,
                        coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_name')) as service_user_name,
                        coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_department_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_department_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_department_name')) as service_department_name,
                        service_info_freezed,
                        substr(pay_time,1,8) as pay_day,
                        sum(pay_amount) as pay_amount,
                        sum(case when afs_refund.refund_status=9 then afs_refund.refund_actual_amount else 0 end) as refund_actual_amount,
                        sum(pay_amount)-nvl(sum(case when afs_refund.refund_status=9 then afs_refund.refund_actual_amount else 0 end),0) as pure_pay_amount

                    from (
                             select order_id,shop_id,shop_pro_id,service_info_freezed,pay_time,pay_amount
                             from ytdw.dw_order_d
                             where dayid='$v_date'
                               and pay_time is not null
                               and bu_id=0
                               and sp_id is null
                               --排除员工店、伙伴店11 20200505
                               and nvl(store_type,100) not in (3,9,10,11)
                               and business_unit not in ('卡券票','其他')
                               --B类
                               and item_style_freezed=1
                               and sale_dc_id=-1) order
                        left join (
	 --20200728
	   select order_id
             ,refund_status
             ,sum(refund_actual_amount) as refund_actual_amount --实际退款金额

             from dw_afs_order_refund_new_d
             where dayid='$v_date'
             and refund_status=9
             group by order_id,refund_status
	 ) afs_refund on order.order_id = afs_refund.order_id
                    group by shop_id,shop_pro_id,
                        coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_id')),
                        coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_name')),
                        coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_department_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_department_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_department_name')),
                        service_info_freezed,
                        substr(pay_time,1,8)
                ) tmp1
                    --省份达标线
                    left join
                (
                    select * from ytdw.ads_salary_base_pro_mark_line_d where dayid='$v_date'
                ) pro_mark_line on pro_mark_line.shop_pro_id=tmp1.shop_pro_id
            where pure_pay_amount>=pro_mark_line.new_sign_shop_mark_line
        ) tmp2 where rn=1
                 and substr(tmp2.pay_day,1,6)='$v_cur_month' --20200728
) table2
    inner join (--20200505
    select shop_id,
           shop_name,
           shop_pro_name,
           shop_city_name,
           shop_area_name,
           store_type_name,
           approve_status_name
    from ytdw.dw_shop_base_d where dayid='$v_date' and bu_id=0 and nvl(store_type,100) not in (3,9,10,11) and shop_status in (1,2,3,4,5)
) table1 on table2.shop_id=table1.shop_id
--首次下b
    left join
(
    select
        shop_id,
        min(substr(pay_time,1,8)) min_pay_day
    from ytdw.dw_order_d
    where dayid='$v_date'
      and pay_time is not null
      and bu_id=0
      and sp_id is null
      --排除员工店、伙伴店11 20200505
      and nvl(store_type,100) not in (3,9,10,11)
      and business_unit not in ('卡券票','其他')
      --B类
      and item_style_freezed=1
      and sale_dc_id=-1
    group by shop_id
) table3 on table3.shop_id=table1.shop_id
where substr(table3.min_pay_day,1,6)='$v_cur_month'
