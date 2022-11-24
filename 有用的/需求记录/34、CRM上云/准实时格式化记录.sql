WITH all_item AS (
    select id as item_id,
           item_style,
           category_id_first,
           item_type,
           brand as brand_id
    from rtdw.ods_vf_t_item
    where inuse = 1
    and bu_id = 0
),

subject_item as (
    SELECT subject_id,
           include_flag,
           biz_ids
    FROM rtdw.ods_vf_t_p0_subject_item
    WHERE is_deleted = 0
    AND object_type = 1
),

subject_main as (
    SELECT subject.id,
           subject_item.include_flag,
           if(subject.feature_type = 1, 1, 0) as item_style
    FROM (
        SELECT id,
               feature_type
        FROM rtdw.ods_vf_t_p0_subject
        WHERE status = 1
        AND is_deleted = 0
    ) subject
    LEFT JOIN subject_item ON subject.id = subject_item.subject_id
),

subject_biz as (
    SELECT subject_id,
           biz_id
    FROM subject_item
    LATERAL VIEW explode(split(biz_ids, ',')) num AS biz_id
)

INSERT OVERWRITE TABLE ads_crm_subject_item_by_brand_h PARTITION (dayid='$v_date')
SELECT subject_main.id as subject_id,
       all_item.item_id
FROM subject_main
CROSS JOIN all_item ON subject_main.item_style = all_item.item_style
LEFT JOIN subject_biz ON subject_main.id = subject_biz.subject_id AND all_item.brand_id = subject_biz.biz_id
WHERE subject_main.include_flag is null
OR (subject_main.include_flag = 1 AND subject_biz.subject_id is not null)  --包含
OR (subject_main.include_flag = 2 AND subject_biz.subject_id is null)      --不包含