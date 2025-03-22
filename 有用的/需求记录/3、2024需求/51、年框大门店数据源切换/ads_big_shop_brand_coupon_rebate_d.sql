----订单
with shop_order as (
    select order_id,
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
    left join (SELECT DISTINCT item_id from yt_bi.ads_big_shop_brand_not_item_d where dayid='${v_date}') not_item on a.item_id=not_item.item_id
    where dayid = '${v_date}'
    and date_id is not null
    and item_style=0
    and sale_dc_id=-1
    and business_unit not in ('B类','卡券票','其他')
    and shop_store_type_name not in ('伙伴店','员工店')
    and category_1st_name not in ('奶粉','数码家电','尿不湿')
    and date_id<='${v_date}'
    and substr(date_id,1,6)='${v_cur_month}'--限制当月
    and item_name not like '%团购%' --剔除团单商品
    and item_name not like '%团单%'
    and item_name not like '%团批%'
    and item_name not like '%勿拍%'
    and item_name not like '%tg%' --剔除团单商品
    and not_item.item_id is null
),

--母婴门店信息
muying_shop_list as (
    SELECT shop_id,
           shop_name,
           shop_member_system,
           shop_member_system_name
    from ytdw.ads_hpc_shp_shop_rights_behavior_tag_d
    where dayid='${v_date}'
    and shop_member_system=2
),

--订单的优惠券信息
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

--优惠券基础信息
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

--大门店品牌信息
shop_brand_list as (
    SELECT *
    from yt_bi.ads_big_shop_brand_shop_d
    where dayid='${v_date}'
),

shop_brand_summary as (
    select shop_id,
           shop_name,
           brand_id,
           brand_name,
           case when pure_pay_amount<=0 then 0 else pure_gmv end as pure_gmv,
           coupon_amount_store,
           coupon_amount_platform
    from (
        SELECT shop_id,
               shop_name,
               brand_id,
               brand_name,
               sum(pfm_net_pay_total_amt_1d) as pure_gmv,
               sum(pfm_net_pay_amt_1d) as pure_pay_amount,
               sum(case when is_pay_bp=1 then coupon_amount_store else 0 end) as coupon_amount_store,--求和全部的店铺券
               sum(case when (coupon_bear_type in (1,4,6,3,5) or coupon_first_sector_id in (164,289) or coupon_secondary_sector_id in (242,142,145,218,219))
                              and is_pay_bp=1
                              and coupon_id not in (143845,	143857,	143856,	143864,	143865,	143866,	143868,	143869,	143870,	143871,	143873,	143876,	143912,	143846,	143848,	143896,	143897,	143898,
                              143849,	143893,	143899,	143850,	143901,	143851,	143852,	143853,	143902,	143903,	143904,	143854,	143855,	143889,	143863,	143867,	143872,	143874,	144033,	144034,	144066,
                              143885,	143915,	143913,	143914,	143917,	143916,	143892,	143906,	143875,	143894,	143884,	143883,	143907,	143895,	143881,	143908,	143921,	143922,	143923,	143924,	143925,
                              144036,	144037,	143878,	143879,	143880,	143882,	143928,	143929,	143877,	143918,	143919,	143920,	143891,	143930,	143931,	143932)
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
            join muying_shop_list on shop_order.shop_id=muying_shop_list.shop_id
            left join order_coupon_info on shop_order.order_id=order_coupon_info.order_id
            left join coupon_info on order_coupon_info.coupon_owner_id=coupon_info.coupon_owner_id
            INNER join shop_brand_list on shop_order.shop_id=shop_brand_list.shop_id and shop_order.brand_id=shop_brand_list.brand_id
        )t1
        GROUP by shop_id,
                 shop_name,
                 brand_id,
                 brand_name
    )t
),

