
--https://help.aliyun.com/document_detail/411966.html

use yt_crm;

-- create role ROLE_CRM_VISITER;
-- create role ROLE_CRM_DEVELOPER;
-- create role ROLE_CRM_OWNER;

-- grant Describe, Select on table * to ROLE ROLE_CRM_VISITER;
-- grant Describe, Select, Alter, Update on table * to ROLE ROLE_CRM_DEVELOPER;
-- grant ALL on table * to ROLE ROLE_CRM_DEVELOPER;

--list users;

--grant ROLE_CRM_VISITER TO `RAM$yangtuojia001@163.com:role/lei.yang9972`;
--grant ROLE_CRM_VISITER TO `RAM$yangtuojia001@163.com:role/pengfei.qin8818`;
--grant ROLE_CRM_VISITER TO `RAM$yangtuojia001@163.com:role/yuwei.nie7151`;

list roles;