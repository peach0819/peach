with record as (
    SELECT *
    FROM prod_mdson.ads_crm_visit_record_d
    WHERE dayid = '${v_date}'
),

user as (
    SELECT *
    FROM prod_mdson.dim_user_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
    AND dismiss_status = 0
),

service_obj as (
    SELECT *
    FROM prod_mdson.ads_crm_visit_service_obj_d
    WHERE dayid = '${v_date}'
    AND if_virtual = 0  --过滤虚拟门店
    AND INSTR(service_obj_name,'测试') = 0 --过滤测试门店
)

SELECT record.id as 拜访ID,
       CASE WHEN record.visit_type = 1 THEN '门店拜访'
            WHEN record.visit_type = 2 THEN '客户拜访'
            WHEN record.visit_type = 3 THEN '经销商拜访'
            WHEN record.visit_type = 4 THEN '服务商拜访'
            ELSE '其他' END as 拜访类型,
       CASE WHEN record.visit_mode = 1 THEN '有效拜访'
            WHEN record.visit_mode = 2 THEN '无效拜访'
            ELSE '其他' END as 是否有效拜访,
       substr(record.visit_time, 1, 10) as 拜访日期,
       record.user_id as 拜访人ID,
       user.user_real_name as 拜访人姓名,
       user.channel_name as 拜访人渠道,
       record.service_obj_id as 拜访对象ID,
       service_obj.service_obj_name as 拜访对象名称,
       service_obj.channel_type as 拜访对象渠道,
       if(service_obj.is_nc = 1, '是', '否') as 是否专职NC门店,
       if(service_obj.is_low_new_nc = 1, '是', '否') as 是否低产或新入职NC门店,
       if(service_obj.is_hospital = 1, '是', '否') as 是否院线店,
       if(service_obj.is_star = 1, '是', '否') as 是否星级门店,
       service_obj.star as 门店星数,
       if(service_obj.is_star_quarter = 1, '是', '否') as 是否季度星级门店,
       service_obj.star_quarter as 门店季度星数,
       service_obj.store_class_name as 门店分类,
       if(service_obj.status = 1, '是', '否') as 门店是否正常营业,
       if(record.freeze_server_id = record.user_id, '是', '否') as 是否所有人拜访
FROM record
INNER JOIN user ON record.user_id = user.user_id
INNER JOIN service_obj ON record.service_obj_id = service_obj.service_obj_id
ORDER BY record.id DESC;