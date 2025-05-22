with user as (
    SELECT user_id, user_real_name
    FROM p_mdson.ads_crm_visit_user_d
    WHERE dayid = '20250520'
),

data as (
    SELECT user_id,
           case tab_type when 0 then '个人的'
                         when 1 then '团队的（包含本人和下级）'
                         when 2 then '下级的（不包含本人）'
                         when 4 then '区域前线'
                         end as tab_type,
           get_json_object(biz_value, '$.month_visit_my_reach') as month_visit_my_reach,
           get_json_object(biz_value, '$.month_visit_reach_rate') as month_visit_reach_rate,
           get_json_object(biz_value, '$.month_visit_reach_rate_numerator') as month_visit_reach_rate_numerator,
           get_json_object(biz_value, '$.month_visit_reach_rate_denominator') as month_visit_reach_rate_denominator,
           get_json_object(biz_value, '$.month_visit_freq_valid_rate') as month_visit_freq_valid_rate,
           get_json_object(biz_value, '$.month_visit_freq_valid_rate_numerator') as month_visit_freq_valid_rate_numerator,
           get_json_object(biz_value, '$.month_visit_freq_valid_rate_denominator') as month_visit_freq_valid_rate_denominator,
           get_json_object(biz_value, '$.month_nka_nc_visit_valid_rate') as month_nka_nc_visit_valid_rate,
           get_json_object(biz_value, '$.month_nka_nc_visit_valid_rate_numerator') as month_nka_nc_visit_valid_rate_numerator,
           get_json_object(biz_value, '$.month_nka_nc_visit_valid_rate_denominator') as month_nka_nc_visit_valid_rate_denominator,
           get_json_object(biz_value, '$.month_rka_nc_visit_valid_rate') as month_rka_nc_visit_valid_rate,
           get_json_object(biz_value, '$.month_rka_nc_visit_valid_rate_numerator') as month_rka_nc_visit_valid_rate_numerator,
           get_json_object(biz_value, '$.month_rka_nc_visit_valid_rate_denominator') as month_rka_nc_visit_valid_rate_denominator,
           get_json_object(biz_value, '$.month_shop_visit_valid_rate') as month_shop_visit_valid_rate,
           get_json_object(biz_value, '$.month_shop_visit_valid_rate_numerator') as month_shop_visit_valid_rate_numerator,
           get_json_object(biz_value, '$.month_shop_visit_valid_rate_denominator') as month_shop_visit_valid_rate_denominator,
           get_json_object(biz_value, '$.month_fws_visit_valid_rate') as month_fws_visit_valid_rate,
           get_json_object(biz_value, '$.month_fws_visit_valid_rate_numerator') as month_fws_visit_valid_rate_numerator,
           get_json_object(biz_value, '$.month_fws_visit_valid_rate_denominator') as month_fws_visit_valid_rate_denominator,
           get_json_object(biz_value, '$.quar_fws_visit_valid_rate') as quar_fws_visit_valid_rate,
           get_json_object(biz_value, '$.quar_fws_visit_valid_rate_numerator') as quar_fws_visit_valid_rate_numerator,
           get_json_object(biz_value, '$.quar_fws_visit_valid_rate_denominator') as quar_fws_visit_valid_rate_denominator,
           get_json_object(biz_value, '$.month_gt_shop_visit_valid_rate') as month_gt_shop_visit_valid_rate,
           get_json_object(biz_value, '$.month_gt_shop_visit_valid_rate_numerator') as month_gt_shop_visit_valid_rate_numerator,
           get_json_object(biz_value, '$.month_gt_shop_visit_valid_rate_denominator') as month_gt_shop_visit_valid_rate_denominator,
           get_json_object(biz_value, '$.quar_gt_shop_visit_valid_rate') as quar_gt_shop_visit_valid_rate,
           get_json_object(biz_value, '$.quar_gt_shop_visit_valid_rate_numerator') as quar_gt_shop_visit_valid_rate_numerator,
           get_json_object(biz_value, '$.quar_gt_shop_visit_valid_rate_denominator') as quar_gt_shop_visit_valid_rate_denominator,
           get_json_object(biz_value, '$.month_gt_hospital_shop_visit_valid_rate') as month_gt_hospital_shop_visit_valid_rate,
           get_json_object(biz_value, '$.month_gt_hospital_shop_visit_valid_rate_numerator') as month_gt_hospital_shop_visit_valid_rate_numerator,
           get_json_object(biz_value, '$.month_gt_hospital_shop_visit_valid_rate_denominator') as month_gt_hospital_shop_visit_valid_rate_denominator,
           get_json_object(biz_value, '$.quar_gt_hospital_shop_visit_valid_rate') as quar_gt_hospital_shop_visit_valid_rate,
           get_json_object(biz_value, '$.quar_gt_hospital_shop_visit_valid_rate_numerator') as quar_gt_hospital_shop_visit_valid_rate_numerator,
           get_json_object(biz_value, '$.quar_gt_hospital_shop_visit_valid_rate_denominator') as quar_gt_hospital_shop_visit_valid_rate_denominator,
           get_json_object(biz_value, '$.month_hospital_visit_valid_rate') as month_hospital_visit_valid_rate,
           get_json_object(biz_value, '$.month_hospital_visit_valid_rate_numerator') as month_hospital_visit_valid_rate_numerator,
           get_json_object(biz_value, '$.month_hospital_visit_valid_rate_denominator') as month_hospital_visit_valid_rate_denominator
    FROM p_mdson.ads_crm_visit_user_indicator_v2_d
    WHERE dayid = '20250520'
    AND data_month = '2025-05'
    AND user_id NOT IN ('admin')
)

