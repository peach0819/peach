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
               'shop_total_return', '0',
               't1_return', '0',
               't2_target', '0',
               't2_gmv', '0',
               't2_beyond', '0',
               't2_return', '0',
               't3_target', '0',
               't3_gmv', '0',
               't3_beyond', '0',
               't3_return', '0',
               'max_return', '0'
           )
       ) as biz_value
-- FROM dw_bi_table
-- WHERE dayid = '$v_date'
;

