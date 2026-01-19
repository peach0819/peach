select MD5(CONCAT('a2_', t_shop.SHOP_ID)) as SHOP_ID,
       t_shop.SHOP_NAME,
       null as SHOP_TYPE,
       t_shop.SHOP_LINKER,
       null as SHOP_FAX,
       t_shop.AREA_ID,
       t_shop.shop_adress as SHOP_ADRESS,
       null as SHOP_TENPAY,
       null as SHOP_BUS_LIC,
       null as SHOP_ORG_CORD,
       null as SHOP_REMARK1,
       null as SHOP_REMARK2,
       t_shop_extra.edit_time as edit_time,
       'etl' as CREAT_USER,
       'etl' as EDIT_USER,
       t_shop.INUSE as INUSE,
       t_shop.SHOP_NUM,
       null as SHOP_ALIPAY_NAME,
       null as SHOP_ALIPAY,
       null as IDENTITYCARD,
       null as SHOP_COMPANY,
       null as SHOP_BANK,
       null as SHOP_BANKNUM,
       null as SHOP_ADDRESSEE,
       null as SHOP_ZIPCODE,
       null as RECORD_SHOP,
       null as record_num,
       null as RECORD_ADDRESS,
       null as record_time,
       null as USER_ID,
       null as PARENT_ID,
       t_shop.PROVINCEAREA_ID,
       t_shop.CITYAREA_ID,
       null as VIP_SERVER,
       null as AFTER_SERVER,
       null as VIP_MATURITY,
       null as AFTER_MATURITY,
       null as PREFECTURE,
       null as WECHAT_SHARE,
       null as level,
       null as shop_face_pic,
       null as shop_notice,
       null as qr_code_path,
       null as shop_money,
       null as is_restrict,
       null as shop_qrcode,
       null as collect_type,
       null as is_agree,
       null as agree_time,
       null as agree_user,
       null as qr_code_pic_path,
       null as chain_type,
       null as sharing_percent,
       null as distributor_percent,
       null as shop_ee_percent,
       null as nick_name,
       2 as shop_grade,
       null as is_open_operation,
       null as tp_delivery_add_type,
       null as is_show_timelimit,
       null as shop_group,
       null as is_hipac_certification,
       null as shop_decoration,
       null as yiji_user_id,
       null as map_address,
       t_shop.latitude,
       t_shop.longitude,
       null as approve_status,
       t_shop.store_type as store_type,
       null as sub_store_type,
       3 as apply_type,
       null as open_time,
       null as opener,
       0 as bu_id,
       t_shop.address_id,
       null as freeze_type,
       0 as dc_id,
       null as biz_domain_id,
       0 as customer_type,
       null as shop_status_new,
       null as discard_time,
       null as member_sys,
       t_biz_2.shop_tag as shop_tag,
       'hipac' as service_code,
       t_shop.SHOP_NUM as service_shop_num,
       t_biz_1.business_scene as business_scene,
       t_shop.edit_time as sync_time,
       bid_type,
       shop_num as hipac_shop_num
from t_shop
INNER join(
    SELECT shop_id,
           shop_tag,
           edit_time,
           json_extract(t_shop_extra.shop_prop, '$.bidType') as bid_type
    from t_shop_extra
    where t_shop_extra.brand_dc_id = 61
) t_shop_extra on t_shop.shop_id = t_shop_extra.shop_id
left join (
    select biz_id as shop_id,
           GROUP_CONCAT(feature_attribute_value SEPARATOR ',') as business_scene
    from t_biz_feature
    where feature_code = 'business_scene'
    and is_deleted = 0
    and feature_attribute_value is not null
    and feature_attribute_value != ''
    group by biz_id
) t_biz_1 on t_biz_1.shop_id = t_shop.SHOP_ID
left join(
    select biz_id as shop_id,
           GROUP_CONCAT(feature_attribute_value SEPARATOR ',') as shop_tag
    from t_biz_feature
    where feature_code = 'business_type'
    and is_deleted = 0
    and feature_attribute_value is not null
    and feature_attribute_value != ''
    group by biz_id
) t_biz_2 on t_biz_2.shop_id = t_shop.SHOP_ID