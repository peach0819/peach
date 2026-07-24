--服务对象信息
with service_obj as (
    SELECT service_obj_id,
           service_obj_name,
           service_obj_type,
           channel_type,
           status,
           store_class_name,
           star,
           is_star,
           is_hospital,
           is_nc,
           is_low_new_nc,
           get_json_object(target, '$.month') as month_change_target,
           get_json_object(target, '$.quarter') as quarter_change_target,
           freeze_server_id
    FROM prod_mdson.ads_crm_visit_service_obj_d
    WHERE dayid = '${v_date}'
    AND if_virtual = 0  --过滤虚拟门店
),

--人员信息
user as (
    SELECT user_id,
           job_name
    FROM prod_mdson.dim_user_d
    WHERE dayid = '${v_date}'
    AND account_type = 1
    AND is_deleted = 0
    AND dismiss_status = 0
    AND substr(nvl(join_time, create_time), 1, 7) <= '${v_opt_month}'
),

--拜访小记
visit as (
    SELECT id,
           visit_type,
           visit_time,
           visit_mode,
           service_obj_id,
           user_id,
           freeze_server_id
    FROM prod_mdson.ads_crm_visit_record_d
    WHERE dayid = '${v_date}'
),

--人员月度折算信息
workday as (
    SELECT user_id,
           actual_day_num / total_day_num as discount_rate
    FROM prod_mdson.ads_crm_visit_user_workday_d
    WHERE dayid = '${v_date}'
    AND data_month = '${v_opt_month}'
),

