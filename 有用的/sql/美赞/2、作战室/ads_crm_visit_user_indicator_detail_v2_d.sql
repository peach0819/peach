INSERT OVERWRITE TABLE ads_crm_visit_user_indicator_detail_v2_d PARTITION (dayid='${v_date}')
--当月人员拜访达标率需要单独从汇总表里面取
SELECT data_month,
       user_id,
       'month_visit_reach_rate' as indicator_code,
       null as service_obj_id,
       null as service_obj_name,
       to_json(named_struct(
           'reach', if_visit_qualified_month_1
       )) as biz_value
FROM prod_mdson.ads_mdson_user_new_visit_summary_data_d_v2
WHERE dayid = '${v_date}'
AND if_visit_qualified_month_1 is not null
AND data_month = '${v_opt_month}'

UNION ALL

--其他指标都从明细表里面取
SELECT '${v_opt_month}' as data_month,
       user_id,
       indicator_code,
       split(service_obj_id, '-')[1] as service_obj_id,
       service_obj_name,
       to_json(named_struct(
           'indicator', indicator,
           'reach', reach,
           'target', cast(target as int)
       )) as biz_value
FROM prod_mdson.ads_crm_visit_base_detail_d
WHERE dayid = '${v_date}'