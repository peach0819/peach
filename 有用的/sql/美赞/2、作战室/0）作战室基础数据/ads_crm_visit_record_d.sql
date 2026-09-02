WITH base as (
    SELECT id,
           visit_type,
           visit_time,
           visit_mode,
           service_obj_id,
           user_id,
           LEAST(REPLACE(LAST_DAY(TO_DATE(visit_time, 'yyyy-MM-dd HH:mi:ss')), '-', ''), '${v_date}') as data_dayid --小记所在月份的月末分区
    FROM prod_mdson.dwd_crm_visit_record_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
    AND visit_status = 2  --已完成的小记
    AND DATETRUNC(TO_DATE('${v_date}', 'yyyymmdd'), 'quarter') = DATETRUNC(TO_DATE(visit_time, 'yyyy-mm-dd hh:mi:ss'), 'quarter') --只取本季度的小记数据
),

service_obj as (
    SELECT dayid,
           service_obj_id,
           freeze_server_id
    FROM prod_mdson.ads_crm_visit_service_obj_d
    WHERE DATETRUNC(TO_DATE('${v_date}', 'yyyymmdd'), 'quarter') = DATETRUNC(TO_DATE(dayid, 'yyyymmdd'), 'quarter') --取本季度的分区
)

INSERT OVERWRITE TABLE ads_crm_visit_record_d PARTITION (dayid = '${v_date}')
SELECT base.id,
       base.visit_type,
       base.visit_time,
       base.visit_mode,
       base.service_obj_id,
       base.user_id,
       service_obj.freeze_server_id
FROM base
LEFT JOIN service_obj ON base.service_obj_id = service_obj.service_obj_id AND base.data_dayid = service_obj.dayid