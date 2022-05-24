use ytdw;

create table if not exists dw_salary_base_salary_public_d
(
    planno                 int comment '方案编号',
    plan_month             string comment '方案月份',
    update_time            string comment '更新时间',
    update_month           string comment '执行月份',
    grant_object_type      string comment '发放对象类型',
    grant_object_user_id   string comment '发放对象id',
    grant_object_user_name string comment '发放对象',
    grant_object_dept_id   string comment '发放对象部门id',
    grant_object_dept_name string comment '发放对象部门',
    leave_time             string comment '离职时间',
    sts_target_name        string comment '统计指标名称',
    sts_target             decimal(18, 2) comment '统计指标数值',
    extra                  string comment '统计指标冗余字段'
) comment '基本提成指标明细表'
partitioned by (dayid string, pltype string)
stored as orc;