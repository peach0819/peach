
update t_sp_area_brand
set is_deleted=1,status=0,end_time=now(), editor='系统地址库订正'
where area_id in
(480,
 481,
 486,
 1168);

update t_sp_area
set is_deleted=1, status=0, editor='系统地址库订正'
where area_id in
(480,
 481,
 486,
 1168);

update t_sp_user_area
set is_deleted =1,editor='系统地址库订正'
where area_id in
(480,
 481,
 486,
 1168);