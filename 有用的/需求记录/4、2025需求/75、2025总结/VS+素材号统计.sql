with t_list as (
    select a.*,
           case when comma_count>=2 then '价表数据' else '单品数据' end push_type,
           b.brand_name,
           b.item_name,
           b.category_1st_name,
           b.business_unit
    from (
        select *,
               length(item_ids) - length(regexp_replace(item_ids,",",'')) comma_count
        from yt_bi.ads_wx_qw_touch_retain_di
        where dayid<='$v_date'
        and wx_msg_send_status_name='发送成功'
        -- 筛选时间
        and dayid>='20250101' and dayid<='20251231'
        -- 筛选创建人
        and touch_task_create_user_real_name in ('尿不湿 纸品-素材号','零辅食&营养品&奶粉素材号','美妆、百货-素材号','用品出行、洗护-素材号','宝宝营养喂养运营小助手','运营小助手','石钰林','棉品 服纺鞋包-素材号','尿不湿纸品小助手2号','出行用品洗护2号','奶粉运营小助手2号','美妆、百货运营小助手🍓','王晓敏','陈雯雯','何屹','王桥雪','吴洁12161','周明慧','许静雯','章冰婕')

        union ALL

        select *,
               length(item_ids) - length(regexp_replace(item_ids,",",'')) comma_count
        from yt_bi.ads_wx_qw_touch_retain_di
        where dayid<='$v_date'
        and wx_msg_send_status_name='发送成功'
        -- 筛选时间
        and dayid>='20250101' and dayid<='20251231'
        -- 筛选创建人
        and touch_task_create_user_real_name in ('周明慧','许静雯')
        and task_name like '%VS%'
    ) a
    left join (
        SELECT item_id,
               item_name,
               business_unit,
               brand_name,
               category_1st_name
        from dim_hpc_itm_item_d
        where dayid='$v_date'
    ) b on a.item_id = b.item_id
),

base as (
    select dayid,
           push_type,
           task_name,
           category_1st_name,
           count(distinct wx_msg_content) `推送条数`,
           count(distinct item_id) `推送商品数`,
           count(distinct concat(item_id,'-',shop_id)) `成功触达UV`,
           count(distinct case when coalesce(before_app_item_72_h_gmv,0)+coalesce(before_xce_item_72_h_gmv,0)>0 then concat(item_id,'-',shop_id) else null end )`72H支付门店数推送前`,
           sum(coalesce(before_app_item_72_h_gmv,0)+coalesce(before_xce_item_72_h_gmv,0))`72H支付GMV推送前`,
           count(distinct case when coalesce(xce_item_72_h_gmv,0)+coalesce(app_item_72_h_gmv,0)>0 then concat(item_id,'-',shop_id) else null end )`72H支付门店数推送后`,
           sum(coalesce(xce_item_72_h_gmv,0)+coalesce(app_item_72_h_gmv,0))`72H支付GMV推送后`
    from t_list
    group by dayid,
             push_type,
             task_name,
             category_1st_name
)

SELECT `push_type`,
       sum(`推送条数`) as `推送条数`,
       sum(`推送商品数`) as `推送商品数`,
       sum(`成功触达uv`) as `成功触达uv`,
       sum(`72h支付门店数推送前`) as `72h支付门店数推送前`,
       sum(`72h支付gmv推送前`) as `72h支付gmv推送前`,
       sum(`72h支付门店数推送后`) as `72h支付门店数推送后`,
       sum(`72h支付gmv推送后`) as `72h支付gmv推送后`
FROM base
group by `push_type`