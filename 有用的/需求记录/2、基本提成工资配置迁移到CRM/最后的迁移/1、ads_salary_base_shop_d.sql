use ytdw;
create table if not exists ads_salary_base_shop_d (
  shop_id string comment '门店id',
  shop_name string comment '门店名称',
  shop_pro_name string comment '门店省',
  shop_city_name string comment '门店市',
  shop_area_name string comment '门店区',
  shop_pay_status string comment '门店下单状态',
  is_cur_month_new_sign string comment '是否本月B有效门店',

  new_sign_pure_pay_amount decimal(11,2) comment '新开日冻结B净支付金额(计算新开专用)',
  new_sign_pay_day string comment 'B有效新开日期',
  new_sign_service_user_id string comment 'B有效新开人userId',
  new_sign_service_user_name string comment 'B有效新开人',
  min_big_b_pay_day string comment '首次下单B日期',
  max_big_b_date string comment '最近支付B日期',
  cur_month_max_big_g_pure_amount decimal(18,2) comment '本月最大日净支付金额',
  last_month_max_big_g_pure_amount decimal(18,2) comment '上月最大日净支付金额',
  is_bd_top10 string comment '是否销售top10门店',
  cur_month_reach_goal int comment '本月门店B达标线',
  cur_month_big_b_pure_gmv decimal(18,2) comment '本月B净GMV（包含线下退款）',
  cur_month_is_reach string comment '本月是否达标（包含线下退款）',
  cur_month_balance decimal(11,2) comment '本月达标差距',
  last_month_reach_goal int comment '上月达标线',
  last_month_big_b_pure_gmv decimal(18,2) comment '上月B净GMV（包含线下退款）',
  last_month_is_reach string comment '上月是否达标（包含线下退款）',

  cur_month_b_level string comment '本月月B类门店坎级',
  last_month_b_level string comment '上月B类门店坎级',
  cur_month_b_category_count string comment '本月B类下单类目数',
  last_month_b_category_count string comment '上月B类下单类目数',
  cur_month_a_pure_gmv decimal(18,2) comment '本月A类净GMV',
  last_month_a_pure_gmv decimal(18,2) comment '上月A类净GMV',
  cur_month_a_level string comment '本月A类门店坎级',
  last_month_a_level string comment '上月A类门店坎级',

  max_valid_visit_time string comment '历史最近有效拜访时间',
  cur_month_valid_visit_time decimal(11,2) comment '本月有效拜访在店时长',
  cur_month_valid_visit_count string comment '本月有效拜访次数',

  bd_feature_names string comment '门店库内销售职能',
  bd_user_ids string comment '门店库内销售人员id',
  bd_user_names string comment '门店库内销售人员',
  bd_department_ids string comment '门店库内销售人员组id',
  bd_department_names string comment '门店库内销售人员组',
  op_feature_names string comment '门店库内电销职能',
  op_user_ids string comment '门店库内电销人员id',
  op_user_names string comment '门店库内电销人员',
  op_department_ids string comment '门店库内电销人员组id',
  op_department_names string comment '门店库内电销人员组',
  store_type_name string comment '门店类型',
  approve_status_name string comment '门店认证状态',
  not_new_sign_reason string comment '非B有效新开原因',
  shop_pro_id int comment '门店省id',
  shop_city_id int comment '门店市id',
  shop_area_id int comment '门店区id',
  update_time string comment '更新时间',
  max_last_b_date string  comment '本月之前的最近冻结B类下单日期',
	all_beforel_ast_month_b_gmv decimal(18,2) comment '本月之前的历史冻结B类净GMV(含线下退款)',
	is_silent string comment '静默/无效门店',
	is_silent_type string comment '静默无效激活状态',
	cur_month_min_b_pay_day string comment '静默无效激活日期',
	is_silent_service_user_id string comment '静默无效激活人user_id',
	is_silent_service_user_name string  comment '静默无效激活人',
	is_brand_shop string comment '可否多品进店',
	is_brand_shop_type string comment '多品进店状态',
	brand_name string comment '多品进店品牌',
	is_brand_pay_day string comment '多品进店日期',
	is_brand_service_user_id string comment '多品进店激活人',
	is_brand_service_user_name  string comment '多品进店激活人名',
	area_manager_dep_name  string comment '大区名',
	bd_manager_dep_name  string comment '主管区域名',
	shop_address_name  string comment '门店街道名',
	is_shop_status string comment '是否冻结',
	today_b_gmv decimal(18,2) comment '今日B类净GMV(库内,包含服务商)',
	today_exclude_sp_b_gmv decimal(18,2) COMMENT '今日B类净GMV(剔除服务商)',
  pre_month_exclude_sp_b_gmv decimal(18,2) COMMENT '上月B类净GMV(剔除服务商)',
  cur_month_exclude_sp_b_gmv decimal(18,2) COMMENT '本月B类净GMV(剔除服务商)'
)
comment '门店主题域集市表'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;

