SELECT i.operator_id, u.full_name,  br.name
FROM yt_hsp.t_sp_info i
LEFT JOIN yt_hsp.t_sp_brand b ON b.sp_id = i.id
LEFT JOIN yt_icp.t_brand br ON b.brand_id = br.id
LEFT JOIN yt_ustone.t_user_admin u ON i.operator_id = u.user_id
WHERE i.sp_status = 1
AND b.status = 1
AND i.operator_id is not null