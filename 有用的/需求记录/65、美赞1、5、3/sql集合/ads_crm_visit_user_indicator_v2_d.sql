with indicator as (
    SELECT data_month,
           user_id,
           --达标
           if_visit_qualified_month as if_visit_qualified,

           --门店拜访频次达成率
           month_visit_valid_cnt,
           visit_m_target,
           month_visit_valid_rate,

           --NKA专职NC门店拜访达成率
           month_nka_nc_visit_valid_cnt,
           month_nka_sever_obj_m,
           month_nka_nc_visit_valid_rate,

           --RKA专职NC门店拜访达成率
           month_rka_nc_visit_valid_cnt,
           month_rka_sever_obj_m,
           month_rka_nc_visit_valid_rate,

           --院线店拜访达成率
           month_hospital_visit_valid_cnt,
           month_hospital_sever_obj_m,
           month_hospital_visit_valid_rate,

           --门店拜访覆盖率
           month_shop_visit_valid_cnt,
           month_sever_obj_m,
           month_shop_visit_valid_rate,

           --月度服务商拜访达成率
           month_fws_visit_valid_cnt,
           month_fws_sever_obj_m,
           month_fws_visit_valid_rate,

           --季度服务商拜访达成率
           quar_fws_visit_valid_cnt,
           quar_fws_sever_obj_m,
           quar_fws_visit_valid_rate,

           --月度GT渠道门店拜访覆盖率
           month_gt_shop_visit_valid_cnt,
           month_gt_sever_obj_m,
           month_gt_shop_visit_valid_rate,

           --季度GT渠道门店拜访覆盖率
           quar_gt_shop_visit_valid_cnt,
           quar_gt_sever_obj_m,
           quar_gt_shop_visit_valid_rate
    FROM p_mdson.ads_mdson_user_new_visit_summary_data_d
    WHERE dayid = '${v_date}'
),

user as (
    SELECT user_id,
           user_root_key,
           user_parent_root_key
    FROM p_mdson.ads_crm_visit_user_d
    WHERE dayid = '${v_date}'
),

base_user as (
    SELECT user_id,
           job_id,
           channel_id,
           brand_dept_virtual_group_id
    FROM p_mdson.dwd_hpc_user_admin_d
    WHERE pt = '${v_date}'
),

visible as (
    SELECT user_id,
           split(visible_config, ',') as indicator_config
    FROM p_mdson.ads_crm_visit_user_indicator_visible_d
    WHERE dayid = '${v_date}'
),

--区域前线的数据范围，4个大的省区
virtual_group as (
    SELECT id,
           leader_id
    FROM p_mdson.dwd_hpc_virtual_group_d
    WHERE dayid = '${v_date}'
    AND leader_id is not NULL
    AND id IN (655414, 655415, 655426, 655427) --写死虚拟组
)

