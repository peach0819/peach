CREATE TABLE IF NOT EXISTS ads_crm_subject_shop_user_d (
	feature_type INT COMMENT '项目分类类型；1、BD，2、电销',
	group_type INT COMMENT '执行团队类型',
	group_type_tag STRING COMMENT '执行团队类型标签',
	shop_id STRING COMMENT '门店id',
	shop_name STRING COMMENT '门店名称',
	province_id STRING COMMENT '省份id',
	city_id STRING COMMENT '市id',
	area_id STRING COMMENT '区id',
	address_id STRING COMMENT '街道id',
	user_id STRING COMMENT '服务人员',
	dept_id BIGINT COMMENT '服务人员所属部门',
	parent_dept_id BIGINT COMMENT '服务人员所属部门上级',
	parent_2_dept_id BIGINT COMMENT '服务人员所属部门上2级',
	latitude STRING COMMENT '纬度',
	longitude STRING COMMENT '经度'
)
PARTITIONED BY (dayid STRING);