WITH shop_user AS (
    SELECT shop_id,
           group_type,
           user_id,
           dept_id,
           parent_dept_id,
           parent_2_dept_id
    FROM yt_crm.ads_crm_subject_shop_user_d
    WHERE dayid='${v_date}'
)

INSERT OVERWRITE TABLE st_p0_subject_saler_brand_ts_h PARTITION (dayid='${v_date}')
SELECT subject_saler_brand_gmv.subject_id,
       subject_saler_brand_gmv.user_id,
       user.user_real_name,
       brand.brand_id AS brand_id,
       brand.brand_name AS brand_name,
       subject_saler_brand_gmv.dept_id,
       user.dept_name,
       subject_saler_brand_gmv.parent_dept_id AS area_dept_id,
       subject_saler_brand_gmv.subject_gmv,
       subject_saler_brand_gmv.pay_shop_count,
       subject_saler_brand_gmv.last_month_pay_shop_count
FROM (
	SELECT subject_id,
           user_id,
           dept_id,
           parent_dept_id,
           parent_2_dept_id,
           brand_id,
           sum(subject_gmv) AS subject_gmv,
           sum(CASE WHEN subject_gmv > 0 THEN 1 ELSE 0 END) AS pay_shop_count,
           sum(CASE WHEN last_month_gmv > 0 THEN 1 ELSE 0 END) AS last_month_pay_shop_count
	FROM (
		SELECT subject_id,
               shop_id,
               brand_id,
               subject_gmv,
               last_month_gmv
		FROM yt_crm.ads_crm_subject_shop_brand_data_h
		WHERE dayid = '${v_date}'
	) shop_brand_gmv
    JOIN (SELECT id,group_type FROM ytdw.ods_vf_t_p0_subject WHERE is_deleted = 0) subject on shop_brand_gmv.subject_id=subject.id
	JOIN shop_user ON shop_brand_gmv.shop_id = shop_user.shop_id and subject.group_type=shop_user.group_type
	GROUP BY subject_id,
             user_id,
             dept_id,
             parent_dept_id,
             parent_2_dept_id,
             brand_id
) subject_saler_brand_gmv
JOIN (
	SELECT user_id,
           user_real_name,
           dept_id,
           dept_name
	FROM ytdw.dim_usr_user_d
	WHERE dayid = '${v_date}'
	AND is_internal_user = 1
) user ON subject_saler_brand_gmv.user_id = user.user_id
JOIN (
	SELECT *
	FROM ytdw.dim_ytj_itm_brand_d
	WHERE dayid = '${v_date}'
) brand ON brand.brand_id = subject_saler_brand_gmv.brand_id
WHERE pay_shop_count > 0
OR last_month_pay_shop_count > 0