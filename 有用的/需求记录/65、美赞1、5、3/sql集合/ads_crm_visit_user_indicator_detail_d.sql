with base as (
    SELECT data_month,
           user_id,
           case indicator_id when 'month_fws_visit_valid_cnt' then 'month_fws_visit_valid_rate'
                             when 'month_gt_shop_visit_valid_cnt' then 'month_gt_shop_visit_valid_rate'
                             when 'month_hospital_visit_valid_cnt' then 'month_hospital_visit_valid_rate'
                             when 'month_nka_nc_visit_valid_cnt' then 'month_nka_nc_visit_valid_rate'
                             when 'month_rka_nc_visit_valid_cnt' then 'month_rka_nc_visit_valid_rate'
                             when 'month_shop_visit_valid_cnt' then 'month_shop_visit_valid_rate'
                             when 'month_visit_valid_cnt' then 'month_visit_freq_valid_rate'
                             when 'quar_fws_visit_valid_cnt' then 'quar_fws_visit_valid_rate'
                             when 'quar_gt_shop_visit_valid_cnt' then 'quar_gt_shop_visit_valid_rate'
                             end as indicator_code,
           service_obj_id,
           service_obj_name,
           valid_visit_m,
           if_visit_qualified
    FROM p_mdson.ads_mdson_user_cur_month_detail_di
    WHERE dayid = '${v_cur_month}'
),

visit_total as (
    SELECT data_month,
           user_id,
           if_visit_qualified_month
    FROM p_mdson.ads_mdson_user_new_visit_summary_data_d
    WHERE dayid = '${v_date}'
)

INSERT OVERWRITE TABLE ads_crm_visit_user_indicator_detail_d PARTITION (dayid='${v_date}')
--当月人员拜访达标率需要单独从汇总表里面取
SELECT data_month,
       user_id,
       'month_visit_reach_rate' as indicator_code,
       null as service_obj_id,
       null as service_obj_name,
       to_json(named_struct(
           'reach', if_visit_qualified_month
       )) as biz_value
FROM visit_total

UNION ALL

--其他指标都从明细表里面取
SELECT data_month,
       user_id,
       indicator_code,
       service_obj_id,
       service_obj_name,
       to_json(named_struct(
           'indicator', valid_visit_m,
           'reach', if_visit_qualified
       )) as biz_value
FROM base