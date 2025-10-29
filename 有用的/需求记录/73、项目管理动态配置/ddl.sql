CREATE TABLE `t_p0_subject_group` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `group_name` varchar(255) NOT NULL COMMENT '项目团队名称',
  `group_tag` varchar(255) NOT NULL COMMENT '项目团队标签',
  `feature_type` tinyint(1) NOT NULL COMMENT '项目职能类型 1:BD；2:电销',
  `feature_ids` varchar(255) COMMENT '项目团队关联职能id，逗号分割',
  `root_dept_id` bigint(20) COMMENT '项目团队部门根节点id',
  `job_ids` varchar(500) COMMENT '销售岗位json',
  `manager_job_ids` varchar(500) COMMENT '销售主管岗位json',
  `area_dept_ids` varchar(500) COMMENT '大区部门json',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='P0项目团队表';

--测试环境
INSERT INTO `t_p0_subject_group` (`id`, `group_name`, `group_tag`, `feature_type`, `feature_ids`, `root_dept_id`, `job_ids`, `manager_job_ids`, `area_dept_ids`)
VALUES (1, '电销团队', 'ts', 2, '2,6,7,13,15', 238, '[]', '[]', '[]'),
       (2, 'VS团队', 'vs', 2, '40,41', 180225, '[]', '[]', '[]'),
       (3, 'BD团队', 'bd', 1, '1,5,12,14', 239, '[]', '[]', '[]'),
       (4, 'CBD团队', 'cbd', 1, '21', 114, '[]', '[]', '[]'),
       (5, '综合电销团队', 'zhpdx', 2, '68', 148329, '[]', '[]', '[]'),
       (6, '品直奶粉电销团队', 'pznfdx', 2, '70', 238, '[]', '[]', '[]');

INSERT INTO `t_p0_subject_group` (`id`, `creator`, `editor`, `group_name`, `group_tag`, `feature_type`, `feature_ids`, `root_dept_id`, `job_ids`, `manager_job_ids`, `area_dept_ids`)
VALUES (7, '12903870260', '12903870260', '品牌奶粉BD团队', 'ppnfbd', 1, '73', 239, '[]', '[]', '[]');

UPDATE t_p0_subject_group set `job_ids` = '[1908,1865,1864]', manager_job_ids = '[1861,1858]', area_dept_ids = '[]' WHERE id = 1;
UPDATE t_p0_subject_group set `job_ids` = '[]', manager_job_ids = '[]', area_dept_ids = '[]' WHERE id = 2;
UPDATE t_p0_subject_group set `job_ids` = '[]', manager_job_ids = '[1859]', area_dept_ids = '[]' WHERE id = 3;
UPDATE t_p0_subject_group set `job_ids` = '[]', manager_job_ids = '[]', area_dept_ids = '[]' WHERE id = 4;
UPDATE t_p0_subject_group set `job_ids` = '[]', manager_job_ids = '[]', area_dept_ids = '[]' WHERE id = 5;
UPDATE t_p0_subject_group set `job_ids` = '[]', manager_job_ids = '[1861,1858]', area_dept_ids = '[]' WHERE id = 6;

--线上
INSERT INTO `t_p0_subject_group` (`id`, `group_name`, `group_tag`, `feature_type`, `feature_ids`, `root_dept_id`, `job_ids`, `manager_job_ids`, `area_dept_ids`)
VALUES (1, '电销团队', 'ts', 2, '2,6,7,13,15', 63, '[12,30,109]', '[14,15,31,162]', '[1437,1451,1931,2234]'),
       (2, 'VS团队', 'vs', 2, '40,41', 2211, '[234,235]', '[233,236,237]', '[1945,2211]'),
       (3, 'BD团队', 'bd', 1, '1,5,12,14', 32, '[6,8,180,189]', '[9,191]', '[635,1659,1847,2161,2162,2163,2164,2195,2196,2227,2229]'),
       (4, 'CBD团队', 'cbd', 1, '21', 1804, '[]', '[]', '[]'),
       (5, '综合电销团队', 'zhpdx', 2, '68', 1945, '[259]', '[237,260]', '[1945]'),
       (6, '品直奶粉电销团队', 'pznfdx', 2, '70', 63, '[264]', '[14,15,31,162]', '[1437,1451,1931,2234]');

INSERT INTO `t_p0_subject_group` (`id`, `creator`, `editor`, `group_name`, `group_tag`, `feature_type`, `feature_ids`, `root_dept_id`, `job_ids`, `manager_job_ids`, `area_dept_ids`)
VALUES (7, '12903870260', '12903870260', '品牌奶粉BD团队', 'ppnfbd', 1, '73', 32, '[266]', '[9]', '[2161]');

BD: 6,8,180,189
CBD:
电销:12,30,109
VS电销：234,235
综合品电销：259
品直奶粉电销:264

电销主管  14,15,31,162
VS电销主管 233,236,237
BD主管 9,191
综合品电销主管 237,260

BD大区：635,1659,1847,2161,2162,2163,2164,2195,2196,2227,2229
电销：1437,1451,1931,2234
VS电销：1945,2211
综合品电销：1945