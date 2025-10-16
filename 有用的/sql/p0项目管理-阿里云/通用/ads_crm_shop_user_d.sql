INSERT OVERWRITE TABLE ads_crm_shop_user_d partition (dayid='${v_date}')
--BD 取有BD的门店
SELECT 'bd' as feature_type,
        shop_id,
        shop_name,
        province_id,
        city_id,
        area_id,
        address_id,
        get_json_object(user_info,'$.user_id') as user_id,
        get_json_object(user_info,'$.dept_id') as dept_id,
        get_json_object(user_info,'$.parent_dept_id') as parent_dept_id,
        get_json_object(user_info,'$.parent_2_dept_id') as parent_2_dept_id,
        latitude,
        longitude
FROM yt_crm.ads_crm_shop_user_base_v2_d
LATERAL VIEW explode(split(regexp_replace(ytdw.get_service_info('group_type:3', user_list), '},', '};'), ';', false)) tmp AS user_info
WHERE dayid='${v_date}' and get_json_object(user_info,'$.user_id')!=''

UNION ALL

SELECT 'ts' as feature_type,
        shop_id,
        shop_name,
        province_id,
        city_id,
        area_id,
        address_id,
        get_json_object(user_info,'$.user_id') as user_id,
        get_json_object(user_info,'$.dept_id') as dept_id,
        get_json_object(user_info,'$.parent_dept_id') as parent_dept_id,
        get_json_object(user_info,'$.parent_2_dept_id') as parent_2_dept_id,
        latitude,
        longitude
FROM yt_crm.ads_crm_shop_user_base_v2_d
LATERAL VIEW explode(split(regexp_replace(ytdw.get_service_info('group_type:1', user_list), '},', '};'), ';', false)) tmp AS user_info
WHERE dayid='${v_date}' and get_json_object(user_info,'$.user_id')!=''

UNION ALL

--VS电销 取有VS电销服务的门店
SELECT 'vs' as feature_type,
        shop_id,
        shop_name,
        province_id,
        city_id,
        area_id,
        address_id,
        get_json_object(user_info,'$.user_id') as user_id,
        get_json_object(user_info,'$.dept_id') as dept_id,
        get_json_object(user_info,'$.parent_dept_id') as parent_dept_id,
        get_json_object(user_info,'$.parent_2_dept_id') as parent_2_dept_id,
        latitude,
        longitude
FROM yt_crm.ads_crm_shop_user_base_v2_d
LATERAL VIEW explode(split(regexp_replace(ytdw.get_service_info('group_type:2', user_list), '},', '};'), ';', false)) tmp AS user_info
WHERE dayid='${v_date}' and get_json_object(user_info,'$.user_id')!=''

UNION ALL

--CBD 取有CBD服务的门店
SELECT 'cbd' as feature_type,
        shop_id,
        shop_name,
        province_id,
        city_id,
        area_id,
        address_id,
        get_json_object(user_info,'$.user_id') as user_id,
        get_json_object(user_info,'$.dept_id') as dept_id,
        get_json_object(user_info,'$.parent_dept_id') as parent_dept_id,
        get_json_object(user_info,'$.parent_2_dept_id') as parent_2_dept_id,
        latitude,
        longitude
FROM yt_crm.ads_crm_shop_user_base_v2_d
LATERAL VIEW explode(split(regexp_replace(ytdw.get_service_info('group_type:4', user_list), '},', '};'), ';', false)) tmp AS user_info
WHERE dayid='${v_date}' and get_json_object(user_info,'$.user_id')!=''

UNION ALL

--综合品电销 取有综合品电销服务的门店
SELECT 'zhpdx' as feature_type,
        shop_id,
        shop_name,
        province_id,
        city_id,
        area_id,
        address_id,
        get_json_object(user_info,'$.user_id') as user_id,
        get_json_object(user_info,'$.dept_id') as dept_id,
        get_json_object(user_info,'$.parent_dept_id') as parent_dept_id,
        get_json_object(user_info,'$.parent_2_dept_id') as parent_2_dept_id,
        latitude,
        longitude
FROM yt_crm.ads_crm_shop_user_base_v2_d
LATERAL VIEW explode(split(regexp_replace(ytdw.get_service_info('group_type:5', user_list), '},', '};'), ';', false)) tmp AS user_info
WHERE dayid='${v_date}' and get_json_object(user_info,'$.user_id')!=''