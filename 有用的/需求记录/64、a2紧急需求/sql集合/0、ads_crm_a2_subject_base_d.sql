with subject as (
    SELECT *,
           case when id IN (11228, 11229) then '复购'
                when id IN (11269) then '新签'
                else null end as a2_subject_type
    FROM ytdw.dwd_p0_subject_d
    WHERE dayid = DATE_FORMAT(DATE_SUB(CURRENT_DATE, 1), 'yyyyMMdd')  --这里永远取最新的分区数据
    AND id IN (11228, 11229, 11269)
    AND dmp_id is not null
)

INSERT OVERWRITE TABLE ads_crm_a2_subject_base_d PARTITION(dayid = '${v_date}')
SELECT id,
       subject_name,
       memo,
       status,
       a2_subject_type,
       subject_month,
       do_start,
       do_end,
       shop_cluster_id
FROM subject
WHERE subject_month = substr('${v_date}', 1, 6)