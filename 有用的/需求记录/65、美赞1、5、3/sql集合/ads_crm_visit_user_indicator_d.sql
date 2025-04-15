with indicator as (
    SELECT data_month,
           user_id,
           --达标
           if_visit_qualified,

           --拜访
           all_valid_visit_m,
           all_visit_m,
           valid_visit_m_pre,
           all_valid_visit_m_quar,

           --计划拜访
           all_visit_plan_m,
           all_vaild_visit_plan_m,
           valid_plan_m_pre,

           --拜访频次
           visit_m_target,
           target_visit_m_pre,

           --NC拜访
           user_sever_nc_obj_m,
           all_valid_visit_nc_obj_m,
           valid_visit_nc_obj_m_pre,

           --NCM拜访
           user_sever_ncm_obj_m,
           all_valid_visit_ncm_obj_m,
           valid_visit_ncm_obj_m_pre,

           --NCM重点门店拜访
           visit_spec_obi_m_target,
           all_valid_visit_spec_obj_m,
           valid_visit_spec_obj_m_pre,

           --服务商拜访
           user_sever_fws_m,
           all_valid_visit_obj_fws_m,
           valid_visit_obj_fws_m_quar_pre,
           all_valid_visit_obj_fws_m_quar
    FROM p_mdson.ads_mdspn_user_cur_month_summary_d
    WHERE dayid = '${v_date}'
),

user as (
    SELECT user_id,
           user_root_key,
           user_parent_root_key
    FROM p_mdson.ads_crm_visit_user_d
    WHERE dayid = '${v_date}'
),

virtual_group as (
    SELECT id,
           leader_id
    FROM p_mdson.dwd_hpc_virtual_group_d
    WHERE dayid = '${v_date}'
    AND leader_id is not NULL
    AND id IN (
        655516,655517,655518,655519,655520,655574,655975,655512,655575,655505,655648,655584,655506,655583,655585,655853,655898,655504
    ) --写死虚拟组
)

