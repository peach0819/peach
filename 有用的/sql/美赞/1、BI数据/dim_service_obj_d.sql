--@exclude_input=prod_mdson.inf_upload_shop_star
--@exclude_input=prod_mdson.dwd_mdson_mb_saleshier_d
--odps sql
--********************************************************************--
--author:zhenfeng.shang12070(Role)
--create time:2024-11-14 15:49:09
--********************************************************************--
-- 20260612：美赞臣作战室改造需新增以下5个字段
-- 是否星级门店，门店星数，是否NC专职或客制化门店，是否低产或新入职NC门店，门店是否正常营业
-- 20260616
-- 更新是否NC专职或客制化门店计算逻辑，添加类型前缀避免除门店外的其他类型被计算为专职或客制化NC门店
-- 原有NC标签也有类似问题，但未做修改
-- 20260617
-- 判定门店正常营业的源表由ads_service_obj_d替换为全量的dwd_service_obj_d
WITH service_obj_info as (
    SELECT id,
           service_obj_id,
           service_obj_type,
           out_service_obj_id,
           service_obj_name,
           channel_type,
           channel_sub_type,
           linker_name,
           linker_phone,
           province,
           city,
           area,
           street,
           address_desc,
           longitude,
           latitude,
           region,
           sub_region,
           sales_area,
           sales_city,
           status,
           link_account,
           extra_json,
           creator,
           create_time,
           editor,
           edit_time,
           is_deleted
    FROM prod_mdson.dwd_service_obj_d
    WHERE dayid = '${v_date}'
),

shop_info as (
    SELECT shop_id,
           biz_type,
           biz_json
    FROM prod_mdson.ads_shop_biz_d
    WHERE dayid = '${v_date}'
    AND biz_type = 101
),

nc_info as (
    SELECT DISTINCT store_code
    FROM prod_mdson.dwd_r_ncinfo_d
    WHERE dayid = '${v_last_date}'
    AND nc_status = '在职员工'
    AND store_status = '正常营业'
    AND nc_jobtype = '专职'
    AND nc_position = 'NC'
),

nc_info_2 as (
    SELECT DISTINCT store_code
    FROM prod_mdson.dwd_r_ncinfo_d
    WHERE dayid = '${v_last_date}'
    AND nc_status = '在职员工'
    AND store_status = '正常营业'
    AND nc_position = 'NC'
),

shop_full_info as (
    SELECT store_code,
           get_json_object(extra_json, '$.IsAroundHospital_PGroup') as IsAroundHospital_PGroup
    FROM prod_mdson.ads_hpc_shop_full_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
),

user_admin as (
    SELECT user.user_id,
           user.user_real_name,
           user.brand_dept_root_name,
           user.empno,
           user.work_code,
           sale_area.region_name,
           sale_area.sub_region_name,
           sale_area.area_name
    FROM (
        SELECT user_id,
               user_real_name,
               brand_dept_root_name,
               empno,
               substring_index(empno, '-', - 1) work_code
        FROM dwd_hpc_user_admin_d
        WHERE pt = '${v_date}'
        AND account_type = 1
        AND user_status = 1
        AND is_deleted = 0 -- 内部员工
        AND empno LIKE 'mu-%'
    ) user
    LEFT JOIN (
        SELECT user_code,
               user_real_name,
               brand_dept_root_name,
               region_name,
               sub_region_name,
               area_name
        FROM ads_sale_area_d
        WHERE dayid = '${v_date}'
    ) sale_area ON user.empno = sale_area.user_code
) -- 20260521 billy 微信确认, 因为上游mj_sales 不能按时生成, 需修改依赖企微用户信息.
-- ,mj_sales AS
-- (
--     SELECT  uid
--             ,salesrepid
--             ,namechn
--     FROM    (
--                 SELECT  uid
--                         ,salesrepid
--                         ,namechn
--                         ,ROW_NUMBER() OVER (PARTITION BY uid ORDER BY uid DESC ) AS rn
--                 FROM    prod_mdson.dwd_mdson_mb_saleshier_d
--                 WHERE   pt = '${v_date}'
--             ) t
--     WHERE   rn = 1
-- )
,

