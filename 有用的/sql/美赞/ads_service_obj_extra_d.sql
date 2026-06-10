--@exclude_input=prod_mdson.inf_upload_shop_star
WITH service_obj as (
    SELECT service_obj_id,
           out_service_obj_id
    FROM prod_mdson.dwd_service_obj_d
    WHERE dayid = '${v_date}'
    AND service_obj_type = 1

    UNION

    SELECT service_obj_id,
           out_service_obj_id
    FROM prod_mdson.ads_service_obj_d
    WHERE dayid = '${v_date}'
    AND service_obj_type = 1
),

target as (
    SELECT service_obj_id,
           map_from_entries(collect_list(if(month_target is not null, NAMED_STRUCT('key', job_id, 'value', month_target), cast(null as STRUCT<key:STRING, value:INT>)))) as month_target,
           map_from_entries(collect_list(if(quar_target is not null, NAMED_STRUCT('key', job_id, 'value', quar_target), cast(null as STRUCT<key:STRING, value:INT>)))) as quarter_target
    FROM prod_mdson.ads_mdson_service_target_d
    WHERE dayid = '${v_date}'
    GROUP BY service_obj_id
),

star as (
    SELECT out_service_obj_id,
           star
    FROM prod_mdson.inf_upload_shop_star
),

nc_shop as (
    SELECT store_code,
           max(
                case when low_performance_type IN ('一期低效', '二期低效')
                          OR DATEDIFF(TO_DATE('${v_date}', 'yyyyMMdd'), TO_DATE(entry_date)) < 365
                     then 1 else 0 end
           ) as nc_type
    FROM prod_mdson.dwd_r_ncinfo_d
    WHERE dayid = '${v_date}'
    AND nc_status = '在职员工'
    AND nc_position = 'NC'
    GROUP BY store_code
)

INSERT OVERWRITE TABLE ads_service_obj_extra_d PARTITION (dayid = '${v_date}')
SELECT nvl(service_obj.service_obj_id, target.service_obj_id) as service_obj_id,
       to_json(named_struct(
           'star', if(service_obj.service_obj_id is not null, nvl(star.star, 0), cast(null as INT)),
           'nc_type', nc_shop.nc_type,
           'month_target', target.month_target,
           'quarter_target', target.quarter_target
       )) as extra
FROM service_obj
FULL JOIN target ON service_obj.service_obj_id = target.service_obj_id
LEFT JOIN star ON service_obj.out_service_obj_id = star.out_service_obj_id
LEFT JOIN nc_shop ON service_obj.out_service_obj_id = nc_shop.store_code