--@exclude_input=prod_mdson_dev.inf_mdson_white_list_store
--@exclude_input=prod_mdson.inf_upload_shop_star
with base as (
    SELECT service_obj_id,
           service_obj_name,
           out_service_obj_id,
           service_obj_type,
           channel_type,
           if(service_obj_type = 1 AND service_obj_name LIKE '%虚拟门店%', 1, 0) as is_virtual,
           if(get_json_object(extra_json, '$.IsAroundHospital_PGroup') = 'T', 1, 0) as is_hospital,
           cast(status as bigint) as status
    FROM prod_mdson.dwd_service_obj_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
),

--NC门店标签，是否NC门店，是否低产新入职门店
nc_shop as (
    SELECT service_obj_id,
           is_nc,
           is_low_new_nc
    FROM prod_mdson.ads_crm_nc_shop_d
    WHERE dayid = '${v_date}'
),

--门店星级
star as (
    SELECT out_service_obj_id,
           star,
           if(star > 0, 1, 0) as is_star
    FROM prod_mdson.inf_upload_shop_star
),

--门店类型
sfa_shop as (
    SELECT storecode,
           storeclassname
    FROM prod_mdson.dwd_sfa_shop_d
    WHERE dayid = 'cur'
),

--门店白名单目标值
target as (
    SELECT store_code,
           if(change_indicator = '月度门店目标拜访频次', 1, 0) as is_month_target,
           max(change_target) as change_target
    FROM prod_mdson_dev.inf_mdson_white_list_store
    WHERE year_month = '${v_cur_month}'
    AND change_indicator IN ('月度门店目标拜访频次', '季度门店目标拜访频次')
    group by store_code,
             change_indicator
),

--门店所有人
server as (
    SELECT s.service_obj_id,
           s.is_kn,
           user.user_id
    FROM (
        SELECT store_code as service_obj_id,
               if(dayid = '${v_date}', 1, 0) as is_kn,
               max(server_code) as server_code
        FROM prod_mdson.ads_service_obj_server_d
        WHERE dayid IN ('${v_date}', replace(dateadd(date '${v_opt_month}-01', - 1, 'dd'), '-', ''))
        AND (store_code NOT LIKE '1-%' OR (store_code LIKE '1-%' AND job_name = 'SHOP_SERVER'))
        group by store_code,
                 dayid
    ) s
    LEFT JOIN (
        SELECT user_id,
               empno
        FROM prod_mdson.dim_user_d
        WHERE dayid = '${v_date}'
        AND is_deleted = 0
        AND dismiss_status = 0
        AND substr(nvl(join_time, create_time), 1, 7) <= '${v_opt_month}'
    ) user ON user.empno = s.server_code
)

INSERT OVERWRITE TABLE ads_crm_visit_service_obj_d PARTITION (dayid = '${v_date}')
SELECT base.service_obj_id,
       base.service_obj_name,
       base.service_obj_type,
       base.channel_type,
       base.status,
       sfa_shop.storeclassname as store_class_name,
       nvl(star.star, 0) as star,
       nvl(star.is_star, 0) as is_star,
       base.is_hospital,
       base.is_virtual,
       nvl(nc_shop.is_nc, 0) as is_nc,
       nvl(nc_shop.is_low_new_nc, 0) as is_low_new_nc,
       to_json(named_struct(
           'month', month_target.change_target,
           'quarter', quarter_target.change_target
       )) as target,
       freeze_server.user_id as freeze_server_id,
       kn_server.user_id as kn_server_id
FROM base
LEFT JOIN sfa_shop ON base.out_service_obj_id = sfa_shop.storecode
LEFT JOIN star ON star.out_service_obj_id = base.out_service_obj_id
LEFT JOIN nc_shop ON nc_shop.service_obj_id = base.service_obj_id
LEFT JOIN target month_target ON month_target.is_month_target = 1 AND month_target.store_code = base.out_service_obj_id
LEFT JOIN target quarter_target ON quarter_target.is_month_target = 0 AND quarter_target.store_code = base.out_service_obj_id
LEFT JOIN server freeze_server ON freeze_server.is_kn = 0 AND base.service_obj_id = freeze_server.service_obj_id
LEFT JOIN server kn_server ON kn_server.is_kn = 1 AND base.service_obj_id = kn_server.service_obj_id