service_obj_server_info as (
    SELECT store_code,
           get_json_object(extra_json, '$.sales_repId') as server_code,
           get_json_object(extra_json, '$.salesrepnamecn') as server_name
    FROM prod_mdson.ads_hpc_shop_full_d
    WHERE dayid = '${v_date}'
    AND status = '1'

    UNION

    SELECT store_code,
           server_code,
           user_admin.user_real_name as server_name
    FROM (
        SELECT split(service_obj_id, '-')[1] as store_code,
               get_json_object(extra_json, '$.dt_handler_no') as server_code -- 经销商数据是全量数据, 不用换表抽取
        FROM prod_mdson.ads_service_obj_d
        WHERE dayid = '${v_date}'
        AND service_obj_type = 4
        AND service_obj_status = 1
        AND get_json_object(extra_json, '$.dt_handler_no') <> '' -- 数据去重
        GROUP BY service_obj_id,
                 get_json_object(extra_json, '$.dt_handler_no')
    ) dt
    JOIN user_admin ON dt.server_code = user_admin.work_code -- 数据去重
    GROUP BY store_code,
             server_code,
             user_admin.user_real_name
),

user_info as (
    SELECT empno,
           department_charger_id,
           department_charger_name
    FROM prod_mdson.dim_user_d
    WHERE dayid = '${v_date}'
    AND account_type <> 2
),

star_shop as ( -- 20260618：原星级及NC标签取法会导致开发回流目标表后产生相互依赖问题
    SELECT concat('1-', out_service_obj_id) as service_obj_id,
           star
    FROM prod_mdson.inf_upload_shop_star
),

nc_shop as ( -- 20260618：原星级及NC标签取法会导致开发回流目标表后产生相互依赖问题
    SELECT concat('1-', store_code) as service_obj_id,
           max(CASE WHEN low_performance_type IN ('一期低效', '二期低效') OR datediff(to_date('${v_date}', 'yyyyMMdd'), to_date(entry_date)) < 365 THEN 1 ELSE 0 END) as nc_type
    FROM prod_mdson.dwd_r_ncinfo_d
    WHERE dayid = '${v_date}'
    AND nc_status = '在职员工'
    AND nc_position = 'NC'
    GROUP BY store_code
),

nc_new_info as ( -- 20260612：NC门店除原有的专职NC外，需包含客制化NC
    SELECT DISTINCT concat('1-', store_code) as store_code
    FROM prod_mdson.dwd_r_ncinfo_d
    WHERE dayid = '${v_last_date}'
    AND nc_status = '在职员工'
    AND store_status = '正常营业'
    AND nc_jobtype IN ('专职', '客制化')
    AND nc_position = 'NC'
),

is_active as ( -- 20260612：门店是否正常营业
    SELECT DISTINCT service_obj_id,
           status as is_service_obj_active
    FROM prod_mdson.dwd_service_obj_d
    WHERE dayid = '${v_date}'
)

INSERT OVERWRITE TABLE prod_mdson.dim_service_obj_d PARTITION (dayid = '${v_date}')
SELECT service_obj_info.*,
       t1.storeclassname,
       (CASE WHEN t2.star > 0 THEN 1 ELSE 0 END) as is_star_shop,
       cast(coalesce(t2.star, 0) as bigint) as shop_star,
FROM service_obj_info
LEFT JOIN shop_info ON split(service_obj_info.service_obj_id, '-')[1] = shop_info.shop_id
LEFT JOIN nc_info ON service_obj_info.out_service_obj_id = nc_info.store_code
LEFT JOIN shop_full_info ON service_obj_info.out_service_obj_id = shop_full_info.store_code
LEFT JOIN service_obj_server_info ON service_obj_info.out_service_obj_id = service_obj_server_info.store_code
LEFT JOIN user_info ON service_obj_server_info.server_code = split(empno, '-')[1]
LEFT JOIN nc_info_2 ON service_obj_info.out_service_obj_id = nc_info_2.store_code
LEFT  JOIN prod_mdson.dwd_sfa_shop_d t1 ON service_obj_server_info.store_code = t1.storecode AND t1.dayid = 'cur'
LEFT JOIN star_shop t2 ON service_obj_info.service_obj_id = t2.service_obj_id
LEFT JOIN nc_new_info t3 ON service_obj_info.service_obj_id = t3.store_code
LEFT JOIN is_active t4 ON service_obj_info.service_obj_id = t4.service_obj_id
LEFT JOIN nc_shop t5 ON service_obj_info.service_obj_id = t5.service_obj_id;