
CREATE TABLE IF NOT EXISTS `t_salary_pro_mark_line` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `data_month` varchar(10) NOT NULL COMMENT '月份',
  `shop_pro_id` bigint(20) NOT NULL COMMENT '省份id',
  `shop_pro_name` varchar(200) NOT NULL COMMENT '省份名称',
  `reach_shop_mark_line` bigint(20) NOT NULL COMMENT '达标门店达标线',
  `new_sign_shop_mark_line` bigint(20) NOT NULL COMMENT '新开门店达标线',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='省份达标线表';