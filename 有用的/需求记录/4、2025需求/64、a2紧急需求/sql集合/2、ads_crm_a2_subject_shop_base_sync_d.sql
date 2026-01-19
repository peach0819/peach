INSERT OVERWRITE TABLE ads_crm_a2_subject_shop_base_sync_d PARTITION(dayid='${v_date}')
SELECT subject_id,
       subject_type,
       subject_type_id,
       subject_month,
       shop_id,
       shop_code,
       shop_name,
       province_id,
       province_name,
       city_id,
       city_name,
       area_id,
       area_name,
       street_id,
       street_name,
       sale_id,
       sale_name,
       sale_user_id,
       has_visit,
       has_valid_visit,
       has_order,
       offtake
FROM yt_crm.ads_crm_a2_subject_shop_base_d
WHERE dayid = '${v_date}'
AND need_stats = 1