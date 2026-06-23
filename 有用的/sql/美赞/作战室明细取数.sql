SELECT data.user_id as `用户id`,
       user_real_name as `用户名`,
       case indicator_code when 'month_visit_reach_rate' then '当月我的拜访达标'
                           when 'month_visit_freq_reach_rate' then '当月拜访频次达标率'
                           when 'month_nc_visit_reach_rate' then '当月专职NC门店拜访达成率'
                           when 'month_fws_visit_cover_rate' then '当月服务商拜访达成率'
                           when 'quarter_fws_visit_cover_rate' then '当季服务商拜访覆盖率'
                           when 'month_star_visit_reach_rate' then '当月星级门店拜访达成率'
                           when 'month_shop_visit_reach_rate' then '当月门店拜访达成率'
                           when 'month_all_big_visit_cover_rate' then '当季全渠道重点门店拜访覆盖率'
                           when 'month_hospital_visit_reach_rate' then '当月院线店拜访达成率'
                           end as `指标名称`,
       service_obj_id as `拜访对象id`,
       service_obj_name as `拜访对象名`,
       GET_JSON_OBJECT(biz_value, '$.indicator') as `指标值`,
       GET_JSON_OBJECT(biz_value, '$.reach') as `是否达标`
FROM prod_mdson.ads_crm_visit_user_indicator_detail_d data
LEFT JOIN (
    SELECT user_id, user_real_name
    FROM prod_mdson.ads_crm_visit_user_d
    WHERE dayid = '${v_date}'
) user ON data.user_id = user.user_id
WHERE dayid = '${v_date}'
AND indicator_code is not null
AND indicator_code IN (
    'month_visit_reach_rate',
    'month_visit_freq_reach_rate',
    'month_nc_visit_reach_rate',
    'month_fws_visit_cover_rate',
    'quarter_fws_visit_cover_rate',
    'month_star_visit_reach_rate',
    'month_shop_visit_reach_rate',
    'month_all_big_visit_cover_rate',
    'month_hospital_visit_reach_rate'
)