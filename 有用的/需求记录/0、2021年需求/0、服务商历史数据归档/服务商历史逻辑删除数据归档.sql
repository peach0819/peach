SELECT count(*), YEAR(edit_time) 
from t_sp_area_brand
WHERE is_deleted = 1
GROUP BY YEAR(edit_time) 

--已废弃表 t_sp_brand_shop_tag:
SELECT *
FROM t_sp_brand_shop_tag 
WHERE is_deleted = 1;

--已废弃表 t_sp_rebate_setting
SELECT *
FROM t_sp_rebate_setting 
WHERE is_deleted = 1;

--服务商品牌授权区域表 t_sp_area_brand
SELECT *
FROM t_sp_area_brand 
WHERE is_deleted = 1
AND YEAR(edit_time)<2020;

--服务商用户授权品牌表 t_sp_user_brand
SELECT *
FROM t_sp_user_brand 
WHERE is_deleted = 1
AND YEAR(edit_time)<2020;

--服务商用户授权区域表 t_sp_user_area
SELECT *
FROM t_sp_user_area 
WHERE is_deleted = 1
AND YEAR(edit_time)<2020;

--服务商授权区域表 t_sp_area
SELECT *
FROM t_sp_area 
WHERE is_deleted = 1
AND YEAR(edit_time)<2020;

--服务商品牌表 t_sp_brand
SELECT *
FROM t_sp_brand 
WHERE is_deleted = 1
AND YEAR(edit_time)<2020;