INSERT OVERWRITE TABLE ads_crm_visit_user_indicator_v2_d PARTITION (dayid = '${v_date}')
--我自己的
SELECT indicator.data_month as data_month,
       user.user_id,
       0 as tab_type,
       to_json(named_struct(
           'user_cnt', 1,

           --当月我的拜访达标
           'month_visit_my_reach', if_visit_qualified,

           --门店拜访频次达成率
           'month_visit_freq_valid_rate', month_visit_valid_rate * 100,
           'month_visit_freq_valid_rate_numerator', month_visit_valid_cnt,
           'month_visit_freq_valid_rate_denominator', visit_m_target,
           'month_visit_freq_valid_rate_reach', '达标',

           --NKA专职NC门店拜访达成率
           'month_nka_nc_visit_valid_rate', month_nka_nc_visit_valid_rate * 100,
           'month_nka_nc_visit_valid_rate_numerator', month_nka_nc_visit_valid_cnt,
           'month_nka_nc_visit_valid_rate_denominator', month_nka_sever_obj_m,
           'month_nka_nc_visit_valid_rate_reach', '达标',

          --RKA专职NC门店拜访达成率
           'month_rka_nc_visit_valid_rate', month_rka_nc_visit_valid_rate * 100,
           'month_rka_nc_visit_valid_rate_numerator', month_rka_nc_visit_valid_cnt,
           'month_rka_nc_visit_valid_rate_denominator', month_rka_sever_obj_m,
           'month_rka_nc_visit_valid_rate_reach', '达标',

           --院线店拜访达成率
           'month_hospital_visit_valid_rate', month_hospital_visit_valid_rate * 100,
           'month_hospital_visit_valid_rate_numerator', month_hospital_visit_valid_cnt,
           'month_hospital_visit_valid_rate_denominator', month_hospital_sever_obj_m,
           'month_hospital_visit_valid_rate_reach', '达标',

           --门店拜访覆盖率
           'month_shop_visit_valid_rate', month_shop_visit_valid_rate * 100,
           'month_shop_visit_valid_rate_numerator', month_shop_visit_valid_cnt,
           'month_shop_visit_valid_rate_denominator', month_sever_obj_m,
           'month_shop_visit_valid_rate_reach', '达标',

           --月度服务商拜访达成率
           'month_fws_visit_valid_rate', month_fws_visit_valid_rate * 100,
           'month_fws_visit_valid_rate_numerator', month_fws_visit_valid_cnt,
           'month_fws_visit_valid_rate_denominator', month_fws_sever_obj_m,
           'month_fws_visit_valid_rate_reach', '达标',

           --季度服务商拜访达成率
           'quar_fws_visit_valid_rate', quar_fws_visit_valid_rate * 100,
           'quar_fws_visit_valid_rate_numerator', quar_fws_visit_valid_cnt,
           'quar_fws_visit_valid_rate_denominator', quar_fws_sever_obj_m,
           'quar_fws_visit_valid_rate_reach', '达标',

           --月度GT渠道门店拜访覆盖率
           'month_gt_shop_visit_valid_rate', month_gt_shop_visit_valid_rate * 100,
           'month_gt_shop_visit_valid_rate_numerator', month_gt_shop_visit_valid_cnt,
           'month_gt_shop_visit_valid_rate_denominator', month_gt_sever_obj_m,
           'month_gt_shop_visit_valid_rate_reach', '达标',

           --季度GT渠道门店拜访覆盖率
           'quar_gt_shop_visit_valid_rate', quar_gt_shop_visit_valid_rate * 100,
           'quar_gt_shop_visit_valid_rate_numerator', quar_gt_shop_visit_valid_cnt,
           'quar_gt_shop_visit_valid_rate_denominator', quar_gt_sever_obj_m,
           'quar_gt_shop_visit_valid_rate_reach', '达标'
       )) as biz_value
FROM user
INNER JOIN indicator ON indicator.user_id = user.user_id

UNION ALL

--我团队的
SELECT /*+ mapjoin(user) */
       indicator.data_month as data_month,
       user.user_id,
       1 as tab_type,
       to_json(named_struct(
           'user_cnt', count(sub.user_id),

           --当月拜访人员达标率
           'month_visit_reach_rate', round(100 * count(case when if_visit_qualified = '达标' then 1 else null end)/count(sub.user_id), 2),
           'month_visit_reach_rate_numerator', count(case when if_visit_qualified = '达标' then 1 else null end),
           'month_visit_reach_rate_denominator', count(sub.user_id),

           --门店拜访频次达成率
           'month_visit_freq_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), visit_m_target, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), month_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), visit_m_target, 0)), 2)),
           'month_visit_freq_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), month_visit_valid_cnt, 0)),
           'month_visit_freq_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), visit_m_target, 0)),

           --NKA专职NC门店拜访达成率
           'month_nka_nc_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_nc_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_sever_obj_m, 0)), 2)),
           'month_nka_nc_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_nc_visit_valid_cnt, 0)),
           'month_nka_nc_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_sever_obj_m, 0)),

          --RKA专职NC门店拜访达成率
           'month_rka_nc_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_nc_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_sever_obj_m, 0)), 2)),
           'month_rka_nc_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_nc_visit_valid_cnt, 0)),
           'month_rka_nc_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_sever_obj_m, 0)),

           --院线店拜访达成率
           'month_hospital_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_sever_obj_m, 0)), 2)),
           'month_hospital_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_visit_valid_cnt, 0)),
           'month_hospital_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_sever_obj_m, 0)),

           --门店拜访覆盖率
           'month_shop_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)), 2)),
           'month_shop_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0)),
           'month_shop_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)),

           --月度服务商拜访达成率
           'month_fws_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_sever_obj_m, 0)), 2)),
           'month_fws_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_visit_valid_cnt, 0)),
           'month_fws_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_sever_obj_m, 0)),

           --季度服务商拜访达成率
           'quar_fws_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_sever_obj_m, 0)), 2)),
           'quar_fws_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_visit_valid_cnt, 0)),
           'quar_fws_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_sever_obj_m, 0)),

           --月度GT渠道门店拜访覆盖率
           'month_gt_shop_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)), 2)),
           'month_gt_shop_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0)),
           'month_gt_shop_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)),

           --季度GT渠道门店拜访覆盖率
           'quar_gt_shop_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_shop_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_sever_obj_m, 0)), 2)),
           'quar_gt_shop_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_shop_visit_valid_cnt, 0)),
           'quar_gt_shop_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_sever_obj_m, 0))
       )) as biz_value
