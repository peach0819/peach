use ytdw;

CREATE TABLE if not exists ads_crm_shop_user_d (
    shop_id          string comment '门店id',
    shop_name        string comment '门店名称',
    shop_type        int comment '单体连锁店标志1:单体；2:连锁',
    store_type       int comment '门店类型1:母婴；2:港货/进口；3:美妆；...',
    province_id      string comment '省份id',
    city_id          string comment '市id',
    area_id          string comment '区id',
    address_id       string comment '街道id',
    latitude         string comment '纬度',
    longitude        string comment '经度',
    user_id          string comment '服务人员json',
    dept_id          string comment '服务人员所属部门json',
    parent_dept_id   string comment '服务人员所属部门上级json',
    parent_2_dept_id string comment '服务人员所属部门上2级json'
) comment '门店服务人员关系表'
partitioned by (dayid string)
stored as orc;

with shop as (
    select shop_id,
           shop_name,
           shop_type,
           store_type,
           shop_pro_id,
           shop_city_id,
           shop_area_id,
           shop_address_id,
           latitude,
           longitude,

           --BD  1-BD  5-BD新签  12-美妆BD  14-美妆BD新签
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:1',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:5',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:12',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:14',service_info,'service_user_id')
           ), '') as bd_user_id,
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:1',service_info,'service_department_id'),
               ytdw.get_service_info('service_feature_id:5',service_info,'service_department_id'),
               ytdw.get_service_info('service_feature_id:12',service_info,'service_department_id'),
               ytdw.get_service_info('service_feature_id:14',service_info,'service_department_id')
           ), 0) as bd_dept_id,

           --电销 2-电销  6-电销新签  7-大电销  13-美妆电销  15-美妆电销新签
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:2',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:6',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:7',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:13',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:15',service_info,'service_user_id')
           ), '') as online_sale_user_id,
           nvl(coalesce(
             ytdw.get_service_info('service_feature_id:2',service_info,'service_department_id'),
             ytdw.get_service_info('service_feature_id:6',service_info,'service_department_id'),
             ytdw.get_service_info('service_feature_id:7',service_info,'service_department_id'),
             ytdw.get_service_info('service_feature_id:13',service_info,'service_department_id'),
             ytdw.get_service_info('service_feature_id:15',service_info,'service_department_id')
           ), 0) as online_sale_dept_id,

           --大BD 4-大BD
           nvl(ytdw.get_service_info('service_feature_id:4',service_info,'service_user_id'), '') as big_bd_user_id,
           nvl(ytdw.get_service_info('service_feature_id:4',service_info,'service_department_id'), 0) as big_bd_dept_id,

           --VS电销 40-VS电销  41-VS电销新签
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:40',service_info,'service_user_id'),
               ytdw.get_service_info('service_feature_id:41',service_info,'service_user_id')
           ), '') as vs_user_id,
           nvl(coalesce(
               ytdw.get_service_info('service_feature_id:40',service_info,'service_department_id'),
               ytdw.get_service_info('service_feature_id:41',service_info,'service_department_id')
           ), 0) as vs_dept_id,

           --CBD 21-CBD
           nvl(ytdw.get_service_info('service_feature_id:21',service_info,'service_user_id'), '') as cbd_user_id,
           nvl(ytdw.get_service_info('service_feature_id:21',service_info,'service_department_id'), 0) as cbd_dept_id
    FROM ytdw.dw_shop_base_d
    WHERE dayid='$v_date'
    AND bu_id = 0
    AND store_type NOT IN (9, 11) --排除员工店、伙伴店
    AND shop_status != 6 --排除未合作门店
),

dept as (
    SELECT id as dept_id, root_key, parent_ids[`size`-2] as parent_dept_id,  parent_ids[`size`-3] as parent_2_dept_id
    FROM (
        SELECT id, name, root_key, split(root_key, '_') as parent_ids, size(split(root_key, '_') ) as `size`
        FROM dwd_department_d
        WHERE dayid='$v_date'
        AND size(split(root_key, '_') ) > 3
    ) t
)

INSERT OVERWRITE TABLE ads_crm_shop_user_d partition (dayid='$v_date')
SELECT shop_id,
       shop_name,
       shop_type,
       store_type,
       shop_pro_id as province_id,
       shop_city_id as city_id,
       shop_area_id as area_id,
       if(shop_address_id = '其他', 0, shop_address_id) as address_id,
       latitude,
       longitude,

       to_json(
           map(
               'bd', if(shop.bd_dept_id is null, '', nvl(shop.bd_user_id, '')),
               'ts', if(shop.online_sale_dept_id is null, '', nvl(shop.online_sale_user_id, '')),
               'big_bd', if(shop.big_bd_dept_id is null, '', nvl(shop.big_bd_user_id, '')),
               'vs', if(shop.vs_dept_id is null, '', nvl(shop.vs_user_id, '')),
               'cbd', if(shop.cbd_dept_id is null, '', nvl(shop.cbd_user_id, ''))
           )
       ) as user_id,

       to_json(
           map(
               'bd', nvl(shop.bd_dept_id, 0),
               'ts', nvl(shop.online_sale_dept_id, 0),
               'big_bd', nvl(shop.big_bd_dept_id, 0),
               'vs', nvl(shop.vs_dept_id, 0),
               'cbd', nvl(shop.cbd_dept_id, 0)
           )
       ) as dept_id,

       to_json(
           map(
               'bd', nvl(bd_dept.parent_dept_id, 0),
               'ts', nvl(online_sale_dept.parent_dept_id, 0),
               'big_bd', nvl(big_bd_dept.parent_dept_id, 0),
               'vs', nvl(vs_dept.parent_dept_id, 0),
               'cbd', nvl(cbd_dept.parent_dept_id, 0)
           )
       ) as parent_dept_id,

       to_json(
           map(
               'bd', nvl(bd_dept.parent_2_dept_id, 0),
               'ts', nvl(online_sale_dept.parent_2_dept_id, 0),
               'big_bd', nvl(big_bd_dept.parent_2_dept_id, 0),
               'vs', nvl(vs_dept.parent_2_dept_id, 0),
               'cbd', nvl(cbd_dept.parent_2_dept_id, 0)
           )
       ) as parent_2_dept_id
FROM shop
LEFT JOIN (SELECT * FROM dept WHERE root_key like '%\_32\_%') bd_dept ON shop.bd_dept_id = bd_dept.dept_id
LEFT JOIN (SELECT * FROM dept WHERE root_key like '%\_63\_%') online_sale_dept ON shop.online_sale_dept_id = online_sale_dept.dept_id
LEFT JOIN (SELECT * FROM dept WHERE root_key like '%\_303\_%') big_bd_dept ON shop.big_bd_dept_id = big_bd_dept.dept_id
LEFT JOIN (SELECT * FROM dept WHERE root_key like '%\_1945\_%') vs_dept ON shop.vs_dept_id = vs_dept.dept_id
LEFT JOIN (SELECT * FROM dept WHERE root_key like '%\_1804\_%') cbd_dept ON shop.cbd_dept_id = cbd_dept.dept_id;