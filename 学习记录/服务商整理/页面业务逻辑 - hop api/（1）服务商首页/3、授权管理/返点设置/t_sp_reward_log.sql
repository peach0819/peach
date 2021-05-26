
CREATE TABLE `t_sp_reward_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `opt_group` varchar(50) DEFAULT NULL COMMENT '操作组，UUID',
  `brand_id` bigint(20) DEFAULT NULL COMMENT '品牌ID',
  `brand_name` varchar(40) DEFAULT NULL COMMENT '品牌名称',
  `opt_type` tinyint(1) DEFAULT NULL COMMENT '操作类型1：新增，2：修改',
  `opt_category` varchar(100) DEFAULT NULL COMMENT '操作类别',
  `opt_content` varchar(120) DEFAULT NULL COMMENT '操作内容',
  `operator` varchar(40) DEFAULT NULL COMMENT '操作人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `creator` varchar(40) DEFAULT NULL COMMENT '创建人',
  `editor` varchar(40) DEFAULT NULL COMMENT '修改人',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除，0：不删除，1：删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=380 DEFAULT CHARSET=utf8mb4 COMMENT='门店返点操作记录表';



