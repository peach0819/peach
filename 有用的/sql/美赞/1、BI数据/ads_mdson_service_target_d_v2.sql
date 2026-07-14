--@exclude_input=prod_mdson_dev.inf_mdson_white_list_store
-- 20260705：作战室-小程序拜访对象目标展示用表v2
WITH mdson_user as ( -- 员工信息
    SELECT user_id,
           user_real_name,
           job_id,
           job_name,
           channel_name,
           empno
    FROM prod_mdson.dim_user_d
    WHERE dayid = '${v_date}'
    AND account_type = 1
    AND is_deleted = 0
    AND dismiss_status = 0
),

mdson_service_obj as ( -- 服务对象信息
    SELECT service_obj_id,
           out_service_obj_id,
           service_obj_name,
           service_obj_type,
           service_obj_type_name,
           region,
           sub_region,
           channel_type,
           channel_sub_type,
           link_account,
           if_nc_service_obj,
           if_ncm_service_obj,
           if_virtual_service_obj,
           if_sepecial_service_obj,
           is_nc,
           isaroundhospital_pgroup,
           status,
           store_class_name,
           is_star_shop,
           shop_star,
           is_nc_new_service_obj,
           is_service_obj_active,
           is_low_new_nc
    FROM prod_mdson.dim_service_obj_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0 --and      status != 0
),

mdson_service_obj_sever as ( -- 服务对象及人员信息
    SELECT store_code,
           server_code,
           server_name,
           job_name,
           extra_json
    FROM prod_mdson.ads_service_obj_server_d
    WHERE dayid = '${v_date}'
    AND store_code NOT LIKE '3-%'

    UNION ALL

    SELECT store_code,
           server_code,
           server_name,
           job_name,
           extra_json
    FROM prod_mdson.ads_service_obj_server_d
    WHERE dayid = '${v_date_1}'
    AND store_code LIKE '3-%'
),

mdson_service_obj_user as ( -- 服务对象及人员信息整合
    SELECT DISTINCT t1.service_obj_id,
           job_id,
           t3.job_name,
           channel_type,
           service_obj_type_name,
           is_nc_new_service_obj,
           is_low_new_nc,
           isaroundhospital_pgroup,
           is_star_shop,
           shop_star,
           store_class_name,
           is_service_obj_active
    FROM mdson_service_obj t1
    LEFT JOIN mdson_service_obj_sever t2 ON t1.service_obj_id = t2.store_code
    LEFT JOIN mdson_user t3 ON t2.server_code = t3.empno
    WHERE job_id IS NOT NULL
),

-- 20260624：增加门店白名单
-- 当月门店白名单
white_list_store as (
    SELECT store_code,
           change_indicator,
           change_target
    FROM prod_mdson_dev.inf_mdson_white_list_store
    WHERE year_month = '${v_cur_month}'
),

 -- 月度指标
white_list_store_month as (
    SELECT store_code,
           change_indicator,
           change_target
    FROM white_list_store
    WHERE change_indicator = '月度门店目标拜访频次'
),

-- 季度目标
white_list_store_quar as (
    SELECT store_code,
           change_indicator,
           change_target
    FROM white_list_store
    WHERE change_indicator = '季度门店目标拜访频次'
)

