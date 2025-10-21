INSERT OVERWRITE TABLE ads_crm_subject_feature_group_d partition (dayid='${v_date}')
--BD团队
select 1 as feature_type,
       3 AS group_type,
       '1,5,12,14' AS feature_ids,
       '32' as dept_root_key,
       'bd' as group_type_tag

UNION ALL

--CBD团队
select 1 as feature_type,
       4 AS group_type,
       '21' AS feature_ids,
       '1804' as dept_root_key,
       'cbd' as group_type_tag

UNION ALL

--电销团队
select 2 as feature_type,
       1 AS group_type,
       '2,6,7,13,15' AS feature_ids,
       '63' as dept_root_key,
       'ts' as group_type_tag

UNION ALL

--VS团队
select 2 as feature_type,
       2 AS group_type,
       '40,41' AS feature_ids,
       '2211' as dept_root_key,
       'vs' as group_type_tag

UNION ALL

--综合电销团队
select 2 as feature_type,
       5 AS group_type,
       '68' AS feature_ids,
       '1945' as dept_root_key,
       'zhpdx' as group_type_tag

UNION ALL

--品直电销团队
SELECT 2 AS feature_type,
       6 AS group_type,
       '70' AS feature_ids,
       '63' as dept_root_key,
       'pznfdx' as group_type_tag