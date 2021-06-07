with ads as (
    SELECT * FROM ads_salary_base_user_d WHERE dayid = '$v_date'
), dwd as (
    SELECT * FROM dwd_salary_user_d WHERE dayid = '$v_date'
), only_new as (
    SELECT
        ads.user_name as ads_user_name,
        ads.is_split as ads_is_split,
        ads.is_coefficient as ads_is_coefficient,
        null as dwd_user_name,
        null as dwd_is_split,
        null as dwd_is_coefficient,
        'only_new' as err_info
    FROM ads
    LEFT JOIN dwd ON ads.user_name = dwd.user_name
    WHERE dwd.user_name is null
), only_old as (
    SELECT
        null as ads_user_name,
        null as ads_is_split,
        null as ads_is_coefficient,
        dwd.user_name as dwd_user_name,
        dwd.is_split as dwd_is_split,
        dwd.is_coefficient as dwd_is_coefficient,
        'only_old' as err_info
    FROM dwd
    LEFT JOIN ads ON ads.user_name = dwd.user_name
    WHERE ads.user_name is null
), diff as (
    SELECT
        ads.user_name as ads_user_name,
        ads.is_split as ads_is_split,
        ads.is_coefficient as ads_is_coefficient,
        dwd.user_name as dwd_user_name,
        dwd.is_split as dwd_is_split,
        dwd.is_coefficient as dwd_is_coefficient,
        'diff' as err_info
    FROM ads
    INNER JOIN dwd ON ads.user_name = dwd.user_name
    WHERE ads.is_split != dwd.is_split
    OR ads.is_coefficient != dwd.is_coefficient
)
SELECT *
FROM only_new

UNION ALL

SELECT *
FROM only_old

UNION ALL

SELECT * FROM diff