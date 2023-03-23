
--https://help.aliyun.com/document_detail/411966.html

use yt_crm;

-- create role ROLE_CRM_VISITER;
-- create role ROLE_CRM_DEVELOPER;
-- create role ROLE_CRM_OWNER;
-- describe role ROLE_CRM_OWNER;

-- grant Describe, Select on table * to ROLE ROLE_CRM_VISITER;
-- grant Describe, Select, Alter, Update on table * to ROLE ROLE_CRM_DEVELOPER;
-- grant Describe, Select, Alter, Update, Drop, ShowHistory,ALL on table * to ROLE ROLE_CRM_OWNER;

--list users;

--grant ROLE_CRM_VISITER TO `RAM$yangtuojia001@163.com:role/lei.yang9972`;
--grant ROLE_CRM_VISITER TO `RAM$yangtuojia001@163.com:role/pengfei.qin8818`;
-- grant ROLE_CRM_OWNER TO `RAM$yangtuojia001@163.com:role/ke.yang`;
-- grant ROLE_CRM_OWNER TO `RAM$yangtuojia001@163.com:role/tao.zheng8833`;

-- list roles;

-- show grants for `RAM$yangtuojia001@163.com:role/tao.zheng8833`;