------------------------------------------------------------------------------指标
detail as (
    --当月拜访频次达标率
    SELECT 'month_visit_freq_reach_rate' as indicator_code,
           '否' as is_service_obj_indicator,
           visit.user_id as user_id,
           visit.service_obj_id,
           count(if((visit_type = 1 AND visit_mode = 1) OR visit_type != 1, visit.id, null)) as indicator, --门店拜访只统计有效拜访，服务商不用（因为服务商没有有效拜访概念）
           null as target
    FROM (
        SELECT *
        FROM visit
        WHERE substr(visit_time, 1, 7) = '${v_opt_month}'
    ) visit
    LEFT JOIN (
        SELECT *
        FROM service_obj
        WHERE service_obj_type != 1 OR (store_class_name = '实体门店' AND status = 1)  --门店仅正常营业的实体门店，服务商不用
    ) service_obj ON service_obj.service_obj_id = visit.service_obj_id
    GROUP BY visit.user_id,
             visit.service_obj_id

    UNION ALL

    --当月专职NC门店拜访达成率
    SELECT 'month_nc_visit_reach_rate' as indicator_code,
          '是' as is_service_obj_indicator,
           service_obj.freeze_server_id as user_id,
           service_obj.service_obj_id,
           count(visit.id) as indicator,
           case when user.job_name IN ('城市渠道负责人', '城市群负责人')
                then case when service_obj.channel_type IN ('COT', 'KA') then if(service_obj.is_low_new_nc = 1, 4, 2)
                          when service_obj.channel_type IN ('GT') then 2
                          END
                END as target
    FROM (
        SELECT *
        FROM service_obj
        WHERE service_obj_type = 1  --门店
        AND store_class_name = '实体门店'
        AND status = 1 --正常营业
        AND is_nc = 1 --NC门店
        AND freeze_server_id is not null --有挂服务人员的门店
    ) service_obj
    LEFT JOIN (
        SELECT *
        FROM visit
        WHERE substr(visit.visit_time, 1, 7) = '${v_opt_month}'
        AND visit_type = 1 --门店拜访
        AND visit_mode = 1 --有效拜访
        AND user_id = freeze_server_id --所有人拜访小记
    ) visit ON service_obj.service_obj_id = visit.service_obj_id
    LEFT JOIN user ON service_obj.freeze_server_id = user.user_id
    GROUP BY service_obj.freeze_server_id,
             service_obj.service_obj_id,
             user.job_name,
             service_obj.channel_type,
             service_obj.is_low_new_nc

    UNION ALL

    --当月服务商拜访达成率
    SELECT 'month_fws_visit_cover_rate' as indicator_code,
          '否' as is_service_obj_indicator,
           service_obj.freeze_server_id as user_id,
           service_obj.service_obj_id,
           count(visit.id) as indicator,
           null as target
    FROM (
        SELECT *
        FROM service_obj
        WHERE service_obj_type = 3
        AND status = 1
        AND freeze_server_id is not null --有挂服务人员的正常营业服务商
    ) service_obj
    LEFT JOIN (
        SELECT *
        FROM visit
        WHERE substr(visit.visit_time, 1, 7) = '${v_opt_month}'
        AND visit_type = 4 --服务商拜访
        AND user_id = freeze_server_id --所有人拜访小记
    ) visit ON service_obj.service_obj_id = visit.service_obj_id
    GROUP BY service_obj.freeze_server_id,
             service_obj.service_obj_id

    UNION ALL

    --当季服务商拜访覆盖率
    SELECT 'quarter_fws_visit_cover_rate' as indicator_code,
          '否' as is_service_obj_indicator,
           service_obj.freeze_server_id as user_id,
           service_obj.service_obj_id,
           count(visit.id) as indicator,
           null as target
    FROM (
        SELECT *
        FROM service_obj
        WHERE service_obj_type = 3
        AND status = 1
        AND freeze_server_id is not null --有挂服务人员的正常营业服务商
    ) service_obj
    LEFT JOIN (
        SELECT *
        FROM visit
        WHERE visit_type = 4 --服务商拜访
        AND user_id = freeze_server_id --所有人拜访小记
    ) visit ON service_obj.service_obj_id = visit.service_obj_id
    GROUP BY service_obj.freeze_server_id,
             service_obj.service_obj_id

    UNION ALL

    --当月星级门店拜访达成率
    SELECT 'month_star_visit_reach_rate' as indicator_code,
          '是' as is_service_obj_indicator,
           service_obj.freeze_server_id as user_id,
           service_obj.service_obj_id,
           count(visit.id) as indicator,
           case when user.job_name IN ('城市渠道负责人', '城市群负责人') AND service_obj.channel_type IN ('GT')
                THEN if(service_obj.star = 5, 2, 1)
                END as target
    FROM (
        SELECT *
        FROM service_obj
        WHERE store_class_name = '实体门店'
        AND status = 1
        AND is_star = 1
        AND service_obj_type = 1
        AND freeze_server_id is not null
    ) service_obj
    LEFT JOIN (
        SELECT *
        FROM visit
        WHERE substr(visit.visit_time, 1, 7) = '${v_opt_month}'
        AND visit_type = 1
        AND visit_mode = 1
        AND user_id = freeze_server_id --所有人拜访小记
    ) visit ON service_obj.service_obj_id = visit.service_obj_id
    LEFT JOIN user ON service_obj.freeze_server_id = user.user_id
    GROUP BY service_obj.freeze_server_id,
             service_obj.service_obj_id,
             user.job_name,
             service_obj.channel_type,
             service_obj.star

    UNION ALL

    --当月门店拜访达成率
    SELECT 'month_shop_visit_reach_rate' as indicator_code,
           '否' as is_service_obj_indicator,
           visit.user_id as user_id,
           visit.service_obj_id,
           count(if((visit_type = 1 AND visit_mode = 1) OR visit_type != 1, visit.id, null)) as indicator, --门店拜访只统计有效拜访，服务商不用（因为服务商没有有效拜访概念）
           null as target
    FROM (
        SELECT *
        FROM visit
        WHERE substr(visit_time, 1, 7) = '${v_opt_month}'
    ) visit
    LEFT JOIN (
        SELECT *
        FROM service_obj
        WHERE service_obj_type != 1 OR (store_class_name = '实体门店' AND status = 1)  --门店仅正常营业的实体门店，服务商不用
    ) service_obj ON service_obj.service_obj_id = visit.service_obj_id
    GROUP BY visit.user_id,
             visit.service_obj_id

    UNION ALL

    --当季全渠道重点门店拜访覆盖率
    SELECT 'quarter_all_big_visit_cover_rate',
           '是' as is_service_obj_indicator,
           service_obj.freeze_server_id as user_id,
           service_obj.service_obj_id,
           count(visit.id) as indicator,
           1 as target
    FROM (
        SELECT *
        FROM service_obj
        WHERE store_class_name = '实体门店'
        AND status = 1
        AND service_obj_type = 1
        AND (channel_type IN ('COT', 'KA') OR (channel_type = 'GT' AND is_nc = 1) OR is_hospital = 1 OR is_star = 1) --重点门店定义 1、COT、KA渠道门店 2、GT渠道专职NC门店 3、院线店  4、星级门店
        AND freeze_server_id is not null --有挂服务人员的
    ) service_obj
    LEFT JOIN (
        SELECT *
        FROM visit
        WHERE visit_type = 1
        AND visit_mode = 1
        AND user_id = freeze_server_id --所有人拜访小记
    ) visit ON service_obj.service_obj_id = visit.service_obj_id
    GROUP BY service_obj.freeze_server_id,
             service_obj.service_obj_id

    UNION ALL

    --当月院线店拜访达成率
    SELECT 'month_hospital_visit_reach_rate' as indicator_code,
          '是' as is_service_obj_indicator,
           service_obj.freeze_server_id as user_id,
           service_obj.service_obj_id,
           count(visit.id) as indicator,
           case when user.job_name IN ('城市渠道负责人', '城市群负责人')
                THEN case when service_obj.channel_type IN ('COT', 'KA') then 2
                          WHEN service_obj.channel_type IN ('GT') THEN if(service_obj.is_star = 1, 2, 1)
                          END
                END as target
    FROM (
        SELECT *
        FROM service_obj
        WHERE is_hospital = 1
        AND service_obj_type = 1
        AND status = 1
        AND store_class_name = '实体门店'
        AND freeze_server_id is not null
    ) service_obj
    LEFT JOIN (
        SELECT *
        FROM visit
        WHERE substr(visit.visit_time, 1, 7) = '${v_opt_month}'
        AND visit_type = 1
        AND visit_mode = 1
        AND user_id = freeze_server_id --所有人拜访小记
    ) visit ON service_obj.service_obj_id = visit.service_obj_id
    LEFT JOIN user ON service_obj.freeze_server_id = user.user_id
    GROUP BY service_obj.freeze_server_id,
             service_obj.service_obj_id,
             user.job_name,
             service_obj.channel_type,
             service_obj.is_star
),

