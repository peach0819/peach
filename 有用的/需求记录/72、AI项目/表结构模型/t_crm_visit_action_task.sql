-- =====================================================================
-- 表结构导入：销售进店任务表 (t_crm_visit_action_task)
-- =====================================================================

-- 【DDL】
CREATE TABLE IF NOT EXISTS `t_crm_visit_action_task` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `task_name` varchar(100) DEFAULT NULL COMMENT '任务名',
  `task_desc` varchar(2000) DEFAULT NULL COMMENT '任务描述',
  `task_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '任务状态 0生效中 1已废弃',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='进店动作任务';

-- 【字段元数据】
-- @task_status
-- Enum: com.yt.crm.biz.visitaction.enums.VisitActionTaskStatusEnum
-- EnumValue：0生效中 1已失效