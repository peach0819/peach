-- =====================================================================
-- 表结构导入：销售进店任务内容表 (t_crm_visit_action_task_content)
-- =====================================================================

-- 【DDL】
CREATE TABLE IF NOT EXISTS `t_crm_visit_action_task_content` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `content_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '内容状态 0生效中 1已废弃',
  `task_id` bigint(20) NOT NULL COMMENT '任务id',
  `task_type` tinyint(4) DEFAULT NULL COMMENT '进店任务类型 0卖进前 1卖进后',
  `team_type` tinyint(4) DEFAULT NULL COMMENT '执行团队 0BD',
  `job_id` varchar(500) DEFAULT NULL COMMENT '执行岗位id多选',
  `content_type` tinyint(4) NOT NULL COMMENT '设定模式 0人工设定 1系统策略',
  `dmp_id` varchar(500) DEFAULT NULL COMMENT '圈选id多选, 人工设定时使用',
  `strategy_id` bigint(20) DEFAULT NULL COMMENT '策略id, 系统策略时使用',
  `brand_id` bigint(20) DEFAULT NULL COMMENT '品牌id',
  `brand_series_id` bigint(20) DEFAULT NULL COMMENT '品牌系列id',
  `action_config` text COMMENT '动作配置',
  PRIMARY KEY (`id`),
  KEY `idx_task_id` (`task_id`),
  KEY `idx_brand_id_brand_series_id` (`brand_id`,`brand_series_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='进店动作任务内容';

-- 【字段元数据】
-- @content_status
-- Enum: com.yt.crm.biz.visitaction.enums.VisitActionTaskContentStatusEnum
-- EnumValue：0生效中 1已失效

-- @task_id
-- ForeignKey: t_crm_visit_action_task.id
-- Desc: 同一个task_id下，存在多个记录，仅最新一条记录的content_status=0，其他的content_status=1

-- @task_type
-- Enum: com.yt.crm.biz.visitaction.enums.VisitActionTaskTypeEnum
-- EnumValue：0卖进前 1卖进后

-- @team_type
-- Enum: com.yt.crm.biz.visitaction.enums.VisitActionTaskTeamTypeEnum
-- EnumValue：0BD团队

-- @job_id
-- Json: List<Long>
-- Desc: 岗位id多选, 岗位id = t_job.id

-- @content_type
-- Enum: com.yt.crm.biz.visitaction.enums.VisitActionTaskContentTypeEnum
-- EnumValue：0人工设定 1系统策略

-- @dmp_id
-- ForeignKey: t_shop_cluster.id
-- Desc: 圈选id, 仅content_type=1有数据

-- @brand_id
-- ForeignKey: t_brand.id
-- Desc: 品牌id, 仅content_type=0有数据

-- @brand_series_id
-- ForeignKey: t_brand_series.id
-- Desc: 品牌系列id, 仅content_type=0有数据

-- @strategy_id
-- Desc: 策略id, 仅content_type=1有数据
-- Enum: com.yt.crm.biz.visitaction.enums.VisitActionTaskStrategyEnum
-- EnumValue：1必拍+库存策略（仅限卖进后）

-- @action_config
-- Desc: 动作配置
-- Json: List<com.yt.crm.biz.visitaction.dto.VisitActionTaskActionDTO>
-- -- public class VisitActionTaskActionDTO {
-- --
-- --     /**
-- --      * 动作id
-- --      */
-- --     private Integer id;
-- --
-- --     /**
-- --      * 知识库id列表
-- --      */
-- --     private List<Long> faqDocIds;
-- -- }