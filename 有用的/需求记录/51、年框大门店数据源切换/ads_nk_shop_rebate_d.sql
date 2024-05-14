--门店订单
with shop_order as (
    select order_id,
           date_id,
           trade_no,
           shop_id,
           shop_name,
           category_1st_name,
           a.item_id,
           item_name,
           brand_id,
           brand_name,
           pfm_pay_total_amt_1d,
           pfm_net_pay_total_amt_1d,
           pfm_net_pay_amt_1d,
           is_pay_bp,
           is_rfd_bp
    from ytdw.dws_hpc_trd_pfm_detail_d a
    where dayid = '${v_date}'
    and date_id is not null
    and item_style=0
    and sale_dc_id=-1
    and business_unit not in ('B类','卡券票','其他')
    and shop_store_type_name not in ('伙伴店','员工店')
    and category_1st_name not in ('奶粉','数码家电','尿不湿')
    and date_id<='${v_date}'
    and substr(date_id,1,4)='2024'--限制当年
    and item_name not like '%团购%' --剔除团单商品
    and item_name not like '%团单%'
    and item_name not like '%团批%'
    and item_name not like '%勿拍%'
    and item_name not like '%tg%' --剔除团单商品
),

--订单上的优惠券信息
order_coupon_info as (
    SELECT order_id,
           coupon_owner_id,
           coupon_amount_platform,
           coupon_amount_store,
           coupon_owner_id_store,
           coupon_id_platform,
           coupon_title_platform
    from ytdw.dw_order_d
    where dayid='${v_date}'
    and bu_id=0
),

--优惠券信息
coupon_info as (
    SELECT coupon_owner_id,
           coupon_id,
           coupon_bear_type,
           coupon_bear_type_name,
           coupon_first_sector_id,
           coupon_first_sector_name,
           coupon_secondary_sector_id,
           coupon_secondary_sector_name
    FROM ytdw.dw_prm_coupon_owner_info_d
    WHERE dayid='${v_date}'
),

--年框签约门店
qianyue_shop as (
    SELECT DISTINCT t2.shop_id
    from (
        SELECT id,
               contract_no,
               contract_title
        from ytdw.dwd_crm_contract_base_d
        where dayid='${v_date}'
        and status=1
        and contract_biz_type='ppfl'
        and is_deleted=0
    )t1
    left join (
        SELECT DISTINCT contract_id,
                        shop_id
        from ytdw.dwd_crm_contract_pecific_d
        where dayid='${v_date}'
        and is_deleted=0
        and pecific_type=1
    )t2 on t1.id=t2.contract_id
),

--门店品牌目标和返点（上传的excel）
shop_brand_list as (
    SELECT * from yt_bi_dev.inf_brand_nk_shop_rule_d
),

--门店品牌汇总数据
shop_brand_summary as (
    SELECT shop_id,
           shop_name,
           brand_id,
           sum(pure_gmv) as pure_gmv_year,
           sum(coupon_amount_store) as coupon_amount_store_year,
           sum(coupon_amount_platform) as coupon_amount_platform_year,
           sum(case when substr(date_id,1,6)='${v_cur_month}' then pure_gmv else 0 end) as pure_gmv_mom,
           sum(case when substr(date_id,1,6)='${v_cur_month}' then coupon_amount_store else 0 end) as coupon_amount_store_mom,
           sum(case when substr(date_id,1,6)='${v_cur_month}' then coupon_amount_platform else 0 end) as coupon_amount_platform_mom
    from (
        select shop_id,
               shop_name,
               brand_id,
               brand_name,
               date_id,
               case when pure_pay_amount<=0 then 0 else pure_gmv end as pure_gmv,
               coupon_amount_store,
               coupon_amount_platform
        from (
        --------这里的数据直接取累返的数据
            SELECT shop_id,
                   shop_name,
                   brand_id,
                   brand_name,
                   date_id,
                   sum(pfm_net_pay_total_amt_1d) as pure_gmv,
                   sum(pfm_net_pay_amt_1d) as pure_pay_amount,
                   sum(case when is_pay_bp=1 then coupon_amount_store else 0 end) as coupon_amount_store,--求和全部的店铺券
                   sum(case when (coupon_bear_type in (1,4,6,3,5) or coupon_first_sector_id in (164,289) or coupon_secondary_sector_id in (242,142,145,218,219))
                                  and is_pay_bp=1
                                  and coupon_id not in (143845,	143857,	143856,	143864,	143865,	143866,	143868,	143869,	143870,	143871,	143873,	143876,	143912,	143846,	143848,	143896,	143897,	143898,
                                   143849, 143893,	143899,	143850,	143901,	143851,	143852,	143853,	143902,	143903,	143904,	143854,	143855,	143889,	143863,	143867,	143872,	143874,	144033,	144034,	144066,
                                   143885, 143915,	143913,	143914,	143917,	143916,	143892,	143906,	143875,	143894,	143884,	143883,	143907,	143895,	143881,	143908,	143921,	143922,	143923,	143924,	143925,
                                   144036, 144037,	143878,	143879,	143880,	143882,	143928,	143929,	143877,	143918,	143919,	143920,	143891,	143930,	143931,	143932)
                            then coupon_amount_platform else 0 end) as coupon_amount_platform --求和特定的平台券
            from (
                 SELECT shop_order.*,
                        order_coupon_info.coupon_owner_id,
                        coupon_id,
                        coupon_amount_platform,
                        coupon_amount_store,
                        coupon_owner_id_store,
                        coupon_id_platform,
                        coupon_title_platform,
                        coupon_bear_type,
                        coupon_bear_type_name,
                        coupon_first_sector_id,
                        coupon_first_sector_name,
                        coupon_secondary_sector_id,
                        coupon_secondary_sector_name
                 from shop_order
                 left join order_coupon_info on shop_order.order_id=order_coupon_info.order_id
                 left join coupon_info on order_coupon_info.coupon_owner_id=coupon_info.coupon_owner_id
                 join shop_brand_list on shop_order.shop_id=shop_brand_list.shop_id and shop_order.brand_id=shop_brand_list.brand_id
            )t1
            GROUP by shop_id,
                     shop_name,
                     brand_id,
                     brand_name,
                     date_id
        )t
    )t
    GROUP by shop_id,
             shop_name,
             brand_id
)

