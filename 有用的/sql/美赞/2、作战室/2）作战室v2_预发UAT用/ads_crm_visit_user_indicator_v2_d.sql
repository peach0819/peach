with user as (
    SELECT user_id,
           user_root_key,
           user_parent_root_key
    FROM prod_mdson.ads_crm_visit_user_d
    WHERE dayid = '${v_date}'
),

display_indicator as (
    SELECT concat_ws(',', collect_list(if(need_single = 1, indicator_code, null))) as single_indicator,
           concat_ws(',', collect_list(if(need_total = 1, indicator_code, null))) as total_indicator,
           1 as join_tag
    FROM (
        SELECT 'month_visit_my_reach' as indicator_code, 1 as need_single, 0 as need_total
        UNION ALL
        SELECT 'quarter_visit_my_reach' as indicator_code, 1 as need_single, 0 as need_total
        UNION ALL
        SELECT 'month_visit_reach_rate' as indicator_code, 0 as need_single, 1 as need_total
        UNION ALL
        SELECT 'month_visit_freq_reach_rate' as indicator_code, 1 as need_single, 1 as need_total
        UNION ALL
        SELECT 'month_nc_visit_reach_rate' as indicator_code, 1 as need_single, 1 as need_total
        UNION ALL
        SELECT 'month_fws_visit_cover_rate' as indicator_code, 1 as need_single, 1 as need_total
        UNION ALL
        SELECT 'quarter_fws_visit_cover_rate' as indicator_code, 1 as need_single, 1 as need_total
        UNION ALL
        SELECT 'month_star_visit_reach_rate' as indicator_code, 1 as need_single, 1 as need_total
        UNION ALL
        SELECT 'month_shop_visit_reach_rate' as indicator_code, 1 as need_single, 1 as need_total
        UNION ALL
        SELECT 'quarter_all_big_visit_cover_rate' as indicator_code, 1 as need_single, 1 as need_total
        UNION ALL
        SELECT 'month_hospital_visit_reach_rate' as indicator_code, 1 as need_single, 1 as need_total
    ) t
),

indicator as (
    SELECT '${v_opt_month}' as data_month,
           d.user_id,
           visible.visible_config,

           --需要统计的指标
           display_indicator.single_indicator,
           display_indicator.total_indicator,

           --指标值
           d.biz_value
    FROM (
        SELECT *,
               1 as join_tag
        FROM prod_mdson.ads_crm_visit_base_summary_d
        WHERE dayid = '${v_date}'
    ) d
    INNER JOIN user ON d.user_id = user.user_id
    LEFT JOIN (
        SELECT user_id,
               visible_config
        FROM prod_mdson.ads_crm_visit_user_indicator_visible_d
        WHERE dayid = '${v_date}'
    ) visible ON visible.user_id = user.user_id
    LEFT JOIN display_indicator ON display_indicator.join_tag = d.join_tag
),

base_user as (
    SELECT user_id,

           --部门为 早阶用户发展(EMD)
           --部门为 华x区区域市场推广部门
           --角色为区域中台、区域中台N-1 7 10
           if(job_id IN (7, 10) OR size(array_intersect(split(brand_dept_root_name, '_'), ARRAY('华东区区域市场推广','华南区区域市场推广','华北区区域市场推广','华西区区域市场推广','早阶用户发展(EMD)'))) > 0, 1, 0) as need_filter
    FROM prod_mdson.dwd_hpc_user_admin_d
    WHERE pt = '${v_date}'
),

--区域前线的数据范围，4个大的省区
virtual_group as (
    SELECT id,
           leader_id
    FROM prod_mdson.dwd_hpc_virtual_group_d
    WHERE dayid = '${v_date}'
    AND leader_id is not NULL
    AND id IN (655414, 655415, 655426, 655427) --写死虚拟组
)

INSERT OVERWRITE TABLE ads_crm_visit_user_indicator_v2_d PARTITION (dayid = '${v_date}')
--我自己的
SELECT indicator.data_month as data_month,
       user.user_id,
       0 as tab_type,
       prod_mdson.mdson_indicator_single(
          indicator.single_indicator,
          indicator.biz_value
       ) as biz_value
FROM user
INNER JOIN indicator ON indicator.user_id = user.user_id

UNION ALL

--我团队的
SELECT /*+ mapjoin(user) */
       indicator.data_month as data_month,
       user.user_id,
       1 as tab_type,
       prod_mdson.mdson_indicator_total(
           indicator.total_indicator,
           indicator.biz_value,
           indicator.visible_config
       ) as biz_value
FROM user
INNER JOIN user sub ON user.user_root_key = sub.user_root_key OR locate(user.user_id, sub.user_parent_root_key) > 0 --表示contains
INNER JOIN indicator ON indicator.user_id = sub.user_id
group by indicator.data_month, user.user_id

UNION ALL

--我下属的
SELECT /*+ mapjoin(user) */
       indicator.data_month as data_month,
       user.user_id,
       2 as tab_type,
       prod_mdson.mdson_indicator_total(
           indicator.total_indicator,
           indicator.biz_value,
           indicator.visible_config
       ) as biz_value
FROM user
INNER JOIN user sub ON locate(user.user_id, sub.user_parent_root_key) > 0 --表示contains
INNER JOIN indicator ON indicator.user_id = sub.user_id
group by indicator.data_month, user.user_id

UNION ALL

--区域前线total
SELECT /*+ mapjoin(user) */
       indicator.data_month as data_month,
       'admin' as user_id,
       4 as tab_type,
       prod_mdson.mdson_indicator_total(
           indicator.total_indicator,
           indicator.biz_value,
           indicator.visible_config
       ) as biz_value
FROM user
INNER JOIN user sub ON user.user_root_key = sub.user_root_key OR locate(user.user_id, sub.user_parent_root_key) > 0 --表示contains
INNER JOIN indicator ON indicator.user_id = sub.user_id
INNER JOIN virtual_group ON virtual_group.leader_id = user.user_id
INNER JOIN base_user ON sub.user_id = base_user.user_id
WHERE base_user.need_filter = 0
group by indicator.data_month

UNION ALL

--区域前线具体人员数据
SELECT /*+ mapjoin(user,virtual_group) */
       indicator.data_month as data_month,
       user.user_id as user_id,
       4 as tab_type,
       prod_mdson.mdson_indicator_total(
           indicator.total_indicator,
           indicator.biz_value,
           indicator.visible_config
       ) as biz_value
FROM user
INNER JOIN user sub ON user.user_root_key = sub.user_root_key OR locate(user.user_id, sub.user_parent_root_key) > 0 --表示contains
INNER JOIN indicator ON indicator.user_id = sub.user_id
INNER JOIN virtual_group ON sub.user_root_key like concat('%', virtual_group.leader_id, '%') --表示contains
INNER JOIN base_user ON sub.user_id = base_user.user_id
WHERE base_user.need_filter = 0
group by indicator.data_month, user.user_id