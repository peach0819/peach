with subject as (
    SELECT subject_id,
           subject_name,
           subject_desc,
           subject_status,
           subject_type,
           subject_month,
           subject_start_time,
           subject_end_time,
           1 as tag
    FROM yt_crm.ads_crm_a2_subject_base_d
    WHERE dayid = '${v_date}'
    AND need_stats = 1
),

subject_shop as (
    SELECT subject_id,
           count(shop_id) as shop_count,
           count(case when has_visit = 1 then 1 else null end) as visit_shop_count,
           count(case when has_valid_visit = 1 then 1 else null end) as valid_visit_shop_count,
           count(case when has_order = 1 then 1 else null end) as order_shop_count
    FROM yt_crm.ads_crm_a2_subject_shop_base_d
    WHERE dayid = '${v_date}'
    group by subject_id
),

month_quality_shop as (
    SELECT count(case when if_hpc_quality_shop = 1 then 1 else null end) as quality_shop_count,
           1 as tag
    FROM yt_bi.ads_hpc_quality_shop_detail_d
    WHERE dayid = DATE_FORMAT(DATE_SUB(CURRENT_DATE, 1), 'yyyyMMdd')
    AND data_month = substr('${v_date}', 1, 6)
    AND shop_prov_id IN (14, 18, 20)
)

INSERT OVERWRITE TABLE ads_crm_a2_subject_d partition(dayid = '${v_date}')
SELECT subject.subject_id,
       subject.subject_name,
       subject.subject_desc,
       subject.subject_status,
       subject.subject_type,
       case when subject.subject_type = '新签' then 1
            when subject.subject_type = '复购' then 2
            end,
       subject.subject_month,
       subject.subject_start_time,
       subject.subject_end_time,
       nvl(subject_shop.shop_count, 0) as shop_count,
       nvl(subject_shop.visit_shop_count, 0) as visit_shop_count,
       nvl(subject_shop.valid_visit_shop_count, 0) as valid_visit_shop_count,
       nvl(subject_shop.order_shop_count, 0) as order_shop_count,
       nvl(month_quality_shop.quality_shop_count, 0) as quality_shop_count,
       if(nvl(subject_shop.shop_count, 0) = 0, 0, round(100 * nvl(subject_shop.visit_shop_count, 0) /nvl(subject_shop.shop_count, 0), 1)) as visit_shop_rate
FROM subject
LEFT JOIN subject_shop ON subject.subject_id = subject_shop.subject_id
LEFT JOIN month_quality_shop ON subject.tag = month_quality_shop.tag