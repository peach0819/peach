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
           freeze_server_id,
           is_star_quarter
    FROM prod_mdson.ads_crm_visit_service_obj_d
    WHERE dayid = '${v_date}'
    AND if_virtual = 0  --过滤虚拟门店
    AND INSTR(service_obj_name,'测试') = 0 --过滤测试门店
    AND freeze_server_id is not null
    AND status = 1
),

user as (
    SELECT user_id,
           job_id,
           job_name,
           empno
    FROM prod_mdson.dim_user_d
    WHERE dayid = '${v_date}'
    AND account_type = 1
    AND is_deleted = 0
    AND dismiss_status = 0
    AND substr(nvl(join_time, create_time), 1, 7) <= '${v_opt_month}'
),

--辖区
area as (
    SELECT user_code as empno,
           CASE WHEN area_name like '%GT%' then 'GT'
                WHEN area_name like '%COT%' then 'COT'
                WHEN area_name like '%KA%' then 'KA'
                ELSE '全渠道' END as job_channel
    FROM prod_mdson.ads_sale_area_d
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

mid as (
    SELECT service_obj.freeze_server_id as user_id,
           user.job_id,
           service_obj.service_obj_id as service_obj_id,
           service_obj.month_change_target,
           service_obj.quarter_change_target,
           case when user.job_name IN ('城市渠道负责人', '城市群负责人')
                then case when service_obj.channel_type IN ('COT', 'KA') then case when service_obj.is_nc = 1 THEN if(service_obj.is_low_new_nc = 1, 4, 2)
                                                                                   when service_obj.is_hospital = 1 then 2
                                                                                   end
                          when service_obj.channel_type IN ('GT') then case when service_obj.is_nc = 1 then 2
                                                                            when service_obj.is_hospital = 1 then 1
                                                                            when service_obj.is_star = 1 AND service_obj.star IN (4, 5) then 1
                                                                            end
                          end
                end as month_target,
           case when user.job_name IN ('城市渠道负责人', '城市群负责人')
                then case when service_obj.channel_type IN ('COT', 'KA') AND service_obj.store_class_name = '实体门店' then 1
                          when service_obj.channel_type IN ('GT') AND service_obj.is_star_quarter = 1 then 1
                          when service_obj.service_obj_type = 3 AND (user.job_name = '城市渠道负责人' OR (user.job_name = '城市群负责人' AND area.job_channel = 'GT')) then 1
                          end
                end as quarter_target
    FROM service_obj
    INNER JOIN user ON service_obj.freeze_server_id = user.user_id
    LEFT JOIN area ON user.empno = area.empno
)

INSERT OVERWRITE TABLE ads_crm_visit_user_shop_target_v2_d PARTITION (dayid = '${v_date}')
SELECT mid.user_id,
       mid.service_obj_id,
       prod_mdson.mdson_indicator_target(mid.month_target, mid.month_change_target, workday.discount_rate) as month_target,
       prod_mdson.mdson_indicator_target(mid.quarter_target, mid.quarter_change_target, null) as quarter_target,
       mid.job_id
FROM mid
LEFT JOIN workday ON mid.user_id = workday.user_id