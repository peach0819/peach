use ytdw;
CREATE TABLE if not exists st_p0_subject_saler_ts_h(
  subject_id string COMMENT '项目id',
  user_id string  COMMENT '销售',
  user_real_name string COMMENT '销售名称',
  dept_id string COMMENT '所属组部门id',
  dept_name string COMMENT '所属组部门名称',
  area_dept_id string COMMENT '所属大区部门ID',
  subject_target string  COMMENT '项目目标',
  subject_gmv string  COMMENT '项目净GMV',
  subject_shop_count string  COMMENT '目标门店数',
  visit_shop_count string  COMMENT '有效拜访门店数',
  order_shop_count string  COMMENT '项目下单门店数',
  avg_call_length string  COMMENT '店均通话时长，秒',
	valid_visit_shop_count int comment '有效拜访门店数',
	visit_order_shop_count int comment '有效拜访下单门店数'
)
comment 'p0电销人员gmv数据看板表'
partitioned by (dayid string)
stored as orc;

with shop_saler as (
    select shop_id,
           get_json_object(user_id, '$.ts') as user_id,
           get_json_object(dept_id, '$.ts') as dept_id,
           get_json_object(parent_dept_id, '$.ts') as parent_dept_id,
           get_json_object(parent_2_dept_id, '$.ts') as parent_2_dept_id
    from ads_crm_shop_user_base_d
    where dayid='$v_date'
    AND get_json_object(user_id, '$.ts') != ''
)

insert overwrite table st_p0_subject_saler_ts_h partition (dayid='$v_date')
select subject_shop_count.subject_id,
  subject_shop_count.user_id,
  user_real_name,
  nvl(dept_id,0) as dept_id,
  nvl(dept.name,'') as dept_name,
  nvl(area_dept_id,0) as area_dept_id,
  nvl(subject_target,0) as subject_target,
  nvl(subject_gmv,0) as subject_gmv,
  nvl(subject_shop_count.shop_count,0) as subject_shop_count,
  nvl(visit_shop_count,0) as visit_shop_count,
  nvl(order_shop_count,0) as order_shop_count,
  nvl(avg_call_length,0) as avg_call_length,
  nvl(valid_visit_shop_count,0) as valid_visit_shop_count,
  nvl(visit_order_shop_count,0) as visit_order_shop_count
from
(
  select subject_shop.subject_id,shop_saler.user_id,dept_id,parent_dept_id as area_dept_id,
  sum(case when is_object_shop=1 then 1 else 0 end) as shop_count
  from
  (
    select id
    from rtdw.ods_vf_t_p0_subject
    where is_deleted=0
    and status=1
    and feature_type=2
  ) subject
  join(
    select subject_id,shop_id,is_object_shop
    from rtdw.ods_vf_t_p0_subject_shop
    where is_deleted=0
  ) subject_shop on subject.id=subject_shop.subject_id
  join shop_saler on shop_saler.shop_id=subject_shop.shop_id
  group by subject_shop.subject_id, shop_saler.user_id,dept_id,parent_dept_id
) subject_shop_count
join(
  select user_id, user_real_name
  from dwd_user_d
  where dayid='$v_date'
) user
on user.user_id = subject_shop_count.user_id
left join(
  select id,name
  from dwd_department_d
  where dayid='$v_date'
) dept
on dept.id=subject_shop_count.dept_id
left join (
  select subject_id,
    user_id,
    0 as subject_target,
    sum(subject_gmv) as subject_gmv,
    sum(case when visit_times>0 or invalid_visit_times>0 then 1 else 0 end) as visit_shop_count,
    sum(case when subject_gmv>0 then 1 else 0 end) as order_shop_count,
    sum(call_length) / count(*) as avg_call_length,
    sum(case when visit_times>0 then 1 else 0 end) as valid_visit_shop_count,
    sum(case when subject_gmv>0 and visit_times>0 then 1 else 0 end) as visit_order_shop_count
  from (
    select subject_id, user_id, subject_gmv, visit_times, call_length,invalid_visit_times
    from(
      select subject_id, shop_id, subject_gmv, visit_times, call_length,invalid_visit_times
      from nrt_p0_subject_ts_h
      where dayid='$v_date'
    ) subject_ts_gmv
    join shop_saler on shop_saler.shop_id=subject_ts_gmv.shop_id
  ) subject_saler_gmv
  group by subject_id,user_id
) subject_saler
on subject_shop_count.user_id=subject_saler.user_id and subject_shop_count.subject_id=subject_saler.subject_id