--单品计算订单
shop_gmv_target_tmp as (
    select t1.shop_id,
           t2.brand_id,
           t2.brand_type,
           sum(pfm_net_pay_total_amt_1d) as pfm_net_pay_total_amt_1d,
           shop_brand_base_goal,
           shop_brand_sprint_goal,
           brand_profit_level,
           brand_cate_name,
           shop_brand_rule_name
    from (
        select *
        from ytdw.dws_hpc_trd_pfm_detail_d
        where dayid='${v_date}'
        and date_id is not null
        and item_style=0
        and sale_dc_id=-1
        and business_unit not in ('B类','卡券票','其他')
        and shop_store_type_name not in ('伙伴店','员工店')
        and category_1st_name not in ('奶粉','数码家电','尿不湿')
        and date_id<='${v_date}'
        and substr(date_id,1,6)='${v_cur_month}'--限制当月
        and item_name not like '%团购%' --剔除团单商品
        and item_name not like '%团单%'
        and item_name not like '%团批%'
        and item_name not like '%勿拍%'
        and item_name not like '%tg%' --剔除团单商品
    ) t1
    left join (SELECT DISTINCT item_id from yt_bi.ads_big_shop_brand_not_item_d where dayid='${v_date}') not_item on t1.item_id=not_item.item_id
    INNER join (
        select *
        from yt_bi.ads_big_shop_brand_shop_d
        where dayid='${v_date}'
    ) t2 on t1.shop_id=t2.shop_id
    and t1.brand_id=t2.brand_id
    where not_item.item_id is null
    group by t1.shop_id,
             t2.brand_id,
             t2.brand_type,
             shop_brand_base_goal,
             shop_brand_sprint_goal,
             brand_profit_level,
             brand_cate_name,
             shop_brand_rule_name
),

order_detail_tmp as (
    select t1.*,
           t2.coupon_owner_id,
           t2.coupon_id_platform,
           t2.coupon_amount_platform,
           t2.coupon_amount_store,
           t2.coupon_owner_id_store,
           t3.brand_type,
           t3.pfm_net_pay_total_amt_1d,
           t3.shop_brand_base_goal,
           t3.shop_brand_sprint_goal,
           t3.curr_target,
           t4.base_goal_price,
           t4.sprint_goal_price,
           t5.coupon_bear_type,
           t5.coupon_bear_type_name,
           t5.coupon_first_sector_id,
           t5.coupon_first_sector_name,
           t5.coupon_secondary_sector_id,
           t5.coupon_secondary_sector_name,
           brand_profit_level,
           brand_cate_name,
           shop_brand_rule_name,
           case when curr_target = 0 then 0
                when curr_target=1 then pay_amt_unit_1d-base_goal_price
                when curr_target=2 then pay_amt_unit_1d-sprint_goal_price
                else 0 end as reward_amount,
                case when is_pay_bp=1 then coupon_amount_store else 0 end as coupon_amount_store_diff,
                case when (coupon_bear_type in (1,4,6,3,5) or coupon_first_sector_id in (164,289) or coupon_secondary_sector_id in (242,142,145,218,219)) and is_pay_bp=1
                           and coupon_id not in (143845,	143857,	143856,	143864,	143865,	143866,	143868,	143869,	143870,	143871,	143873,	143876,	143912,	143846,	143848,	143896,	143897,	143898,
                           143849,	143893,	143899,	143850,	143901,	143851,	143852,	143853,	143902,	143903,	143904,	143854,	143855,	143889,	143863,	143867,	143872,	143874,	144033,	144034,	144066,
                           143885,	143915,	143913,	143914,	143917,	143916,	143892,	143906,	143875,	143894,	143884,	143883,	143907,	143895,	143881,	143908,	143921,	143922,	143923,	143924,	143925,
                           144036,	144037,	143878,	143879,	143880,	143882,	143928,	143929,	143877,	143918,	143919,	143920,	143891,	143930,	143931,	143932)
                    then coupon_amount_platform else 0 end as coupon_amount_platform_diff
    from (
        select a.*
        from (
            select date_id,
                   order_id,
                   trade_no,
                   shop_id,
                   brand_id,
                   brand_name,
                   shop_name,
                   item_id,
                   pfm_pay_itm_actual_amt_1d,
                   pfm_pay_itm_unit_1d,
                   is_pay_bp,
                   round(pfm_pay_itm_actual_amt_1d/pfm_pay_itm_unit_1d,2)  as pay_amt_unit_1d
            from ytdw.dws_hpc_trd_pfm_detail_d
            where dayid='${v_date}'
            and is_pay_bp=1
            and substr(date_id,1,6)= '${v_cur_month}'
        ) a
        INNER join (
            select order_id
            from ytdw.dw_trd_order_d
            where dayid = '${v_date}'
            and order_pay_ym  = '${v_cur_month}'
            and item_id in (-1)
        ) b on a.order_id=b.order_id
    ) t1
    left join (
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
    ) t2 on t1.order_id=t2.order_id
    INNER join (
        select *,
               case when pfm_net_pay_total_amt_1d>nvl(shop_brand_sprint_goal,9999999) then 2
                    when pfm_net_pay_total_amt_1d>nvl(shop_brand_base_goal,-1) and pfm_net_pay_total_amt_1d<nvl(shop_brand_sprint_goal,9999999) then 1
                    else 0 end as curr_target
        from shop_gmv_target_tmp
    ) t3 on t1.shop_id = t3.shop_id and t1.brand_id=t3.brand_id
    INNER join (
        select * from yt_bi.inf_upload_single_item_price_rule
    ) t4 on t1.item_id = t4.item_id and t3.brand_type=t4.brand_type
    left join coupon_info t5 on t2.coupon_owner_id=t5.coupon_owner_id
),

