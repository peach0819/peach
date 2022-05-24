with order1 as (
    SELECT *
    FROM dw_trd_order_d
    where dayid='$v_date'
    AND order_place_time> '20210701000000'
)

SELECT
           order_id,
           trade_id,
           trade_no,
           order_place_time,
           shop_id,
           sale_dc_id,
           sale_dc_id_name,
           bu_id,
           bu_id_name,
           is_pickup_pay_order,
           supply_id,
           supply_name,
           category_1st_id,
           category_2nd_id,
           category_3rd_id,
           category_1st_name,
           category_2nd_name,
           category_3rd_name,
           performance_category_1st_id,
           performance_category_1st_name,
           performance_category_2nd_id,
           performance_category_2nd_name,
           performance_category_3rd_id,
           performance_category_3rd_name,
           item_style,
           item_style_name
FROM order1
WHERE bu_id !=0
