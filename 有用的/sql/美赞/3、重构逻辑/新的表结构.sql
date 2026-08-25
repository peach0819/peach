CREATE TABLE IF NOT EXISTS ads_crm_nc_shop_d (
	service_obj_id STRING COMMENT '服务对象ID',
	is_nc BIGINT COMMENT '是否专职或客制化NC门店',
	is_low_new_nc BIGINT COMMENT '是否低产或新入职NC门店'
)
PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_visit_user_workday_d (
	user_id               STRING COMMENT '用户id',
	data_month            STRING COMMENT '目标月份',
	total_day_num         BIGINT COMMENT '目标月份总天数',
    holiday_day_num       BIGINT COMMENT '目标月份节假日天数',
    vacation_day_num      BIGINT COMMENT '目标月份用户请假天数',
    actual_day_num        BIGINT COMMENT '目标月份实际天数'
)
PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_visit_service_obj_d (
    service_obj_id           STRING COMMENT '服务对象ID',
    service_obj_name         STRING COMMENT '服务对象名称',
    service_obj_type         BIGINT COMMENT '服务对象类型 1门店;2客户;3服务商;4经销商',
    channel_type             STRING COMMENT '渠道类型',
    status                   BIGINT COMMENT '状态 1正常营业 0废弃',
    store_class_name         STRING COMMENT '门店种类名  云店,仓库,办公室,实体门店,网络店铺',
    star                     BIGINT COMMENT '门店星级',
    is_star                  BIGINT COMMENT '是否星级门店',
    is_hospital              BIGINT COMMENT '是否院线店',
    if_virtual               STRING COMMENT '是否虚拟门店',
    is_nc                    BIGINT COMMENT '是否专职或客制化NC门店',
	is_low_new_nc            BIGINT COMMENT '是否低产或新入职NC门店',
	target                   STRING COMMENT '门店专属白名单目标值',
	freeze_server_id         STRING COMMENT '冻结所有人ID',
	kn_server_id             STRING COMMENT '库内所有人ID'
)
PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_visit_record_d (
    id                  BIGINT COMMENT '小记id',
    visit_type          BIGINT COMMENT '类型；1、门店拜访；2、客户拜访；3、经销商拜访；4、服务商拜访；',
    visit_time          STRING COMMENT '拜访时间',
    visit_mode          BIGINT COMMENT '拜访结果类型1为有效拜访，2无效小记；3为一般拜访',
    service_obj_id      STRING COMMENT '拜访对象id',
    user_id             STRING COMMENT '出访人ID 销售账号',
	freeze_server_id    STRING COMMENT '冻结所有人ID'
)
PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_visit_base_detail_d (
	indicator_code STRING COMMENT '指标code',
	user_id STRING COMMENT '员工ID',
	service_obj_id STRING COMMENT '服务对象ID',
	service_obj_name STRING COMMENT '服务对象名称',
	indicator STRING COMMENT '指标值',
	target STRING COMMENT '指标目标值',
	reach STRING COMMENT '指标是否达标'
)
PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_visit_base_summary_d (
	user_id STRING COMMENT '用户id',
	biz_value STRING COMMENT '业务值'
)
PARTITIONED BY (dayid STRING);