with subject as (
    SELECT subject.id,
           subject.subject_name,
           subject.object_shop_type,
           subject.shop_cluster_id,
           if(subject.refresh_type = 0, log.create_date, '${v_date}') as refresh_date,
           feature.group_type_tag
    FROM (
        SELECT id,
               subject_name,
               object_shop_type,
               shop_cluster_id,
               refresh_type,
               group_type
        FROM ytdw.dwd_p0_subject_d
        WHERE dayid = '${v_date}'
        AND status = 1
    ) subject
    LEFT JOIN (
        SELECT biz_id as subject_id,
               substr(create_time, 0, 8) as create_date
        FROM ytdw.dwd_crm_log_d
        WHERE dayid = '${v_date}'
        AND biz_type = 'P0_SUBJECT'
        AND operation_type = 'PUBLISH'
    ) log ON subject.id = log.subject_id
    LEFT JOIN (
        SELECT group_type,
               group_type_tag
        FROM yt_crm.ads_crm_subject_feature_group_d
        WHERE dayid = '${v_date}'
    ) feature ON subject.group_type = feature.group_type
),

shop_user as (
    SELECT group_type_tag,
           shop_id,
           shop_name,
           province_id,
           city_id,
           area_id,
           address_id,
           user_id,
           dept_id,
           parent_dept_id,
           parent_2_dept_id,
           latitude,
           longitude
    FROM yt_crm.ads_crm_subject_shop_user_d
    WHERE dayid = '${v_date}'
),

shop_group as (
    SELECT group_id,
           shop_id,
           dayid
    FROM ytdw.ads_dmp_group_data_d
    WHERE dayid > '0'
),

--门店统计范围为 指定圈选 的项目
with_dmp as (
    SELECT subject.id as subject_id,
           shop_user.shop_id,
           shop_user.shop_name,
           shop_user.province_id,
           shop_user.city_id,
           shop_user.area_id,
           shop_user.address_id,
           shop_user.user_id,
           shop_user.dept_id,
           shop_user.parent_dept_id,
           shop_user.parent_2_dept_id,
           shop_user.latitude,
           shop_user.longitude
    FROM subject
    INNER JOIN shop_user ON subject.group_type_tag = shop_user.group_type_tag
    INNER JOIN shop_group ON subject.refresh_date = shop_group.dayid AND subject.shop_cluster_id = shop_group.group_id AND shop_user.shop_id = shop_group.shop_id
    WHERE subject.object_shop_type = 2
),

--门店统计范围为 所有门店 的项目
without_dmp as (
    SELECT subject.id as subject_id,
           shop_user.shop_id,
           shop_user.shop_name,
           shop_user.province_id,
           shop_user.city_id,
           shop_user.area_id,
           shop_user.address_id,
           shop_user.user_id,
           shop_user.dept_id,
           shop_user.parent_dept_id,
           shop_user.parent_2_dept_id,
           shop_user.latitude,
           shop_user.longitude
    FROM subject
    INNER JOIN shop_user ON subject.group_type_tag = shop_user.group_type_tag
    WHERE subject.object_shop_type = 1
)

INSERT OVERWRITE TABLE ads_crm_subject_shop_d partition (dayid='${v_date}')
SELECT * FROM with_dmp
UNION ALL
SELECT * FROM without_dmp