FROM user
INNER JOIN user sub ON user.user_root_key = sub.user_root_key OR locate(user.user_root_key, sub.user_parent_root_key) > 0 --表示contains
INNER JOIN indicator ON indicator.user_id = sub.user_id
LEFT JOIN visible ON visible.user_id = sub.user_id
INNER JOIN base_user ON sub.user_id = base_user.user_id
WHERE base_user.brand_dept_virtual_group_id NOT IN (655849, 655850, 655851, 655852) --部门为 早阶用户发展(EMD) 655849 655850 655851 655852
AND base_user.brand_dept_virtual_group_id NOT IN (655429, 655430, 655453, 655454) --部门为 华x区区域市场推广部门 655429, 655430, 655453, 655454
AND base_user.job_id NOT IN (7, 10) --角色为区域中台、区域中台N-1 7 10
group by indicator.data_month, user.user_id

UNION ALL

--我下属的
SELECT /*+ mapjoin(user) */
       indicator.data_month as data_month,
       user.user_id,
       2 as tab_type,
       to_json(named_struct(
                      'user_cnt', count(sub.user_id),

           --当月拜访人员达标率
           'month_visit_reach_rate', round(100 * count(case when if_visit_qualified = '达标' then 1 else null end)/count(sub.user_id), 2),
           'month_visit_reach_rate_numerator', count(case when if_visit_qualified = '达标' then 1 else null end),
           'month_visit_reach_rate_denominator', count(sub.user_id),

           --门店拜访频次达成率
           'month_visit_freq_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), visit_m_target, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), month_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), visit_m_target, 0)), 2)),
           'month_visit_freq_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), month_visit_valid_cnt, 0)),
           'month_visit_freq_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), visit_m_target, 0)),

           --NKA专职NC门店拜访达成率
           'month_nka_nc_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_nc_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_sever_obj_m, 0)), 2)),
           'month_nka_nc_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_nc_visit_valid_cnt, 0)),
           'month_nka_nc_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_sever_obj_m, 0)),

          --RKA专职NC门店拜访达成率
           'month_rka_nc_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_nc_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_sever_obj_m, 0)), 2)),
           'month_rka_nc_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_nc_visit_valid_cnt, 0)),
           'month_rka_nc_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_sever_obj_m, 0)),

           --院线店拜访达成率
           'month_hospital_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_sever_obj_m, 0)), 2)),
           'month_hospital_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_visit_valid_cnt, 0)),
           'month_hospital_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_sever_obj_m, 0)),

           --门店拜访覆盖率
           'month_shop_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)), 2)),
           'month_shop_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0)),
           'month_shop_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)),

           --月度服务商拜访达成率
           'month_fws_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_sever_obj_m, 0)), 2)),
           'month_fws_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_visit_valid_cnt, 0)),
           'month_fws_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_sever_obj_m, 0)),

           --季度服务商拜访达成率
           'quar_fws_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_sever_obj_m, 0)), 2)),
           'quar_fws_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_visit_valid_cnt, 0)),
           'quar_fws_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_sever_obj_m, 0)),

           --月度GT渠道门店拜访覆盖率
           'month_gt_shop_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)), 2)),
           'month_gt_shop_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0)),
           'month_gt_shop_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)),

           --季度GT渠道门店拜访覆盖率
           'quar_gt_shop_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_shop_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_sever_obj_m, 0)), 2)),
           'quar_gt_shop_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_shop_visit_valid_cnt, 0)),
           'quar_gt_shop_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_sever_obj_m, 0))
       )) as biz_value