order_detail_tmp2 as (
    select *,
           case when reward_amount*pfm_pay_itm_unit_1d-nvl(coupon_amount_store_diff,0)-nvl(coupon_amount_platform_diff,0) > 0
                then reward_amount*pfm_pay_itm_unit_1d-nvl(coupon_amount_store_diff,0)-nvl(coupon_amount_platform_diff,0)
                else 0 end as reward_amount_without_coupon,
           case when reward_amount*pfm_pay_itm_unit_1d-nvl(coupon_amount_store_diff,0)-nvl(coupon_amount_platform_diff,0)>0
                then nvl(coupon_amount_store_diff,0)+nvl(coupon_amount_platform_diff,0)
                else 0 end as coupon_all_amount
    from order_detail_tmp
),

shop_brand_single_item_summary as (
    select shop_id,
           shop_name,
           brand_id,
           brand_name,
           brand_cate_name,
           brand_type,
           case when curr_target=2 then (shop_brand_base_goal/pfm_net_pay_total_amt_1d)*reward_all else 0 end as shop_brand_sprint_reward,
           case when curr_target=2 then reward_all-(shop_brand_base_goal/pfm_net_pay_total_amt_1d)*reward_all
                when curr_target=1 then reward_all
                else 0 end as shop_brand_base_reward,
           coupon_all_amount
    from (
        select shop_id,
               brand_id,
               brand_name,
               shop_name,
               brand_type,
               shop_brand_base_goal,
               shop_brand_sprint_goal,
               pfm_net_pay_total_amt_1d,
               brand_profit_level,
               brand_cate_name,
               shop_brand_rule_name,
               curr_target,
               sum(reward_amount_without_coupon) as reward_all,
               sum(coupon_all_amount) as coupon_all_amount
        from order_detail_tmp2
        group by shop_id,
                 brand_id,
                 brand_type,
                 shop_brand_base_goal,
                 shop_brand_sprint_goal,
                 pfm_net_pay_total_amt_1d,
                 brand_name,
                 shop_name,
                 brand_profit_level,
                 brand_cate_name,
                 shop_brand_rule_name,
                 curr_target
    ) a
)


INSERT OVERWRITE TABLE yt_bi.ads_big_shop_brand_coupon_rebate_d PARTITION (dayid = '${v_date}')
SELECT t01.shop_id,
       t01.shop_name,
       t01.brand_id,
       t01.brand_name,
       t01.brand_cate_name,
       t01.brand_type,
       t01.brand_profit_level,
       t01.shop_brand_rule_name,
       t01.pure_gmv,
       t01.shop_brand_base_goal,
       t01.shop_brand_base_progess,
       round(shop_brand_base_progess/shop_brand_base_goal,4) as shop_brand_base_progess_percent,
       COALESCE(round(t02.shop_brand_base_reward,0),round(t01.shop_brand_base_reward,0),0) as shop_brand_base_reward,
       shop_brand_sprint_goal,
       shop_brand_sprint_progess,
       round(shop_brand_sprint_progess/shop_brand_sprint_goal,4) as shop_brand_sprint_progess_percent,
       COALESCE(round(t02.shop_brand_sprint_reward,0),round(t01.shop_brand_sprint_reward,0),0) as shop_brand_sprint_reward,
       nvl(t02.coupon_all_amount,t01.cupon_all_amount) as cupon_all_amount