INSERT OVERWRITE TABLE ads_crm_visit_user_indicator_d PARTITION (dayid = '${v_date}')
--我自己的
SELECT indicator.data_month as data_month,
       user.user_id,
       0 as tab_type,
       to_json(named_struct(
           'user_cnt', 1,
           'month_visit_my_reach', if_visit_qualified,
           'month_visit_valid_cnt', all_valid_visit_m,
           'quarter_visit_valid_cnt', all_valid_visit_m_quar,
           'month_visit_valid_rate', valid_visit_m_pre * 100,
           'month_visit_plan_reach_rate', valid_plan_m_pre * 100,
           'month_visit_freq_reach_rate', target_visit_m_pre * 100,
           'month_visit_nc_cover_rate', valid_visit_nc_obj_m_pre * 100,
           'month_visit_ncm_cover_rate', valid_visit_ncm_obj_m_pre * 100,
           'month_visit_ncm_big_freq_reach_rate', valid_visit_spec_obj_m_pre * 100,
           'month_visit_hsp_cnt_actual', all_valid_visit_obj_fws_m,
           'quarter_visit_hsp_cover_rate', valid_visit_obj_fws_m_quar_pre * 100,

           --百分比指标分子分母
           'month_visit_valid_rate_numerator', all_valid_visit_m,
           'month_visit_valid_rate_denominator', all_visit_m,
           'month_visit_plan_reach_rate_numerator', all_vaild_visit_plan_m,
           'month_visit_plan_reach_rate_denominator', all_visit_plan_m,
           'month_visit_freq_reach_rate_numerator', all_valid_visit_m,
           'month_visit_freq_reach_rate_denominator', visit_m_target,
           'month_visit_nc_cover_rate_numerator', all_valid_visit_nc_obj_m,
           'month_visit_nc_cover_rate_denominator', user_sever_nc_obj_m,
           'month_visit_ncm_cover_rate_numerator', all_valid_visit_ncm_obj_m,
           'month_visit_ncm_cover_rate_denominator', user_sever_ncm_obj_m,
           'month_visit_ncm_big_freq_reach_rate_numerator', all_valid_visit_spec_obj_m,
           'month_visit_ncm_big_freq_reach_rate_denominator', visit_spec_obi_m_target,
           'quarter_visit_hsp_cover_rate_numerator', all_valid_visit_obj_fws_m_quar,
           'quarter_visit_hsp_cover_rate_denominator', user_sever_fws_m
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
           'month_visit_reach_rate', round(100 * count(case when if_visit_qualified = '达标' then 1 else null end)/count(sub.user_id), 2),
           'month_visit_valid_cnt', sum(all_valid_visit_m),
           'quarter_visit_valid_cnt', sum(all_valid_visit_m_quar),
           'month_visit_valid_rate', if(sum(all_visit_m) = 0, null, round(100 * sum(all_valid_visit_m)/sum(all_visit_m), 2)),
           'month_visit_plan_reach_rate', if(sum(all_visit_plan_m) = 0, null, round(100 * sum(all_vaild_visit_plan_m)/sum(all_visit_plan_m), 2)),
           'month_visit_freq_reach_rate', if(sum(visit_m_target) = 0, null, round(100 * sum(all_valid_visit_m)/sum(visit_m_target), 2)),
           'month_visit_nc_cover_rate', if(sum(user_sever_nc_obj_m) = 0, null, round(100 * sum(all_valid_visit_nc_obj_m)/sum(user_sever_nc_obj_m), 2)),
           'month_visit_ncm_cover_rate', if(sum(user_sever_ncm_obj_m) = 0, null, round(100 * sum(all_valid_visit_ncm_obj_m)/sum(user_sever_ncm_obj_m), 2)),
           'month_visit_ncm_big_freq_reach_rate', if(sum(visit_spec_obi_m_target) = 0, null, round(100 * sum(all_valid_visit_spec_obj_m)/sum(visit_spec_obi_m_target), 2)),
           'month_visit_hsp_cnt_actual', sum(all_valid_visit_obj_fws_m),
           'quarter_visit_hsp_cover_rate', if(sum(user_sever_fws_m) = 0, null, round(100 * sum(all_valid_visit_obj_fws_m_quar)/sum(user_sever_fws_m), 2)),

           --百分比指标分子分母
           'month_visit_reach_rate_numerator', count(case when if_visit_qualified = '达标' then 1 else null end),
           'month_visit_reach_rate_denominator', count(sub.user_id),
           'month_visit_valid_rate_numerator', sum(all_valid_visit_m),
           'month_visit_valid_rate_denominator', sum(all_visit_m),
           'month_visit_plan_reach_rate_numerator', sum(all_vaild_visit_plan_m),
           'month_visit_plan_reach_rate_denominator', sum(all_visit_plan_m),
           'month_visit_freq_reach_rate_numerator', sum(all_valid_visit_m),
           'month_visit_freq_reach_rate_denominator', sum(visit_m_target),
           'month_visit_nc_cover_rate_numerator', sum(all_valid_visit_nc_obj_m),
           'month_visit_nc_cover_rate_denominator', sum(user_sever_nc_obj_m),
           'month_visit_ncm_cover_rate_numerator', sum(all_valid_visit_ncm_obj_m),
           'month_visit_ncm_cover_rate_denominator', sum(user_sever_ncm_obj_m),
           'month_visit_ncm_big_freq_reach_rate_numerator', sum(all_valid_visit_spec_obj_m),
           'month_visit_ncm_big_freq_reach_rate_denominator', sum(visit_spec_obi_m_target),
           'quarter_visit_hsp_cover_rate_numerator', sum(all_valid_visit_obj_fws_m_quar),
           'quarter_visit_hsp_cover_rate_denominator', sum(user_sever_fws_m)
       )) as biz_value
