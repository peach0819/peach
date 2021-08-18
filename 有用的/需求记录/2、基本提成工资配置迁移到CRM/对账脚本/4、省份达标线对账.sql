
with ads as (
    SELECT * FROM ads_salary_base_pro_mark_line_d WHERE dayid = '$v_date'
), dwd as (
    SELECT * FROM dwd_salary_pro_mark_line_d WHERE dayid = '$v_date'
), only_new as (
    SELECT
        ads.shop_pro_id as ads_shop_pro_id,
        ads.shop_pro_name as ads_shop_pro_name,
        ads.reach_shop_mark_line as ads_reach_shop_mark_line,
        ads.new_sign_shop_mark_line as ads_new_sign_shop_mark_line,
        null as dwd_shop_pro_id,
        null as dwd_shop_pro_name,
        null as dwd_reach_shop_mark_line,
        null as dwd_new_sign_shop_mark_line,
        'only_new' as err_info
    FROM ads
    LEFT JOIN dwd ON ads.shop_pro_id = dwd.shop_pro_id
    WHERE dwd.shop_pro_id is null
), only_old as (
    SELECT
        null as ads_shop_pro_id,
        null as ads_shop_pro_name,
        null as ads_reach_shop_mark_line,
        null as ads_new_sign_shop_mark_line,
        dwd.shop_pro_id as dwd_shop_pro_id,
        dwd.shop_pro_name as dwd_shop_pro_name,
        dwd.reach_shop_mark_line as dwd_reach_shop_mark_line,
        dwd.new_sign_shop_mark_line as dwd_new_sign_shop_mark_line,
        'only_old' as err_info
    FROM dwd
    LEFT JOIN ads ON ads.shop_pro_id = dwd.shop_pro_id
    WHERE ads.shop_pro_id is null
), diff as (
    SELECT
        ads.shop_pro_id as ads_shop_pro_id,
        ads.shop_pro_name as ads_shop_pro_name,
        ads.reach_shop_mark_line as ads_reach_shop_mark_line,
        ads.new_sign_shop_mark_line as ads_new_sign_shop_mark_line,
        dwd.shop_pro_id as dwd_shop_pro_id,
        dwd.shop_pro_name as dwd_shop_pro_name,
        dwd.reach_shop_mark_line as dwd_reach_shop_mark_line,
        dwd.new_sign_shop_mark_line as dwd_new_sign_shop_mark_line,
        'diff' as err_info
    FROM ads
    INNER JOIN dwd ON ads.shop_pro_id = dwd.shop_pro_id
    WHERE ads.new_sign_shop_mark_line != dwd.new_sign_shop_mark_line
    OR ads.reach_shop_mark_line != dwd.reach_shop_mark_line
    OR ads.shop_pro_name != dwd.shop_pro_name
)
SELECT *
FROM only_new

UNION ALL

SELECT *
FROM only_old

UNION ALL

SELECT * FROM diff