from (
    SELECT brand_id,
           shop_id,
           shop_name,
           brand_type,
           brand_name,
           brand_cate_name,
           brand_profit_level,
           shop_brand_rule_name,
           pure_gmv,
           shop_brand_base_goal,
           shop_brand_base_progess,
           case when brand_id in (18198,586,12956) then shop_brand_base_reward
                when (shop_brand_base_reward-round(shop_brand_base_reward/(shop_brand_base_reward+shop_brand_sprint_reward),2)*cupon_all_amount)<=0 then 0
                else shop_brand_base_reward-round(shop_brand_base_reward/(shop_brand_base_reward+shop_brand_sprint_reward),2)*cupon_all_amount end as shop_brand_base_reward,
           shop_brand_sprint_goal,
           shop_brand_sprint_progess,
           case when (shop_brand_sprint_reward-cupon_all_amount)<=0 then 0 else shop_brand_sprint_reward-cupon_all_amount end as shop_brand_sprint_reward,
           cupon_all_amount
    from (
        SELECT t1.brand_id,
               t1.shop_id,
               muying_shop_list.shop_name,
               brand_type,
               t1.brand_name,
               brand_cate_name,
               brand_profit_level,
               shop_brand_rule_name,
               shop_brand_base_goal,
               nvl(shop_brand_summary.pure_gmv,0) as pure_gmv,
               if(nvl(shop_brand_summary.pure_gmv,0)<=0,0,shop_brand_summary.pure_gmv) as shop_brand_base_progess,
               case when t1.brand_id in (18198,586,12956) and nvl(shop_brand_summary.pure_gmv,0)>shop_brand_base_goal then shop_brand_base_reward
                    when nvl(shop_brand_summary.pure_gmv,0)>shop_brand_base_goal and nvl(shop_brand_sprint_goal,0)<=0 then round(nvl(shop_brand_summary.pure_gmv,0)*shop_brand_base_reward,4)
                    when nvl(shop_brand_summary.pure_gmv,0)>shop_brand_base_goal and nvl(shop_brand_summary.pure_gmv,0)<shop_brand_sprint_goal and shop_brand_sprint_goal>0 then round(nvl(shop_brand_summary.pure_gmv,0)*shop_brand_base_reward,4) --超过存量目标未达到增量目标
                    when nvl(shop_brand_summary.pure_gmv,0)>shop_brand_base_goal and nvl(shop_brand_summary.pure_gmv,0)>=shop_brand_sprint_goal and shop_brand_sprint_goal>0 then 0--超过存量目标未达到增量目标
                    else 0 end as shop_brand_base_reward,
               shop_brand_sprint_goal,
               if(nvl(shop_brand_summary.pure_gmv,0)<=0,0,shop_brand_summary.pure_gmv) as shop_brand_sprint_progess,
               case when nvl(shop_brand_summary.pure_gmv,0)>=shop_brand_sprint_goal and shop_brand_sprint_goal>0 then round((nvl(shop_brand_summary.pure_gmv,0))*shop_brand_sprint_reward,4) --超过存量目标未达到增量目标
                    else 0 end as shop_brand_sprint_reward,
               nvl(coupon_amount_store,0)+nvl(coupon_amount_platform,0) as cupon_all_amount
        from (
            SELECT * from shop_brand_list
        )t1
        left join muying_shop_list on t1.shop_id=muying_shop_list.shop_id
        left join shop_brand_summary on t1.shop_id=shop_brand_summary.shop_id and t1.brand_id=shop_brand_summary.brand_id
    )t
) t01
left join (
    select * from shop_brand_single_item_summary
) t02 on t01.brand_id=t02.brand_id and t01.shop_id=t02.shop_id and t01.brand_type = t02.brand_type
where t01.shop_id is not null