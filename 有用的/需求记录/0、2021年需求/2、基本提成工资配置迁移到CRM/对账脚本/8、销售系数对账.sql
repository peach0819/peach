with ads as (
    SELECT * FROM ads_salary_base_sales_coefficient_d WHERE dayid = '$v_date'
), dwd as (
    SELECT * FROM dwd_salary_sales_coefficient_d WHERE is_valid = 1 and dayid = substr('$v_date',0,6)
), only_new as (
    SELECT
        ads.sales_user_name as ads_sales_user_name,
        ads.coefficient as ads_coefficient,
        ads.remark as ads_remark,
        null as dwd_sales_user_name,
        null as dwd_coefficient,
        null as dwd_remark,
        'only_new' as err_info
    FROM ads
    LEFT JOIN dwd ON ads.sales_user_name = dwd.sales_user_name
    WHERE dwd.sales_user_name is null
), only_old as (
    SELECT
        null as ads_sales_user_name,
        null as ads_coefficient,
        null as ads_remark,
        dwd.sales_user_name as dwd_sales_user_name,
        dwd.coefficient as dwd_coefficient,
        dwd.remark as dwd_remark,
        'only_old' as err_info
    FROM dwd
    LEFT JOIN ads ON ads.sales_user_name = dwd.sales_user_name
    WHERE ads.sales_user_name is null
), diff as (
    SELECT
        ads.sales_user_name as ads_sales_user_name,
        ads.coefficient as ads_coefficient,
        ads.remark as ads_remark,
        dwd.sales_user_name as dwd_sales_user_name,
        dwd.coefficient as dwd_coefficient,
        dwd.remark as dwd_remark,
        'diff' as err_info
    FROM ads
    INNER JOIN dwd ON ads.sales_user_name = dwd.sales_user_name
    WHERE ads.coefficient != dwd.coefficient
    OR ads.remark != dwd.remark
)
SELECT *
FROM only_new

UNION ALL

SELECT *
FROM only_old

UNION ALL

SELECT * FROM diff