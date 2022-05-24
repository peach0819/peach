CREATE TABLE `t_salary_config_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `config_id` bigint(20) DEFAULT NULL COMMENT '表格id',
  `config_name` varchar(50) DEFAULT NULL COMMENT '表格名称',
  `data_date` date DEFAULT NULL COMMENT '改变日期',
  `editor_name` varchar(50) DEFAULT NULL COMMENT '最后编辑者姓名',
  `file_name` varchar(200) DEFAULT NULL COMMENT '文件名',
  idx_config_id(config_id),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='工资配置日志';