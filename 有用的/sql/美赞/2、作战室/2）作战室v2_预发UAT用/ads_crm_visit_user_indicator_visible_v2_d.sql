with user as (
    SELECT user_id
    FROM prod_mdson.ads_crm_visit_user_d
    WHERE dayid = '${v_date}'
),

visible as (
    SELECT job_id,
           channel_id,
           indicator_id
    FROM prod_mdson.dwd_crm_visit_indicator_visible_v2_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
),

indicator as (
    SELECT id,
           indicator_code
    FROM prod_mdson.dwd_crm_visit_indicator_d
    WHERE is_deleted = 0
    AND dayid = '${v_date}'
),

base_user as (
    SELECT user_id,
           case when user_id = '6f0dfa170c9049da98e884a5f6591003' then 28 else job_id end as job_id, --胡志伟写死城市群负责人
           channel_id
    FROM prod_mdson.dwd_hpc_user_admin_d
    WHERE pt = '${v_date}'
)

INSERT OVERWRITE TABLE ads_crm_visit_user_indicator_visible_v2_d PARTITION (dayid = '${v_date}')
SELECT user.user_id,
       concat_ws(',' , sort_array(collect_set(indicator.indicator_code))) as visible_indicator
FROM user
INNER JOIN base_user ON user.user_id = base_user.user_id
INNER JOIN visible ON visible.job_id = base_user.job_id AND (visible.channel_id is null OR visible.channel_id = base_user.channel_id)
INNER JOIN indicator ON indicator.id = visible.indicator_id
group by user.user_id