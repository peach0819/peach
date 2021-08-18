create table if not exists ytdw.dw_salary_scene_summary_d (
  is_split string comment '是否拆分',
  service_feature_name string comment '服务人员职能名称',
  service_feature_names string comment '服务人员职能名称集合',
  coefficient_logical string comment '系数逻辑',
  commission_logical string comment '提成逻辑',
  service_count int comment '销售人数',
  gmv decimal(18,2) comment '库内GMV总和',
  gmv_freezed decimal(18,2) comment '冻结GMV总和',
  update_time string comment '更新时间'
)
comment '销售汇总数据'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc
location '/dw/ytdw/dw/dw_salary_scene_summary_d';

insert overwrite table ytdw.dw_salary_scene_summary_d partition(dayid='$v_date')
select
  is_split,
  service_feature_name,
  service_feature_names,
  coefficient_logical,
  commission_logical,
  count(distinct service_user_id),
  sum(gmv),
  sum(gmv_freezed),
  from_unixtime(unix_timestamp()) as update_time
from
(
select
  salary_user.is_split,
  ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_feature_name') as service_feature_name,
  concat_ws(',',ytdw.get_service_info('service_type:销售',order.service_info,'service_feature_name'),ytdw.get_service_info('service_type:电销',order.service_info,'service_feature_name')) as service_feature_names,
  salary_logical_scene.coefficient_logical,
  salary_logical_scene.commission_logical,
  ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_id') as service_user_id,
  --库内当月GMV
  sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) as gmv,
  --冻结当月GMV
  0 as gmv_freezed
  from
  (
    select
      *
    from ytdw.dw_order_d
    lateral view explode(split(regexp_replace(ytdw.get_service_info('service_type:销售',service_info),'\},','\}\;'),'\;')) tmp as bd_service_info
    where dayid='$v_date'
    and substr(pay_time,1,8)<='$v_date'
    and bu_id=0
    --剔除服务商
    --and sp_id is null
    --剔除 业务域等 卡券票和其他
    and business_unit not in ('卡券票','其他')
    --剔除员工店，二批商
    and store_type not in (9,10)
  ) order
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
    ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_feature_name'),
    concat_ws(',',ytdw.get_service_info('service_type:销售',order.service_info,'service_feature_name'),ytdw.get_service_info('service_type:电销',order.service_info,'service_feature_name')),
    salary_user.is_split,
    salary_logical_scene.coefficient_logical,
    salary_logical_scene.commission_logical

union all

select
  salary_user.is_split,
  ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_feature_name') as service_feature_name,
  concat_ws(',',ytdw.get_service_info('service_type:销售',order.service_info_freezed,'service_feature_name'),ytdw.get_service_info('service_type:电销',order.service_info_freezed,'service_feature_name')) as service_feature_names,
  salary_logical_scene.coefficient_logical,
  salary_logical_scene.commission_logical,
  ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_user_id') as service_user_id,
  --库内当月GMV
  0 as gmv,
  --冻结当月GMV
  sum(case when substr(order.pay_time,1,6)='$v_cur_month' then order.total_pay_amount else 0 end) as gmv_freezed
  from
  (
    select
      *
    from ytdw.dw_order_d
    lateral view explode(split(regexp_replace(ytdw.get_service_info('service_type:销售',service_info_freezed),'\},','\}\;'),'\;')) tmp as bd_service_info
    where dayid='$v_date'
    and substr(pay_time,1,8)<='$v_date'
    and bu_id=0
    --剔除服务商
    --and sp_id is null
    --剔除 业务域等 卡券票和其他
    and business_unit not in ('卡券票','其他')
    --剔除员工店，二批商
    and store_type not in (9,10)
  ) order
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
    ytdw.get_service_info('service_type:销售',order.bd_service_info,'service_feature_name'),
    concat_ws(',',ytdw.get_service_info('service_type:销售',order.service_info_freezed,'service_feature_name'),ytdw.get_service_info('service_type:电销',order.service_info_freezed,'service_feature_name')),
    salary_user.is_split,
    salary_logical_scene.coefficient_logical,
    salary_logical_scene.commission_logical
) table
group by
  is_split,
  service_feature_name,
  service_feature_names,
  coefficient_logical,
  commission_logical