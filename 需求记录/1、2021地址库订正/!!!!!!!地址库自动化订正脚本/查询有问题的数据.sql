SELECT b.id
FROM  yt_hsp.t_sp_area_brand b
INNER JOIN yt_ustone.t_area a ON b.area_id = a.area_id
WHERE a.is_invalid = 1
AND b.status=1


SELECT b.id
FROM  yt_hsp.t_sp_area b
INNER JOIN yt_ustone.t_area a ON b.area_id = a.area_id
WHERE a.is_invalid = 1
AND b.status=1;


SELECT b.id
FROM  yt_hsp.t_sp_user_area b
INNER JOIN yt_ustone.t_area a ON b.area_id = a.area_id
WHERE a.is_invalid = 1
AND b.is_deleted=0;