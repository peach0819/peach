create table if not exists ytdw.dim_itm_item_d (
item_id                           bigint  comment '商品ID',
item_name                         string  comment '商品名称',
item_guide_price                  double  comment '指导售价',
item_stock                        int     comment '商品总库存',
extend                            string  comment '扩展字段',
extend_inner                      string  comment '扩展字段，主要用于内部打标等逻辑，用户不可操作的字段',
yt_item_no                        string  comment '洋驼商品编号',
item_remarks                      string  comment '备注',
item_locality                     string  comment '产地',
item_spec                         string  comment '规格描述的枚举code,1：罐装2：袋装3：包装4：盒装5：瓶装6：组7：箱8：套餐',
item_picture                      string  comment '图片地址',
item_describe                     string  comment '宝贝描述',
create_time                       string  comment '创建时间',
create_user_id                    string  comment '创建人',
edit_time                         string  comment '最近修改时间',
edit_user_id                      string  comment '最近修改人',
item_onsale_time                  string  comment '系统上架时间（小二点击商品上架时间）',
is_inuse                          int     comment '1-使用中；0-未使用',
item_other_picture                string  comment '其他图片地址',
item_status                       tinyint comment '0：下架1：上架',
is_valid                          tinyint comment '1生效0禁用',
channel                           string  comment '1：后台代下单2：淘宝订单（已废弃，业务下线）3：微小店4：微信代下单6：微商城（已废弃，业务下线） -99：无渠道 0：所有渠道',
item_key_word                     string  comment '商品关键字，逗号分隔',
item_type                         tinyint comment '1=保税商品2=一般贸易3=海外直邮',
item_type_name                    string  comment '贸易类型名称',
category_1st_id                   bigint  comment '一级类目ID',
category_1st_name                 string  comment '一级类目名称',
category_2nd_id                   bigint  comment '二级类目ID',
category_2nd_name                 string  comment '二级类目名称',
category_3rd_id                   bigint  comment '三级类目ID',
category_3rd_name                 string  comment '三级类目名称',
category_4th_id                   bigint  comment '四级类目ID',
category_4th_name                 string  comment '四级类目名称',
is_show_date                      tinyint comment '是否显示生产日期 默认是0 ：否  1：是',
is_show_exp_date                  tinyint comment '是否显示效期 默认是0 ：否  1：是',
exp_date_span                     int     comment '效期跨度, 1 2 3 4',
prod_date_span                    int     comment '生产日期跨度',
is_genearl_cross_date_bidding     tinyint comment '大贸商品是否跨生产日期竞价-1:是；0:否',
item_brief_remarks                string  comment '商品简述',
item_properties                   string  comment '商品属性',
brand_id                          bigint  comment '品牌ID',
brand_series_id                   bigint  comment '品牌系列ID',
brand_no                          string  comment '品牌编号',
brand_name                        string  comment '品牌名称',
item_tags                         string  comment '商品标签(上新)',
added_tax_rate                    int     comment '增值税',
excise_rate                       int     comment '消费税',
tariff_rate                       int     comment '关税',
is_standard                       tinyint comment '1:是0：否',
is_show                           tinyint comment '1:是0：否',
white_list                        string  comment '白名单：存储分组id，多个分组以逗号分隔，例如“1,2”',
black_list                        string  comment '黑名单：存储分组id，多个分组以逗号分隔，例如“1,2”',
item_attributes                   string  comment '商品同步属性(用来存放需要同步OPENSEARCH,格式:key:value；key:value,非同步数据建议不要存放在该字段)',
item_tags_value                   string  comment '商品标签数值，如：highReward:5000；x:200；y:100',
item_version                      int     comment '商品更改版本号',
item_source                       tinyint comment '商品来源默认是0：小二（admin）1：seller',
item_style                        tinyint comment '商品标签类型默认是0：A类1：B类',
spu_id                            bigint  comment 'SPUID',
spu_other_picture                 string  comment 'SPU通用详情图，多个用逗号分开',
spu_brief_remarks                 string  comment 'SPU通用卖点',
item_barcode                      string  comment '商品条形码',
supply_area                       string  comment '商品实际的供货区域',
search_fuzzy_word                 string  comment '模糊搜索字段（用于商品搜索）',
floating_quota                    int     comment '浮动额度',
video_id                          bigint  comment '主图视频',
video_picture                     string  comment '主图视频封面图',
detail_video_id                   bigint  comment '详情视频',
detail_video_picture              string  comment '详情视频封面图',
business_unit                     string  comment '业务域',
bu_id                             int     comment '业务类型:0:海拍客；1:嗨清仓2:pp6:嗨家',
sys_category_1st_id               int     comment '系统一级类目ID',
sys_category_1st_name             string  comment '系统一级类目名称',
sys_category_2nd_id               int     comment '系统二级类目ID',
sys_category_2nd_name             string  comment '系统二级类目名称',
sys_category_3rd_id               int     comment '系统三级类目ID',
sys_category_3rd_name             string  comment '系统三级类目名称',
sys_category_4th_id               int     comment '系统四级类目ID',
sys_category_4th_name             string  comment '系统四级类目名称',
item_child_type                   int     comment '商品贸易子类型',
item_child_type_name              string  comment '商品贸易子类型名称',
is_direct                         int     comment '是否品牌直供 1：是 0：否',
item_business_group_code          string  comment '商品业务组code',
item_business_group_name          string  comment '商品业务组名称',
item_style_name                   string  comment '商品AB类型名称',
item_brand_tag_code               string  comment '商品品牌标签code',
item_brand_tag_name               string  comment '商品品牌标签名称',
is_pickup_item                    tinyint comment '是否提货卡商品（0:否,1:是）',
performance_brand_id              bigint  comment '业绩品牌ID',
performance_brand_name            string  comment '业绩品牌名称',
performance_category_1st_id       bigint  comment '业绩一级类目ID',
performance_category_1st_name     string  comment '业绩一级类目名称',
performance_category_2nd_id       bigint  comment '业绩二级类目ID',
performance_category_2nd_name     string  comment '业绩二级类目名称',
performance_category_3rd_id       bigint  comment '业绩三级类目ID',
performance_category_3rd_name     string  comment '业绩三级类目名称',
performance_business_group_code   string  comment '业绩业务组code',
performance_business_group_name   string  comment '业绩业务组名称',
item_sale_type                    tinyint comment '商品售卖类型：1 无sku有批次|2 有sku有批次|3 有sku无批次',
item_sale_type_name               string  comment '商品售卖类型名称',
diz_type                          string  comment '数据集类型：old历史兼容模式，hipac 海拍客数据集',
brand_series_name                 string  comment '品牌系列',
brand_series_no                   string  comment '品牌系列编号，用于查看',
category_leaf_id                  bigint  comment '叶子类目ID',
category_leaf_name                string  comment '叶子类目名称',
is_platform_valid                 bigint  comment '是否平台有效商品:0无效,1有效'
)
comment '商品维表'
partitioned by (dayid string)
stored as orc;

