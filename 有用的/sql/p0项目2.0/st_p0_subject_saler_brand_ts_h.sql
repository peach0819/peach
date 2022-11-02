use ytdw;
CREATE TABLE if not exists st_p0_subject_saler_brand_ts_h (
  subject_id bigint COMMENT '项目id',
  user_id string COMMENT '销售id',
  user_real_name string COMMENT '销售名称',
  brand_id bigint COMMENT '品牌id',
  brand_name string COMMENT '品牌名称',
  dept_id bigint COMMENT '所属组部门id',
  dept_name string  COMMENT '所属组部门名称',
  area_dept_id bigint COMMENT '所属大区部门ID',
  subject_gmv string COMMENT '项目净GMV',
  pay_shop_count int COMMENT '项目期间支付门店数',
  last_month_pay_shop_count int COMMENT '上月支付门店数'
)   comment 'p0项目品牌维度数据表'
partitioned by (dayid string)
stored as orc;
insert overwrite table ytdw.st_p0_subject_saler_brand_ts_h  partition (dayid='$v_date')


select subject_id,
  user_id,
  user_real_name,
  brand.brand_id as brand_id,
  brand.brand_name as brand_name,
  dept_id,
  dept_name,
  online_sale_parent_dept_id as area_dept_id,
  subject_gmv,
  pay_shop_count,
  last_month_pay_shop_count
from
(
  select subject_id,online_sale_user_id, online_sale_dept_id, online_sale_parent_dept_id,online_sale_parent_2_dept_id,
  brand_id, sum(subject_gmv) as subject_gmv, sum(case when subject_gmv > 0 then 1 else 0 end) pay_shop_count,
  sum(case when last_month_gmv > 0 then 1 else 0 end) last_month_pay_shop_count
  from
  (
    select subject_id,shop_id,brand_id,subject_gmv,last_month_gmv
    from ads_crm_subject_shop_brand_data_h
    where dayid='$v_date'
  ) shop_brand_gmv
  join(
      select shop_id,
         get_json_object(user_id, '$.ts') as online_sale_user_id,
         get_json_object(dept_id, '$.ts') as online_sale_dept_id,
         get_json_object(parent_dept_id, '$.ts') as online_sale_parent_dept_id,
         get_json_object(parent_2_dept_id, '$.ts') as online_sale_parent_2_dept_id
    from ads_crm_shop_user_base_d
    where dayid='$v_date'
    AND get_json_object(user_id, '$.ts') != ''
  ) shop_user
  on shop_brand_gmv.shop_id=shop_user.shop_id
  group by subject_id,online_sale_user_id, online_sale_dept_id, online_sale_parent_dept_id,online_sale_parent_2_dept_id,brand_id
) subject_saler_brand_gmv
join(
  select user_id, user_real_name, dept_id, dept_name
  from dim_usr_user_d
  where dayid='$v_date' and is_internal_user=1
) user
on subject_saler_brand_gmv.online_sale_user_id=user.user_id
join(
  select *
  from dim_ytj_itm_brand_d
  where dayid='$v_date'
) brand
on brand.brand_id=subject_saler_brand_gmv.brand_id
where pay_shop_count > 0 or last_month_pay_shop_count > 0