--  门店基础信息
with  shop_base as (
                      select
                        shop_id,
                        shop_name,
                        shop_pro_name,
                        shop_city_name,
                        shop_area_name,
                        service_info,
                        store_type_name,
                        approve_status_name,
                        shop_pro_id,
                        shop_city_id,
                        shop_area_id,
                        area_manager_dep_name,
                        bd_manager_dep_name,
                        shop_address_name,
                        shop_status
                      from dw_shop_base_d
                      where dayid='$v_date' and shop_status in (1,2,3,4,5) and bu_id=0 and nvl(store_type,100) not in (3,9,10,11)),
-- 订单基础信息
      order_base as (
                      select
                        order.order_id,
                        order.shop_id,
                        order.shop_pro_id,
                        order.service_info_freezed,
                        order.pay_time,
                        order.pay_amount,
                        order.brand_name,
                        order.pay_day,
                        order.total_pay_amount,
                        order.pay_month,
                        order.item_style,
                        order.sp_id,
                        order.item_style_freezed,
                        order.service_info,
                        order.store_type,
                        nvl(afs_refund.last_mnt_before_refund_actual_amount,0) as last_mnt_before_refund_actual_amount,
                        nvl(afs_refund.pre_mnt_refund_actual_amount,0) as pre_mnt_refund_actual_amount,
                        nvl(afs_refund.cur_mnt_refund_actual_amount,0) as cur_mnt_refund_actual_amount,
                        nvl(afs_refund.refund_actual_amount,0) as refund_actual_amount,
                        nvl(afs_refund.cur_day_refund_actual_amount,0) as cur_day_refund_actual_amount
                      from
                      (
                        select
                          order_id,
                          shop_id,
                          shop_pro_id,
                          service_info_freezed,
                          pay_time,
                          pay_amount,
                          brand_name,
                          substr(pay_time,1,8) as pay_day,
                          total_pay_amount,
                          substr(pay_time,1,6) as pay_month,
                          item_style,
                          sp_id,
                          item_style_freezed,
                          service_info,
                          store_type
                        from dw_order_d
                        where dayid='$v_date'
                              and pay_time is not null
                              and bu_id=0
                              and business_unit not in ('卡券票','其他')
                              -- 剔除贝莱订单
                              and sale_dc_id=-1
                      ) order
                      left join
                      (
                        select
                          order_id,
                          sum(case when substr(refund_end_time,1,8)='$v_date' then refund_actual_amount else 0 end) as cur_day_refund_actual_amount,
                          sum(case when substr(refund_end_time,1,6)='$v_pre_month' then refund_actual_amount else 0 end) as pre_mnt_refund_actual_amount,
                          sum(case when substr(refund_end_time,1,6)='$v_cur_month' then refund_actual_amount else 0 end) as cur_mnt_refund_actual_amount,
                          --实际退款金额
                          sum(refund_actual_amount) as refund_actual_amount,
                          sum(case when substr(refund_end_time,1,6)<'$v_cur_month' then refund_actual_amount else 0 end) as last_mnt_before_refund_actual_amount
                        from dw_afs_order_refund_new_d
                        where dayid='$v_date' and refund_status=9
                        group by order_id
                      ) afs_refund on order.order_id = afs_refund.order_id)

