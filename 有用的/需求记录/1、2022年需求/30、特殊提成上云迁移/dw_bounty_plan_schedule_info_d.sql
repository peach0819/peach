CREATE TABLE IF NOT EXISTS dw_bounty_plan_schedule_info_d
(
    schedule_time STRING COMMENT '调度时间',
    schedule_type STRING COMMENT '调度类型 当天today, 补数supply',
    source        STRING COMMENT '来源系统auto 手动manual',
    id            BIGINT COMMENT '调度记录id'
) ;