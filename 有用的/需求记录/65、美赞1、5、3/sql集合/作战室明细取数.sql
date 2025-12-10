SELECT user_id,
       indicator_code,
       service_obj_id,
       service_obj_name,
       GET_JSON_OBJECT(biz_value, '$.indicator') as reach
       GET_JSON_OBJECT(biz_value, '$.reach') as reach
FROM p_mdson.ads_crm_visit_user_indicator_detail_d
WHERE dayid = '20251204'
AND indicator_code is not null