FROM user
INNER JOIN user sub ON user.user_root_key = sub.user_root_key OR locate(user.user_root_key, sub.user_parent_root_key) > 0 --表示contains
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
           'month_visit_reach_rate', round(100 * count(case when if_visit_qualified = '达标' then 1 else null end)/count(sub.user_id), 2),
           'month_visit_valid_cnt', sum(all_valid_visit_m),
           'quarter_visit_valid_cnt', sum(all_valid_visit_m_quar),
           'month_visit_valid_rate', if(sum(all_visit_m) = 0, null, round(100 * sum(all_valid_visit_m)/sum(all_visit_m), 2)),
           'month_visit_plan_reach_rate', if(sum(all_visit_plan_m) = 0, null, round(100 * sum(all_vaild_visit_plan_m)/sum(all_visit_plan_m), 2)),
           'month_visit_freq_reach_rate', if(sum(visit_m_target) = 0, null, round(100 * sum(all_valid_visit_m)/sum(visit_m_target), 2)),
           'month_visit_nc_cover_rate', if(sum(user_sever_nc_obj_m) = 0, null, round(100 * sum(all_valid_visit_nc_obj_m)/sum(user_sever_nc_obj_m), 2)),
           'month_visit_ncm_cover_rate', if(sum(user_sever_ncm_obj_m) = 0, null, round(100 * sum(all_valid_visit_ncm_obj_m)/sum(user_sever_ncm_obj_m), 2)),
           'month_visit_ncm_big_freq_reach_rate', if(sum(visit_spec_obi_m_target) = 0, null, round(100 * sum(all_valid_visit_spec_obj_m)/sum(visit_spec_obi_m_target), 2)),
           'month_visit_hsp_cnt_actual', sum(all_valid_visit_obj_fws_m),
           'quarter_visit_hsp_cover_rate', if(sum(user_sever_fws_m) = 0, null, round(100 * sum(all_valid_visit_obj_fws_m_quar)/sum(user_sever_fws_m), 2)),

           --百分比指标分子分母
           'month_visit_reach_rate_numerator', count(case when if_visit_qualified = '达标' then 1 else null end),
           'month_visit_reach_rate_denominator', count(sub.user_id),
           'month_visit_valid_rate_numerator', sum(all_valid_visit_m),
           'month_visit_valid_rate_denominator', sum(all_visit_m),
           'month_visit_plan_reach_rate_numerator', sum(all_vaild_visit_plan_m),
           'month_visit_plan_reach_rate_denominator', sum(all_visit_plan_m),
           'month_visit_freq_reach_rate_numerator', sum(all_valid_visit_m),
           'month_visit_freq_reach_rate_denominator', sum(visit_m_target),
           'month_visit_nc_cover_rate_numerator', sum(all_valid_visit_nc_obj_m),
           'month_visit_nc_cover_rate_denominator', sum(user_sever_nc_obj_m),
           'month_visit_ncm_cover_rate_numerator', sum(all_valid_visit_ncm_obj_m),
           'month_visit_ncm_cover_rate_denominator', sum(user_sever_ncm_obj_m),
           'month_visit_ncm_big_freq_reach_rate_numerator', sum(all_valid_visit_spec_obj_m),
           'month_visit_ncm_big_freq_reach_rate_denominator', sum(visit_spec_obi_m_target),
           'quarter_visit_hsp_cover_rate_numerator', sum(all_valid_visit_obj_fws_m_quar),
           'quarter_visit_hsp_cover_rate_denominator', sum(user_sever_fws_m)
       )) as biz_value
FROM user
INNER JOIN user sub ON locate(user.user_root_key, sub.user_parent_root_key) > 0 --表示contains
INNER JOIN indicator ON indicator.user_id = sub.user_id
group by indicator.data_month, user.user_id

UNION ALL

--全国数据

