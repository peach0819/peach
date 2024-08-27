--yt_ustone
ALTER TABLE t_shop_danone ADD COLUMN danone_sign_brand varchar(200) COMMENT '达能合作品牌';

--yt_hop库 测试环境
insert into t_open_api (`creator`, `editor`, `hop_api_id`, `category_id`, `name`, `return_example`)
values('system', 'system', 52659956, 7, '达能门店品牌审核结果回传接口', '{"code":200,"message":"成功","data":{"syncSuccess":true,"message":""},"success":true}');

--yt_hop库 正式环境
insert into t_open_api (`creator`, `editor`, `hop_api_id`, `category_id`, `name`, `return_example`)
values('system', 'system', 23058, 7, '达能门店品牌审核结果回传接口', '{"code":200,"message":"成功","data":{"syncSuccess":true,"message":""},"success":true}');

--yt_ustone库  正式环境 线上验证门店
INSERT INTO t_shop_danone (`shop_id`, `shop_num`, `shop_license_code`, `danone_shop_code`, `danone_shop_name`, `danone_shop_linker_name`, `danone_shop_linker_phone`, `danone_shop_account`, `danone_shop_password`, `has_spc`, `spc_cnt`, `danone_sign_brand`, `creator`, `editor`)
VALUES ('e001c87e92e145f19abfadf52357a8a5', 'M64049061', '91610102MA6U3U3M20', '100049923', '嘉里城母婴用品店', '王母婴1', '13461357900', '18721689464', '123456', '1', '0', '', 'system', 'system');