insert overwrite table ytdw.dim_itm_item_d partition (dayid = '$v_date')
select
  t1.id as item_id,
  t1.item_name,
  t1.guide_price,
  t1.item_stock,
  t1.expand,
  t1.expand_inner,
  t1.yt_item_no,
  t1.remarks,
  t1.locality,
  t1.spec,
  t1.picture,
  t1.item_describe,
  t1.create_time,
  t1.create_user,
  t1.edit_time,
  t1.edit_user,
  t1.onsale_time,
  t1.inuse,
  t1.other_picture,
  t1.item_status,
  t1.is_valid,
  t1.channel,
  t1.key_word,
  t1.item_type,
  enum.enum_value as item_type_name,
  t1.category_id_first as category_1st_id,
  t2.name as category_1st_name,
  t1.category_id_second as category_2nd_id,
  t3.name as category_2nd_name,
  t1.category_id_third as category_3rd_id,
  t4.name as category_3rd_name,
  case when t5.level = 4 then t1.category else null end as category_4th_id,
  case when t5.level = 4 then t5.name else null end as category_4th_name,
  t5.is_show_date,
  t5.is_show_exp_date,
  t5.exp_date_span,
  t5.prod_date_span,
  t5.is_genearl_cross_date_bidding,
  t1.brief_remarks,
  t1.properties,
  t6.id as brand_id,
  t1.brand_series_id,
  t6.NO as brand_no,
  t6.NAME as brand_name,
  t1.tags,
  t1.added_tax_rate,
  t1.excise_rate,
  t1.tariff_rate,
  t1.is_standard,
  t1.is_show,
  t1.white_list,
  t1.black_list,
  t1.attributes,
  t1.tags_value,
  t1.version,
  t1.source,
  t1.item_style,
  t1.spu_id,
  t1.spu_other_picture,
  t1.spu_brief_remarks,
  t1.item_barcode,
  t1.supply_area,
  t1.search_fuzzy_word,
  t1.floating_quota,
  t1.video_id,
  t1.video_picture,
  t1.detail_video_id,
  t1.detail_video_picture,
  case when t1.bu_id = 2 then 'PP'
       when t1.bu_id = 1 then '嗨清仓'
       when t1.bu_id = 6 then '嗨家'
       when t1.bu_id = 3 then '妈宝'
       when t1.bu_id = 0 and business_tag.item_business_group_name like '%跨境%' then '跨境'
       when t1.bu_id = 0 and business_tag.item_business_group_name like '%长尾%' or business_tag.item_business_group_code = 'cw9' then '长尾'
       when t1.bu_id = 0 and business_tag.item_business_group_name like '%B类%' then 'B类'
       when t1.bu_id = 0 and business_tag.item_business_group_name like '%进口%' then '进口'
       when t1.bu_id = 0 and business_tag.item_business_group_name like '%美妆个护%' then '美妆个护'
       when t1.bu_id = 0 and business_tag.item_business_group_name is not null then business_tag.item_business_group_name
       when t1.bu_id = 0 and business_tag.item_business_group_name is null then '其他'
  else '其他' end as business_unit,
  t1.bu_id,
  t2.sys_id   as sys_category_1st_id,
  t2.sys_name as sys_category_1st_name,
  t3.sys_id   as sys_category_2nd_id,
  t3.sys_name as sys_category_2nd_name,
  t4.sys_id   as sys_category_3rd_id,
  t4.sys_name as sys_category_3rd_name,
  t5.sys_id   as sys_category_4th_id,
  t5.sys_name as sys_category_4th_name,
  t1.item_child_type,
  case when t1.item_child_type=1 then '国内贸易'
       when t1.item_child_type=2 then '完税进口'
  else null end as item_child_type_name, --商品贸易子类型
  case when instr(t1.tags,'17')>0 then 1 else 0 end as is_direct,
  business_tag.item_business_group_code,
  business_tag.item_business_group_name,
  case when t1.item_style=1 then 'B' else 'A' end as item_style_name,
  t7.tag_code,
  t7.tag_name,
  case when nvl(pickup_item.item_id,pickup_trade.item_id) is not null then 1 else 0 end as is_pickup_item,
  coalesce(pickup_item.pickup_brand_id,pickup_trade.pickup_brand_id,t6.id) as performance_brand_id,
  coalesce(pickup_item.pickup_brand_name,pickup_trade.pickup_brand_name,t6.NAME) as performance_brand_name,
  coalesce(pickup_item.pickup_category_id_first,pickup_trade.pickup_category_id_first,t1.category_id_first) as performance_category_1st_id,
  coalesce(pickup_item.pickup_category_name_first,pickup_trade.pickup_category_id_first_name,t2.name) as performance_category_1st_name,
  coalesce(pickup_item.pickup_category_id_second,pickup_trade.pickup_category_id_second,t1.category_id_second) as performance_category_2nd_id,
  coalesce(pickup_item.pickup_category_name_second,pickup_trade.pickup_category_id_second_name,t3.name) as performance_category_2nd_name,
  coalesce(pickup_item.pickup_category_id_third,pickup_trade.pickup_category_id_third,t1.category_id_third) as performance_category_3rd_id,
  coalesce(pickup_item.pickup_category_name_third,pickup_trade.pickup_category_id_third_name,t4.name) as performance_category_3rd_name,
  business_tag.performance_business_group_code,
  business_tag.performance_business_group_name,
  t1.sale_type as item_sale_type ,
  if(enum1.enum_value is not null,nvl(enum1.enum_value,'未知'),null) as item_sale_type_name,--商品售卖类型
  diz_type,
  brand_series.brand_series_name as brand_series_name,
  brand_series.brand_series_no as brand_series_no,
  t1.category as category_leaf_id,
  t5.name as category_leaf_name,
  platform_valid_item.is_platform_valid as is_platform_valid