SELECT /*+ mapjoin(user) */
       indicator.data_month as data_month,
       'admin' as user_id,
       3 as tab_type,
       to_json(named_struct(
           'user_cnt', count(sub.user_id),
           'month_visit_reach_rate', round(100 * count(case when if_visit_qualified = '达标' then 1 else null end)/count(sub.user_id), 2),
           'month_visit_valid_cnt', sum(all_valid_visit_m),
           'quarter_visit_valid_cnt', sum(all_valid_visit_m_quar),
           'month_visit_valid_rate', if(sum(all_visit_m) = 0, null, round(100 * sum(all_valid_visit_m)/sum(all_visit_m), 2)),
           'month_visit_plan_reach_rate', if(sum(all_visit_plan_m) = 0, null, round(100 * sum(all_vaild_visit_plan_m)/sum(all_visit_plan_m), 2)),
           'month_visit_freq_reach_rate', if(sum(visit_m_target) = 0, null, round(100 * sum(all_valid_visit_m)/sum(visit_m_target), 2)),
           'month_visit_nc_cover_rate', if(sum(user_sever_nc_obj_m) = 0, null, round(100 * sum(all_valid_visit_nc_obj_m)/sum(user_sever_nc_obj_m), 2)),
           'month_visit_ncm_cover_rate', if(sum(user_sever_ncm_obj_m) = 0, null, round(100 * sum(all_valid_visit_ncm_obj_m)/sum(user_sever_ncm_obj_m), 2)),
           'month_visit_ncm_big_freq_reach_rate', if(sum(visit_spec_obi_m_target) = 0, null, round(100 * sum(all_valid_visit_spec_obj_m)/sum(visit_spec_obi_m_target), 2)),
           'month_visit_hsp_cnt_actual', sum(all_valid_visit_obj_fws_m),
           'quarter_visit_hsp_cover_rate', if(sum(user_sever_fws_m) = 0, null, round(100 * sum(all_valid_visit_obj_fws_m_quar)/sum(user_sever_fws_m), 2)),

           --百分比指标分子分母
           'month_visit_reach_rate_numerator', count(case when if_visit_qualified = '达标' then 1 else null end),
           'month_visit_reach_rate_denominator', count(sub.user_id),
           'month_visit_valid_rate_numerator', sum(all_valid_visit_m),
           'month_visit_valid_rate_denominator', sum(all_visit_m),
           'month_visit_plan_reach_rate_numerator', sum(all_vaild_visit_plan_m),
           'month_visit_plan_reach_rate_denominator', sum(all_visit_plan_m),
           'month_visit_freq_reach_rate_numerator', sum(all_valid_visit_m),
           'month_visit_freq_reach_rate_denominator', sum(visit_m_target),
           'month_visit_nc_cover_rate_numerator', sum(all_valid_visit_nc_obj_m),
           'month_visit_nc_cover_rate_denominator', sum(user_sever_nc_obj_m),
           'month_visit_ncm_cover_rate_numerator', sum(all_valid_visit_ncm_obj_m),
           'month_visit_ncm_cover_rate_denominator', sum(user_sever_ncm_obj_m),
           'month_visit_ncm_big_freq_reach_rate_numerator', sum(all_valid_visit_spec_obj_m),
           'month_visit_ncm_big_freq_reach_rate_denominator', sum(visit_spec_obi_m_target),
           'quarter_visit_hsp_cover_rate_numerator', sum(all_valid_visit_obj_fws_m_quar),
           'quarter_visit_hsp_cover_rate_denominator', sum(user_sever_fws_m)
       )) as biz_value
FROM user
INNER JOIN user sub ON user.user_root_key = sub.user_root_key OR locate(user.user_root_key, sub.user_parent_root_key) > 0 --表示contains
INNER JOIN indicator ON indicator.user_id = sub.user_id
INNER JOIN virtual_group ON virtual_group.leader_id = user.user_id
group by indicator.data_month
