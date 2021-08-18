
SELECT *
FROM yt_hsp.t_sp_order_snapshot o
INNER JOIN yt_ustone.t_shop s ON o.shop_id = s.SHOP_ID
WHERE s.sub_store_type IN (11102,11104);



SELECT o.*
FROM yt_hsp.t_sp_order_snapshot o
INNER JOIN yt_ustone.t_shop s ON o.shop_id = s.SHOP_ID
INNER JOIN yt_ustone.t_shop_extra e ON s.shop_id = e.shop_id
INNER JOIN yt_ustone.t_user u ON e.biz_id = u.user_id
WHERE s.sub_store_type IN (11102,11104)
AND u.user_type = 12
AND o.sp_id!=u.biz_id
order by o.id desc
limit 10