insert overwrite table ads_salary_base_shop_d partition(dayid='$v_date')
select
  shop_base.shop_id,
  shop_base.shop_name,
  shop_base.shop_pro_name,
  shop_base.shop_city_name,
  shop_base.shop_area_name,
  shop_order.shop_pay_status,
  case when shop_new_sign.approve_status_name in ('审核成功','审核成功（无资质）','真实性认证成功') then '有效新开' else '否' end as is_cur_month_new_sign,
  nvl(shop_new_sign.pure_pay_amount,0),
  shop_new_sign.pay_day,
  shop_new_sign.service_user_id,
  shop_new_sign.service_user_name,
  shop_big_b_min_day.min_pay_day,

  shop_order.max_big_b_date,
  nvl(shop_order.cur_month_max_big_g_pure_amount,0),
  nvl(shop_order.last_month_max_big_g_pure_amount,0),
  shop_order.is_bd_top10,
  shop_order.cur_month_reach_goal,
  nvl(shop_order.cur_month_big_b_pure_gmv,0),
  shop_order.cur_month_is_reach,
  case when shop_order.cur_month_balance>=0 then '' else shop_order.cur_month_balance end as cur_month_balance,
  shop_order.last_month_reach_goal,
  nvl(shop_order.last_month_big_b_pure_gmv,0),
  shop_order.last_month_is_reach,

  shop_level.cur_b_level,
  shop_level.last_b_level,
  shop_level.b_real_num,
  shop_level.b_last_num,
  nvl(shop_level.a_cur_true_gmv,0),
  nvl(shop_level.a_last_true_gmv,0),
  shop_level.cur_a_level,
  shop_level.last_a_level,

  shop_visit_history.max_valid_visit_time,
  shop_visit.cur_month_valid_visit_time,
  shop_visit.cur_month_valid_visit_count,

  ytdw.get_service_info('service_type:销售',shop_base.service_info,'service_feature_name'),
  ytdw.get_service_info('service_type:销售',shop_base.service_info,'service_user_id'),
  ytdw.get_service_info('service_type:销售',shop_base.service_info,'service_user_name'),
  ytdw.get_service_info('service_type:销售',shop_base.service_info,'service_department_id'),
  ytdw.get_service_info('service_type:销售',shop_base.service_info,'service_department_name'),
  ytdw.get_service_info('service_type:电销',shop_base.service_info,'service_feature_name'),
  ytdw.get_service_info('service_type:电销',shop_base.service_info,'service_user_id'),
  ytdw.get_service_info('service_type:电销',shop_base.service_info,'service_user_name'),
  ytdw.get_service_info('service_type:电销',shop_base.service_info,'service_department_id'),
  ytdw.get_service_info('service_type:电销',shop_base.service_info,'service_department_name'),
  shop_base.store_type_name,
  shop_base.approve_status_name,
  case
    when shop_new_sign.shop_id is not null and shop_new_sign.approve_status_name in ('审核成功','审核成功（无资质）','真实性认证成功') then ''
    when shop_new_sign.shop_id is not null and shop_new_sign.approve_status_name not in ('审核成功','审核成功（无资质）','真实性认证成功') then '门店审核未通过'
    when shop_new_sign.shop_id is null and substr(shop_big_b_min_day.min_pay_day,1,6)<'$v_cur_month' then concat('历史下过B类')
    when shop_new_sign.shop_id is null and shop_big_b_min_day.shop_id is null then '未下过B类'
    when shop_new_sign.shop_id is null and substr(shop_big_b_min_day.min_pay_day,1,6)='$v_cur_month'
    then '金额未满足要求'
  else '未知原因' end as not_new_sign_reason,
  shop_base.shop_pro_id,
  shop_base.shop_city_id,
  shop_base.shop_area_id,
  from_unixtime(unix_timestamp()) as update_time,
  shop_silent.max_last_b_date,
  shop_silent.all_before_last_month_b_gmv,
  shop_silent.is_silent,
  shop_silent.is_silent_type,
  shop_silent.cur_month_min_b_pay_day,
  shop_silent.service_user_id as is_silent_service_user_id,
  shop_silent.service_user_name as is_silent_service_user_name,
  shop_silent.is_brand_shop,
  shop_silent.is_brand_shop_type,
  shop_silent.brand_name,
  shop_silent.is_brand_pay_day,
  shop_silent.is_brand_service_user_id,
  shop_silent.is_brand_service_user_name,
  shop_base.area_manager_dep_name,
  shop_base.bd_manager_dep_name,
  shop_base.shop_address_name,
  case when shop_base.shop_status=5 then '是' else '否' end as is_shop_status,
  shop_order.today_b_gmv,
  shop_order.today_exclude_sp_b_gmv,
  shop_order.pre_month_exclude_sp_b_gmv,
  shop_order.cur_month_exclude_sp_b_gmv
