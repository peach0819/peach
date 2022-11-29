use ytdw;

CREATE TABLE if not exists ads_crm_subject_item_by_brand_d (
  subject_id string comment '项目id',
  item_id string comment '商品id'
)
comment '项目根据品牌计算对应商品范围'
partitioned by (dayid string)
stored as orc;

WITH all_item AS (
    SELECT id AS item_id,
           brand AS brand_id
    FROM ytdw.dwd_item_d
    WHERE dayid = '$v_date'
    AND inuse = 1
    AND bu_id = 0
    AND item_style = 0
),

subject_item as (
    SELECT subject_id,
           include_flag,
           biz_ids
    FROM ytdw.dwd_p0_subject_item_d
    WHERE dayid = '$v_date'
    AND is_deleted = 0
    AND object_type = 1
),

subject_main as (
    SELECT subject.id,
           subject_item.include_flag
    FROM (
        SELECT id
        FROM ytdw.dwd_p0_subject_d
        WHERE dayid = '$v_date'
        AND status = 1
        AND feature_type = 2
    ) subject
    LEFT JOIN subject_item ON subject.id = subject_item.subject_id
),

subject_brand as (
    SELECT subject_id,
           brand_id
    FROM subject_item
    LATERAL VIEW explode(split(biz_ids, ',')) num AS brand_id
)

INSERT OVERWRITE TABLE ads_crm_subject_item_by_brand_d PARTITION (dayid='$v_date')
SELECT subject_main.id as subject_id,
       all_item.item_id
FROM subject_main
CROSS JOIN all_item ON 1 = 1
LEFT JOIN subject_brand ON subject_main.id = subject_brand.subject_id AND all_item.brand_id = subject_brand.brand_id
WHERE subject_main.include_flag is null
OR (subject_main.include_flag = 1 AND subject_brand.subject_id is not null)  --包含
OR (subject_main.include_flag = 2 AND subject_brand.subject_id is null)      --不包含