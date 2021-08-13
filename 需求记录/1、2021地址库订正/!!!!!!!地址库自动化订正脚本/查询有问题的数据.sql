--t_sp_area_brand
SELECT b.id
FROM  yt_hsp.t_sp_area_brand b
INNER JOIN yt_ustone.t_area a ON b.area_id = a.area_id
WHERE a.status = 2
AND a.inuse = 0
AND b.status=1

--t_sp_area
SELECT b.id
FROM  yt_hsp.t_sp_area b
INNER JOIN yt_ustone.t_area a ON b.area_id = a.area_id
WHERE a.status = 2
AND a.inuse = 0
AND b.status=1;

--t_sp_user_area
SELECT b.id
FROM  yt_hsp.t_sp_user_area b
INNER JOIN yt_ustone.t_area a ON b.area_id = a.area_id
WHERE a.status = 2
AND a.inuse = 0
AND b.is_deleted=0;

--t_sp_brand.area_cnt
SELECT b.*
FROM t_sp_brand b
INNER JOIN (
    SELECT count(*) as cnt, brand_id, sp_id
    FROM t_sp_area_brand
    WHERE is_deleted=0
    and status=1
    group by brand_id, sp_id
) temp ON b.sp_id = temp.sp_id AND b.brand_id = temp.brand_id
WHERE b.status = 1
and b.is_deleted = 0
AND b.area_cnt != temp.cnt