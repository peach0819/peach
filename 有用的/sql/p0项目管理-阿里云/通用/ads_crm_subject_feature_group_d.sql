INSERT OVERWRITE TABLE ads_crm_subject_feature_group_d partition (dayid='${v_date}')
SELECT feature_type,
       id as group_type,
       feature_ids,
       root_dept_id as dept_root_key,
       group_tag as group_type_tag
FROM ytdw.dwd_p0_subject_group_d
WHERE dayid = '${v_date}'
AND is_deleted = 0