SELECT data.user_id as `用户id`,
       user.user_real_name as `用户名`,
       data.tab_type as `指标类型`,
       nvl(data.month_visit_my_reach, '') as `当月我的拜访达标`,
       nvl(data.month_visit_reach_rate, '') as `当月拜访人员达标率`,
       nvl(data.month_visit_reach_rate_numerator, '') as `当月拜访人员达标率分子`,
       nvl(data.month_visit_reach_rate_denominator, '') as `当月拜访人员达标率分母`,
       nvl(data.month_visit_freq_valid_rate, '') as `门店拜访频次达成率`,
       nvl(data.month_visit_freq_valid_rate_numerator, '') as `门店拜访频次达成率分子`,
       nvl(data.month_visit_freq_valid_rate_denominator, '') as `门店拜访频次达成率分母`,
       nvl(data.month_nka_nc_visit_valid_rate, '') as `NKA专职NC门店拜访达成率`,
       nvl(data.month_nka_nc_visit_valid_rate_numerator, '') as `NKA专职NC门店拜访达成率分子`,
       nvl(data.month_nka_nc_visit_valid_rate_denominator, '') as `NKA专职NC门店拜访达成率分母`,
       nvl(data.month_rka_nc_visit_valid_rate, '') as `RKA专职NC门店拜访达成率`,
       nvl(data.month_rka_nc_visit_valid_rate_numerator, '') as `RKA专职NC门店拜访达成率分子`,
       nvl(data.month_rka_nc_visit_valid_rate_denominator, '') as `RKA专职NC门店拜访达成率分母`,
       nvl(data.month_hospital_visit_valid_rate, '') as `院线店拜访达成率`,
       nvl(data.month_hospital_visit_valid_rate_numerator, '') as `院线店拜访达成率分子`,
       nvl(data.month_hospital_visit_valid_rate_denominator, '') as `院线店拜访达成率分母`,
       nvl(data.month_shop_visit_valid_rate, '') as `门店拜访覆盖率`,
       nvl(data.month_shop_visit_valid_rate_numerator, '') as `门店拜访覆盖率分子`,
       nvl(data.month_shop_visit_valid_rate_denominator, '') as `门店拜访覆盖率分母`,
       nvl(data.month_fws_visit_valid_rate, '') as `月度服务商拜访达成率`,
       nvl(data.month_fws_visit_valid_rate_numerator, '') as `月度服务商拜访达成率分子`,
       nvl(data.month_fws_visit_valid_rate_denominator, '') as `月度服务商拜访达成率分母`,
       nvl(data.quar_fws_visit_valid_rate, '') as `季度服务商拜访达成率`,
       nvl(data.quar_fws_visit_valid_rate_numerator, '') as `季度服务商拜访达成率分子`,
       nvl(data.quar_fws_visit_valid_rate_denominator, '') as `季度服务商拜访达成率分母`,
       nvl(data.month_gt_shop_visit_valid_rate, '') as `月度GT渠道门店拜访覆盖率`,
       nvl(data.month_gt_shop_visit_valid_rate_numerator, '') as `月度GT渠道门店拜访覆盖率分子`,
       nvl(data.month_gt_shop_visit_valid_rate_denominator, '') as `月度GT渠道门店拜访覆盖率分母`,
       nvl(data.quar_gt_shop_visit_valid_rate, '') as `季度GT渠道门店拜访覆盖率`,
       nvl(data.quar_gt_shop_visit_valid_rate_numerator, '') as `季度GT渠道门店拜访覆盖率分子`,
       nvl(data.quar_gt_shop_visit_valid_rate_denominator, '') as `季度GT渠道门店拜访覆盖率分母`,
       nvl(data.month_gt_hospital_shop_visit_valid_rate, '') as `月度GT渠道院线店拜访覆盖率`,
       nvl(data.month_gt_hospital_shop_visit_valid_rate_numerator, '') as `月度GT渠道院线店拜访覆盖率分子`,
       nvl(data.month_gt_hospital_shop_visit_valid_rate_denominator, '') as `月度GT渠道院线店拜访覆盖率分母`,
       nvl(data.quar_gt_hospital_shop_visit_valid_rate, '') as `季度GT渠道院线店拜访覆盖率`,
       nvl(data.quar_gt_hospital_shop_visit_valid_rate_numerator, '') as `季度GT渠道院线店拜访覆盖率分子`,
       nvl(data.quar_gt_hospital_shop_visit_valid_rate_denominator, '') as `季度GT渠道院线店拜访覆盖率分母`,
       nvl(data.month_hospital_visit_valid_rate, '') as `院线店拜访覆盖率`,
       nvl(data.month_hospital_visit_valid_rate_numerator, '') as `院线店拜访覆盖率分子`,
       nvl(data.month_hospital_visit_valid_rate_denominator, '') as `院线店拜访覆盖率分母`
FROM data
INNER JOIN user ON data.user_id = user.user_id