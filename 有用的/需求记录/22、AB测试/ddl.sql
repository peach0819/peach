

ALTER TABLE t_touch_task ADD COLUMN use_ab_test tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否开启AB测试 0不开启 1开启';

ALTER TABLE t_touch_task_shop ADD COLUMN ab_test_group VARCHAR(20) COMMENT 'AB测试分桶';
ALTER TABLE t_touch_task_shop ADD COLUMN ab_test_group_id tinyint(4) COMMENT 'AB测试分组';

ALTER TABLE t_touch_task_detail ADD COLUMN ab_test_group VARCHAR(20) COMMENT 'AB测试分桶';
ALTER TABLE t_touch_task_detail ADD COLUMN ab_test_group_id tinyint(4) COMMENT 'AB测试分组';

CREATE TABLE `t_touch_task_content` (
  `id` bigint(32) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `task_id` bigint(32) NOT NULL COMMENT '触达任务id',
  `ab_test_group_id` tinyint(4) COMMENT 'AB测试分组',
  `flow_ratio` int(4) COMMENT 'AB测试时，流量占比 25 50 75',
  `strategy_id` bigint(32) DEFAULT NULL COMMENT '算法策略id',
  `content_template` text NOT NULL COMMENT 'json字符串List<key:type，value:；1、文本，2、图片-自动抓取主图，3、图片-上传单图，4、文件，5、视频key:content，value:文本模板，包含变量 {}key:url，value:多张图片逗号分隔>',
  PRIMARY KEY (`id`),
  KEY `idx_task_id` (`task_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='触达任务内容';