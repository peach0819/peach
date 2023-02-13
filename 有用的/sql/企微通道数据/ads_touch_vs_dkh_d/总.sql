use ytdw;

create table if not exists ads_touch_vs_dkh_d
(
    shop_id             string comment '门店id',
    biz_value           string comment '门店名'
) comment '微商大客户播报数据'
partitioned by (dayid string)
stored as orc;

insert overwrite table ads_touch_vs_dkh_d partition(dayid='$v_date')
SELECT 'test',
       to_json(
           map(
               'shop_total_return', shop_total_return,
               't1_target', '0',
               't1_gmv', '0',
               't1_beyond', '0',
               't1_return', t1_return,
               't2_target', t2_target,
               't2_gmv', t2_gmv,
               't2_beyond', t2_beyond,
               't2_return', t2_return,
               't3_target', t3_target,
               't3_gmv', t3_gmv,
               't3_beyond', t3_beyond,
               't3_return', t3_return,
               'max_return', max_return
           )
       ) as biz_value
FROM ads_hipac_ws_return_d
WHERE dayid = '$v_date'
;