INSERT OVERWRITE TABLE prod_mdson.ads_mdson_service_target_d_v2 PARTITION (dayid = '${v_date}')
SELECT service_obj_id,
       job_id,

       -- 月目标
       CASE WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_nc_new_service_obj = 1 AND is_low_new_nc = 1 AND t1.change_target IS NULL THEN 4 -- 低产新入职NC门店
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_nc_new_service_obj = 1 AND is_low_new_nc = 1 AND t1.change_target IN ('2', '减半') THEN 2
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_nc_new_service_obj = 1 AND is_low_new_nc = 1 AND t1.change_target IN ('1') THEN 1 -- 常规NC门店
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_nc_new_service_obj = 1 AND is_low_new_nc = 0 AND (t1.change_target IS NULL OR t1.change_target = '2') THEN 2
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND is_nc_new_service_obj = 1 AND is_low_new_nc = 0 AND t1.change_target IN ('1', '减半') THEN 1 -- 院线店
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND isaroundhospital_pgroup = 1 AND (t1.change_target IS NULL OR t1.change_target = '2') THEN 2
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND isaroundhospital_pgroup = 1 AND t1.change_target IN ('1', '减半') THEN 1 -- GT院线店/五星门店/星级院线店
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND (is_nc_new_service_obj = 1 OR shop_star = 5 OR (isaroundhospital_pgroup = 1 AND is_star_shop = 1)) AND (t1.change_target IS NULL OR t1.change_target = '2') THEN 2
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND (is_nc_new_service_obj = 1 OR shop_star = 5 OR (isaroundhospital_pgroup = 1 AND is_star_shop = 1)) AND t1.change_target IN ('1', '减半') THEN 1 -- GT非5星的星级门店/院线店
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND (is_star_shop = 1 OR isaroundhospital_pgroup = 1) AND (t1.change_target IS NULL OR t1.change_target IN ('1', '减半')) THEN 1
            ELSE 0 END as month_target,

       -- 季目标
       CASE WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND (store_class_name = '实体门店' AND is_service_obj_active = 1) AND t2.change_target = '4' THEN 4
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND (store_class_name = '实体门店' AND is_service_obj_active = 1) AND t2.change_target = '3' THEN 3
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND (store_class_name = '实体门店' AND is_service_obj_active = 1) AND t2.change_target = '2' THEN 2
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('COT', 'KA') AND (store_class_name = '实体门店' AND is_service_obj_active = 1) AND (t2.change_target = '1' OR t2.change_target IS NULL) THEN 1 -- GT渠道专职NC门店
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_nc_new_service_obj = 1 AND t2.change_target = '4' THEN 4
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_nc_new_service_obj = 1 AND t2.change_target = '3' THEN 3
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_nc_new_service_obj = 1 AND t2.change_target = '2' THEN 2
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND channel_type IN ('GT') AND is_nc_new_service_obj = 1 AND (t2.change_target = '1' OR t2.change_target IS NULL) THEN 1 -- 院线店
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND isaroundhospital_pgroup = 1 AND t2.change_target = '4' THEN 4
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND isaroundhospital_pgroup = 1 AND t2.change_target = '3' THEN 3
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND isaroundhospital_pgroup = 1 AND t2.change_target = '2' THEN 2
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND isaroundhospital_pgroup = 1 AND (t2.change_target = '1' OR t2.change_target IS NULL) THEN 1 -- 星级门店
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND is_star_shop = 1 AND t2.change_target = '4' THEN 4
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND is_star_shop = 1 AND t2.change_target = '3' THEN 3
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND is_star_shop = 1 AND t2.change_target = '2' THEN 2
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND is_star_shop = 1 AND (t2.change_target = '1' OR t2.change_target IS NULL) THEN 1 -- 服务商
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND service_obj_type_name = '服务商' AND t2.change_target = '4' THEN 4
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND service_obj_type_name = '服务商' AND t2.change_target = '3' THEN 3
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND service_obj_type_name = '服务商' AND t2.change_target = '2' THEN 2
            WHEN job_name IN ('城市渠道负责人', '城市群负责人') AND service_obj_type_name = '服务商' AND (t2.change_target = '1' OR t2.change_target IS NULL) THEN 1
            ELSE 0 END as quar_target
FROM mdson_service_obj_user
LEFT JOIN white_list_store_month t1 ON mdson_service_obj_user.service_obj_id = concat('1-', t1.store_code)
LEFT JOIN white_list_store_quar t2 ON mdson_service_obj_user.service_obj_id = concat('1-', t2.store_code)