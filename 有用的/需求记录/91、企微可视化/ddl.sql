CREATE TABLE t_crm_chat_dept (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',

  `dept_id` bigint(20) NOT NULL COMMENT '企微部门id',
  `dept_name` varchar(255) COMMENT '企微部门名称',
  `parent_dept_id` bigint(20) COMMENT '父部门id',
  `sort` bigint(20) COMMENT '排序（企微内部的值）',
  `extra` text COMMENT '扩展信息json',
  PRIMARY KEY (`id`),
  KEY `idx_dept_id` (`dept_id`),
  KEY `idx_parent_dept_id` (`parent_dept_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='企微部门信息';

ALTER TABLE t_crm_chat ADD COLUMN `dept_id` bigint(20) COMMENT '企微部门id';
ALTER TABLE t_crm_chat ADD KEY `idx_dept_id` (`dept_id`);