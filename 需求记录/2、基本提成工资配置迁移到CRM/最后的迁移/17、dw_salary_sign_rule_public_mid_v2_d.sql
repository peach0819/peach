
CREATE TABLE if not exists dw_salary_sign_rule_public_mid_v2_d(
  order_id string,
  trade_no string,
  business_unit string COMMENT '业务域',
  category_id_first bigint COMMENT '商品一级类目id',
  category_id_second bigint COMMENT '商品二级类目id',
  category_id_first_name string COMMENT '商品一级类目',
  category_id_second_name string COMMENT '商品二级类目',
  brand_id bigint COMMENT '商品品牌id',
  brand_name string COMMENT '商品品牌',
  item_id bigint COMMENT '商品ID',
  item_name string COMMENT '商品名称',
  item_style tinyint COMMENT 'AB类型',
  item_style_name string COMMENT 'AB类型名称',
  is_sp_shop string COMMENT '是否服务商订单',
  is_bigbd_shop string COMMENT '是否大BD门店',
  is_spec_order string COMMENT '是否特殊订单',
  shop_item_sign_day string COMMENT '该门店首次下单该商品日期',
  shop_item_sign_time string COMMENT '该门店首次下单该商品时间',
  shop_brand_sign_day string COMMENT '该门店首次下单该品牌日期',
  shop_brand_sign_time string COMMENT '该门店首次下单该品牌时间',
  pay_time string COMMENT '支付时间',
  pay_day string COMMENT '支付日期',
  shop_id string COMMENT '门店ID',
  shop_name string COMMENT '门店名称',
  store_type string COMMENT '门店类型',
  store_type_name string COMMENT '门店类型名称',
  war_zone_id string COMMENT '战区经理ID',
  war_zone_name string COMMENT '战区经理',
  war_zone_dep_id string COMMENT '战区ID',
  war_zone_dep_name string COMMENT '战区',
  area_manager_id string COMMENT '大区经理id',
  area_manager_name string COMMENT '大区经理',
  area_manager_dep_id string COMMENT '大区区域ID',
  area_manager_dep_name string COMMENT '大区',
  bd_manager_id string COMMENT '主管id',
  bd_manager_name string COMMENT '主管',
  bd_manager_dep_id string COMMENT '主管区域ID',
  bd_manager_dep_name string COMMENT '区域',
  service_user_id_freezed string COMMENT '冻结销售人员ID',
  service_department_id_freezed string COMMENT '冻结销售人员部门ID',
  service_user_name_freezed string COMMENT '冻结销售人员姓名',
  service_feature_name_freezed string COMMENT '冻结销售人员职能',
  service_job_name_freezed string COMMENT '冻结销售人员角色',
  service_department_name_freezed string COMMENT '冻结销售人员部门',
  gmv_less_refund decimal(18,2) COMMENT '实货gmv-退款',
  pay_amount decimal(18,2) COMMENT '实货支付金额',
  pay_amount_less_refund decimal(18,2) COMMENT '实货支付金额-退款',
  gmv decimal(18,2) COMMENT '实货gmv',
  refund_actual_amount decimal(18,2) COMMENT '实货退款',
  refund_retreat_amount decimal(18,2) COMMENT '实货清退金额',
  sale_team_name string comment '销售团队标识 1:电销部 2:BD部 3:大客户部 4:服务商部 5:美妆销售团队',
  sale_team_freezed_name string comment '冻结销售团队标识 1:电销部 2:BD部 3:大客户部 4:服务商部 5:美妆销售团队',
  sale_team_id int comment '销售团队标识ID',
  sale_team_freezed_id int comment '冻结销售团队标识ID'
  ) COMMENT 'sign规则通用方案中间表'
PARTITIONED BY (
  dayid string)
row format delimited fields terminated by '\001'
stored as orc
;

insert overwrite table dw_salary_sign_rule_public_mid_v2_d partition (dayid='$v_date')
select order.order_id,order.trade_no,
business_unit,--业务域,
category_id_first,  --商品一级类目,
category_id_second, --商品二级类目,
category_id_first_name,
category_id_second_name,
brand_id,
brand_name,--商品品牌,
item_id,
item_name,--商品名称,
item_style,
item_style_name,--ab类型,
is_sp_shop,--是否服务商订单
is_bigbd_shop,--是否大BD门店
case when spec_order.trade_no is not null then '是' else '否' end as is_spec_order,--是否特殊订单,
shop_item_sign_day,
shop_item_sign_time,
shop_brand_sign_day,
shop_brand_sign_time,
pay_time,
pay_day,
order.shop_id,
shop_name,--门店名称,
store_type,--门店类型,
store_type_name,
war_zone_id       , --战区经理ID
war_zone_name     , --战区经理
war_zone_dep_id   , --战区ID
war_zone_dep_name , --战区
area_manager_id     	,   --大区经理id
area_manager_name   	,   --大区经理
area_manager_dep_id, --大区区域ID
area_manager_dep_name,   --大区
bd_manager_id       	,--主管id
bd_manager_name     	,--主管
bd_manager_dep_id ,--主管区域ID
bd_manager_dep_name 	,--区域
service_user_id_freezed,
service_department_id_freezed,
service_user_name_freezed,--冻结销售人员姓名,
service_feature_name_freezed,--冻结销售人员职能,
service_job_name_freezed,--冻结销售人员角色,
service_department_name_freezed,--冻结销售人员部门,
--默认指标--
--默认指标--
order.gmv - nvl(refund.refund_actual_amount,0) as gmv_less_refund,  --实货gmv-退款,
order.pay_amount,--实货支付金额
order.pay_amount - nvl(refund.refund_actual_amount,0)  as pay_amount_less_refund,--实货支付金额-退款
gmv,--实货gmv,
nvl(refund.refund_actual_amount,0) as refund_actual_amount,--实货退款,
nvl(refund.refund_retreat_amount,0) as refund_retreat_amount,--实货清退金额
sale_team_name,
sale_team_freezed_name,
case when sale_team_name='电销部' then 1 when sale_team_name='BD部' then 2 when sale_team_name='大客户部' then 3 when sale_team_name='服务商部' then 4
		 when sale_team_name='美妆销售团队' then 5 else null end as sale_team_id,
