
with ads as (
    SELECT * FROM ads_salary_base_offline_refund_d WHERE dayid = '$v_date'
), dwd as (
    SELECT * FROM dw_offline_refund_d WHERE dayid = '$v_date'
), only_new as (
    SELECT
        ads.trade_no as ads_trade_no,
        ads.refund_actual_amount as ads_refund_actual_amount,
        null as dwd_trade_no,
        null as dwd_refund_actual_amount,
        'only_new' as err_info
    FROM ads
    LEFT JOIN dwd ON ads.trade_no = dwd.trade_no
    WHERE dwd.trade_no is null
), only_old as (
    SELECT
        null as ads_trade_no,
        null as ads_refund_actual_amount,
        dwd.trade_no as dwd_trade_no,
        dwd.refund_actual_amount as dwd_refund_actual_amount,
        'only_old' as err_info
    FROM dwd
    LEFT JOIN ads ON ads.trade_no = dwd.trade_no
    WHERE ads.trade_no is null
), diff as (
    SELECT
        ads.trade_no as ads_trade_no,
        ads.refund_actual_amount as ads_refund_actual_amount,
        dwd.trade_no as dwd_trade_no,
        dwd.refund_actual_amount as dwd_refund_actual_amount,
        'diff' as err_info
    FROM ads
    INNER JOIN dwd ON ads.trade_no = dwd.trade_no
    WHERE ads.refund_actual_amount != dwd.refund_actual_amount
)
SELECT *
FROM only_new

UNION ALL

SELECT *
FROM only_old

UNION ALL

SELECT * FROM diff