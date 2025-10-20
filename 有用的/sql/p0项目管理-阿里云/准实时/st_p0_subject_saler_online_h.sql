--@exclude_input=ytdw.ods_vf_t_p0_subject_shop
--@exclude_input=ytdw.ods_vf_t_p0_subject
WITH shop_saler AS (
    SELECT shop_id,
           group_type,
           user_id,
           dept_id,
           parent_dept_id,
           parent_2_dept_id
    FROM yt_crm.ads_crm_subject_shop_user_d
    WHERE dayid='${v_date}'
    AND feature_type = 2
)

INSERT OVERWRITE TABLE st_p0_subject_saler_online_h PARTITION (dayid='${v_date}')
SELECT subject_shop_count.subject_id,
       subject_shop_count.group_type,
       subject_shop_count.user_id,
       user.user_real_name,
       nvl(subject_shop_count.dept_id, 0) AS dept_id,
       nvl(dept.name, '') AS dept_name,
       nvl(subject_shop_count.area_dept_id, 0) AS area_dept_id,
       nvl(subject_saler.subject_target, 0) AS subject_target,
       nvl(subject_saler.subject_gmv, 0) AS subject_gmv,
       nvl(subject_shop_count.shop_count, 0) AS subject_shop_cnt,
       nvl(subject_saler.visit_shop_count, 0) AS visit_shop_cnt,
       nvl(subject_saler.order_shop_count, 0) AS order_shop_cnt,
       nvl(subject_saler.avg_call_length, 0) AS avg_call_length,
       nvl(subject_saler.valid_visit_shop_count, 0) AS valid_visit_shop_cnt,
       nvl(subject_saler.visit_order_shop_count, 0) AS valid_visit_order_shop_cnt
FROM (
    SELECT subject_shop.subject_id,
           subject.group_type,
           shop_saler.user_id,
           dept_id,
           parent_dept_id AS area_dept_id,
           sum(CASE WHEN is_object_shop = 1 THEN 1 ELSE 0 END) AS shop_count
    FROM (
        SELECT id,group_type
        FROM ytdw.ods_vf_t_p0_subject
        WHERE is_deleted = 0
        AND status = 1
        AND feature_type = 2 --电销大类
	) subject
	JOIN (
        SELECT subject_id,shop_id,is_object_shop
        FROM ytdw.ods_vf_t_p0_subject_shop
        WHERE is_deleted = 0
	) subject_shop ON subject.id = subject_shop.subject_id
	JOIN shop_saler ON shop_saler.shop_id = subject_shop.shop_id and shop_saler.group_type = subject.group_type
	GROUP BY subject_shop.subject_id,
             subject.group_type,
             shop_saler.user_id,
             dept_id,
             parent_dept_id
) subject_shop_count
JOIN (SELECT user_id,user_real_name FROM ytdw.dwd_user_d WHERE dayid = '${v_date}') user ON user.user_id = subject_shop_count.user_id
LEFT JOIN (SELECT id,name FROM ytdw.dwd_department_d WHERE dayid = '${v_date}') dept ON dept.id = subject_shop_count.dept_id
LEFT JOIN (
	SELECT subject_id,
           user_id,
           0 AS subject_target,
           sum(subject_gmv) AS subject_gmv,
           sum(CASE WHEN visit_times > 0 OR invalid_visit_times > 0 THEN 1 ELSE 0 END) AS visit_shop_count,
           sum(CASE WHEN subject_gmv > 0 THEN 1 ELSE 0 END) AS order_shop_count,
           sum(call_length) / count(*) AS avg_call_length,
           sum(CASE WHEN visit_times > 0 THEN 1 ELSE 0 END) AS valid_visit_shop_count,
           sum(CASE WHEN subject_gmv > 0 AND visit_times > 0 THEN 1 ELSE 0 END) AS visit_order_shop_count
	FROM (
		SELECT subject_id,
               user_id,
               subject_gmv,
               visit_times,
               call_length,
               invalid_visit_times
		FROM (
			SELECT subject_id,
                   group_type,
                   shop_id,
                   subject_gmv,
                   visit_times,
                   call_length,
                   invalid_visit_times
			FROM yt_crm.nrt_p0_subject_ts_h
			WHERE dayid = '${v_date}'
		) subject_ts_gmv
		JOIN shop_saler ON shop_saler.shop_id = subject_ts_gmv.shop_id and shop_saler.group_type = subject_ts_gmv.group_type
	) subject_saler_gmv
	GROUP BY subject_id,
	         user_id
) subject_saler ON subject_shop_count.user_id = subject_saler.user_id AND subject_shop_count.subject_id = subject_saler.subject_id