case when sale_team_freezed_name='电销部' then 1 when sale_team_freezed_name='BD部' then 2 when sale_team_freezed_name='大客户部' then 3 when sale_team_freezed_name='服务商部' then 4
		 when sale_team_freezed_name='美妆销售团队' then 5 else null end as sale_team_freezed_id
 from
--订单表
(
select order_id,trade_no,
     business_unit,--业务域,
     category_id_first,  --商品一级类目,
     category_id_second, --商品二级类目,
     category_id_first_name,
     category_id_second_name,
     brand_id,
     brand_name,--商品品牌,
     item_id,
     item_name,--商品名称,
     item_style,
	    case when item_style=0 then 'A' when item_style=1 then 'B' else '其他' end as item_style_name,--ab类型,
     '否'  as is_sp_shop,--是否服务商订单
     case when ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_id') is not null then '是' else '否' end as is_bigbd_shop,--是否大BD门店
     substr(shop_item_sign_time,1,8) as shop_item_sign_day,
     shop_item_sign_time,
     substr(shop_brand_sign_time,1,8) as shop_brand_sign_day,
     shop_brand_sign_time,
     pay_time,
     pay_day,
     shop_id,
     shop_name,--门店名称,
     store_type,--门店类型,
     store_type_name,
	 case when sale_team_name ='BD部' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_user_id')
	       when sale_team_name ='大客户部' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_user_id') else null end as service_user_id_freezed,
     case when sale_team_name ='BD部' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_department_id')
	       when sale_team_name ='大客户部' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_department_id') else null end as service_department_id_freezed,
     case when sale_team_name ='BD部' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_user_name')
	       when sale_team_name ='大客户部' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_user_name') else null end as service_user_name_freezed,--冻结销售人员姓名,
     case when sale_team_name ='BD部' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_feature_name')
	       when sale_team_name ='大客户部' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_feature_name') else null end as service_feature_name_freezed,--冻结销售人员职能,
     case when sale_team_name ='BD部' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_job_name')
	       when sale_team_name ='大客户部' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_job_name') else null end as service_job_name_freezed,--冻结销售人员角色,
     case when sale_team_name ='BD部' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_department_name')
	       when sale_team_name ='大客户部' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_department_name') else null end as service_department_name_freezed,--冻结销售人员部门,
     --默认指标--
     pay_amount,--实货支付金额
     gmv,--实货gmv,
     sale_team_name,
	   sale_team_freezed_name
 from
 (
   select order_id,trade_no,
     business_unit,--业务域,
     category_id_first,  --商品一级类目,
     category_id_second, --商品二级类目,
     category_id_first_name,
     category_id_second_name,
     brand_id,
     brand_name,--商品品牌,
     item_id,
     item_name,--商品名称,
     item_style,
     first_value(pay_time) over(partition by shop_id,item_id order by pay_time) as shop_item_sign_time,
     first_value(pay_time) over(partition by shop_id,brand_id order by pay_time) as shop_brand_sign_time,
     pay_time,
     pay_day,
     shop_id,
     shop_name,--门店名称,
     store_type,--门店类型,
     store_type_name,
	 service_info_freezed,
    --默认指标--
     pay_amount,--实货支付金额
     total_pay_amount as gmv,--实货gmv
	 sale_team_name,
	 sale_team_freezed_name
  from dw_order_d
  where dayid ='$v_date'
   and pay_time is not null
   and bu_id=0
     --剔除美妆、员工店、伙伴店
   -- and nvl(store_type,100) not in (3,9,11)
   -- and sale_dc_id=-1
   and sp_id is null --剔除服务商订单
   and business_unit not in ('卡券票','其他')
   and item_style=1
) order_mid
where substr(shop_brand_sign_time,1,8)>='$v_120_days_ago' or substr(shop_item_sign_time,1,8)>='$v_120_days_ago'

) order
--退款表
left join
(select order_id,sum(refund_actual_amount) as refund_actual_amount,
        sum(case when multiple_refund=10 then refund_actual_amount else 0 end) as refund_retreat_amount
from dw_afs_order_refund_new_d --（后期通过type识别清退金额）
where dayid ='$v_date'
and refund_status=9
group by order_id
) refund on order.order_id=refund.order_id
--特殊订单表
left join
( select trade_no
from dw_offline_spec_refund_d where dayid ='$v_date'
) spec_order on order.trade_no= spec_order.trade_no
--门店表
left join
(select
shop_id,
war_zone_id       , --战区经理ID
war_zone_name     , --战区经理
war_zone_dep_id   , --战区ID
war_zone_dep_name , --战区
area_manager_id     	,   --大区经理id
area_manager_name   	,   --大区经理
area_manager_dep_id,--大区区域ID
area_manager_dep_name,   --大区
bd_manager_id       	,--主管id
bd_manager_name     	,--主管
bd_manager_dep_id ,--主管区域ID
bd_manager_dep_name 	--区域
from dw_shop_base_d where dayid ='$v_date'
) shop on order.shop_id=shop.shop_id
where
--is_bigbd_shop='否' --剔除大BD门店订单
spec_order.trade_no is null --过滤特殊订单