mid as (
    SELECT detail.indicator_code,
           detail.user_id,
           detail.service_obj_id,
           service_obj.service_obj_name,
           detail.indicator,
           --折算目标
           prod_mdson.mdson_indicator_target(
               nvl(detail.target, 1),
               if(detail.is_service_obj_indicator = '是', if(detail.indicator_code like 'month_%', service_obj.month_change_target, quarter_change_target), null),
               if(detail.indicator_code like 'month_%', workday.discount_rate, null)
           ) as target,

           --时间进度
           if(indicator_code like 'month_%', DAYOFMONTH(TO_DATE('${v_date}', 'yyyymmdd')) / DAYOFMONTH(LAST_DAY(TO_DATE('${v_date}', 'yyyymmdd'))), 1) as time_progress
    FROM detail
    LEFT JOIN service_obj ON detail.service_obj_id = service_obj.service_obj_id
    LEFT JOIN workday ON detail.user_id = workday.user_id
)

INSERT OVERWRITE TABLE ads_crm_visit_base_detail_d PARTITION (dayid = '${v_date}')
SELECT indicator_code,
       user_id,
       service_obj_id,
       service_obj_name,
       indicator,
       target,
       if(indicator/target >= time_progress, '达标', '未达标') as reach
FROM mid
WHERE target > 0