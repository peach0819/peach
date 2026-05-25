update t_p0_subject set do_start = '2025-12-01 00:00:00', do_end = '2025-12-31 00:00:00', stat_start = '2025-12-01 00:00:00', stat_end = '2025-12-31 00:00:00', subject_month = '202512'  WHERE id = 13766;
update t_p0_subject set do_start = '2025-10-01 00:00:00', do_end = '2025-10-31 00:00:00', stat_start = '2025-10-01 00:00:00', stat_end = '2025-10-31 00:00:00', subject_month = '202510'  WHERE id = 13765;
update t_p0_subject set do_start = '2025-08-23 00:00:00', do_end = '2025-08-31 00:00:00', stat_start = '2025-08-23 00:00:00', stat_end = '2025-08-31 00:00:00', subject_month = '202508'  WHERE id = 13764;
update t_p0_subject set do_start = '2025-11-01 00:00:00', do_end = '2025-11-30 00:00:00', stat_start = '2025-11-01 00:00:00', stat_end = '2025-11-30 00:00:00', subject_month = '202511'  WHERE id = 13762;
update t_p0_subject set do_start = '2025-09-01 00:00:00', do_end = '2025-09-30 00:00:00', stat_start = '2025-09-01 00:00:00', stat_end = '2025-09-30 00:00:00', subject_month = '202509'  WHERE id = 13761;
update t_p0_subject set do_start = '2025-06-01 00:00:00', do_end = '2025-06-30 00:00:00', stat_start = '2025-06-01 00:00:00', stat_end = '2025-06-30 00:00:00', subject_month = '202506'  WHERE id = 13763;


update t_p0_subject set edit_time = '2025-12-31 00:00:00'  WHERE id = 13766;
update t_p0_subject set edit_time = '2025-10-31 00:00:00'  WHERE id = 13765;
update t_p0_subject set edit_time = '2025-08-31 00:00:00'  WHERE id = 13764;
update t_p0_subject set edit_time = '2025-11-30 00:00:00'  WHERE id = 13762;
update t_p0_subject set edit_time = '2025-09-30 00:00:00'  WHERE id = 13761;
update t_p0_subject set edit_time = '2025-06-30 00:00:00'  WHERE id = 13763;


update t_p0_subject_group set root_dept_id = 1958 WHERE id  = 2;
update t_p0_subject_group set root_dept_id = 2232 WHERE id  = 5;


14470	可心柔浙江省项目-8.23-8.31
14471	可心柔浙江省项目-9.01-9.30
14472	可心柔浙江省项目-10.01-10.31
14473	可心柔浙江省项目-11.1-11.30
14474	可心柔浙江省项目-12.1-12.31

update t_p0_subject set status = 2, do_start = '2025-08-23 00:00:00', do_end = '2025-08-31 00:00:00', stat_start = '2025-08-23 00:00:00', stat_end = '2025-08-31 00:00:00', subject_month = '202508', edit_time = '2025-08-31 00:00:00'  WHERE id = 14470;
update t_p0_subject set status = 2, do_start = '2025-09-01 00:00:00', do_end = '2025-09-30 00:00:00', stat_start = '2025-09-01 00:00:00', stat_end = '2025-09-30 00:00:00', subject_month = '202509', edit_time = '2025-09-30 00:00:00'  WHERE id = 14471;
update t_p0_subject set status = 2, do_start = '2025-10-01 00:00:00', do_end = '2025-10-31 00:00:00', stat_start = '2025-10-01 00:00:00', stat_end = '2025-10-31 00:00:00', subject_month = '202510', edit_time = '2025-10-31 00:00:00'  WHERE id = 14472;
update t_p0_subject set status = 2, do_start = '2025-11-01 00:00:00', do_end = '2025-11-30 00:00:00', stat_start = '2025-11-01 00:00:00', stat_end = '2025-11-30 00:00:00', subject_month = '202511', edit_time = '2025-11-30 00:00:00'  WHERE id = 14473;
update t_p0_subject set status = 2, do_start = '2025-12-01 00:00:00', do_end = '2025-12-31 00:00:00', stat_start = '2025-12-01 00:00:00', stat_end = '2025-12-31 00:00:00', subject_month = '202512', edit_time = '2025-12-31 00:00:00'  WHERE id = 14474;