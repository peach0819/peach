

ALTER TABLE t_touch_task ADD COLUMN use_ab_test tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否开启AB测试 0不开启 1开启';
ALTER TABLE t_touch_task ADD COLUMN ab_content_template MEDIUMTEXT COMMENT 'AB测试内容';
ALTER TABLE t_touch_task_detail ADD COLUMN ab_test_group_id tinyint(4) COMMENT 'AB测试分组';