


INSERT INTO `t_p0_subject_group` (`id`, `creator`, `editor`, `group_name`, `group_tag`, `feature_type`, `feature_ids`, `root_dept_id`, `job_ids`, `manager_job_ids`, `area_dept_ids`)
VALUES (8, '12903870260', '12903870260', '大BD团队', 'bigbd', 1, '4', 32, '[93]', '[4,9]', '[1659,1847,2161,2196,2227,2229,2249,2252,2280]'),
       (9, '12903870260', '12903870260', 'YBD团队', 'ybd', 1, '63', 32, '[247]', '[4,9,249]', '[1659,1847,2161,2196,2227,2229,2249,2252,2280]');

update t_p0_subject_group set area_dept_ids = '[1659,1847,2161,2196,2227,2229,2249,2252,2280]' WHERE id = 3;