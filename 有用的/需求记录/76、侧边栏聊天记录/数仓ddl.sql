CREATE TABLE IF NOT EXISTS ads_crm_transfer_chat_msg_d (
    msg_id bigint COMMENT '消息id',
    qw_chat_id bigint COMMENT '企微实体id',
    shop_chat_id bigint COMMENT '门店个微实体id',
    direction int COMMENT '1:qw_chat_id操作 2:shop_chat_id操作',
    msg_time DATETIME COMMENT '消息时间',
    msg_type STRING COMMENT '消息类型',
    content STRING COMMENT '消息内容'
)
PARTITIONED BY (dayid STRING);