INSERT OVERWRITE TABLE yt_bi.ads_nk_shop_rebate_d PARTITION (dayid = '${v_date}')
SELECT shop_id,
       shop_name,
       brand_id,
       brand_name,
       year_goal,
       pure_gmv_year,
       year_rebate_pre,
       case when pure_gmv_year>=year_goal then round(pure_gmv_year*year_rebate_pre,0) else 0 end as year_rebate_amount,
       round(coupon_amount_store_year+coupon_amount_platform_year,0) as year_all_coupon_amount,
       case when pure_gmv_year>=year_goal and pure_gmv_year*year_rebate_pre-(coupon_amount_store_year+coupon_amount_platform_year)>0
            then round(pure_gmv_year*year_rebate_pre-(coupon_amount_store_year+coupon_amount_platform_year),0)
            else 0 end year_actual_rebate_amount,
       month_goal,
       pure_gmv_mom,
       month_rebate_pre,
       case when pure_gmv_mom>=month_goal then round(pure_gmv_mom*month_rebate_pre,0) else 0 end as mom_rebate_amount,
       round(coupon_amount_store_mom+coupon_amount_platform_mom,0) as mom_all_coupon_amount,
       case when pure_gmv_mom>=month_goal and pure_gmv_mom*month_rebate_pre-(coupon_amount_store_mom+coupon_amount_platform_mom)>0
            then round(pure_gmv_mom*month_rebate_pre-(coupon_amount_store_mom+coupon_amount_platform_mom),0)
            else 0 end mom_actual_rebate_amount
from (
    SELECT shop_brand_list.shop_id,
           shop_name,
           shop_brand_list.brand_id,
           shop_brand_list.brand_name,
           year_goal,
           case when substr('${v_date}',1,6)='202404' then month_04_goal
                when substr('${v_date}',1,6)='202405' then month_05_goal
                when substr('${v_date}',1,6)='202406' then month_06_goal
                when substr('${v_date}',1,6)='202407' then month_07_goal
                when substr('${v_date}',1,6)='202408' then month_08_goal
                when substr('${v_date}',1,6)='202409' then month_09_goal
                when substr('${v_date}',1,6)='202410' then month_10_goal
                when substr('${v_date}',1,6)='202411' then month_11_goal
                when substr('${v_date}',1,6)='202412' then month_12_goal
                else null end as month_goal,
           year_rebate_pre,
           month_rebate_pre,
           pure_gmv_year,
           coupon_amount_store_year,
           coupon_amount_platform_year,
           pure_gmv_mom,
           coupon_amount_store_mom,
           coupon_amount_platform_mom
    from shop_brand_list
    left join shop_brand_summary on shop_brand_list.shop_id = shop_brand_summary.shop_id and shop_brand_list.brand_id = shop_brand_summary.brand_id
    INNER join qianyue_shop on shop_brand_list.shop_id = qianyue_shop.shop_id
)t