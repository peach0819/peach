--yt_ustone
ALTER TABLE t_shop_danone ADD COLUMN danone_sign_brand varchar(200) COMMENT '达能合作品牌';

--yt_hop库 测试环境
insert into t_open_api (`creator`, `editor`, `hop_api_id`, `category_id`, `name`, `return_example`)
values('system', 'system', 52659956, 7, '达能门店品牌审核结果回传接口', '{"code":200,"message":"成功","data":{"syncSuccess":true,"message":""},"success":true}');

--yt_hop库 正式环境
insert into t_open_api (`creator`, `editor`, `hop_api_id`, `category_id`, `name`, `return_example`)
values('system', 'system', 23058, 7, '达能门店品牌审核结果回传接口', '{"code":200,"message":"成功","data":{"syncSuccess":true,"message":""},"success":true}');