from shop_base

--门店有效新开
left join
(
  select
    shop_base.shop_id,
    table2.service_user_id,
    table2.service_user_name,
    table2.pay_day,
    table2.pure_pay_amount,
    shop_base.approve_status_name
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
          sum(nvl(refund_actual_amount,0)) as refund_actual_amount,
          sum(pay_amount)-sum(nvl(refund_actual_amount,0)) as pure_pay_amount
        from order_base
        where sp_id is null
              --排除员工店、伙伴店11
              and nvl(store_type,100) not in (3,9,10,11)
              and item_style_freezed=1
        group by shop_id,shop_pro_id,
        coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_id')),
        coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_name')),
        coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_department_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_department_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_department_name')),
        service_info_freezed,
        substr(pay_time,1,8)
      ) tmp1
      --省份达标线
      left join
      (select shop_pro_id,new_sign_shop_mark_line from ads_salary_base_pro_mark_line_d where dayid='$v_date') pro_mark_line on pro_mark_line.shop_pro_id=tmp1.shop_pro_id
      where pure_pay_amount>=pro_mark_line.new_sign_shop_mark_line
    ) tmp2
    where rn=1 and substr(tmp2.pay_day,1,6)='$v_cur_month'
  ) table2
  inner join
  shop_base on table2.shop_id=shop_base.shop_id
  --首次下b
  left join
  (
    select
      shop_id,
      min(substr(pay_time,1,8)) min_pay_day
    from order_base
    where sp_id is null
          --排除员工店、伙伴店11
          and nvl(store_type,100) not in (3,9,10,11)
          and item_style_freezed=1
    group by shop_id
  ) table3 on table3.shop_id=shop_base.shop_id
  where substr(table3.min_pay_day,1,6)='$v_cur_month'
) shop_new_sign on shop_new_sign.shop_id=shop_base.shop_id

