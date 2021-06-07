
update t_sp_area_brand
set is_deleted=1,status=0,end_time=now(), editor='系统地址库订正'
where area_id in
(1224,1225,1768);

update t_sp_area
set is_deleted=1, status=0, editor='系统地址库订正'
where area_id in
(1224,1225,1768);

update t_sp_user_area
set is_deleted =1,editor='系统地址库订正'
where area_id in
(1224,1225,1768);


update t_sp_area_brand set area_id = 1226 where area_id = 1224;
update t_sp_area_brand set area_id = 1223 where area_id = 1225;
update t_sp_area_brand set area_id = 1770 where area_id = 1768;

update t_sp_area set area_id = 1226 where area_id = 1224;
update t_sp_area set area_id = 1223 where area_id = 1225;
update t_sp_area set area_id = 1770 where area_id = 1768;

update t_sp_user_area set area_id = 1226 where area_id = 1224;
update t_sp_user_area set area_id = 1223 where area_id = 1225;
update t_sp_user_area set area_id = 1770 where area_id = 1768;