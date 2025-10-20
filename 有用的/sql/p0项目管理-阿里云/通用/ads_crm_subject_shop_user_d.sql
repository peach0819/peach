WITH feature_group as (
    select feature_type,
           group_type,
           group_type_tag,
           feature_ids,
           dept_root_key,
           1 as join_tag
    from yt_crm.ads_crm_subject_feature_group_d
    where dayid = '${v_date}'
),

shop as (
    SELECT shop_id,
           shop_name,
           shop_pro_id,
           shop_city_id,
           shop_area_id,
           shop_address_id,
           latitude,
           longitude,
           service_info,
           1 as join_tag
    FROM ytdw.dw_shop_base_d
    WHERE dayid = '${v_date}'
    AND bu_id = 0
    AND store_type NOT IN (9, 11) --排除员工店、伙伴店
    AND shop_status != 6 --排除未合作门店
),

group_shop as (
    SELECT feature_group.feature_type,
           feature_group.group_type,
           feature_group.group_type_tag,
           feature_group.dept_root_key,
           shop.shop_id,
           shop.shop_name,
           shop.shop_pro_id,
           shop.shop_city_id,
           shop.shop_area_id,
           shop.shop_address_id,
           shop.latitude,
           shop.longitude,
           yt_crm.get_subject_service_info(feature_group.feature_ids, service_info) as feature_service_info
    FROM feature_group
    LEFT JOIN shop ON feature_group.join_tag = shop.join_tag
),

dept as (
    SELECT id as dept_id,
           root_key,
           parent_ids[depth-1] as parent_dept_id,
           parent_ids[depth-2] as parent_2_dept_id
    FROM (
        SELECT id,
               name,
               root_key,
               split(root_key, '_') as parent_ids,
               size(split(root_key, '_') ) as depth
        FROM ytdw.dwd_department_d
        WHERE dayid='${v_date}'
        AND size(split(root_key, '_')) >= 2
    ) t
)

INSERT OVERWRITE TABLE ads_crm_subject_shop_user_d partition (dayid='${v_date}')
SELECT group_shop.feature_type,
       group_shop.group_type,
       group_shop.group_type_tag,
       group_shop.shop_id,
       group_shop.shop_name,
       group_shop.shop_pro_id as province_id,
       group_shop.shop_city_id as city_id,
       group_shop.shop_area_id as area_id,
       group_shop.shop_address_id as address_id,
       get_json_object(group_shop.feature_service_info, '$.service_user_id') as user_id,
       get_json_object(group_shop.feature_service_info, '$.service_department_id') as dept_id,
       nvl(dept.parent_dept_id, 0) as parent_dept_id,
       nvl(dept.parent_2_dept_id, 0) as parent_2_dept_id,
       group_shop.latitude,
       group_shop.longitude
FROM group_shop
LEFT JOIN dept ON dept.dept_id = get_json_object(group_shop.feature_service_info, '$.service_department_id') AND dept.root_key like concat('%\_', group_shop.dept_root_key, '\_%')
WHERE group_shop.feature_service_info is not null