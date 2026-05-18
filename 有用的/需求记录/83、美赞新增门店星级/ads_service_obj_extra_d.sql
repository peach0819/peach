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

star as (
    SELECT out_service_obj_id,
           star
    FROM prod_mdson.inf_upload_shop_star
),

nc_shop as  (
    SELECT store_code,
           max(
                case when low_performance_type IN ('一期低效', '二期低效')
                          OR DATEDIFF(TO_DATE('${v_date}', 'yyyyMMdd'), TO_DATE(entry_date)) < 365
                     then 1 else 0 end
           ) as nc_type
    from prod_mdson.dwd_r_ncinfo_d
    where dayid='${v_date}'
    and nc_status='在职员工'
    and nc_position='NC'
    group by store_code
)

INSERT OVERWRITE TABLE ads_service_obj_extra_d PARTITION (dayid = '${v_date}')
SELECT service_obj.service_obj_id,
       to_json(named_struct(
           'star', nvl(star.star, 0),
           'nc_type', nc_shop.nc_type
       )) as extra
FROM service_obj
LEFT JOIN star ON service_obj.out_service_obj_id = star.out_service_obj_id
LEFT JOIN nc_shop ON service_obj.out_service_obj_id = nc_shop.store_code