--门店订单信息
left join
(
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
      else '未下单门店'
    end as shop_pay_status,
    shop_max_order.last_month_max_big_g_pure_amount,
    shop_max_order.cur_month_max_big_g_pure_amount,
    case when shop_top.shop_id is not null then 'BDtop10门店' else '否' end as is_bd_top10,
    from_unixtime(unix_timestamp()) as update_time,
    shop_status.today_b_gmv,
    today_exclude_sp_b_gmv,
    pre_month_exclude_sp_b_gmv,
    cur_month_exclude_sp_b_gmv
  from shop_base
  --门店交易信息
  left join
  (
    select
      shop_id,
      sum(case when substr(pay_time,1,6)='$v_pre_month' then total_pay_amount else 0 end)
      -sum(pre_mnt_refund_actual_amount)
      -nvl(sum(nvl(offline_refund.last_month_refund_actual_amount,0)),0)
      as last_month_big_b_pure_gmv,
      sum(case when substr(pay_time,1,6)='$v_cur_month' then total_pay_amount else 0 end)
      -sum(cur_mnt_refund_actual_amount)
      -nvl(sum(nvl(offline_refund.cur_month_refund_actual_amount,0)),0)
      as cur_month_big_b_pure_gmv
    from
    (select * from order_base where store_type not in (9,10) and item_style=1) order
    --线下退款
    left join
    (
      select
        order_shop.order_id,
        cur_month_offline_refund.refund_actual_amount*(order_shop.item_actual_amount/trade_shop_total.item_actual_amount) cur_month_refund_actual_amount,
        last_month_offline_refun.refund_actual_amount*(order_shop.item_actual_amount/trade_shop_total.item_actual_amount) last_month_refund_actual_amount
      from
      (
        select * from dwd_order_shop_d where dayid='$v_date' and is_deleted=0
      ) order_shop
      left join
      (
        select * from dwd_trade_shop_d where dayid='$v_date' and is_deleted=0
      ) trade_shop on trade_shop.trade_id=order_shop.trade_id
      left join
      (
        select trade_id,sum(item_actual_amount) item_actual_amount
          from dwd_order_shop_d where dayid='$v_date' and is_deleted=0
        group by trade_id
      ) trade_shop_total on trade_shop_total.trade_id=order_shop.trade_id
      left join
      (
        select trade_no,sum(refund_actual_amount) refund_actual_amount from ads_salary_base_offline_refund_d where dayid='$v_date' group by trade_no
      ) cur_month_offline_refund on cur_month_offline_refund.trade_no=trade_shop.trade_no
      left join
      (
        select trade_no,sum(refund_actual_amount) refund_actual_amount from ads_salary_base_offline_refund_d where dayid='$v_pre_month_last_day' group by trade_no
      ) last_month_offline_refun on last_month_offline_refun.trade_no=trade_shop.trade_no
    ) offline_refund on offline_refund.order_id=order.order_id
    group by shop_id
  ) shop_order on shop_order.shop_id=shop_base.shop_id
  --上月省份达标线
  left join
  (
    select shop_pro_id,reach_shop_mark_line from ads_salary_base_pro_mark_line_d where dayid='$v_pre_month_last_day'
  ) last_month_pro_mark_line on last_month_pro_mark_line.shop_pro_id=shop_base.shop_pro_id
  --本月省份达标线
  left join
  (
    select shop_pro_id,reach_shop_mark_line from ads_salary_base_pro_mark_line_d where dayid='$v_date'
  ) cur_month_pro_mark_line on cur_month_pro_mark_line.shop_pro_id=shop_base.shop_pro_id
  --门店订单信息
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
  	from order_base
  	where store_type not in (9,10)
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
          sum(pay_amount)-sum(nvl(refund_actual_amount,0)) pure_pay_amount
      	from order_base
      	where store_type not in (9,10)
      	      and item_style_freezed=1
      	      and substr(pay_time,1,6)>='$v_pre_month'
        group by shop_id,substr(pay_time,1,8),substr(pay_time,1,6)
      ) tmp1
    ) tmp2 where rn=1
    group by shop_id
  ) shop_max_order on shop_max_order.shop_id=shop_base.shop_id
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
          nvl(sum(pre_mnt_refund_actual_amount),0)  as b_pure_gmv_04
    	  from order_base
    	  where store_type not in (9,10)
    	        and item_style=1
        group by
        shop_id,
        coalesce(ytdw.get_service_info('service_feature_id:1',service_info,'service_user_id'),ytdw.get_service_info('service_feature_id:4',service_info,'service_user_id'),ytdw.get_service_info('service_feature_id:5',service_info,'service_user_id'))
      ) tmp
    ) tmp2 where rn<=10
  ) shop_top on shop_top.shop_id=shop_base.shop_id
) shop_order on shop_order.shop_id=shop_base.shop_id

--门店砍级
left join
(
  select
    shop_id,
    cur_b_level,
    last_b_level,
    b_real_num,
    b_last_num,
    a_cur_true_gmv,
    a_last_true_gmv,
    cur_a_level,
    last_a_level
  from dw_shop_ab_level_d where dayid='$v_date'
) shop_level on shop_level.shop_id=shop_base.shop_id

--本月有效拜访情况
left join
(

  select shop_id,
    max(case when visit_mode=1 then from_unixtime(unix_timestamp(visit_start_time,'yyyyMMddHHmmss')) else null end) as max_valid_visit_time,
    count(case when visit_mode=1 then shop_id else null end) as cur_month_valid_visit_count,
    (sum(case when visit_mode=1 then visit_duration else 0 end))/3600 as cur_month_valid_visit_time  -- 本月有效拜访在店时长
  from dw_sel_bd_visit_record_d
  where  dayid = '$v_date' and substr(visit_start_time,1,6)='$v_cur_month'
 group by shop_id
) shop_visit on shop_visit.shop_id=shop_base.shop_id

--历史有效拜访
left join
(
  select
    shop_id,
    max(case when visit_mode=1 then from_unixtime(unix_timestamp(visit_time,'yyyyMMddHHmmss')) else null end) as max_valid_visit_time
  from dwd_crm_visit_history_d where dayid = '$v_date'
  group by shop_id
) shop_visit_history on shop_visit_history.shop_id=shop_base.shop_id

