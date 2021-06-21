
create table if not exists ytdw.ads_order_base_user_d (
  user_name string comment 'bd名字',
  is_split string comment '是否拆分',
  is_coefficient string comment '是否有系数',
  update_time string comment '更新时间',
  data_month string comment '数据月份'
)
comment 'bd人员表'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;