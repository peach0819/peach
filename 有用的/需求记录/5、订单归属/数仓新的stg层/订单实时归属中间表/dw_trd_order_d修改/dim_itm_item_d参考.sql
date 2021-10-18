with item_property_temp as (
    select /*+ BROADCAST(b) */ a.*
         ,b.unit_name
    from
        (select *
              ,row_number() over(partition by item_id order by length(category_property_id) desc,category_property_id desc) as item_property_rank -- 历史类目迁移时，造成了一个商品有多个保质期，叶子类目大的为新的，为兜底逻辑，后期商品八戒那边会进行数据订正
         from dwd_item_property_d
         where dayid='$v_date'
           and is_deleted=0
           and property_name like '%保质期%'
        ) a
            left join
        (select enum_key as unit
              ,enum_value as unit_name
         from dw_met_enum_detail_d
         where dayid='$v_date'
           and enum_detail_status=1
           and enum_code='item_property_unit_value'
        ) b
        on a.unit=b.unit
    where a.item_property_rank=1

)

insert overwrite table ytdw.dim_itm_item_d partition (dayid = '$v_date')
select /*+ BROADCAST(enum,enum1,y) */
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
    platform_valid_item.is_platform_valid as is_platform_valid,
    virtual_group_id_lv2 as buyer_virtual_group_id_lv1,
    virtual_group_name_lv2 as buyer_virtual_group_name_lv1,
    virtual_group_id_lv3 as buyer_virtual_group_id_lv2,
    virtual_group_name_lv3 as buyer_virtual_group_name_lv2
        ,z.property_value as shelf_life_value --'保质期保质值'
        ,z.unit as shelf_life_unit --保质期保质单位：天，年，月'
        ,z.unit_name as shelf_life_unit_name --'保质期保质单位名称,天，年，月'
        ,t1.production_time as item_production_time
        ,t1.item_milk_type
        ,y.item_milk_type_name
from
    ( --过滤一些测试商品
        select *
             ,concat(case when dc_id=0 then 'old' else '' end
            ,','
            ,if(bu_id=0 and dc_id=0,'hipac','')
            ) as diz_type
             ,case when item_style = 0 and category_id_first = 12 and brand in (611,1133,547,736,1141,583,815) then 1
                   when item_style = 0 and category_id_first = 12 and item_type in (1,3) then 2
                   when item_style = 0 and category_id_first = 12 then 3
                   when item_style = 1 and category_id_first = 12 then 4
                   else null end as item_milk_type
        from dwd_item_full_d where dayid = '$v_date'
                               and substr(create_time,1,8)<='$v_date'
                               and id not in ('271791','325516','187049','187325','187329','187330','105006','293796','247515','316732','316721','366633','379050')
                               and category_id_first not in ('11551')
    ) as t1
        left join
    (
        select
            enum_key,enum_value
        from dw_met_enum_detail_d
        where dayid = '$v_date'
          and enum_code = 'item_biz_type'
          and enum_detail_status = 1
        group by  enum_key,enum_value
    ) enum on enum.enum_key = t1.item_type
--商品售卖类型枚举关联
        left join
    (select
         enum_key,enum_value
     from dw_met_enum_detail_d
     where dayid = '$v_date'
       and enum_code = 'item_sale_type'
       and enum_detail_status = 1
     group by  enum_key,enum_value
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
        left join dim_hpc_itm_virtual_group v
                  on t1.id = v.item_id
        left join
    (select enum_key as item_milk_type
          ,enum_value as item_milk_type_name
     from dw_met_enum_detail_d
     where dayid='$v_date'
       and enum_detail_status=1
       and enum_code='item_milk_type'
    ) y
    on t1.item_milk_type=y.item_milk_type
        left join item_property_temp z
                  on t1.id=z.item_id

;