with subject as (
    SELECT id,
           subject_name,
           memo,
           status,
           subject_month,
           do_start,
           do_end,
           shop_cluster_id,
           case when feature_type = 1 then '新签'
                when feature_type = 2 then '复购'
                else null end as subject_type
    FROM ytdw.dwd_p0_subject_d
    WHERE dayid = DATE_FORMAT(DATE_SUB(CURRENT_DATE, 1), 'yyyyMMdd')  --这里永远取最新的分区数据
    AND dmp_id is not null
),

scope as (
    SELECT subject_id,
           need_stats,
           shop_type
    FROM yt_crm.ads_crm_a2_subject_scope_d
    WHERE dayid = DATE_FORMAT(DATE_SUB(CURRENT_DATE, 1), 'yyyyMMdd')  --这里永远取最新的分区数据
)

INSERT OVERWRITE TABLE ads_crm_a2_subject_base_d PARTITION(dayid = '${v_date}')
SELECT id,
       subject_name,
       memo,
       status,
       subject_type,
       subject_month,
       do_start,
       do_end,
       shop_cluster_id,
       scope.need_stats,
       scope.shop_type
FROM subject
INNER JOIN scope ON subject.id = scope.subject_id
WHERE subject_month = substr('${v_date}', 1, 6)