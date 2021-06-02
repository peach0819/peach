
with ads as (
    SELECT * FROM ads_salary_base_logical_scene_d WHERE dayid = '$v_date'
), dwd as (
    SELECT * FROM dwd_salary_logical_scene_d WHERE dayid = '$v_date'
), only_new as (
    SELECT
        ads.is_split as ads_is_split,
        ads.service_feature_names as ads_service_feature_names,
        ads.service_feature_name as ads_service_feature_name,
        ads.coefficient_logical as ads_coefficient_logical,
        ads.commission_logical as ads_commission_logical,
        null as dwd_is_split,
        null as dwd_service_feature_names,
        null as dwd_service_feature_name,
        null as dwd_coefficient_logical,
        null as dwd_commission_logical,
        'only_new' as err_info
    FROM ads
    LEFT JOIN dwd ON ads.is_split = dwd.is_split and ads.service_feature_names = dwd.service_feature_names and ads.service_feature_name = dwd.service_feature_name
    WHERE dwd.is_split is null
), only_old as (
    SELECT
        null as ads_is_split,
        null as ads_service_feature_names,
        null as ads_service_feature_name,
        null as ads_coefficient_logical,
        null as ads_commission_logical,
        dwd.is_split as dwd_is_split,
        dwd.service_feature_names as dwd_service_feature_names,
        dwd.service_feature_name as dwd_service_feature_name,
        dwd.coefficient_logical as dwd_coefficient_logical,
        dwd.commission_logical as dwd_commission_logical,
        'only_old' as err_info
    FROM dwd
    LEFT JOIN ads ON ads.is_split = dwd.is_split and ads.service_feature_names = dwd.service_feature_names and ads.service_feature_name = dwd.service_feature_name
    WHERE ads.is_split is null
), diff as (
    SELECT
        ads.is_split as ads_is_split,
        ads.service_feature_names as ads_service_feature_names,
        ads.service_feature_name as ads_service_feature_name,
        ads.coefficient_logical as ads_coefficient_logical,
        ads.commission_logical as ads_commission_logical,
        dwd.is_split as dwd_is_split,
        dwd.service_feature_names as dwd_service_feature_names,
        dwd.service_feature_name as dwd_service_feature_name,
        dwd.coefficient_logical as dwd_coefficient_logical,
        dwd.commission_logical as dwd_commission_logical,
        'diff' as err_info
    FROM ads
    INNER JOIN dwd ON ads.is_split = dwd.is_split and ads.service_feature_names = dwd.service_feature_names and ads.service_feature_name = dwd.service_feature_name
    WHERE ads.coefficient_logical != dwd.coefficient_logical
    OR ads.commission_logical != dwd.commission_logical
)
SELECT *
FROM only_new

UNION ALL

SELECT *
FROM only_old

UNION ALL

SELECT * FROM diff