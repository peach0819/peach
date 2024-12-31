#参数配置表
CREATE TABLE crm_base_config
(
    `id`              bigint(20)               NOT NULL AUTO_INCREMENT COMMENT '自增主键',
    `create_time`     datetime                 NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`     datetime                 NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
    `is_deleted`      tinyint(1)               NOT NULL DEFAULT '0' COMMENT '是否删除',
    `config_name`     varchar(128)  default '' not null comment '配置名称',
    `config_key`      varchar(128)  default '' not null comment '配置键名',
    `config_options`  varchar(1024) default '' not null comment '可选的选项',
    `config_value`    varchar(256)  default '' not null comment '配置值',
    `is_allow_change` tinyint(1)               not null comment '是否允许修改',
    `remark`          varchar(128)             null comment '备注',
    PRIMARY KEY (`id`),
    UNIQUE KEY `udx_config_key` (`config_key`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  ROW_FORMAT = DYNAMIC COMMENT ='参数配置表';

#系统部门表
CREATE TABLE crm_base_dept
(
    `id`          bigint(20)             NOT NULL AUTO_INCREMENT COMMENT '自增主键',
    `create_time` datetime               NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime               NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
    `is_deleted`  tinyint(1)             NOT NULL DEFAULT '0' COMMENT '是否删除',
    `parent_id`   bigint      default 0  not null comment '父部门id',
    `ancestors`   text                   not null comment '祖级列表',
    `dept_name`   varchar(64) default '' not null comment '部门名称',
    `order_num`   int         default 0  not null comment '显示顺序',
    `leader_id`   bigint                 null,
    `leader_name` varchar(64)            null comment '负责人',
    `phone`       varchar(16)            null comment '联系电话',
    `email`       varchar(128)           null comment '邮箱',
    `status`      smallint    default 0  not null comment '部门状态（0停用 1启用）',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  ROW_FORMAT = DYNAMIC COMMENT ='系统部门表';

#系统访问记录
CREATE TABLE crm_base_login_info
(
    `id`               bigint(20)              NOT NULL AUTO_INCREMENT COMMENT '自增主键',
    `create_time`      datetime                NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`      datetime                NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
    `is_deleted`       tinyint(1)              NOT NULL DEFAULT '0' COMMENT '是否删除',
    `username`         varchar(50)  default '' not null comment '用户账号',
    `ip_address`       varchar(128) default '' not null comment '登录IP地址',
    `login_location`   varchar(255) default '' not null comment '登录地点',
    `browser`          varchar(50)  default '' not null comment '浏览器类型',
    `operation_system` varchar(50)  default '' not null comment '操作系统',
    `status`           smallint     default 0  not null comment '登录状态（1成功 0失败）',
    `msg`              varchar(255) default '' not null comment '提示消息',
    `login_time`       datetime                null comment '访问时间',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  ROW_FORMAT = DYNAMIC COMMENT ='系统访问记录';

#菜单表
CREATE TABLE crm_base_menu
(
    `id`          bigint(20)                 NOT NULL AUTO_INCREMENT COMMENT '自增主键',
    `create_time` datetime                   NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime                   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
    `is_deleted`  tinyint(1)                 NOT NULL DEFAULT '0' COMMENT '是否删除',
    `menu_name`   varchar(64)                not null comment '菜单名称',
    `menu_type`   smallint      default 0    not null comment '菜单的类型(1为普通菜单2为目录3为内嵌iFrame4为外链跳转)',
    `router_name` varchar(255)  default ''   not null comment '路由名称（需保持和前端对应的vue文件中的name保持一致defineOptions方法中设置的name）',
    `parent_id`   bigint        default 0    not null comment '父菜单ID',
    `path`        varchar(255)               null comment '组件路径（对应前端项目view文件夹中的路径）',
    `is_button`   tinyint(1)    default 0    not null comment '是否按钮',
    `permission`  varchar(128)               null comment '权限标识',
    `meta_info`   varchar(1024) default '{}' not null comment '路由元信息（前端根据这个信息进行逻辑处理）',
    `status`      smallint      default 0    not null comment '菜单状态（1启用 0停用）',
    `remark`      varchar(256)  default ''   null comment '备注',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  ROW_FORMAT = DYNAMIC COMMENT ='菜单表';

#通知公告表
CREATE TABLE crm_base_notice
(
    `id`             bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '自增主键',
    `create_time`    datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`    datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
    `is_deleted`     tinyint(1)  NOT NULL DEFAULT '0' COMMENT '是否删除',
    `notice_title`   varchar(64) not null comment '公告标题',
    `notice_type`    smallint    not null comment '公告类型（1通知 2公告）',
    `notice_content` text        null comment '公告内容',
    `status`         smallint             default 0 not null comment '公告状态（1正常 0关闭）',
    `remark`         varchar(255)         default '' not null comment '备注',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  ROW_FORMAT = DYNAMIC COMMENT ='通知公告表';

#操作日志记录
CREATE TABLE crm_base_operation_log
(
    `id`                bigint(20)               NOT NULL AUTO_INCREMENT COMMENT '自增主键',
    `create_time`       datetime                 NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`       datetime                 NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
    `is_deleted`        tinyint(1)               NOT NULL DEFAULT '0' COMMENT '是否删除',
    `business_type`     smallint      default 0  not null comment '业务类型（0其它 1新增 2修改 3删除）',
    `request_method`    smallint      default 0  not null comment '请求方式',
    `request_module`    varchar(64)   default '' not null comment '请求模块',
    `request_url`       varchar(256)  default '' not null comment '请求URL',
    `called_method`     varchar(128)  default '' not null comment '调用方法',
    `operator_type`     smallint      default 0  not null comment '操作类别（0其它 1后台用户 2手机端用户）',
    `user_id`           bigint        default 0  null comment '用户ID',
    `username`          varchar(32)   default '' null comment '操作人员',
    `operator_ip`       varchar(128)  default '' null comment '操作人员ip',
    `operator_location` varchar(256)  default '' null comment '操作地点',
    `dept_id`           bigint        default 0  null comment '部门ID',
    `dept_name`         varchar(64)              null comment '部门名称',
    `operation_param`   varchar(2048) default '' null comment '请求参数',
    `operation_result`  varchar(2048) default '' null comment '返回参数',
    `status`            smallint      default 1  not null comment '操作状态（1正常 0异常）',
    `error_stack`       varchar(2048) default '' null comment '错误消息',
    `operation_time`    datetime                 not null comment '操作时间',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  ROW_FORMAT = DYNAMIC COMMENT ='操作日志记录';

#岗位表
CREATE TABLE crm_base_post
(
    `id`          bigint(20)   NOT NULL AUTO_INCREMENT COMMENT '自增主键',
    `create_time` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
    `is_deleted`  tinyint(1)   NOT NULL DEFAULT '0' COMMENT '是否删除',
    `post_code`   varchar(64)  not null comment '岗位编码',
    `post_name`   varchar(64)  not null comment '岗位名称',
    `post_sort`   int          not null comment '显示顺序',
    `status`      smallint     not null comment '状态（1正常 0停用）',
    `remark`      varchar(512) null comment '备注',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  ROW_FORMAT = DYNAMIC COMMENT ='岗位表';

#角色表
CREATE TABLE crm_base_role
(
    `id`          bigint(20)   NOT NULL AUTO_INCREMENT COMMENT '自增主键',
    `create_time` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
    `is_deleted`  tinyint(1)   NOT NULL DEFAULT '0' COMMENT '是否删除',
    `role_name`   varchar(32)  not null comment '角色名称',
    `role_key`    varchar(128) not null comment '角色权限字符串',
    `role_sort`   int          not null comment '显示顺序',
    `data_scope`  smallint              default 1 null comment '数据范围（1：全部数据权限 2：自定数据权限 3: 本部门数据权限 4: 本部门及以下数据权限 5: 本人权限）',
    `dept_id_set` varchar(1024)         default '' null comment '角色所拥有的部门数据权限',
    `status`      smallint     not null comment '角色状态（1正常 0停用）',
    `remark`      varchar(512) null comment '备注',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  ROW_FORMAT = DYNAMIC COMMENT ='角色表';

#角色和菜单关联表
CREATE TABLE crm_base_role_menu
(
    `id`          bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
    `create_time` datetime   NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
    `is_deleted`  tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
    `role_id`     bigint     not null comment '角色ID',
    `menu_id`     bigint     not null comment '菜单ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `udx_role_menu` (`role_id`, `menu_id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  ROW_FORMAT = DYNAMIC COMMENT ='角色和菜单关联表';

