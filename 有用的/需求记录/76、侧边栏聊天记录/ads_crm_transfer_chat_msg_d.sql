with transfer as (
    SELECT distinct get_json_object(content_json, '$.externalUserId') as external_user_id,
		            get_json_object(content_json, '$.leaveQwUserId') as leave_qw_user_id
    FROM ytdw.dwd_crm_import_content_d
    WHERE dayid = '${v_date}'
	AND import_type IN (4,5)
	AND result = '接替完毕'
	AND status = 2
	AND substr(request_time, 1, 8) > '${v_180_days_ago}'
),

msg as (
	SELECT id as msg_id,
	       admin_chat_id as qw_chat_id,
		   shop_chat_id,
		   direction,
		   msg_time,
		   msg_type,
		   content
	FROM yt_crm.ads_crm_chat_msg_qw
	WHERE substr(msg_time, 1, 8) > '${v_180_days_ago}'
	AND qw_action = 'send'
	AND msg_type IN ('text', 'image', 'voice')
),

chat as (
	SELECT id,
	       qw_user_id,
		   qw_external_user_id
	FROM ytdw.dwd_crm_chat_d
	WHERE dayid = '${v_date}'
)

INSERT OVERWRITE TABLE ads_crm_transfer_chat_msg_d PARTITION (dayid = '${v_date}')
SELECT msg.msg_id,
       msg.qw_chat_id,
       msg.shop_chat_id,
       msg.direction,
       FROM_UNIXTIME(UNIX_TIMESTAMP(msg.msg_time, 'yyyyMMddHHmmss')) as msg_time,
       msg.msg_type,
       msg.content
FROM msg
INNER JOIN chat qw_chat ON msg.qw_chat_id = qw_chat.id
INNER JOIN chat shop_chat ON msg.shop_chat_id = shop_chat.id
INNER JOIN transfer ON qw_chat.qw_user_id = transfer.leave_qw_user_id AND shop_chat.qw_external_user_id = transfer.external_user_id