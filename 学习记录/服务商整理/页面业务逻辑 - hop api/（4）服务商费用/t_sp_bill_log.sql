
CREATE TABLE `t_sp_bill_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `oper_type` tinyint(1) DEFAULT NULL COMMENT '操作类型',
  `operator` varchar(45) DEFAULT NULL COMMENT '操作人',
  `content` varchar(200) DEFAULT NULL COMMENT '操作内容',
  `oper_time` datetime DEFAULT NULL COMMENT '操作时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `creator` varchar(45) DEFAULT NULL COMMENT '创建人',
  `editor` varchar(45) DEFAULT NULL COMMENT '修改人',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除，1：删除，0：未删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=348 DEFAULT CHARSET=utf8mb4 COMMENT='对帐单操作记录表';