from
( --过滤一些测试商品
  select *
  ,concat(case when dc_id=0 then 'old' else '' end
          ,','
          ,if(bu_id=0 and dc_id=0,'hipac','')
         ) as diz_type
   from dwd_item_full_d where dayid = '$v_date'
   and substr(create_time,1,8)<='$v_date'
   and id not in ('271791','325516','187049','187325','187329','187330','105006','293796','247515','316732','316721','366633','379050')
   and category_id_first not in ('11551')
) as t1
left join
(
  select
    enum_key,enum_value
  from dwd_enum_info_d
  where dayid = '$v_date' and table_name = 'ods_t_item_snapshot_d' and enum_name = 'item_type' and status = 1
  group by  enum_key,enum_value
) enum on enum.enum_key = t1.item_type
--商品售卖类型枚举关联
left join
  (select enum_key,enum_value
   from dwd_enum_info_d
   where dayid='$v_date'
   and enum_name='sale_type'
   and db_name='ytdw'
   and table_name='ods_t_item_d'
   and status=1
   group by enum_key,enum_value
  ) enum1 on t1.sale_type=enum1.enum_key
left join
(
  select * from dw_category_info_d where dayid = '$v_date'
) as t2
on t1.category_id_first = t2.id
left join
(
  select * from dw_category_info_d where dayid = '$v_date'
) as t3
on t1.category_id_second = t3.id
left join
(
  select * from dw_category_info_d where dayid = '$v_date'
) as t4
on t1.category_id_third = t4.id
left join
(
  select * from dw_category_info_d where dayid = '$v_date'
) as t5
on t1.category = t5.id
left join
(
  select * from dwd_brand_d WHERE dayid = '$v_date'
) as t6
on t1.brand = t6.id
--获取品牌标签,当前只有5种类型
left join
(
  select * from dwd_tag_d where dayid = '$v_date' and id in  ('34','35','36','37','38')
) as t7 on t6.tags = t7.tag_code
--商品维度提货卡相关字段
left join
(
  select * from ytdw.dw_itm_pickup_card_d where dayid = '$v_date'
) as pickup_item on pickup_item.item_id = t1.id
--订单维度提货卡相关字段
--2020.11.18加入row_number强制去重,避免出现测试数据的干扰
left join
(
  select
    pickup_trade.item_id,
    pickup_trade.pickup_category_id_first,
    pickup_trade.pickup_category_id_first_name,
    pickup_trade.pickup_category_id_second,
    pickup_trade.pickup_category_id_second_name,
    pickup_trade.pickup_category_id_third,
    pickup_trade.pickup_category_id_third_name,
    pickup_trade.pickup_brand_id,
    pickup_trade.pickup_brand_name
  from
  (
    select
      row_number() over(partition by pickup_trade.item_id order by pickup_trade.item_id) as rn,
      pickup_trade.*
    from
    (
      select
        order_shop.item_id as item_id,
        pickup_card_category.pickup_category_id_first as pickup_category_id_first,
        pickup_card_category.pickup_category_id_first_name as pickup_category_id_first_name,
        pickup_card_category.pickup_category_id_second as pickup_category_id_second,
        pickup_card_category.pickup_category_id_second_name as pickup_category_id_second_name,
        pickup_card_category.pickup_category_id_third as pickup_category_id_third,
        pickup_card_category.pickup_category_id_third_name as pickup_category_id_third_name,
        pickup_card_category.pickup_brand_id as pickup_brand_id,
        pickup_card_category.pickup_brand_name as pickup_brand_name
      from
      (
        select
          trade_id,
          item_id,
          item_name
        from ytdw.dwd_order_shop_full_d
        where dayid = '$v_date'
          and is_deleted=0
          and item_dc_id=0
      ) as order_shop
      join
      (
        select
          trade_id,
          pickup_category_id_first,
          pickup_category_id_first_name,
          pickup_category_id_second,
          pickup_category_id_second_name,
          pickup_category_id_third,
          pickup_category_id_third_name,
          pickup_brand_id,
          pickup_brand_name
        from ytdw.dw_trd_pickup_card_category_d where dayid = '$v_date'
      ) as pickup_card_category
      on pickup_card_category.trade_id = order_shop.trade_id
    ) as pickup_trade
  ) as pickup_trade
  where pickup_trade.rn = 1
) as pickup_trade on pickup_trade.item_id = t1.id
--商品业务组、业绩业务组打标
left join
(
  select * from ytdw.dw_itm_bussiness_group_tag_d where dayid = '$v_date'
) as business_tag on business_tag.item_id=t1.id
left join
(
  select *
  from ytdw.dim_itm_brand_series_d
  where dayid='$v_date'
) brand_series
on t1.brand_series_id=brand_series.brand_series_id
left join
(
  select
    t1.id as item_id,
    case when
      ( --有批次
        t1.bu_id = 0                       --hipac
        and t1.dc_id = 0                 --hipac
        and (array_contains(split(t1.channel,','),'1') or array_contains(split(t1.channel,','),'4')) --hipac
        and t1.is_valid = 1              --商品未禁用
        and t1.inuse = 1                 --商品未删除
        and t1.supply_valid = 1          --商品供应商未删除
        and t1.item_status = 1           --商品上架
        and t1.sale_type in (1,2)        --有批次
        and t1.supply_area is not null
        and t1.supply_area != ''
        and t2.is_valid = 1              --存在有效且开售的批次
      )
      or
      ( --无批次
        t1.bu_id = 0                     --hipac
        and t1.dc_id = 0                 --hipac
        and (array_contains(split(t1.channel,','),'1') or array_contains(split(t1.channel,','),'4')) --hipac
        and t1.is_valid = 1              --商品未禁用
        and t1.inuse = 1                 --商品未删除
        and t1.supply_valid = 1          --商品供应商未删除
        and t1.item_status = 1           --商品上架
        and t1.sale_type = 3             --无批次
        and t1.supply_area is not null
        and t1.supply_area != ''
      )
    then 1 else 0 end as is_platform_valid
  from
  (
    select
      id,
      item_name,
      bu_id,
      dc_id,
      is_valid,
      inuse,
      supply_valid,
      item_status,
      supply_area,
      sale_type,
      channel
    from ytdw.dwd_item_full_d
    where dayid = '$v_date'
  ) as t1
  left join
  ( --商品批次表
    select
      distinct item_id,
      1 as is_valid    --存在有效且开售的批次
    from
    (
      select
        item_id,
        batch_status,
        is_pause
      from ytdw.dwd_item_batch_d
      where dayid = '$v_date'
        and batch_status = 2  --生效
        and is_pause = 0      --开售
        and is_effective = 1
        and is_deleted = 0
    ) a
  ) t2 on t1.id = t2.item_id
) as platform_valid_item on platform_valid_item.item_id = t1.id
;