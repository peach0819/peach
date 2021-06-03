
with ads as (
    SELECT * FROM ads_salary_base_offline_refund_order_d WHERE dayid = '$v_date'
), dwd as (
    SELECT * FROM dw_order_offline_refund_d WHERE dayid = '$v_date'
), only_new as (
    SELECT
        ads.order_id as ads_order_id,
        ads.trade_id as ads_trade_id,
        ads.trade_no as ads_trade_no,
        ads.refund_actual_amount as ads_refund_actual_amount,
        null as dwd_order_id,
        null as dwd_trade_id,
        null as dwd_trade_no,
        null as dwd_refund_actual_amount,
        'only_new' as err_info
    FROM ads
    LEFT JOIN dwd ON ads.order_id = dwd.order_id and ads.trade_id = dwd.trade_id and ads.trade_no = dwd.trade_no
    WHERE dwd.order_id is null
), only_old as (
    SELECT
        null as ads_order_id,
        null as ads_trade_id,
        null as ads_trade_no,
        null as ads_refund_actual_amount,
        dwd.order_id as dwd_order_id,
        dwd.trade_id as dwd_trade_id,
        dwd.trade_no as dwd_trade_no,
        dwd.refund_actual_amount as dwd_refund_actual_amount,
        'only_old' as err_info
    FROM dwd
    LEFT JOIN ads ON ads.order_id = dwd.order_id and ads.trade_id = dwd.trade_id and ads.trade_no = dwd.trade_no
    WHERE ads.order_id is null
), diff as (
    SELECT
        ads.order_id as ads_order_id,
        ads.trade_id as ads_trade_id,
        ads.trade_no as ads_trade_no,
        ads.refund_actual_amount as ads_refund_actual_amount,
        dwd.order_id as dwd_order_id,
        dwd.trade_id as dwd_trade_id,
        dwd.trade_no as dwd_trade_no,
        dwd.refund_actual_amount as dwd_refund_actual_amount,
        'diff' as err_info
    FROM ads
    INNER JOIN dwd ON ads.order_id = dwd.order_id and ads.trade_id = dwd.trade_id and ads.trade_no = dwd.trade_no
    WHERE ads.refund_actual_amount != dwd.refund_actual_amount
)
SELECT *
FROM only_new

UNION ALL

SELECT *
FROM only_old

UNION ALL

SELECT * FROM diff