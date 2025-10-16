INSERT OVERWRITE TABLE ads_crm_subject_feature_group_d partition (dayid='${v_date}')
select 1 as feature_type,3 AS group_type,'1,5,12,14' AS feature_ids,'\_32\_' as dept_root_key
UNION ALL
select 1 as feature_type,4 AS group_type,'21' AS feature_ids,'\_1804\_' as dept_root_key
UNION ALL
select 2 as feature_type,1 AS group_type,'2,6,7,13,15' AS feature_ids,'\_63\_' as dept_root_key
UNION ALL
select 2 as feature_type,2 AS group_type,'40,41' AS feature_ids,'\_2211\_' as dept_root_key
UNION ALL
select 2 as feature_type,5 AS group_type,'68' AS feature_ids,'\_1945\_' as dept_root_key