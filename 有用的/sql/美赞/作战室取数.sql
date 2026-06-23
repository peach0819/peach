SELECT data.user_id as `用户id`,
       user.user_real_name as `用户名`,
       user_admin.user_phone as `手机`,
       user_admin.brand_dept_root_name as `部门`,
       data.tab_type as `指标类型`,

       nvl(get_json_object(biz_value, '$.month_visit_my_reach'), '') as `当月我的拜访达标`,
       nvl(get_json_object(biz_value, '$.month_visit_reach_rate'), '') as `当月拜访人员达标率`,
       nvl(get_json_object(biz_value, '$.month_visit_reach_rate_numerator'), '') as `当月拜访人员达标率分子`,
       nvl(get_json_object(biz_value, '$.month_visit_reach_rate_denominator'), '') as `当月拜访人员达标率分母`,
       nvl(get_json_object(biz_value, '$.quarter_visit_my_reach'), '') as `当季我的拜访达标`,

	   nvl(get_json_object(biz_value, '$.month_visit_freq_reach_rate'), '')  as `当月拜访频次达标率`,
	   nvl(get_json_object(biz_value, '$.month_visit_freq_reach_rate_numerator'), '')  as `当月拜访频次达标率分子`,
	   nvl(get_json_object(biz_value, '$.month_visit_freq_reach_rate_denominator'), '')  as `当月拜访频次达标率分母`,
	   nvl(get_json_object(biz_value, '$.month_nc_visit_reach_rate'), '')  as `当月专职NC门店拜访达成率`,
	   nvl(get_json_object(biz_value, '$.month_nc_visit_reach_rate_numerator'), '')  as `当月专职NC门店拜访达成率分子`,
	   nvl(get_json_object(biz_value, '$.month_nc_visit_reach_rate_denominator'), '')  as `当月专职NC门店拜访达成率分母`,
	   nvl(get_json_object(biz_value, '$.month_fws_visit_cover_rate'), '')  as `当月服务商拜访达成率`,
	   nvl(get_json_object(biz_value, '$.month_fws_visit_cover_rate_numerator'), '')  as `当月服务商拜访达成率分子`,
	   nvl(get_json_object(biz_value, '$.month_fws_visit_cover_rate_denominator'), '')  as `当月服务商拜访达成率分母`,
	   nvl(get_json_object(biz_value, '$.quarter_fws_visit_cover_rate'), '')  as `当季服务商拜访覆盖率`,
	   nvl(get_json_object(biz_value, '$.quarter_fws_visit_cover_rate_numerator'), '')  as `当季服务商拜访覆盖率分子`,
	   nvl(get_json_object(biz_value, '$.quarter_fws_visit_cover_rate_denominator'), '')  as `当季服务商拜访覆盖率分母`,
	   nvl(get_json_object(biz_value, '$.month_star_visit_reach_rate'), '')  as `当月星级门店拜访达成率`,
	   nvl(get_json_object(biz_value, '$.month_star_visit_reach_rate_numerator'), '')  as `当月星级门店拜访达成率分子`,
	   nvl(get_json_object(biz_value, '$.month_star_visit_reach_rate_denominator'), '')  as `当月星级门店拜访达成率分母`,
	   nvl(get_json_object(biz_value, '$.month_shop_visit_reach_rate'), '')  as `当月门店拜访达成率`,
	   nvl(get_json_object(biz_value, '$.month_shop_visit_reach_rate_numerator'), '')  as `当月门店拜访达成率分子`,
	   nvl(get_json_object(biz_value, '$.month_shop_visit_reach_rate_denominator'), '')  as `当月门店拜访达成率分母`,
	   nvl(get_json_object(biz_value, '$.month_all_big_visit_cover_rate'), '')  as `当季全渠道重点门店拜访覆盖率`,
	   nvl(get_json_object(biz_value, '$.month_all_big_visit_cover_rate_numerator'), '')  as `当季全渠道重点门店拜访覆盖率分子`,
	   nvl(get_json_object(biz_value, '$.month_all_big_visit_cover_rate_denominator'), '')  as `当季全渠道重点门店拜访覆盖率分母`,
	   nvl(get_json_object(biz_value, '$.month_hospital_visit_reach_rate'), '')  as `当月院线店拜访达成率`,
	   nvl(get_json_object(biz_value, '$.month_hospital_visit_reach_rate_numerator'), '')  as `当月院线店拜访达成率分子`,
	   nvl(get_json_object(biz_value, '$.month_hospital_visit_reach_rate_denominator'), '')  as `当月院线店拜访达成率分母`
FROM (
    SELECT user_id,
           case tab_type when 0 then '个人的'
                         when 2 then '下级的（不包含本人）'
                         when 4 then '区域前线'
                         end as tab_type,
           biz_value
    FROM prod_mdson.ads_crm_visit_user_indicator_d
    WHERE dayid = '${v_date}'
    AND data_month = concat(substr('${v_date}', 1, 4), '-', substr('${v_date}', 5, 2))
    AND user_id NOT IN ('admin')
    AND tab_type IN (0, 2, 4)
) data
INNER JOIN (
    SELECT user_id, user_real_name
    FROM prod_mdson.ads_crm_visit_user_d
    WHERE dayid = '${v_date}'
) user ON data.user_id = user.user_id
LEFT JOIN (
    SELECT user_id, user_phone, brand_dept_root_name
    FROM prod_mdson.dwd_hpc_user_admin_d
    WHERE pt = '20260622'
) user_admin ON data.user_id = user_admin.user_id