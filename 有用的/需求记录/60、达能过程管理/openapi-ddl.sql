--yt_hop库 测试环境
insert into t_open_api (`creator`, `editor`, `hop_api_id`, `category_id`, `name`, `return_example`)
values ('system', 'system', 53811976, 7, '达能创建全量同步数据版本接口', '{"code":200,"message":"成功","data":10000,"success":true}'),
       ('system', 'system', 53811815, 7, '达能同步SPC打卡数据接口', '{"code":200,"message":"成功","data":true,"success":true}'),
       ('system', 'system', 53811977, 7, '达能同步SPC陈列拍摄数据接口', '{"code":200,"message":"成功","data":true,"success":true}'),
       ('system', 'system', 53811978, 7, '达能同步POS库存数据接口', '{"code":200,"message":"成功","data":true,"success":true}'),
       ('system', 'system', 53811979, 7, '达能同步POS订单数据接口', '{"code":200,"message":"成功","data":true,"success":true}');


--yt_hop库 正式环境
insert into t_open_api (`creator`, `editor`, `hop_api_id`, `category_id`, `name`, `return_example`)
values ('system', 'system', 23355, 7, '达能创建全量同步数据版本接口', '{"code":200,"message":"成功","data":10000,"success":true}'),
       ('system', 'system', 23356, 7, '达能同步SPC打卡数据接口', '{"code":200,"message":"成功","data":true,"success":true}'),
       ('system', 'system', 23354, 7, '达能同步SPC陈列拍摄数据接口', '{"code":200,"message":"成功","data":true,"success":true}'),
       ('system', 'system', 23357, 7, '达能同步POS库存数据接口', '{"code":200,"message":"成功","data":true,"success":true}'),
       ('system', 'system', 23358, 7, '达能同步POS订单数据接口', '{"code":200,"message":"成功","data":true,"success":true}');