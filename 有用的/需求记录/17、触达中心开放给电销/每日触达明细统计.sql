SELECT  date_format(create_time, '%Y-%m-%d') as task_date,
        count(distinct admin_chat_id) as qw_count,
        count(distinct shop_id) as shop_count,
        count(DISTINCT shop_chat_id) as total_customer_count,
        max(case when promotion.promotion_type is null then '' else promotion.promotion_type end) as promotion_type
FROM t_touch_task_detail
LEFT JOIN (
    select date_format(start_time, '%Y-%m-%d') as promotion_date,
           case when promotion_type = 0 then 'AB类大促'
                when promotion_type = 1 then 'A类大促'
                when promotion_type = 2 then 'B类大促'
                when promotion_type = 3 then 'AB类小促'
                when promotion_type = 4 then 'A类大促B类小促'
                when promotion_type = 5 then 'A类小促B类大促'
                when promotion_type = 6 then 'A类小促'
                when promotion_type = 7 then 'B类小促'
                when promotion_type = 8 then 'A类超级品类日'
                when promotion_type = 9 then 'A类超级品牌日'
            else ''
            end as promotion_type
    from yt_ope.t_promotion_config
    WHERE dc_status = 0
) promotion ON date_format(t_touch_task_detail.create_time, '%Y-%m-%d') = promotion.promotion_date
WHERE detail_status = 2
AND create_time > '2021-11-17 00:00:00'
group by date_format(create_time, '%Y-%m-%d')
order by task_date