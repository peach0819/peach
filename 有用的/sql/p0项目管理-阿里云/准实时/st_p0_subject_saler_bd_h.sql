WITH shop_saler AS (
    SELECT shop_id,
           group_type,
           user_id,
           dept_id,
           parent_dept_id,
           parent_2_dept_id
    FROM yt_crm.ads_crm_subject_shop_user_d
    WHERE dayid='${v_date}'
    AND feature_type = 1
)

INSERT OVERWRITE TABLE st_p0_subject_saler_bd_h PARTITION (dayid='${v_date}')
SELECT subject_shop_count.subject_id,
       subject_shop_count.group_type,
       subject_shop_count.user_id,
       user.user_real_name,
       nvl(subject_shop_count.dept_id, 0) AS dept_id,
       nvl(dept.name, '') AS dept_name,
       nvl(subject_shop_count.area_dept_id, 0) AS area_dept_id,
       nvl(subject_saler.subject_gmv, 0) AS subject_gmv,
       nvl(subject_saler.act_net_gmv, 0) AS act_net_gmv,
       nvl(subject_shop_count.shop_cnt, 0) AS subject_shop_cnt, -- 目标门店数
       NVL(subject_saler.order_shop_cnt,0) AS order_shop_cnt, -- 支付门店数
       nvl(subject_saler.visit_shop_cnt, 0) AS visit_shop_cnt, --拜访门店数
       nvl(subject_saler.valid_visit_shop_cnt, 0) AS valid_visit_shop_cnt, -- 有效拜访门店数
       nvl(subject_saler.valid_visit_order_shop_cnt, 0) AS valid_visit_order_shop_cnt --有效拜访下单门店数
FROM (
    SELECT
        subject_shop.subject_id,
        subject.group_type,
        shop_saler.user_id,
        dept_id,
        parent_dept_id AS area_dept_id,
        sum(CASE WHEN is_object_shop = 1 THEN 1 ELSE 0 END) AS shop_cnt
    FROM (
        SELECT id,group_type
        FROM ytdw.ods_vf_t_p0_subject
        WHERE is_deleted = 0
        AND status = 1
        AND feature_type = 1 --BD大类
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
LEFT JOIN (SELECT id,name	FROM ytdw.dwd_department_d WHERE dayid = '${v_date}') dept ON dept.id = subject_shop_count.dept_id
LEFT JOIN (
    SELECT subject_shop_gmv.subject_id,
           shop_saler.user_id,
           sum(nvl(subject_shop_gmv.subject_gmv,0)) as subject_gmv,
           sum(nvl(subject_shop_gmv.act_net_gmv,0)) as act_net_gmv,
           sum(IF(NVL(subject_shop_gmv.total_visit_times,0)>0,1,0)) as visit_shop_cnt,
           sum(IF(NVL(subject_shop_gmv.subject_gmv,0)>0,1,0)) AS order_shop_cnt,
           sum(NVL(subject_shop_gmv.valid_visit,0)) as valid_visit_shop_cnt,
           sum(NVL(subject_shop_gmv.valid_visit_order,0)) as valid_visit_order_shop_cnt
    FROM (
        SELECT subject_id,
               group_type,
               shop_id,
               subject_gmv,
               act_net_gmv,
               total_visit_times,
               valid_visit,
               valid_visit_order
        FROM yt_crm.nrt_p0_subject_shop_bd_h
        WHERE dayid = '${v_date}'
    ) subject_shop_gmv
    JOIN shop_saler ON shop_saler.shop_id = subject_shop_gmv.shop_id and shop_saler.group_type = subject_shop_gmv.group_type
	GROUP BY subject_shop_gmv.subject_id,
             shop_saler.user_id
) subject_saler ON subject_shop_count.user_id = subject_saler.user_id AND subject_shop_count.subject_id = subject_saler.subject_id