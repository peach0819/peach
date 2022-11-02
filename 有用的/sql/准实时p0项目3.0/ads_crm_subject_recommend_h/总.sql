use ytdw;
CREATE TABLE if not exists ads_crm_subject_recommend_h (
  shop_id string comment '门店ID',
  shop_name string comment '门店名称',
  province_id bigint comment '省',
  city_id bigint comment '市',
  area_id bigint comment '区',
  address_id  bigint comment '街道',
  user_id string comment '所属销售id',
  dept_id bigint comment '销售所属叶子部门id（组）',
  parent_dept_id  bigint comment '销售所属叶子部门上级部门id（BD：省区）',
  parent_2_dept_id bigint comment '销售所属叶子部门上上级部门id（BD：战区）',
  subject_ids	string comment '项目id列表，逗号分隔',
  subject_count int comment '项目数量',
  subject_data string comment '项目数据，json格式',
  visit_frequency string comment '拜访频次',
  no_valid_visit int comment '项目期间有效拜访次数是否为0',
  no_invalid_visit int comment '项目期间无效拜访次数是否为0',
  last_visit_time string comment '最近有效拜访时间',
  last_request_time string comment '最近浏览时间',
  last_pay_time string comment '最近支付时间'
)
comment '项目门店推荐(回流)'
partitioned by (dayid string)
stored as orc;

insert overwrite table ads_crm_subject_recommend_h partition (dayid='$v_date')

select shop_subject.shop_id,
  shop_saler.shop_name,
  shop_saler.province_id,
  shop_saler.city_id,
  shop_saler.area_id,
  shop_saler.address_id,
  if(shop_saler.ts_user_id!='', shop_saler.ts_user_id, shop_saler.vs_user_id) as user_id,
  if(shop_saler.ts_dept_id!=0, shop_saler.ts_dept_id, shop_saler.vs_dept_id) as dept_id,
  if(shop_saler.ts_parent_dept_id!=0, shop_saler.ts_parent_dept_id, shop_saler.vs_parent_dept_id) as parent_dept_id,
  if(shop_saler.ts_parent_2_dept_id!=0, shop_saler.ts_parent_2_dept_id, shop_saler.vs_parent_2_dept_id) as parent_2_dept_id,
  subject_ids,
  subject_count,
  subject_data,
  shop_visit.visit_frequency,
  case when visit_times > 0 then 1 else 0 end as no_valid_visit,
  case when invalid_visit_times > 0 then 1 else 0 end as no_invalid_visit,
  shop_subject.last_visit_time as last_visit_time,
  shop_visit.last_visit_time as last_request_time,
  shop_pay.pay_time as last_pay_time
from
(
  select subject_shop.shop_id,count(*) as subject_count,
    concat_ws(',',collect_set(cast(subject_shop.subject_id as string))) as subject_ids,
    concat('[',concat_ws(',',collect_set(
      concat('{\"subject_id\":',subject_shop.subject_id,
             ',\"subject_gmv\":',nvl(subject_gmv,0),
             ',\"this_month_gmv\":',nvl(this_month_gmv,0),
             ',\"last_1_month_gmv\":',nvl(last_1_month_gmv,0),
             ',\"last_2_month_gmv\":',nvl(last_2_month_gmv,0),
             ',\"valid_visit_times\":', nvl(visit_times,0),
             ',\"invalid_visit_times\":', nvl(invalid_visit_times,0),'}')
    )),']') as subject_data,
    sum(visit_times) as visit_times,
    sum(invalid_visit_times) as invalid_visit_times,
    max(last_visit_time) as last_visit_time
  from
  (
    select subject_id,shop_id
    from rtdw.ods_vf_t_p0_subject_shop
    where is_deleted=0
    and is_object_shop=1
  ) subject_shop

  -- 过滤不在执行时间内的项目
  join(
    select id
    from rtdw.ods_vf_t_p0_subject
    where is_deleted=0
      and status=1
      and feature_type=2
      and substr(do_start, 1, 10)<='$v_cur_day'
      and substr(do_end, 1, 10)>='$v_cur_day'
  ) subject
  on subject_shop.subject_id=subject.id
  left join (
    select subject_id, shop_id,
             subject_gmv,
             this_month_gmv,
             last_1_month_gmv,
             last_2_month_gmv,
             visit_times,
             invalid_visit_times,
             last_visit_time
    from nrt_p0_subject_ts_h
    where dayid='$v_date'
  ) subject_shop_gmv
  on subject_shop_gmv.subject_id=subject_shop.subject_id
    and subject_shop_gmv.shop_id=subject_shop.shop_id
  group by subject_shop.shop_id
) shop_subject
join (
  select shop_id,
         shop_name,
         province_id,
         city_id,
         area_id,
         address_id,
         get_json_object(user_id, '$.ts') as ts_user_id,
         get_json_object(dept_id, '$.ts') as ts_dept_id,
         get_json_object(parent_dept_id, '$.ts') as ts_parent_dept_id,
         get_json_object(parent_2_dept_id, '$.ts') as ts_parent_2_dept_id,
         get_json_object(user_id, '$.vs') as vs_user_id,
         get_json_object(dept_id, '$.vs') as vs_dept_id,
         get_json_object(parent_dept_id, '$.vs') as vs_parent_dept_id,
         get_json_object(parent_2_dept_id, '$.vs') as vs_parent_2_dept_id
  from ads_crm_shop_user_base_d
  where dayid='$v_date'
) shop_saler
on shop_subject.shop_id=shop_saler.shop_id
left join(
  select shop_id,visit_frequency,last_visit_time
  from nrt_ts_shop_visit
  where dayid='$v_date'
) shop_visit
on shop_subject.shop_id=shop_visit.shop_id
left join(
  select shop_id, max(pay_time) as pay_time
   from
  (
    select shop_id,item_id,order_id,pay_time
    FROM
      rtdw.ods_vf_pt_order_shop   --订单表
    where is_deleted=0
      and bu_id=0
  ) all_order
  join(
    select id
    from dwd_item_d
    where dayid='$v_date'
    and item_style=0
  ) item
  on all_order.item_id=item.id
  LEFT JOIN
  (
    select
      order_id,
      sp_id
    from
      rtdw.ods_vf_t_sp_order_snapshot
    where is_deleted=0
  ) sp_order
  on all_order.order_id=sp_order.order_id
  where sp_order.sp_id is null  -- 剔除服务商订单
  group by shop_id
) shop_pay
on shop_subject.shop_id=shop_pay.shop_id