FROM user
INNER JOIN user sub ON locate(user.user_root_key, sub.user_parent_root_key) > 0 --表示contains
INNER JOIN indicator ON indicator.user_id = sub.user_id
LEFT JOIN visible ON visible.user_id = sub.user_id
INNER JOIN base_user ON sub.user_id = base_user.user_id
WHERE base_user.brand_dept_virtual_group_id NOT IN (655849, 655850, 655851, 655852) --部门为 早阶用户发展(EMD) 655849 655850 655851 655852
AND base_user.brand_dept_virtual_group_id NOT IN (655429, 655430, 655453, 655454) --部门为 华x区区域市场推广部门 655429, 655430, 655453, 655454
AND base_user.job_id NOT IN (7, 10) --角色为区域中台、区域中台N-1 7 10
group by indicator.data_month, user.user_id

UNION ALL

--区域前线total
SELECT /*+ mapjoin(user) */
       indicator.data_month as data_month,
       'admin' as user_id,
       4 as tab_type,
       to_json(named_struct(
                      'user_cnt', count(sub.user_id),

           --当月拜访人员达标率
           'month_visit_reach_rate', round(100 * count(case when if_visit_qualified = '达标' then 1 else null end)/count(sub.user_id), 2),
           'month_visit_reach_rate_numerator', count(case when if_visit_qualified = '达标' then 1 else null end),
           'month_visit_reach_rate_denominator', count(sub.user_id),

           --门店拜访频次达成率
           'month_visit_freq_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), visit_m_target, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), month_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), visit_m_target, 0)), 2)),
           'month_visit_freq_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), month_visit_valid_cnt, 0)),
           'month_visit_freq_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), visit_m_target, 0)),

           --NKA专职NC门店拜访达成率
           'month_nka_nc_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_nc_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_sever_obj_m, 0)), 2)),
           'month_nka_nc_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_nc_visit_valid_cnt, 0)),
           'month_nka_nc_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_sever_obj_m, 0)),

          --RKA专职NC门店拜访达成率
           'month_rka_nc_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_nc_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_sever_obj_m, 0)), 2)),
           'month_rka_nc_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_nc_visit_valid_cnt, 0)),
           'month_rka_nc_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_sever_obj_m, 0)),

           --院线店拜访达成率
           'month_hospital_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_sever_obj_m, 0)), 2)),
           'month_hospital_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_visit_valid_cnt, 0)),
           'month_hospital_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_sever_obj_m, 0)),

           --门店拜访覆盖率
           'month_shop_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)), 2)),
           'month_shop_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0)),
           'month_shop_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)),

           --月度服务商拜访达成率
           'month_fws_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_sever_obj_m, 0)), 2)),
           'month_fws_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_visit_valid_cnt, 0)),
           'month_fws_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_sever_obj_m, 0)),

           --季度服务商拜访达成率
           'quar_fws_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_sever_obj_m, 0)), 2)),
           'quar_fws_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_visit_valid_cnt, 0)),
           'quar_fws_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_sever_obj_m, 0)),

           --月度GT渠道门店拜访覆盖率
           'month_gt_shop_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)), 2)),
           'month_gt_shop_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0)),
           'month_gt_shop_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)),

           --季度GT渠道门店拜访覆盖率
           'quar_gt_shop_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_shop_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_sever_obj_m, 0)), 2)),
           'quar_gt_shop_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_shop_visit_valid_cnt, 0)),
           'quar_gt_shop_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_sever_obj_m, 0))
       )) as biz_value
FROM user
INNER JOIN user sub ON user.user_root_key = sub.user_root_key OR locate(user.user_root_key, sub.user_parent_root_key) > 0 --表示contains
INNER JOIN indicator ON indicator.user_id = sub.user_id
INNER JOIN virtual_group ON virtual_group.leader_id = user.user_id
LEFT JOIN visible ON visible.user_id = sub.user_id
INNER JOIN base_user ON sub.user_id = base_user.user_id
WHERE base_user.brand_dept_virtual_group_id NOT IN (655849, 655850, 655851, 655852) --部门为 早阶用户发展(EMD) 655849 655850 655851 655852
AND base_user.brand_dept_virtual_group_id NOT IN (655429, 655430, 655453, 655454) --部门为 华x区区域市场推广部门 655429, 655430, 655453, 655454
AND base_user.job_id NOT IN (7, 10) --角色为区域中台、区域中台N-1 7 10
group by indicator.data_month

