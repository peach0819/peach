with user as (
    SELECT user_id,
           user_root_key,
           user_parent_root_key
    FROM prod_mdson.ads_crm_visit_user_d
    WHERE dayid = '${v_date}'
),

visible as (
    SELECT user_id,
           split(visible_config, ',') as indicator_config
    FROM prod_mdson.ads_crm_visit_user_indicator_visible_d
    WHERE dayid = '${v_date}'
),

indicator as (
    SELECT data_month,
           d.user_id,
           --当月我的拜访达标 month_visit_reach_rate
           if_visit_qualified_month as month_visit_my_reach,
           if(array_contains(visible.indicator_config, 'month_visit_reach_rate'), 1, 0) as month_visit_reach_rate_cnt,
           if(array_contains(visible.indicator_config, 'month_visit_reach_rate') AND if_visit_qualified_month = '达标', 1, 0) as month_visit_reach_rate_reach_cnt,

           --门店拜访频次达成率 month_visit_freq_valid_rate
           month_visit_valid_cnt as month_visit_freq_valid_rate_numerator,
           visit_m_target as month_visit_freq_valid_rate_denominator,
           month_visit_valid_rate * 100 as month_visit_freq_valid_rate,
           month_visit_valid_rate_qualified as month_visit_freq_valid_rate_reach,
           if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate'), 1, 0) as month_visit_freq_valid_rate_cnt,
           if(array_contains(visible.indicator_config, 'month_visit_freq_valid_rate') AND month_visit_valid_rate_qualified = '达标', 1, 0) as month_visit_freq_valid_rate_reach_cnt,

           --NKA专职NC门店拜访达成率 month_nka_nc_visit_valid_rate
           month_nka_nc_visit_valid_cnt as month_nka_nc_visit_valid_rate_numerator,
           month_nka_sever_obj_m as month_nka_nc_visit_valid_rate_denominator,
           month_nka_nc_visit_valid_rate * 100 as month_nka_nc_visit_valid_rate,
           month_nka_nc_visit_valid_rate_qualified as month_nka_nc_visit_valid_rate_reach,
           if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate'), 1, 0) as month_nka_nc_visit_valid_rate_cnt,
           if(array_contains(visible.indicator_config, 'month_nka_nc_visit_valid_rate') AND month_nka_nc_visit_valid_rate_qualified = '达标', 1, 0) as month_nka_nc_visit_valid_rate_reach_cnt,

           --RKA专职NC门店拜访达成率 month_rka_nc_visit_valid_rate
           month_rka_nc_visit_valid_cnt as month_rka_nc_visit_valid_rate_numerator,
           month_rka_sever_obj_m as month_rka_nc_visit_valid_rate_denominator,
           month_rka_nc_visit_valid_rate * 100 as month_rka_nc_visit_valid_rate,
           month_rka_nc_visit_valid_rate_qualified as month_rka_nc_visit_valid_rate_reach,
           if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate'), 1, 0) as month_rka_nc_visit_valid_rate_cnt,
           if(array_contains(visible.indicator_config, 'month_rka_nc_visit_valid_rate') AND month_rka_nc_visit_valid_rate_qualified = '达标', 1, 0) as month_rka_nc_visit_valid_rate_reach_cnt,

           --门店拜访覆盖率 month_shop_visit_valid_rate
           month_shop_visit_valid_cnt as month_shop_visit_valid_rate_numerator,
           month_sever_obj_m as month_shop_visit_valid_rate_denominator,
           month_shop_visit_valid_rate * 100 as month_shop_visit_valid_rate,
           month_shop_visit_valid_rate_qualified as month_shop_visit_valid_rate_reach,
           if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate'), 1, 0) as month_shop_visit_valid_rate_cnt,
           if(array_contains(visible.indicator_config, 'month_shop_visit_valid_rate') AND month_shop_visit_valid_rate_qualified = '达标', 1, 0) as month_shop_visit_valid_rate_reach_cnt,

           --月度服务商拜访达成率 month_fws_visit_valid_rate
           month_fws_visit_valid_cnt as month_fws_visit_valid_rate_numerator,
           month_fws_sever_obj_m as month_fws_visit_valid_rate_denominator,
           month_fws_visit_valid_rate * 100 as month_fws_visit_valid_rate,
           month_fws_visit_valid_rate_qualified as month_fws_visit_valid_rate_reach,
           if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate'), 1, 0) as month_fws_visit_valid_rate_cnt,
           if(array_contains(visible.indicator_config, 'month_fws_visit_valid_rate') AND month_fws_visit_valid_rate_qualified = '达标', 1, 0) as month_fws_visit_valid_rate_reach_cnt,

           --季度服务商拜访达成率 quar_fws_visit_valid_rate
           quar_fws_visit_valid_cnt as quar_fws_visit_valid_rate_numerator,
           quar_fws_sever_obj_m as quar_fws_visit_valid_rate_denominator,
           quar_fws_visit_valid_rate * 100 as quar_fws_visit_valid_rate,
           quar_fws_visit_valid_rate_qualified as quar_fws_visit_valid_rate_reach,
           if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate'), 1, 0) as quar_fws_visit_valid_rate_cnt,
           if(array_contains(visible.indicator_config, 'quar_fws_visit_valid_rate') AND quar_fws_visit_valid_rate_qualified = '达标', 1, 0) as quar_fws_visit_valid_rate_reach_cnt,

           --月度GT渠道门店拜访覆盖率 month_gt_shop_visit_valid_rate
           month_gt_shop_visit_valid_cnt as month_gt_shop_visit_valid_rate_numerator,
           month_gt_sever_obj_m as month_gt_shop_visit_valid_rate_denominator,
           month_gt_shop_visit_valid_rate * 100 as month_gt_shop_visit_valid_rate,
           month_gt_shop_visit_valid_rate_qualified as month_gt_shop_visit_valid_rate_reach,
           if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate'), 1, 0) as month_gt_shop_visit_valid_rate_cnt,
           if(array_contains(visible.indicator_config, 'month_gt_shop_visit_valid_rate') AND month_gt_shop_visit_valid_rate_qualified = '达标', 1, 0) as month_gt_shop_visit_valid_rate_reach_cnt,

           --季度GT渠道门店拜访覆盖率 quar_gt_shop_visit_valid_rate
           quar_gt_shop_visit_valid_cnt as quar_gt_shop_visit_valid_rate_numerator,
           quar_gt_sever_obj_m as quar_gt_shop_visit_valid_rate_denominator,
           quar_gt_shop_visit_valid_rate * 100 as quar_gt_shop_visit_valid_rate,
           quar_gt_shop_visit_valid_rate_qualified as quar_gt_shop_visit_valid_rate_reach,
           if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate'), 1, 0) as quar_gt_shop_visit_valid_rate_cnt,
           if(array_contains(visible.indicator_config, 'quar_gt_shop_visit_valid_rate') AND quar_gt_shop_visit_valid_rate_qualified = '达标', 1, 0) as quar_gt_shop_visit_valid_rate_reach_cnt,

           --月度GT渠道院线店拜访覆盖率 month_gt_hospital_shop_visit_valid_rate
           month_gt_hospital_shop_visit_valid_cnt as month_gt_hospital_shop_visit_valid_rate_numerator,
           month_gt_hospital_sever_obj_m as month_gt_hospital_shop_visit_valid_rate_denominator,
           month_gt_hospital_shop_visit_valid_rate * 100 as month_gt_hospital_shop_visit_valid_rate,
           month_gt_hospital_shop_visit_valid_rate_qualified as month_gt_hospital_shop_visit_valid_rate_reach,
           if(array_contains(visible.indicator_config, 'month_gt_hospital_shop_visit_valid_rate'), 1, 0) as month_gt_hospital_shop_visit_valid_rate_cnt,
           if(array_contains(visible.indicator_config, 'month_gt_hospital_shop_visit_valid_rate') AND month_gt_hospital_shop_visit_valid_rate_qualified = '达标', 1, 0) as month_gt_hospital_shop_visit_valid_rate_reach_cnt,

           --季度GT渠道院线店拜访覆盖率 quar_gt_hospital_shop_visit_valid_rate
           quar_gt_hospital_shop_visit_valid_cnt as quar_gt_hospital_shop_visit_valid_rate_numerator,
           quar_gt_hospital_sever_obj_m as quar_gt_hospital_shop_visit_valid_rate_denominator,
           quar_gt_hospital_shop_visit_valid_rate * 100 as quar_gt_hospital_shop_visit_valid_rate,
           quar_gt_hospital_shop_visit_valid_rate_qualified as quar_gt_hospital_shop_visit_valid_rate_reach,
           if(array_contains(visible.indicator_config, 'quar_gt_hospital_shop_visit_valid_rate'), 1, 0) as quar_gt_hospital_shop_visit_valid_rate_cnt,
           if(array_contains(visible.indicator_config, 'quar_gt_hospital_shop_visit_valid_rate') AND quar_gt_hospital_shop_visit_valid_rate_qualified = '达标', 1, 0) as quar_gt_hospital_shop_visit_valid_rate_reach_cnt,

           --院线店拜访覆盖率 month_hospital_visit_valid_rate
           month_hospital_visit_valid_cnt_new as month_hospital_visit_valid_rate_numerator,
           month_hospital_sever_obj_m_new as month_hospital_visit_valid_rate_denominator,
           month_hospital_visit_valid_rate_new * 100 as month_hospital_visit_valid_rate,
           month_hospital_visit_valid_rate_new_qualified as month_hospital_visit_valid_rate_reach,
           if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate'), 1, 0) as month_hospital_visit_valid_rate_cnt,
           if(array_contains(visible.indicator_config, 'month_hospital_visit_valid_rate') AND month_hospital_visit_valid_rate_new_qualified = '达标', 1, 0) as month_hospital_visit_valid_rate_reach_cnt
    FROM (
        SELECT *
        FROM prod_mdson.ads_mdson_user_new_visit_summary_data_d
        WHERE dayid = '${v_date}'
    ) d
    INNER JOIN user ON d.user_id = user.user_id
    LEFT JOIN visible ON visible.user_id = user.user_id
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

INSERT OVERWRITE TABLE ads_crm_visit_user_indicator_d PARTITION (dayid = '${v_date}')
--我自己的
SELECT indicator.data_month as data_month,
       user.user_id,
       0 as tab_type,
       to_json(named_struct(
           'user_cnt', 1,

           --当月我的拜访达标
           'month_visit_my_reach', month_visit_my_reach,

           --门店拜访频次达成率
           'month_visit_freq_valid_rate', month_visit_freq_valid_rate,
           'month_visit_freq_valid_rate_numerator', month_visit_freq_valid_rate_numerator,
           'month_visit_freq_valid_rate_denominator', month_visit_freq_valid_rate_denominator,
           'month_visit_freq_valid_rate_reach', month_visit_freq_valid_rate_reach,

           --NKA专职NC门店拜访达成率
           'month_nka_nc_visit_valid_rate', month_nka_nc_visit_valid_rate,
           'month_nka_nc_visit_valid_rate_numerator', month_nka_nc_visit_valid_rate_numerator,
           'month_nka_nc_visit_valid_rate_denominator', month_nka_nc_visit_valid_rate_denominator,
           'month_nka_nc_visit_valid_rate_reach', month_nka_nc_visit_valid_rate_reach,

          --RKA专职NC门店拜访达成率
           'month_rka_nc_visit_valid_rate', month_rka_nc_visit_valid_rate,
           'month_rka_nc_visit_valid_rate_numerator', month_rka_nc_visit_valid_rate_numerator,
           'month_rka_nc_visit_valid_rate_denominator', month_rka_nc_visit_valid_rate_denominator,
           'month_rka_nc_visit_valid_rate_reach', month_rka_nc_visit_valid_rate_reach,

           --门店拜访覆盖率
           'month_shop_visit_valid_rate', month_shop_visit_valid_rate,
           'month_shop_visit_valid_rate_numerator', month_shop_visit_valid_rate_numerator,
           'month_shop_visit_valid_rate_denominator', month_shop_visit_valid_rate_denominator,
           'month_shop_visit_valid_rate_reach', month_shop_visit_valid_rate_reach,

           --月度服务商拜访达成率
           'month_fws_visit_valid_rate', month_fws_visit_valid_rate,
           'month_fws_visit_valid_rate_numerator', month_fws_visit_valid_rate_numerator,
           'month_fws_visit_valid_rate_denominator', month_fws_visit_valid_rate_denominator,
           'month_fws_visit_valid_rate_reach', month_fws_visit_valid_rate_reach,

           --季度服务商拜访达成率
           'quar_fws_visit_valid_rate', quar_fws_visit_valid_rate,
           'quar_fws_visit_valid_rate_numerator', quar_fws_visit_valid_rate_numerator,
           'quar_fws_visit_valid_rate_denominator', quar_fws_visit_valid_rate_denominator,
           'quar_fws_visit_valid_rate_reach', quar_fws_visit_valid_rate_reach,

           --月度GT渠道门店拜访覆盖率
           'month_gt_shop_visit_valid_rate', month_gt_shop_visit_valid_rate,
           'month_gt_shop_visit_valid_rate_numerator', month_gt_shop_visit_valid_rate_numerator,
           'month_gt_shop_visit_valid_rate_denominator', month_gt_shop_visit_valid_rate_denominator,
           'month_gt_shop_visit_valid_rate_reach', month_gt_shop_visit_valid_rate_reach,

           --季度GT渠道门店拜访覆盖率
           'quar_gt_shop_visit_valid_rate', quar_gt_shop_visit_valid_rate,
           'quar_gt_shop_visit_valid_rate_numerator', quar_gt_shop_visit_valid_rate_numerator,
           'quar_gt_shop_visit_valid_rate_denominator', quar_gt_shop_visit_valid_rate_denominator,
           'quar_gt_shop_visit_valid_rate_reach', quar_gt_shop_visit_valid_rate_reach,

           --月度GT渠道院线店拜访覆盖率
           'month_gt_hospital_shop_visit_valid_rate', month_gt_hospital_shop_visit_valid_rate,
           'month_gt_hospital_shop_visit_valid_rate_numerator', month_gt_hospital_shop_visit_valid_rate_numerator,
           'month_gt_hospital_shop_visit_valid_rate_denominator', month_gt_hospital_shop_visit_valid_rate_denominator,
           'month_gt_hospital_shop_visit_valid_rate_reach', month_gt_hospital_shop_visit_valid_rate_reach,

           --季度GT渠道院线店拜访覆盖率
           'quar_gt_hospital_shop_visit_valid_rate', quar_gt_hospital_shop_visit_valid_rate,
           'quar_gt_hospital_shop_visit_valid_rate_numerator', quar_gt_hospital_shop_visit_valid_rate_numerator,
           'quar_gt_hospital_shop_visit_valid_rate_denominator', quar_gt_hospital_shop_visit_valid_rate_denominator,
           'quar_gt_hospital_shop_visit_valid_rate_reach', quar_gt_hospital_shop_visit_valid_rate_reach,

           --院线店拜访覆盖率
           'month_hospital_visit_valid_rate', month_hospital_visit_valid_rate,
           'month_hospital_visit_valid_rate_numerator', month_hospital_visit_valid_rate_numerator,
           'month_hospital_visit_valid_rate_denominator', month_hospital_visit_valid_rate_denominator,
           'month_hospital_visit_valid_rate_reach', month_hospital_visit_valid_rate_reach
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
           'month_visit_reach_rate', if(sum(month_visit_reach_rate_cnt) = 0, null, round(100 * sum(month_visit_reach_rate_reach_cnt) / sum(month_visit_reach_rate_cnt), 2)),
           'month_visit_reach_rate_numerator', sum(month_visit_reach_rate_reach_cnt),
           'month_visit_reach_rate_denominator', sum(month_visit_reach_rate_cnt),

           --门店拜访频次达成率
           'month_visit_freq_valid_rate', if(sum(month_visit_freq_valid_rate_cnt) = 0, null, round(100 * sum(month_visit_freq_valid_rate_reach_cnt)/sum(month_visit_freq_valid_rate_cnt), 2)),
           'month_visit_freq_valid_rate_numerator', sum(month_visit_freq_valid_rate_reach_cnt),
           'month_visit_freq_valid_rate_denominator', sum(month_visit_freq_valid_rate_cnt),

           --NKA专职NC门店拜访达成率
           'month_nka_nc_visit_valid_rate', if(sum(month_nka_nc_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_nka_nc_visit_valid_rate_reach_cnt)/sum(month_nka_nc_visit_valid_rate_cnt), 2)),
           'month_nka_nc_visit_valid_rate_numerator', sum(month_nka_nc_visit_valid_rate_reach_cnt),
           'month_nka_nc_visit_valid_rate_denominator', sum(month_nka_nc_visit_valid_rate_cnt),

          --RKA专职NC门店拜访达成率
           'month_rka_nc_visit_valid_rate', if(sum(month_rka_nc_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_rka_nc_visit_valid_rate_reach_cnt)/sum(month_rka_nc_visit_valid_rate_cnt), 2)),
           'month_rka_nc_visit_valid_rate_numerator', sum(month_rka_nc_visit_valid_rate_reach_cnt),
           'month_rka_nc_visit_valid_rate_denominator', sum(month_rka_nc_visit_valid_rate_cnt),

           --门店拜访覆盖率
           'month_shop_visit_valid_rate', if(sum(month_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_shop_visit_valid_rate_reach_cnt)/sum(month_shop_visit_valid_rate_cnt), 2)),
           'month_shop_visit_valid_rate_numerator', sum(month_shop_visit_valid_rate_reach_cnt),
           'month_shop_visit_valid_rate_denominator', sum(month_shop_visit_valid_rate_cnt),

           --月度服务商拜访达成率
           'month_fws_visit_valid_rate', if(sum(month_fws_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_fws_visit_valid_rate_reach_cnt)/sum(month_fws_visit_valid_rate_cnt), 2)),
           'month_fws_visit_valid_rate_numerator', sum(month_fws_visit_valid_rate_reach_cnt),
           'month_fws_visit_valid_rate_denominator', sum(month_fws_visit_valid_rate_cnt),

           --季度服务商拜访达成率
           'quar_fws_visit_valid_rate', if(sum(quar_fws_visit_valid_rate_cnt) = 0, null, round(100 * sum(quar_fws_visit_valid_rate_reach_cnt)/sum(quar_fws_visit_valid_rate_cnt), 2)),
           'quar_fws_visit_valid_rate_numerator', sum(quar_fws_visit_valid_rate_reach_cnt),
           'quar_fws_visit_valid_rate_denominator', sum(quar_fws_visit_valid_rate_cnt),

           --月度GT渠道门店拜访覆盖率
           'month_gt_shop_visit_valid_rate', if(sum(month_gt_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_gt_shop_visit_valid_rate_reach_cnt)/sum(month_gt_shop_visit_valid_rate_cnt), 2)),
           'month_gt_shop_visit_valid_rate_numerator', sum(month_gt_shop_visit_valid_rate_reach_cnt),
           'month_gt_shop_visit_valid_rate_denominator', sum(month_gt_shop_visit_valid_rate_cnt),

           --季度GT渠道门店拜访覆盖率
           'quar_gt_shop_visit_valid_rate', if(sum(quar_gt_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(quar_gt_shop_visit_valid_rate_reach_cnt)/sum(quar_gt_shop_visit_valid_rate_cnt), 2)),
           'quar_gt_shop_visit_valid_rate_numerator', sum(quar_gt_shop_visit_valid_rate_reach_cnt),
           'quar_gt_shop_visit_valid_rate_denominator', sum(quar_gt_shop_visit_valid_rate_cnt),

           --月度GT渠道院线店拜访覆盖率
           'month_gt_hospital_shop_visit_valid_rate', if(sum(month_gt_hospital_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_gt_hospital_shop_visit_valid_rate_reach_cnt)/sum(month_gt_hospital_shop_visit_valid_rate_cnt), 2)),
           'month_gt_hospital_shop_visit_valid_rate_numerator', sum(month_gt_hospital_shop_visit_valid_rate_reach_cnt),
           'month_gt_hospital_shop_visit_valid_rate_denominator', sum(month_gt_hospital_shop_visit_valid_rate_cnt),

           --季度GT渠道院线店拜访覆盖率
           'quar_gt_hospital_shop_visit_valid_rate', if(sum(quar_gt_hospital_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(quar_gt_hospital_shop_visit_valid_rate_reach_cnt)/sum(quar_gt_hospital_shop_visit_valid_rate_cnt), 2)),
           'quar_gt_hospital_shop_visit_valid_rate_numerator', sum(quar_gt_hospital_shop_visit_valid_rate_reach_cnt),
           'quar_gt_hospital_shop_visit_valid_rate_denominator', sum(quar_gt_hospital_shop_visit_valid_rate_cnt),

           --院线店拜访覆盖率
           'month_hospital_visit_valid_rate', if(sum(month_hospital_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_hospital_visit_valid_rate_reach_cnt)/sum(month_hospital_visit_valid_rate_cnt), 2)),
           'month_hospital_visit_valid_rate_numerator', sum(month_hospital_visit_valid_rate_reach_cnt),
           'month_hospital_visit_valid_rate_denominator', sum(month_hospital_visit_valid_rate_cnt)
       )) as biz_value
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
       to_json(named_struct(
           'user_cnt', count(sub.user_id),

           --当月拜访人员达标率
           'month_visit_reach_rate', if(sum(month_visit_reach_rate_cnt) = 0, null, round(100 * sum(month_visit_reach_rate_reach_cnt) / sum(month_visit_reach_rate_cnt), 2)),
           'month_visit_reach_rate_numerator', sum(month_visit_reach_rate_reach_cnt),
           'month_visit_reach_rate_denominator', sum(month_visit_reach_rate_cnt),

           --门店拜访频次达成率
           'month_visit_freq_valid_rate', if(sum(month_visit_freq_valid_rate_cnt) = 0, null, round(100 * sum(month_visit_freq_valid_rate_reach_cnt)/sum(month_visit_freq_valid_rate_cnt), 2)),
           'month_visit_freq_valid_rate_numerator', sum(month_visit_freq_valid_rate_reach_cnt),
           'month_visit_freq_valid_rate_denominator', sum(month_visit_freq_valid_rate_cnt),

           --NKA专职NC门店拜访达成率
           'month_nka_nc_visit_valid_rate', if(sum(month_nka_nc_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_nka_nc_visit_valid_rate_reach_cnt)/sum(month_nka_nc_visit_valid_rate_cnt), 2)),
           'month_nka_nc_visit_valid_rate_numerator', sum(month_nka_nc_visit_valid_rate_reach_cnt),
           'month_nka_nc_visit_valid_rate_denominator', sum(month_nka_nc_visit_valid_rate_cnt),

          --RKA专职NC门店拜访达成率
           'month_rka_nc_visit_valid_rate', if(sum(month_rka_nc_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_rka_nc_visit_valid_rate_reach_cnt)/sum(month_rka_nc_visit_valid_rate_cnt), 2)),
           'month_rka_nc_visit_valid_rate_numerator', sum(month_rka_nc_visit_valid_rate_reach_cnt),
           'month_rka_nc_visit_valid_rate_denominator', sum(month_rka_nc_visit_valid_rate_cnt),

           --门店拜访覆盖率
           'month_shop_visit_valid_rate', if(sum(month_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_shop_visit_valid_rate_reach_cnt)/sum(month_shop_visit_valid_rate_cnt), 2)),
           'month_shop_visit_valid_rate_numerator', sum(month_shop_visit_valid_rate_reach_cnt),
           'month_shop_visit_valid_rate_denominator', sum(month_shop_visit_valid_rate_cnt),

           --月度服务商拜访达成率
           'month_fws_visit_valid_rate', if(sum(month_fws_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_fws_visit_valid_rate_reach_cnt)/sum(month_fws_visit_valid_rate_cnt), 2)),
           'month_fws_visit_valid_rate_numerator', sum(month_fws_visit_valid_rate_reach_cnt),
           'month_fws_visit_valid_rate_denominator', sum(month_fws_visit_valid_rate_cnt),

           --季度服务商拜访达成率
           'quar_fws_visit_valid_rate', if(sum(quar_fws_visit_valid_rate_cnt) = 0, null, round(100 * sum(quar_fws_visit_valid_rate_reach_cnt)/sum(quar_fws_visit_valid_rate_cnt), 2)),
           'quar_fws_visit_valid_rate_numerator', sum(quar_fws_visit_valid_rate_reach_cnt),
           'quar_fws_visit_valid_rate_denominator', sum(quar_fws_visit_valid_rate_cnt),

           --月度GT渠道门店拜访覆盖率
           'month_gt_shop_visit_valid_rate', if(sum(month_gt_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_gt_shop_visit_valid_rate_reach_cnt)/sum(month_gt_shop_visit_valid_rate_cnt), 2)),
           'month_gt_shop_visit_valid_rate_numerator', sum(month_gt_shop_visit_valid_rate_reach_cnt),
           'month_gt_shop_visit_valid_rate_denominator', sum(month_gt_shop_visit_valid_rate_cnt),

           --季度GT渠道门店拜访覆盖率
           'quar_gt_shop_visit_valid_rate', if(sum(quar_gt_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(quar_gt_shop_visit_valid_rate_reach_cnt)/sum(quar_gt_shop_visit_valid_rate_cnt), 2)),
           'quar_gt_shop_visit_valid_rate_numerator', sum(quar_gt_shop_visit_valid_rate_reach_cnt),
           'quar_gt_shop_visit_valid_rate_denominator', sum(quar_gt_shop_visit_valid_rate_cnt),

           --月度GT渠道院线店拜访覆盖率
           'month_gt_hospital_shop_visit_valid_rate', if(sum(month_gt_hospital_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_gt_hospital_shop_visit_valid_rate_reach_cnt)/sum(month_gt_hospital_shop_visit_valid_rate_cnt), 2)),
           'month_gt_hospital_shop_visit_valid_rate_numerator', sum(month_gt_hospital_shop_visit_valid_rate_reach_cnt),
           'month_gt_hospital_shop_visit_valid_rate_denominator', sum(month_gt_hospital_shop_visit_valid_rate_cnt),

           --季度GT渠道院线店拜访覆盖率
           'quar_gt_hospital_shop_visit_valid_rate', if(sum(quar_gt_hospital_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(quar_gt_hospital_shop_visit_valid_rate_reach_cnt)/sum(quar_gt_hospital_shop_visit_valid_rate_cnt), 2)),
           'quar_gt_hospital_shop_visit_valid_rate_numerator', sum(quar_gt_hospital_shop_visit_valid_rate_reach_cnt),
           'quar_gt_hospital_shop_visit_valid_rate_denominator', sum(quar_gt_hospital_shop_visit_valid_rate_cnt),

           --院线店拜访覆盖率
           'month_hospital_visit_valid_rate', if(sum(month_hospital_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_hospital_visit_valid_rate_reach_cnt)/sum(month_hospital_visit_valid_rate_cnt), 2)),
           'month_hospital_visit_valid_rate_numerator', sum(month_hospital_visit_valid_rate_reach_cnt),
           'month_hospital_visit_valid_rate_denominator', sum(month_hospital_visit_valid_rate_cnt)
       )) as biz_value
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
       to_json(named_struct(
           'user_cnt', count(sub.user_id),

           --当月拜访人员达标率
           'month_visit_reach_rate', if(sum(month_visit_reach_rate_cnt) = 0, null, round(100 * sum(month_visit_reach_rate_reach_cnt)/sum(month_visit_reach_rate_cnt), 2)),
           'month_visit_reach_rate_numerator', sum(month_visit_reach_rate_reach_cnt),
           'month_visit_reach_rate_denominator', sum(month_visit_reach_rate_cnt),

           --门店拜访频次达成率
           'month_visit_freq_valid_rate', if(sum(month_visit_freq_valid_rate_cnt) = 0, null, round(100 * sum(month_visit_freq_valid_rate_reach_cnt)/sum(month_visit_freq_valid_rate_cnt), 2)),
           'month_visit_freq_valid_rate_numerator', sum(month_visit_freq_valid_rate_reach_cnt),
           'month_visit_freq_valid_rate_denominator', sum(month_visit_freq_valid_rate_cnt),

           --NKA专职NC门店拜访达成率
           'month_nka_nc_visit_valid_rate', if(sum(month_nka_nc_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_nka_nc_visit_valid_rate_reach_cnt)/sum(month_nka_nc_visit_valid_rate_cnt), 2)),
           'month_nka_nc_visit_valid_rate_numerator', sum(month_nka_nc_visit_valid_rate_reach_cnt),
           'month_nka_nc_visit_valid_rate_denominator', sum(month_nka_nc_visit_valid_rate_cnt),

          --RKA专职NC门店拜访达成率
           'month_rka_nc_visit_valid_rate', if(sum(month_rka_nc_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_rka_nc_visit_valid_rate_reach_cnt)/sum(month_rka_nc_visit_valid_rate_cnt), 2)),
           'month_rka_nc_visit_valid_rate_numerator', sum(month_rka_nc_visit_valid_rate_reach_cnt),
           'month_rka_nc_visit_valid_rate_denominator', sum(month_rka_nc_visit_valid_rate_cnt),

           --门店拜访覆盖率
           'month_shop_visit_valid_rate', if(sum(month_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_shop_visit_valid_rate_reach_cnt)/sum(month_shop_visit_valid_rate_cnt), 2)),
           'month_shop_visit_valid_rate_numerator', sum(month_shop_visit_valid_rate_reach_cnt),
           'month_shop_visit_valid_rate_denominator', sum(month_shop_visit_valid_rate_cnt),

           --月度服务商拜访达成率
           'month_fws_visit_valid_rate', if(sum(month_fws_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_fws_visit_valid_rate_reach_cnt)/sum(month_fws_visit_valid_rate_cnt), 2)),
           'month_fws_visit_valid_rate_numerator', sum(month_fws_visit_valid_rate_reach_cnt),
           'month_fws_visit_valid_rate_denominator', sum(month_fws_visit_valid_rate_cnt),

           --季度服务商拜访达成率
           'quar_fws_visit_valid_rate', if(sum(quar_fws_visit_valid_rate_cnt) = 0, null, round(100 * sum(quar_fws_visit_valid_rate_reach_cnt)/sum(quar_fws_visit_valid_rate_cnt), 2)),
           'quar_fws_visit_valid_rate_numerator', sum(quar_fws_visit_valid_rate_reach_cnt),
           'quar_fws_visit_valid_rate_denominator', sum(quar_fws_visit_valid_rate_cnt),

           --月度GT渠道门店拜访覆盖率
           'month_gt_shop_visit_valid_rate', if(sum(month_gt_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_gt_shop_visit_valid_rate_reach_cnt)/sum(month_gt_shop_visit_valid_rate_cnt), 2)),
           'month_gt_shop_visit_valid_rate_numerator', sum(month_gt_shop_visit_valid_rate_reach_cnt),
           'month_gt_shop_visit_valid_rate_denominator', sum(month_gt_shop_visit_valid_rate_cnt),

           --季度GT渠道门店拜访覆盖率
           'quar_gt_shop_visit_valid_rate', if(sum(quar_gt_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(quar_gt_shop_visit_valid_rate_reach_cnt)/sum(quar_gt_shop_visit_valid_rate_cnt), 2)),
           'quar_gt_shop_visit_valid_rate_numerator', sum(quar_gt_shop_visit_valid_rate_reach_cnt),
           'quar_gt_shop_visit_valid_rate_denominator', sum(quar_gt_shop_visit_valid_rate_cnt),

           --月度GT渠道院线店拜访覆盖率
           'month_gt_hospital_shop_visit_valid_rate', if(sum(month_gt_hospital_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_gt_hospital_shop_visit_valid_rate_reach_cnt)/sum(month_gt_hospital_shop_visit_valid_rate_cnt), 2)),
           'month_gt_hospital_shop_visit_valid_rate_numerator', sum(month_gt_hospital_shop_visit_valid_rate_reach_cnt),
           'month_gt_hospital_shop_visit_valid_rate_denominator', sum(month_gt_hospital_shop_visit_valid_rate_cnt),

           --季度GT渠道院线店拜访覆盖率
           'quar_gt_hospital_shop_visit_valid_rate', if(sum(quar_gt_hospital_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(quar_gt_hospital_shop_visit_valid_rate_reach_cnt)/sum(quar_gt_hospital_shop_visit_valid_rate_cnt), 2)),
           'quar_gt_hospital_shop_visit_valid_rate_numerator', sum(quar_gt_hospital_shop_visit_valid_rate_reach_cnt),
           'quar_gt_hospital_shop_visit_valid_rate_denominator', sum(quar_gt_hospital_shop_visit_valid_rate_cnt),

           --院线店拜访覆盖率
           'month_hospital_visit_valid_rate', if(sum(month_hospital_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_hospital_visit_valid_rate_reach_cnt)/sum(month_hospital_visit_valid_rate_cnt), 2)),
           'month_hospital_visit_valid_rate_numerator', sum(month_hospital_visit_valid_rate_reach_cnt),
           'month_hospital_visit_valid_rate_denominator', sum(month_hospital_visit_valid_rate_cnt)
       )) as biz_value
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
       to_json(named_struct(
           'user_cnt', count(sub.user_id),

           --当月拜访人员达标率
           'month_visit_reach_rate', if(sum(month_visit_reach_rate_cnt) = 0, null, round(100 * sum(month_visit_reach_rate_reach_cnt)/sum(month_visit_reach_rate_cnt), 2)),
           'month_visit_reach_rate_numerator', sum(month_visit_reach_rate_reach_cnt),
           'month_visit_reach_rate_denominator', sum(month_visit_reach_rate_cnt),

           --门店拜访频次达成率
           'month_visit_freq_valid_rate', if(sum(month_visit_freq_valid_rate_cnt) = 0, null, round(100 * sum(month_visit_freq_valid_rate_reach_cnt)/sum(month_visit_freq_valid_rate_cnt), 2)),
           'month_visit_freq_valid_rate_numerator', sum(month_visit_freq_valid_rate_reach_cnt),
           'month_visit_freq_valid_rate_denominator', sum(month_visit_freq_valid_rate_cnt),

           --NKA专职NC门店拜访达成率
           'month_nka_nc_visit_valid_rate', if(sum(month_nka_nc_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_nka_nc_visit_valid_rate_reach_cnt)/sum(month_nka_nc_visit_valid_rate_cnt), 2)),
           'month_nka_nc_visit_valid_rate_numerator', sum(month_nka_nc_visit_valid_rate_reach_cnt),
           'month_nka_nc_visit_valid_rate_denominator', sum(month_nka_nc_visit_valid_rate_cnt),

          --RKA专职NC门店拜访达成率
           'month_rka_nc_visit_valid_rate', if(sum(month_rka_nc_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_rka_nc_visit_valid_rate_reach_cnt)/sum(month_rka_nc_visit_valid_rate_cnt), 2)),
           'month_rka_nc_visit_valid_rate_numerator', sum(month_rka_nc_visit_valid_rate_reach_cnt),
           'month_rka_nc_visit_valid_rate_denominator', sum(month_rka_nc_visit_valid_rate_cnt),

           --门店拜访覆盖率
           'month_shop_visit_valid_rate', if(sum(month_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_shop_visit_valid_rate_reach_cnt)/sum(month_shop_visit_valid_rate_cnt), 2)),
           'month_shop_visit_valid_rate_numerator', sum(month_shop_visit_valid_rate_reach_cnt),
           'month_shop_visit_valid_rate_denominator', sum(month_shop_visit_valid_rate_cnt),

           --月度服务商拜访达成率
           'month_fws_visit_valid_rate', if(sum(month_fws_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_fws_visit_valid_rate_reach_cnt)/sum(month_fws_visit_valid_rate_cnt), 2)),
           'month_fws_visit_valid_rate_numerator', sum(month_fws_visit_valid_rate_reach_cnt),
           'month_fws_visit_valid_rate_denominator', sum(month_fws_visit_valid_rate_cnt),

           --季度服务商拜访达成率
           'quar_fws_visit_valid_rate', if(sum(quar_fws_visit_valid_rate_cnt) = 0, null, round(100 * sum(quar_fws_visit_valid_rate_reach_cnt)/sum(quar_fws_visit_valid_rate_cnt), 2)),
           'quar_fws_visit_valid_rate_numerator', sum(quar_fws_visit_valid_rate_reach_cnt),
           'quar_fws_visit_valid_rate_denominator', sum(quar_fws_visit_valid_rate_cnt),

           --月度GT渠道门店拜访覆盖率
           'month_gt_shop_visit_valid_rate', if(sum(month_gt_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_gt_shop_visit_valid_rate_reach_cnt)/sum(month_gt_shop_visit_valid_rate_cnt), 2)),
           'month_gt_shop_visit_valid_rate_numerator', sum(month_gt_shop_visit_valid_rate_reach_cnt),
           'month_gt_shop_visit_valid_rate_denominator', sum(month_gt_shop_visit_valid_rate_cnt),

           --季度GT渠道门店拜访覆盖率
           'quar_gt_shop_visit_valid_rate', if(sum(quar_gt_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(quar_gt_shop_visit_valid_rate_reach_cnt)/sum(quar_gt_shop_visit_valid_rate_cnt), 2)),
           'quar_gt_shop_visit_valid_rate_numerator', sum(quar_gt_shop_visit_valid_rate_reach_cnt),
           'quar_gt_shop_visit_valid_rate_denominator', sum(quar_gt_shop_visit_valid_rate_cnt),

           --月度GT渠道院线店拜访覆盖率
           'month_gt_hospital_shop_visit_valid_rate', if(sum(month_gt_hospital_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_gt_hospital_shop_visit_valid_rate_reach_cnt)/sum(month_gt_hospital_shop_visit_valid_rate_cnt), 2)),
           'month_gt_hospital_shop_visit_valid_rate_numerator', sum(month_gt_hospital_shop_visit_valid_rate_reach_cnt),
           'month_gt_hospital_shop_visit_valid_rate_denominator', sum(month_gt_hospital_shop_visit_valid_rate_cnt),

           --季度GT渠道院线店拜访覆盖率
           'quar_gt_hospital_shop_visit_valid_rate', if(sum(quar_gt_hospital_shop_visit_valid_rate_cnt) = 0, null, round(100 * sum(quar_gt_hospital_shop_visit_valid_rate_reach_cnt)/sum(quar_gt_hospital_shop_visit_valid_rate_cnt), 2)),
           'quar_gt_hospital_shop_visit_valid_rate_numerator', sum(quar_gt_hospital_shop_visit_valid_rate_reach_cnt),
           'quar_gt_hospital_shop_visit_valid_rate_denominator', sum(quar_gt_hospital_shop_visit_valid_rate_cnt),

            --院线店拜访覆盖率
           'month_hospital_visit_valid_rate', if(sum(month_hospital_visit_valid_rate_cnt) = 0, null, round(100 * sum(month_hospital_visit_valid_rate_reach_cnt)/sum(month_hospital_visit_valid_rate_cnt), 2)),
           'month_hospital_visit_valid_rate_numerator', sum(month_hospital_visit_valid_rate_reach_cnt),
           'month_hospital_visit_valid_rate_denominator', sum(month_hospital_visit_valid_rate_cnt)
       )) as biz_value
FROM user
INNER JOIN user sub ON user.user_root_key = sub.user_root_key OR locate(user.user_id, sub.user_parent_root_key) > 0 --表示contains
INNER JOIN indicator ON indicator.user_id = sub.user_id
INNER JOIN virtual_group ON sub.user_root_key like concat('%', virtual_group.leader_id, '%') --表示contains
INNER JOIN base_user ON sub.user_id = base_user.user_id
WHERE base_user.need_filter = 0
group by indicator.data_month, user.user_id