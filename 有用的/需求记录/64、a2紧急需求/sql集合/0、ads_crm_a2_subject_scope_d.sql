INSERT OVERWRITE TABLE ads_crm_a2_subject_scope_d PARTITION (dayid = '${v_date}')
SELECT