UNION ALL

--区域前线具体人员数据
SELECT /*+ mapjoin(user,virtual_group) */
       indicator.data_month as data_month,
       user.user_id as user_id,
       4 as tab_type,
       to_json(named_struct(
                      'user_cnt', count(sub.user_id),

           --当月拜访人员达标率
           'month_visit_reach_rate', round(100 * count(case when if_visit_qualified = '达标' then 1 else null end)/count(sub.user_id), 2),
           'month_visit_reach_rate_numerator', count(case when if_visit_qualified = '达标' then 1 else null end),
           'month_visit_reach_rate_denominator', count(sub.user_id),

           --门店拜访频次达成率
           'month_visit_freq_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), visit_m_target, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), month_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), visit_m_target, 0)), 2)),
           'month_visit_freq_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), month_visit_valid_cnt, 0)),
           'month_visit_freq_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), visit_m_target, 0)),

           --NKA专职NC门店拜访达成率
           'month_nka_nc_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_nc_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_sever_obj_m, 0)), 2)),
           'month_nka_nc_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_nc_visit_valid_cnt, 0)),
           'month_nka_nc_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), month_nka_sever_obj_m, 0)),

          --RKA专职NC门店拜访达成率
           'month_rka_nc_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_nc_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_sever_obj_m, 0)), 2)),
           'month_rka_nc_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_nc_visit_valid_cnt, 0)),
           'month_rka_nc_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), month_rka_sever_obj_m, 0)),

           --院线店拜访达成率
           'month_hospital_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_sever_obj_m, 0)), 2)),
           'month_hospital_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_visit_valid_cnt, 0)),
           'month_hospital_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), month_hospital_sever_obj_m, 0)),

           --门店拜访覆盖率
           'month_shop_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)), 2)),
           'month_shop_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0)),
           'month_shop_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)),

           --月度服务商拜访达成率
           'month_fws_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_sever_obj_m, 0)), 2)),
           'month_fws_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_visit_valid_cnt, 0)),
           'month_fws_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), month_fws_sever_obj_m, 0)),

           --季度服务商拜访达成率
           'quar_fws_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_sever_obj_m, 0)), 2)),
           'quar_fws_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_visit_valid_cnt, 0)),
           'quar_fws_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), quar_fws_sever_obj_m, 0)),

           --月度GT渠道门店拜访覆盖率
           'month_gt_shop_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)), 2)),
           'month_gt_shop_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_shop_visit_valid_cnt, 0)),
           'month_gt_shop_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), month_gt_sever_obj_m, 0)),

           --季度GT渠道门店拜访覆盖率
           'quar_gt_shop_visit_valid_rate', if(sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_sever_obj_m, 0)) = 0, null, round(100 * sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_shop_visit_valid_cnt, 0))/sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_sever_obj_m, 0)), 2)),
           'quar_gt_shop_visit_valid_rate_numerator', sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_shop_visit_valid_cnt, 0)),
           'quar_gt_shop_visit_valid_rate_denominator', sum(if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), quar_gt_sever_obj_m, 0))
       )) as biz_value
FROM user
INNER JOIN user sub ON user.user_root_key = sub.user_root_key OR locate(user.user_root_key, sub.user_parent_root_key) > 0 --表示contains
INNER JOIN indicator ON indicator.user_id = sub.user_id
INNER JOIN virtual_group ON locate(sub.user_root_key, virtual_group.leader_id) > 0 --表示contains
LEFT JOIN visible ON visible.user_id = sub.user_id
INNER JOIN base_user ON sub.user_id = base_user.user_id
WHERE base_user.brand_dept_virtual_group_id NOT IN (655849, 655850, 655851, 655852) --部门为 早阶用户发展(EMD) 655849 655850 655851 655852
AND base_user.brand_dept_virtual_group_id NOT IN (655429, 655430, 655453, 655454) --部门为 华x区区域市场推广部门 655429, 655430, 655453, 655454
AND base_user.job_id NOT IN (7, 10) --角色为区域中台、区域中台N-1 7 10
group by indicator.data_month, user.user_id