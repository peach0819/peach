with base as (
    SELECT DISTINCT service_obj_id
    FROM prod_mdson.dwd_service_obj_d
    WHERE dayid = '${v_date}'
),

--NC门店信息
nc_info as (
    SELECT distinct dayid,
                    concat('1-', store_code) as service_obj_id
    FROM prod_mdson.dwd_r_ncinfo_d
    WHERE dayid IN (REPLACE(DATEADD(date'${v_op_month}-01', -1, 'dd'), '-', ''), concat(substr('${v_date}', 1, 6), '15'))
    AND nc_status = '在职员工'
    AND store_status = '正常营业'
    AND nc_jobtype IN ('专职', '客制化') -- 20260612：NC门店除原有的专职NC外，需包含客制化NC
    AND nc_position = 'NC'
    AND date_format(entry_date, 'yyyyMM') != '${v_cur_month}'
),

-- 低产/新入职NC门店
low_new_nc as (
    SELECT dayid,
           concat('1-', store_code) as service_obj_id,
           max(CASE WHEN low_performance_type IN ('一期低效', '二期低效') OR datediff(to_date(dayid, 'yyyyMMdd'), to_date(entry_date)) < 365 THEN 1 ELSE 0 END) as is_low_new_nc
    FROM prod_mdson.dwd_r_ncinfo_d
    WHERE dayid IN (REPLACE(DATEADD(date'${v_op_month}-01', -1, 'dd'), '-', ''), concat(substr('${v_date}', 1, 6), '15'))
    AND nc_status = '在职员工'
    AND nc_position = 'NC'
    AND date_format(entry_date, 'yyyyMM') != '${v_cur_month}'
    GROUP BY concat('1-', store_code),
             dayid
),

--有离职人员门店
resign as (
    SELECT DISTINCT concat('1-', store_code) as service_obj_id
    FROM prod_mdson.dwd_r_ncinfo_d
    WHERE dayid = '${v_date}'
    AND nc_position = 'NC'
    AND date_format(resign_date, 'yyyyMM') = '${v_cur_month}'
    AND '${v_date}' >= concat(date_format(resign_date, 'yyyyMM'), '15')
)

INSERT OVERWRITE TABLE ads_crm_nc_shop_d PARTITION (dayid = '${v_date}')
SELECT base.service_obj_id,
       if(nc_info.service_obj_id is not null, 1, 0) as is_nc,
       nvl(low_new_nc.is_low_new_nc, 0) as is_low_new_nc
FROM base
LEFT JOIN resign ON base.service_obj_id = resign.service_obj_id
LEFT JOIN nc_info ON nc_info.service_obj_id = base.service_obj_id AND nc_info.dayid = if(resign.service_obj_id is null, REPLACE(DATEADD(date'${v_op_month}-01', -1, 'dd'), '-', ''), concat(substr('${v_date}', 1, 6), '15'))
LEFT JOIN low_new_nc ON low_new_nc.service_obj_id = base.service_obj_id AND low_new_nc.dayid = if(resign.service_obj_id is null, REPLACE(DATEADD(date'${v_op_month}-01', -1, 'dd'), '-', ''), concat(substr('${v_date}', 1, 6), '15'))