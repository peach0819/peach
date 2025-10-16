--odps sql
--********************************************************************--
--author:dong.wang(Role)
--create time:2025-06-17 10:29:02
--********************************************************************--
with all_shop as (
    select
        shop_id,
        shop_name,
        shop_type,
        store_type,
        shop_pro_id,
        shop_city_id,
        shop_area_id,
        shop_address_id,
        latitude,
        longitude,
        service_info
    FROM ytdw.dw_shop_base_d
    WHERE dayid='${v_date}'
    AND bu_id = 0
    AND store_type NOT IN (9, 11) --排除员工店、伙伴店
    AND shop_status != 6 --排除未合作门店
),
user_shop as (
    select *,
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:1',service_info,'service_feature_id'),
               ytdw.get_service_info('service_feature_id:5',service_info,'service_feature_id'),
               ytdw.get_service_info('service_feature_id:12',service_info,'service_feature_id'),
               ytdw.get_service_info('service_feature_id:14',service_info,'service_feature_id')
           ), '') as service_feature_id,
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:1',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:5',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:12',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:14',service_info,'service_user_id')
           ), '') as user_id,
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:1',service_info,'service_department_id'),
               ytdw.get_service_info('service_feature_id:5',service_info,'service_department_id'),
               ytdw.get_service_info('service_feature_id:12',service_info,'service_department_id'),
               ytdw.get_service_info('service_feature_id:14',service_info,'service_department_id')
           ), 0) as dept_id
    FROM all_shop
    where nvl(coalesce(
               ytdw.get_service_info('service_feature_id:1',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:5',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:12',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:14',service_info,'service_user_id')
           ), '')!=''

    union all
    select *,
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:2',service_info,'service_feature_id'),
               ytdw.get_service_info('service_feature_id:6',service_info,'service_feature_id'),
               ytdw.get_service_info('service_feature_id:7',service_info,'service_feature_id'),
               ytdw.get_service_info('service_feature_id:13',service_info,'service_feature_id'),
               ytdw.get_service_info('service_feature_id:15',service_info,'service_feature_id')
           ), '') as service_feature_id,
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:2',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:6',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:7',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:13',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:15',service_info,'service_user_id')
           ), '') as user_id,
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:2',service_info,'service_department_id'),
               ytdw.get_service_info('service_feature_id:6',service_info,'service_department_id'),
               ytdw.get_service_info('service_feature_id:7',service_info,'service_department_id'),
               ytdw.get_service_info('service_feature_id:13',service_info,'service_department_id'),
               ytdw.get_service_info('service_feature_id:15',service_info,'service_department_id')
           ), 0) as dept_id
    FROM all_shop
    where  nvl(coalesce(
               ytdw.get_service_info('service_feature_id:2',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:6',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:7',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:13',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:15',service_info,'service_user_id')
           ), '') !=''

    union all
    select *,
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:40',service_info,'service_feature_id'),
               ytdw.get_service_info('service_feature_id:41',service_info,'service_feature_id')
           ), '') as service_feature_id,
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:40',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:41',service_info,'service_user_id')
           ), '') as user_id,
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:40',service_info,'service_department_id'),
               ytdw.get_service_info('service_feature_id:41',service_info,'service_department_id')
           ), 0) as dept_id
    FROM all_shop
    where  nvl(coalesce(
               ytdw.get_service_info('service_feature_id:40',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:41',service_info,'service_user_id')
           ), '') !=''

    union all
    select *,
           --CBD 21-CBD
           nvl(ytdw.get_service_info('service_feature_id:21',service_info,'service_feature_id'), '') as service_feature_id,
           nvl(ytdw.get_service_info('service_feature_id:21',service_info,'service_user_id'), '') as user_id,
           nvl(ytdw.get_service_info('service_feature_id:21',service_info,'service_department_id'), 0) as dept_id
    FROM all_shop
    where nvl(ytdw.get_service_info('service_feature_id:21',service_info,'service_user_id'), '')!=''

    union all
    select *,
           --综合品电销 68-综合品电销
           nvl(ytdw.get_service_info('service_feature_id:68',service_info,'service_feature_id'), '') as service_feature_id,
           nvl(ytdw.get_service_info('service_feature_id:68',service_info,'service_user_id'), '') as user_id,
           nvl(ytdw.get_service_info('service_feature_id:68',service_info,'service_department_id'), 0) as dept_id
    FROM all_shop
    where nvl(ytdw.get_service_info('service_feature_id:68',service_info,'service_user_id'), '')!=''
)

INSERT OVERWRITE TABLE ads_crm_shop_user_base_v2_d partition (dayid='${v_date}')
SELECT
    user_shop.shop_id,
    user_shop.shop_name,
    user_shop.shop_type,
    user_shop.store_type,
    user_shop.shop_pro_id,
    user_shop.shop_city_id,
    user_shop.shop_area_id,
    if(user_shop.shop_address_id = '其他', 0, shop_address_id),
    user_shop.latitude,
    user_shop.longitude,
    REPLACE(
        REPLACE(
            TO_JSON(
                COLLECT_LIST(
                    NAMED_STRUCT(
                        'feature_type', feature_group.feature_type,
                        'group_type',  feature_group.group_type,
                        'user_id', if(user_shop.dept_id is null, '', nvl(user_shop.user_id, '')),
                        'dept_id', nvl(user_shop.dept_id, 0),
                        'parent_dept_id', nvl(dept.parent_dept_id, 0),
                        'parent_2_dept_id',nvl(dept.parent_2_dept_id, 0)
                    )
                )
            )
        ,'[', '' )
    ,']', '') as user_list
FROM user_shop
left join
(
    select feature_type,group_type,dept_root_key,feature_ids,feature_id
    from yt_crm.ads_crm_subject_feature_group_d
    LATERAL VIEW explode(SPLIT(feature_ids, ',')) tmp AS feature_id
    where dayid='${v_date}'
)feature_group on user_shop.service_feature_id=feature_group.feature_id
LEFT JOIN
 (
    SELECT id as dept_id, root_key, parent_ids[depth-1] as parent_dept_id,  parent_ids[depth-2] as parent_2_dept_id
    FROM (
        SELECT id, name, root_key, split(root_key, '_') as parent_ids, size(split(root_key, '_') ) as depth
        FROM ytdw.dwd_department_d
        WHERE dayid='${v_date}'
        AND size(split(root_key, '_') ) >= 2
    ) t
)dept ON user_shop.dept_id = dept.dept_id AND dept.root_key like concat('%',feature_group.dept_root_key,'%')
group by
    user_shop.shop_id,
    user_shop.shop_name,
    user_shop.shop_type,
    user_shop.store_type,
    user_shop.shop_pro_id,
    user_shop.shop_city_id,
    user_shop.shop_area_id,
    user_shop.shop_address_id,
    user_shop.latitude,
    user_shop.longitude
