

use ytdw;

create table if not exists ads_crm_visit_record_qw_msg_d_test
(
  record_id string comment '拜访小记ID',
  admin_chat_id bigint comment '小二crm系统聊天主体chat_id',
  shop_chat_id bigint comment '门店crm系统聊天主体chat_id',
  wx_msg_id bigint comment '企微的chat_id',
  direction int comment '发送类型 1： 小二发送给门店，2门店发送给小二',
  msg_time string comment '消息时间',
  msg_type string comment '微信消息类型',
  content string comment '微信消息内容',
  extend string comment '其他',
  room_id string comment '群聊群id',
  is_qw int comment '1:企微渠道'
)
partitioned by (dayid string)
stored as orc;

WITH records AS (
		SELECT record_id,
		   get_json_object(extra_json, '$.adminChatId') AS admin_chat_id,
			get_json_object(extra_json, '$.shopChatId') AS shop_chat_id,
			date_format(get_json_object(extra_json, '$.chatStartTime'), 'yyyyMMddHHmmss') AS chat_start_time,
			date_format(get_json_object(extra_json, '$.chatEndTime'), 'yyyyMMddHHmmss') AS chat_end_time
		FROM ytdw.dwd_visit_record_d
		WHERE dayid = '$v_date'
		AND record_type = 4
		AND visit_type = 4
		AND get_json_object(extra_json, '$.adminChatId') is not null
		AND get_json_object(extra_json, '$.shopChatId') is not null
		AND get_json_object(extra_json, '$.chatStartTime') is not null
		AND get_json_object(extra_json, '$.chatEndTime') is not NULL
		AND date_format(get_json_object(extra_json, '$.chatStartTime'), 'yyyyMMdd') = '$v_date'
    ),
	qw_chats AS (
		SELECT id AS wx_msg_id, admin_chat_id, shop_chat_id, direction, msg_time AS wx_msg_time,
			msg_type, content, extend AS extend, room_id, 1 AS is_qw
		FROM ytdw.dwd_crm_chat_msg_qw_d
		WHERE dayid = '$v_date'
		AND admin_chat_id IS NOT NULL
		AND shop_chat_id IS NOT NULL
		AND is_deleted = 0
		and substr(msg_time, 0, 8) = '$v_date'
	),
	tuse_chats AS (
		SELECT id AS wx_msg_id, from_chat_id, to_chat_id, tuse_msg_time AS wx_msg_time, tuse_msg_type AS msg_type,
			tuse_msg_content AS content, NULL AS extend, NULL AS room_id, 0 AS is_qw, 1 as tuse_tag
		FROM ytdw.dwd_crm_tuse_qw_personal_msg_d
		WHERE dayid = '$v_date'
		AND is_deleted = 0
		AND from_chat_id IS NOT NULL
		AND to_chat_id IS NOT NULL
		and substr(tuse_msg_time, 0, 8) = '$v_date'
	),
	channels AS (
		SELECT records.record_id, records.admin_chat_id, records.shop_chat_id, records.chat_start_time, records.chat_end_time,
			CASE WHEN qw_channel IS NOT NULL AND qw_channel = 1
			 	 THEN 1
				 ELSE 2
			END AS chat_source
		FROM records
		LEFT JOIN (
				SELECT record_id, record.admin_chat_id, record.shop_chat_id, record.chat_start_time, record.chat_end_time,
					CASE
					 WHEN count(*) > 0 THEN 1
					 ELSE 0
					END AS qw_channel
				FROM qw_chats chat
				INNER JOIN records record ON record.admin_chat_id = chat.admin_chat_id AND record.shop_chat_id = chat.shop_chat_id
				WHERE chat.direction = 2
				AND chat.wx_msg_time >= record.chat_start_time
				AND chat.wx_msg_time <= record.chat_end_time
				GROUP BY record_id, record.admin_chat_id, record.shop_chat_id, record.chat_start_time, record.chat_end_time
			) is_qw_channel ON records.record_id = is_qw_channel.record_id
	)


INSERT OVERWRITE TABLE ads_crm_visit_record_qw_msg_d_test PARTITION (dayid='$v_date')
  SELECT record_id, record.admin_chat_id, record.shop_chat_id, wx_msg_id, direction,
	ytdw.yt_date_format(wx_msg_time, 'yyyy-MM-dd HH:mm:ss') AS msg_time, msg_type,
	content, extend, room_id, is_qw
FROM (
	SELECT *
	FROM channels
	WHERE chat_source = 1
) record
INNER JOIN qw_chats ON record.admin_chat_id = qw_chats.admin_chat_id AND record.shop_chat_id = qw_chats.shop_chat_id
WHERE qw_chats.wx_msg_time >= chat_start_time
AND qw_chats.wx_msg_time <= chat_end_time


UNION ALL

SELECT record_id, record.admin_chat_id, record.shop_chat_id, wx_msg_id,
	CASE
	 WHEN admin_chat_id = from_chat_id THEN 1
	 ELSE 2
	END AS direction, ytdw.yt_date_format(wx_msg_time, 'yyyy-MM-dd HH:mm:ss') AS msg_time, msg_type,
	content, extend, room_id, is_qw
FROM (
	SELECT *, 1 as tuse_tag
	FROM channels
	WHERE chat_source = 2
) record
left  JOIN tuse_chats ON ((admin_chat_id = from_chat_id AND shop_chat_id = to_chat_id) )
-- OR (admin_chat_id = to_chat_id AND shop_chat_id = from_chat_id))
WHERE  tuse_chats.wx_msg_time >= chat_start_time
AND tuse_chats.wx_msg_time <= chat_end_time
and tuse_chats.tuse_tag is not null
and from_chat_id is not null
and to_chat_id is not null

union all


SELECT record_id, record.admin_chat_id, record.shop_chat_id, wx_msg_id,
	CASE
	 WHEN admin_chat_id = from_chat_id THEN 1
	 ELSE 2
	END AS direction, ytdw.yt_date_format(wx_msg_time, 'yyyy-MM-dd HH:mm:ss') AS msg_time, msg_type,
	content, extend, room_id, is_qw
FROM (
	SELECT *, 1 as tuse_tag
	FROM channels
	WHERE chat_source = 2
) record
left  JOIN tuse_chats ON

-- ((admin_chat_id = from_chat_id AND shop_chat_id = to_chat_id) )
 ((admin_chat_id = to_chat_id AND shop_chat_id = from_chat_id))
WHERE  tuse_chats.wx_msg_time >= chat_start_time
AND tuse_chats.wx_msg_time <= chat_end_time
and tuse_chats.tuse_tag is not null
and from_chat_id is not null
and to_chat_id is not null