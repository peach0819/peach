with base as (
    SELECT *
    FROM yt_crm.ads_crm_a2_subject_shop_base_d
    WHERE dayid = '${v_date}'
),

subject as (
    SELECT subject_id
    FROM yt_crm.ads_crm_a2_subject_base_d
    WHERE dayid = '${v_date}'
    AND need_stats = 1
)

INSERT OVERWRITE TABLE ads_crm_a2_subject_shop_base_sync_d PARTITION(dayid='${v_date}')
SELECT base.subject_id,
       base.subject_type,
       base.subject_type_id,
       base.subject_month,
       base.shop_id,
       base.shop_code,
       base.shop_name,
       base.province_id,
       base.province_name,
       base.city_id,
       base.city_name,
       base.area_id,
       base.area_name,
       base.street_id,
       base.street_name,
       base.sale_id,
       base.sale_name,
       base.sale_user_id,
       base.has_visit,
       base.has_valid_visit,
       base.has_order,
       base.offtake
FROM base
INNER JOIN subject ON base.subject_id = subject.subject_id