WITH all_item AS (
    SELECT id AS item_id, item_style, category_id_first, item_type, brand AS brand_id
    FROM ytdw.dwd_item_d
    WHERE dayid = '${v_date}'
      AND inuse = 1
      AND bu_id = 0
),

-- 包含品牌
subject_include_brand AS (
    SELECT subject_main.id AS subject_id, all_item.item_id
    FROM (
        SELECT id,
               CASE feature_type
                   WHEN 1 THEN 1
                   ELSE 0
                   END AS item_style
        FROM ytdw.dwd_p0_subject_d
        WHERE dayid = '${v_date}'
        AND status = 1
        AND feature_type = 2
    ) subject_main
    JOIN (
        SELECT subject_id, item_style, brand_id
        FROM ytdw.dwd_p0_subject_item_d
        LATERAL VIEW explode(split(biz_ids, ',')) num AS brand_id
        WHERE dayid = '${v_date}'
        AND is_deleted = 0
        AND object_type = 1
        AND include_flag = 1
    ) subject_brand ON subject_main.id = subject_brand.subject_id
    JOIN all_item ON subject_main.item_style = subject_brand.item_style AND all_item.brand_id = subject_brand.brand_id
),

-- 不包含品牌范围
subject_exclude_brand AS (
    SELECT subject_main.id AS subject_id, all_item.item_id
    FROM (
        SELECT id,
               CASE feature_type
                   WHEN 1 THEN 1
                   ELSE 0
                   END AS item_style
        FROM ytdw.dwd_p0_subject_d
        WHERE dayid = '${v_date}'
          AND status = 1
          AND feature_type = 2
    ) subject_main
    JOIN (
        SELECT subject_id
        FROM ytdw.dwd_p0_subject_item_d
        WHERE dayid = '${v_date}'
        AND is_deleted = 0
        AND object_type = 1
        AND include_flag = 2
        GROUP BY subject_id
    ) exclude_subject ON subject_main.id = exclude_subject.subject_id
    JOIN all_item ON subject_main.item_style = all_item.item_style
    LEFT JOIN (
        SELECT subject_id, item_style, brand_id
        FROM ytdw.dwd_p0_subject_item_d
        LATERAL VIEW explode(split(biz_ids, ',')) num AS brand_id
        WHERE dayid = '${v_date}'
        AND is_deleted = 0
        AND object_type = 1
        AND include_flag = 2
    ) subject_brand ON subject_main.id = subject_brand.subject_id AND all_item.brand_id = subject_brand.brand_id
    WHERE subject_brand.subject_id IS NULL
),

-- 未配置品牌范围
subject_not_exist_brand AS (
    SELECT subject_item_style.subject_id, all_item.item_id
    FROM (
        SELECT subject_main.id AS subject_id, item_style
        FROM (
                 SELECT id,
                        CASE feature_type
                            WHEN 1 THEN 1
                            ELSE 0
                            END AS item_style
                 FROM ytdw.dwd_p0_subject_d
                 WHERE dayid = '${v_date}'
                   AND status = 1
                   AND feature_type = 2
             ) subject_main
                 LEFT JOIN (
            SELECT subject_id
            FROM ytdw.dwd_p0_subject_item_d
            WHERE dayid = '${v_date}'
              AND is_deleted = 0
              AND object_type = 1
            GROUP BY subject_id
        ) subject_brand ON subject_main.id = subject_brand.subject_id
        WHERE subject_brand.subject_id IS NULL
    ) subject_item_style JOIN all_item ON subject_item_style.item_style = all_item.item_style
)

INSERT OVERWRITE TABLE ads_crm_subject_item_by_brand_d PARTITION (dayid='${v_date}')
SELECT subject_id, item_id FROM subject_include_brand

UNION ALL

SELECT subject_id, item_id FROM subject_exclude_brand

UNION ALL

SELECT subject_id, item_id FROM subject_not_exist_brand