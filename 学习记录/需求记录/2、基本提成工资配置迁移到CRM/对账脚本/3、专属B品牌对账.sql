
with ads as (
    SELECT * FROM ads_salary_base_exclusive_b_brand_d WHERE dayid = '$v_date'
), dwd as (
    SELECT * FROM dwd_salary_exclusive_b_brand_d WHERE dayid = '$v_date'
), only_new as (
    SELECT
        ads.brand_id as ads_brand_id,
        ads.brand_name as ads_brand_name,
        null as dwd_brand_id,
        null as dwd_brand_name,
        'only_new' as err_info
    FROM ads
    LEFT JOIN dwd ON ads.brand_id = dwd.brand_id
    WHERE dwd.brand_id is null
), only_old as (
    SELECT
        null as ads_brand_id,
        null as ads_brand_name,
        dwd.brand_id as dwd_brand_id,
        dwd.brand_name as dwd_brand_name,
        'only_old' as err_info
    FROM dwd
    LEFT JOIN ads ON ads.brand_id = dwd.brand_id
    WHERE ads.brand_id is null
), diff as (
    SELECT
        ads.brand_id as ads_brand_id,
        ads.brand_name as ads_brand_name,
        dwd.brand_id as dwd_brand_id,
        dwd.brand_name as dwd_brand_name,
        'diff' as err_info
    FROM ads
    INNER JOIN dwd ON ads.brand_id = dwd.brand_id
    WHERE ads.brand_name != dwd.brand_name
)
SELECT *
FROM only_new

UNION ALL

SELECT *
FROM only_old

UNION ALL

SELECT * FROM diff