v_date=$1

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;

CREATE TABLE if not exists ads_crm_shop_user_d (
    feature_type     string comment '职能类型',
    shop_id          string comment '门店id',
    shop_name        string comment '门店名称',
    province_id      string comment '省份id',
    city_id          string comment '市id',
    area_id          string comment '区id',
    address_id       string comment '街道id',
    user_id          string comment '服务人员',
    dept_id          bigint comment '服务人员所属部门',
    parent_dept_id   bigint comment '服务人员所属部门上级',
    parent_2_dept_id bigint comment '服务人员所属部门上2级',
    latitude         string comment '纬度',
    longitude        string comment '经度'
) comment '门店服务人员回流清洗表'
partitioned by (dayid string)
stored as orc;

with base as (
    SELECT shop_id,
           shop_name,
           province_id,
           city_id,
           area_id,
           address_id,
           latitude,
           longitude,
           user_id,
           dept_id,
           parent_dept_id,
           parent_2_dept_id
    FROM ads_crm_shop_user_base_d
    WHERE dayid = '$v_date'
),

--BD 取大BD为空的门店
bd as (
    SELECT 'bd' as feature_type,
           shop_id,
           shop_name,
           province_id,
           city_id,
           area_id,
           address_id,
           get_json_object(user_id, '$.bd') as user_id,
           get_json_object(dept_id, '$.bd') as dept_id,
           get_json_object(parent_dept_id, '$.bd') as parent_dept_id,
           get_json_object(parent_2_dept_id, '$.bd') as parent_2_dept_id,
           latitude,
           longitude
    FROM base
    WHERE get_json_object(user_id, '$.big_bd') = ''
),

--电销 取有电销服务的门店
ts as (
    SELECT 'ts' as feature_type,
           shop_id,
           shop_name,
           province_id,
           city_id,
           area_id,
           address_id,
           get_json_object(user_id, '$.ts') as user_id,
           get_json_object(dept_id, '$.ts') as dept_id,
           get_json_object(parent_dept_id, '$.ts') as parent_dept_id,
           get_json_object(parent_2_dept_id, '$.ts') as parent_2_dept_id,
           latitude,
           longitude
    FROM base
    WHERE get_json_object(user_id, '$.ts') != ''
),

--VS电销 取有VS电销服务的门店
vs as (
    SELECT 'vs' as feature_type,
           shop_id,
           shop_name,
           province_id,
           city_id,
           area_id,
           address_id,
           get_json_object(user_id, '$.vs') as user_id,
           get_json_object(dept_id, '$.vs') as dept_id,
           get_json_object(parent_dept_id, '$.vs') as parent_dept_id,
           get_json_object(parent_2_dept_id, '$.vs') as parent_2_dept_id,
           latitude,
           longitude
    FROM base
    WHERE get_json_object(user_id, '$.vs') != ''
),

--CBD 取有CBD服务的门店
cbd as (
    SELECT 'cbd' as feature_type,
           shop_id,
           shop_name,
           province_id,
           city_id,
           area_id,
           address_id,
           get_json_object(user_id, '$.cbd') as user_id,
           get_json_object(dept_id, '$.cbd') as dept_id,
           get_json_object(parent_dept_id, '$.cbd') as parent_dept_id,
           get_json_object(parent_2_dept_id, '$.cbd') as parent_2_dept_id,
           latitude,
           longitude
    FROM base
    WHERE get_json_object(user_id, '$.cbd') != ''
)

INSERT OVERWRITE TABLE ads_crm_shop_user_d partition (dayid='$v_date')
SELECT * FROM bd
UNION ALL
SELECT * FROM ts
UNION ALL
SELECT * FROM vs
UNION ALL
SELECT * FROM cbd;
"