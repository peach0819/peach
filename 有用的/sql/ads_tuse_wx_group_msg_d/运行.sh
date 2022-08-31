v_date=$1

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;

create table if not exists ads_tuse_wx_group_msg_d (
    callback_id         int    comment '回调id',
    callback_data       string comment '回调数据',
    tuse_send_wx_id     string comment '发送者涂色编号',
    send_chat_id        int    comment '发送者chatId',
    send_chat_name      string comment '发送者chat名',
    tuse_to_wx_id       string comment '接受者涂色编号',
    to_chat_id          int    comment '接受者chatId',
    to_chat_name        string comment '接受者chat名',
    tuse_group_id       string comment '涂色群编号',
    chat_group_id       int    comment 'chatgroupId',
    chat_group_name     string comment '群名',
    tuse_msg_id         string comment '涂色消息编号',
    biz_id              string comment '业务主键id, 群编号,消息编号',
    tuse_msg_type       int    comment '消息类型',
    tuse_msg_time       string comment '消息时间',
    tuse_meta_content   string comment '消息内容元数据',
    tuse_content        string comment '消息内容解析数据'
) comment '涂色个微群聊记录表'
partitioned by (dayid string)
stored as orc;

with base as (
    SELECT id,
           get_json_object(content,'$.data') as content
    FROM dwd_crm_tuse_callback_msg_d
    WHERE dayid = '$v_date'
    AND msg_type = 5003
),

chat_group as (
    SELECT id,
           group_id,
           group_name
    FROM dwd_crm_chat_group_d
    WHERE dayid = '$v_date'
),

chat_group_member as (
    SELECT chat_group_id,
           user_id,
           chat_id,
           user_name
    FROM dwd_crm_chat_group_member_d
    WHERE dayid = '$v_date'
    AND member_type = 3
),

parse as (
    SELECT id as callback_id,
           content as callback_data,
           get_json_object(content,'$.vcFromWxUserSerialNo') as tuse_send_wx_id,
           get_json_object(content,'$.vcToWxUserSerialNo') as tuse_to_wx_id,
           get_json_object(content,'$.vcChatRoomSerialNo') as tuse_group_id,
           get_json_object(content,'$.vcMsgId') as tuse_msg_id,
           get_json_object(content,'$.nMsgType') as tuse_msg_type,
           get_json_object(content,'$.dtMsgTime') as tuse_msg_time,
           get_json_object(content,'$.vcContent') as tuse_meta_content
    FROM base
),

cur as (
    SELECT parse.callback_id,
           parse.callback_data,

           parse.tuse_send_wx_id,
           send_chat.chat_id as send_chat_id,
           send_chat.user_name as send_chat_name,

           parse.tuse_to_wx_id,
           to_chat.chat_id as to_chat_id,
           to_chat.user_name as to_chat_name,

           parse.tuse_group_id,
           chat_group.id as chat_group_id,
           chat_group.group_name as chat_group_name,

           parse.tuse_msg_id,
           concat(parse.tuse_group_id, ',', parse.tuse_msg_id) as biz_id,
           parse.tuse_msg_type,
           parse.tuse_msg_time,
           parse.tuse_meta_content,
           if(parse.tuse_msg_type IN (2001,2013,2017,2019,2020,2024,2025,2026), string(unbase64(parse.tuse_meta_content)), parse.tuse_meta_content) as tuse_content,

           row_number() over(partition by concat(parse.tuse_group_id, ',', parse.tuse_msg_id) order by parse.callback_id) as rn
    FROM parse
    LEFT JOIN chat_group ON parse.tuse_group_id = chat_group.group_id
    LEFT JOIN chat_group_member send_chat ON chat_group.id = send_chat.chat_group_id AND parse.tuse_send_wx_id = send_chat.user_id
    LEFT JOIN chat_group_member to_chat ON chat_group.id = to_chat.chat_group_id AND parse.tuse_to_wx_id = to_chat.user_id
    HAVING rn = 1
)

insert overwrite table ads_tuse_wx_group_msg_d partition(dayid='$v_date')
SELECT callback_id,
       callback_data,
       tuse_send_wx_id,
       send_chat_id,
       send_chat_name,
       tuse_to_wx_id,
       to_chat_id,
       to_chat_name,
       tuse_group_id,
       chat_group_id,
       chat_group_name,
       tuse_msg_id,
       biz_id,
       tuse_msg_type,
       tuse_msg_time,
       tuse_meta_content,
       tuse_content
FROM cur

UNION ALL

SELECT old.callback_id,
       old.callback_data,
       old.tuse_send_wx_id,
       old.send_chat_id,
       old.send_chat_name,
       old.tuse_to_wx_id,
       old.to_chat_id,
       old.to_chat_name,
       old.tuse_group_id,
       old.chat_group_id,
       old.chat_group_name,
       old.tuse_msg_id,
       old.biz_id,
       old.tuse_msg_type,
       old.tuse_msg_time,
       old.tuse_meta_content,
       old.tuse_content
FROM (
    SELECT *
    FROM ads_tuse_wx_group_msg_d
    WHERE dayid = '$v_1_days_ago'
) old
LEFT JOIN cur ON old.biz_id = cur.biz_id
WHERE cur.biz_id is null OR cur.biz_id = ''
;
"