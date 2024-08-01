function run(){
apache-spark-sql -e "
use ytdw;

CREATE TABLE if not exists st_p0_subject_rule_detail_d (
  plan_no_shop_user_category_brand_item_id  string comment '方案编号_门店id_发放对象id_类目id_品牌id_商品id',
  subject_id string comment '项目id',
  plan_no string comment '方案编号',
  bounty_rule_type  string comment '模板规则  1:存量净GMV；2:新签商品；3:新签品牌',
  shop_id string comment '门店id',
  shop_name string comment '门店名称',
  is_subject_shop string comment '是否属于项目门店 1:目标门店；2:统计门店；0:不属于',
  grant_object_type string comment '发放对象类型',
  grant_object_user_id  string comment '发放对象id',
  grant_object_user_dep_id  string comment '发放对象所属部门id',
  war_zone_dep_id string comment '对象所属战区部门id',
  area_manager_dep_id string comment '对象所属大区部门id',
  bd_manager_dep_id string comment '对象所属主管部门id',
  category_id_first string comment '商品一级类目id (1)',
  category_id_first_name  string comment '商品一级类目名 (1)',
  category_id_second  string comment '商品二级类目id (1)',
  category_id_second_name string comment '商品二级类目名 (1)',
  brand_id  string comment '商品品牌id',
  brand_name  string comment '商品品牌',
  item_id string comment '商品id (1,2)',
  item_name string comment '商品名称 (1,2)',
  gmv_less_refund string comment '实货gmv-退款',
  gmv string comment '实货gmv',
  pay_amount  string comment '实货支付金额',
  pay_amount_less_refund  string comment '实货支付金额-退款',
  refund_actual_amount  string comment '实货退款',
  refund_retreat_amount string comment '实货清退金额',
  new_sign_line string comment '新签门槛线',
  is_over_sign_line string comment '是否满足新签门槛 (2, 3)',
  is_first_sign string comment '是否首次达成 (2, 3)',
  is_succ_sign  string comment '是否新签成功 (2, 3)',
  sts_target_name string comment '统计指标名称',
  sts_target string comment '统计指标数值  (1)'
)
comment '销售项目方案提成明细'
partitioned by (dayid string)
stored as orc;

insert overwrite table st_p0_subject_rule_detail_d partition (dayid='$2')
select 
  concat(bounty_rule_type, '_',planno,'_',plan_data.shop_id,'_',grant_object_user_id,'_',category_id_first,'_',brand_id,'_',item_id) as plan_no_shop_user_category_brand_item_id,
  plan.subject_id,
  planno,
  bounty_rule_type,
  plan_data.shop_id,
  shop_name,
  case when subject_shop.is_object_shop is null then 0 when subject_shop.is_object_shop=1 then 1 else 2 end as is_subject_shop,
  grant_object_type,
  grant_object_user_id,
  nvl(grant_object_user_dep_id,0) as grant_object_user_dep_id,
  nvl(war_zone_dep_id,0) as war_zone_dep_id,
  nvl(area_manager_dep_id,0) as area_manager_dep_id,
  nvl(bd_manager_dep_id,0) as bd_manager_dep_id,
  category_id_first,
  category_id_first_name,
  category_id_second,
  category_id_second_name,
  brand_id,
  brand_name,
  item_id,
  item_name,
  nvl(gmv_less_refund,0) as gmv_less_refund,
  nvl(gmv,0) as gmv,
  nvl(pay_amount,0) as pay_amount,
  nvl(pay_amount_less_refund,0) as pay_amount_less_refund,
  nvl(refund_actual_amount,0) as refund_actual_amount,
  nvl(refund_retreat_amount,0) as refund_retreat_amount,
  new_sign_line,
  is_over_sign_line,
  is_first_sign,
  is_succ_sign,
  sts_target_name,
  sts_target
from 
(
  select 
    planno,
    1 as bounty_rule_type,
    shop_id,
    shop_name,
    grant_object_type,
    grant_object_user_id,
    grant_object_user_dep_id,
    war_zone_dep_id,
    area_manager_dep_id,
    bd_manager_dep_id,
    category_id_first,
    category_id_second,
    category_id_first_name,
    category_id_second_name,
    brand_id,
    brand_name,
    item_id,
    item_name,
    gmv_less_refund,
    gmv,
    pay_amount,
    pay_amount_less_refund,
    refund_actual_amount,
    refund_retreat_amount,
    null as new_sign_line,
    null as is_over_sign_line,
    null as is_first_sign,
    null as is_succ_sign,
    sts_target_name,
    sts_target
  from dw_salary_gmv_rule_public_d where dayid='$2'  and nvl(grant_object_user_id, '')<>''
  AND pltype = 'cur'

  
  union all
  select 
    planno,
    2 as bounty_rule_type,
    shop_id,
    shop_name,
    grant_object_type,
    grant_object_user_id,
    grant_object_user_dep_id,
    war_zone_dep_id,
    area_manager_dep_id,
    bd_manager_dep_id,
    0 as category_id_first,
    0 as category_id_second,
    null as category_id_first_name,
    null as category_id_second_name,
    brand_id,
    brand_name,
    item_id,
    item_name,
    gmv_less_refund,
    gmv,
    pay_amount,
    pay_amount_less_refund,
    refund_actual_amount,
    refund_retreat_amount,
    new_sign_line,
    is_over_sign_line,
    is_first_sign,
    is_succ_sign,
    sts_target_name,
    null as sts_target
  from (
    select
    *
    from 
    (
    select
    *,
    row_number() over(partition by planno,shop_id,item_id order by is_succ_sign_new desc) as is_save_2
    from 
    (
    select
    *,
    row_number() over(partition by planno,shop_id,item_id,is_succ_sign_new order by gmv_less_refund desc) as is_save_1
    from 
    (
    select
    *,
    case when is_over_sign_line='是' and is_first_sign_new='是' then '是'
    else '否' end  as is_succ_sign_new
    from 
    (
    select
    *,
    case when new_sign_rn_new=1 then '是'
    else '否' end as is_first_sign_new
    from 
    (
    select 
    *,
    row_number() over(partition by planno,shop_id,item_id,is_over_sign_line order by new_sign_day) as new_sign_rn_new
    from dw_salary_sign_item_rule_public_d 
    where dayid='$2' and nvl(grant_object_user_id, '')<>''
    AND pltype = 'cur'

    )t 
    )b 
    )b1 
    )t1 
    where is_save_1=1
    )t2 
    where is_save_2=1
  ) item_data
  
  union all
  select 
    planno,
    3 as bounty_rule_type,
    shop_id,
    shop_name,
    grant_object_type,
    grant_object_user_id,
    grant_object_user_dep_id,
    war_zone_dep_id,
    area_manager_dep_id,
    bd_manager_dep_id,
    0 as category_id_first,
    0 as category_id_second,
    null as category_id_first_name,
    null as category_id_second_name,
    brand_id,
    brand_name,
    0 as item_id,
    null as item_name,
    gmv_less_refund,
    gmv,
    pay_amount,
    pay_amount_less_refund,
    refund_actual_amount,
    refund_retreat_amount,
    new_sign_line,
    is_over_sign_line,
    is_first_sign,
    is_succ_sign,
    sts_target_name,
    null as sts_target
  from (
    select
    *
    from 
    (
    select
    *,
    row_number() over(partition by planno,shop_id,brand_id order by is_succ_sign_new desc) as is_save_2
    from 
    (
    select
    *,
    row_number() over(partition by planno,shop_id,brand_id,is_succ_sign_new order by gmv_less_refund desc) as is_save_1
    from 
    (
    select
    *,
    case when is_over_sign_line='是' and is_first_sign_new='是' then '是'
    else '否' end  as is_succ_sign_new
    from 
    (
    select
    *,
    case when new_sign_rn_new=1 then '是'
    else '否' end as is_first_sign_new
    from 
    (
    select 
    *,
    row_number() over(partition by planno,shop_id,brand_id,is_over_sign_line order by new_sign_day) as new_sign_rn_new
    from dw_salary_sign_brand_rule_public_d 
    where dayid='$2' and nvl(grant_object_user_id, '')<>''
    AND pltype = 'cur'
    )t 
    )b 
    )b1 
    )t1 
    where is_save_1=1
    )t2 
    where is_save_2=1
  ) brand_data
) plan_data
join(
  select no, subject_id from dw_bounty_plan_schedule_d where nvl(subject_id,0)<>0 AND name not like '%测试%'
) plan
on plan.no=plan_data.planno 
left join(
  select subject_id,shop_id,is_object_shop from dwd_p0_subject_shop_d where dayid='$2' 
) subject_shop
on plan.subject_id=subject_shop.subject_id and plan_data.shop_id=subject_shop.shop_id
"
}

source ../sql_variable.sh $v_date
v_date=$1
#本月1号
v_first_day=$(date -d"$1" +%Y%m01)
#上月最后一天
v_pre_month_last_day=$(date -d"$v_first_day -1 day" +%Y%m%d)
#上月1号
v_pre_month_first_day=$(date -d"$1 -1 month" +%Y%m01)
#上上月最后一天
v_pre_2_month_last_day=$(date -d"$v_pre_month_first_day -1 day" +%Y%m%d)

run $v_date $v_date &&
run $v_date $v_pre_month_last_day &&
run $v_date $v_pre_2_month_last_day &&
exit 0