--首次下大b
left join
(
  select
    shop_id,
    min(substr(pay_time,1,8)) min_pay_day
  from order_base
  where sp_id is null
        --排除员工店、伙伴店11 20200505
        and nvl(store_type,100) not in (3,9,10,11)
        and item_style_freezed=1
  group by shop_id
) shop_big_b_min_day on shop_big_b_min_day.shop_id=shop_base.shop_id

-- 静默门店
left join
(
  select
    shop_silent.shop_id,
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
    select
      shop_id,
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
      select
        shop_order.shop_id,
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
          sum(case when substr(pay_time,1,6)<'$v_cur_month' then total_pay_amount else 0 end)
          -sum(nvl(last_mnt_before_refund_actual_amount,0))
          -sum(nvl(offline_refund.refund_actual_amount,0)) as all_beforel_ast_month_b_gmv
          --20200728 退款改造
    	  from
    	  (
          select
            *
          from order_base
          where pay_day<='$v_date'
                --服务商数据
                and sp_id is null
                --排除员工店
                and store_type not in (9,10)
                and item_style_freezed=1
    	  ) order
          --线下退款(排除当月订单)
        left join
        (
    		  select
    		    order_id,refund_actual_amount
    	    from ads_salary_base_offline_refund_order_d
    		  where (dayid='$v_date' or dayid='20190831' or dayid='20190731' or dayid='20190630' or dayid='20190531' or dayid='20190430')
    		        and substr(dayid,1,6) <'$v_cur_month'
        ) offline_refund on offline_refund.order_id=order.order_id
    	  group by order.shop_id
      ) shop_order
  	  --门店激活信息判断
  	  left join
  	  (
    	  select
          shop_id,pay_day as cur_month_min_b_pay_day,
          service_user_id,
          service_user_name,
          service_department_name,
          b_pure_pay_amount,
          row_number()over(partition by shop_id order by pay_day asc,b_pure_pay_amount desc) as rn
  	    from
  	    (
          select
            shop_id,
            pay_day,
            coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_id')) as service_user_id,
            coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_name')) as service_user_name,
            coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_department_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_department_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_department_name')) as service_department_name,
            sum(pay_amount)-sum(nvl(refund_actual_amount,0)) as b_pure_pay_amount
          from
          (
            select
              *
            from order_base
            where  pay_day<='$v_date'
                   --服务商数据
                   and sp_id is null
                   --排除员工店
                   and store_type not in (9,10)
                   and item_style_freezed=1
          )tmp
          where substr(pay_day,1,6)='$v_cur_month'
  	      group by
          shop_id,
          pay_day,
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
        sum(pay_amount)-sum(nvl(refund_actual_amount,0)) pure_pay_amount,
        first_value(pay_day)over(partition by shop_id,brand_name order by pay_day) as shop_brand_sign_day
	  	from
	  	(
	  	  select
          *
        from order_base
        where  pay_day<='$v_date'
               --服务商数据
               and sp_id is null
               --排除员工店
               and store_type not in (9,10)
               and item_style_freezed=1
      )tmp
      group by
      shop_id,
      brand_name,
      pay_day,
      coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_id'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_id')) ,
      coalesce(ytdw.get_service_info('service_feature_id:5',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:1',service_info_freezed,'service_user_name'),ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_name'))
    ) orders
    left join
    (
      select * from ads_salary_base_user_d where dayid='$v_date' and is_split='新签'
    ) salary_user on salary_user.user_name=orders.service_user_name
    where substr(shop_brand_sign_day,1,6)='$v_cur_month' and pure_pay_amount>=1000 and salary_user.user_name is not null
  ) brand_shop on shop_silent.shop_id=brand_shop.shop_id and rn=1
  	 --过滤有效新开（沉淀一个月数据后可做替换，也可直接直接执行上个月任务）
	left join
  (
    select
      shop_id
    from dw_salary_shop_data_d
  -- 	where (dayid ='$v_date' or dayid='20190731' or dayid='20190831' or dayid='20190630' or dayid='20190531' or dayid ='20190430' )
  -- 	      and substr(dayid,1,6)>='$v_today_3_months_ago_m'
  	where dayid ='$v_date'
  	group by shop_id
  ) new_sign_shop on new_sign_shop.shop_id=shop_silent.shop_id
) shop_silent on shop_silent.shop_id=shop_base.shop_id
