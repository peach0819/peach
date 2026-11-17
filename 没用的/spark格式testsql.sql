--odps sql
--********************************************************************--
--author:xi.tao9646(Role)
--create time:2023-07-05 14:08:24
--********************************************************************--
SET hive.exec.dynamic. PARTITION = TRUE;
SET hive.exec.dynamic. PARTITION .mode = nonstrict;
 -- 微信官方消息
WITH dim_wx_chat as (
    SELECT *
    FROM dim_ytj_sel_chat_d
    WHERE dayid = yt_date_format(date_sub(CURRENT_DATE, 1), 'yyyyMMdd')
) -- 跟新时间在近7天内的创建时间
,

update_date as ( --    select distinct date_id
    --    from
    --      (select substr(msg_time,1,8) as date_id
    --      from dwd_crm_chat_msg_qw_d
    --      where dayid=yt_date_format(date_sub(current_date,1),'yyyyMMdd')
    --      and is_deleted=0
    --      and substr(edit_time,1,8)<='${v_date}'
    --      and substr(edit_time,1,8)>=yt_date_sub('${v_date}',31)
    --      group by substr(msg_time,1,8)
    --      union all
    --      select substr(tuse_msg_time,1,8) as date_id
    --      from dwd_crm_tuse_qw_personal_msg_d
    --      where dayid=yt_date_format(date_sub(current_date,1),'yyyyMMdd')
    --      and is_deleted = 0
    --      and substr(edit_time,1,8)<='${v_date}'
    --      and substr(edit_time,1,8)>=yt_date_sub('${v_date}',31)
    --      group by substr(tuse_msg_time,1,8)
    --      ) a
    SELECT date_id
    FROM ytdw.dim_pub_date_d
    WHERE dayid = "${v_date}"
    AND date_id >= '${v_15_days_ago}'
    AND date_id <= '${v_date}'
    GROUP BY date_id
),

qw_msg as (
    SELECT  /*+ MAPJOIN(update_date) */ concat('wx#', id) as wx_msg_id, -- 2016 音乐   2017 视屏号消息  10000 系统消息尚未翻译
           CASE WHEN msg_type = 'text' THEN 2001
                WHEN msg_type = 'image' THEN 2002
                WHEN msg_type = 'weapp' THEN 2013
                WHEN msg_type = 'voice' THEN 2003
                WHEN msg_type = 'video' THEN 2004
                WHEN msg_type = 'emtion' THEN msg_type
                WHEN msg_type = 'revoke' THEN msg_type
                WHEN msg_type = 'card' THEN 2006
                WHEN msg_type = 'link' THEN 2005
                WHEN msg_type = 'meeting_voice_call' THEN msg_type
                WHEN msg_type = 'file' THEN 2010
                WHEN msg_type = 'external_redpacket' THEN msg_type
                WHEN msg_type = 'chatrecord' THEN msg_type
                WHEN msg_type = 'mixed' THEN msg_type
                WHEN msg_type = 'location' THEN 2021
                WHEN msg_type = 'disagree' THEN msg_type
                WHEN msg_type = 'sphfeed' THEN msg_type
                WHEN msg_type = 'docmsg' THEN msg_type
                WHEN msg_type = 'agree' THEN msg_type
                WHEN msg_type = 'redpacket' THEN msg_type
                ELSE msg_type END as wx_msg_type,
           CASE WHEN direction = 1 THEN 1
                WHEN direction = 2 THEN 2 END as wx_msg_send_type,
           admin_chat_id as qw_chat_id,
           shop_chat_id as gw_chat_id,
           msg_time as wx_msg_time,
           room_id as wx_room_id,
           CASE WHEN msg_type = 'weapp' THEN get_json_object(meta_data, '$.weapp.title') ELSE replace(replace(content, '[', ''), ']', '') END as wx_msg_content,
           meta_data as wx_meta_data,
           create_time as wx_msg_create_time,
           edit_time as wx_msg_edit_time,
           'wx' as wx_msg_data_source,
           id as qw_msg_id,
           - rand()* 1000 - 30000 as rand_id
    FROM (
        SELECT *
        FROM dwd_crm_chat_msg_qw_d
        WHERE dayid = yt_date_format(date_sub(CURRENT_DATE, 1), 'yyyyMMdd')
        AND substr(edit_time, 1, 8) <= '${v_date}'
        AND substr(edit_time, 1, 8) >= '${v_15_days_ago}'
        AND is_deleted = 0
    ) a
    JOIN update_date b ON substr(a.msg_time, 1, 8) = b.date_id
) -- 涂色消息
,

tuse_msg as (
    SELECT *,
           first_value(if(wx_msg_send_type = 2 AND wx_msg_content = '消息已发出，但被对方拒收了', wx_msg_id, NULL), TRUE) OVER (PARTITION BY nvl(qw_chat_id, rand_id), nvl(gw_chat_id, rand_id) ORDER BY unix_timestamp(wx_msg_time, 'yyyyMMddHHmmss') RANGE BETWEEN CURRENT ROW
    AND 2 FOLLOWING) as black_reply_msg_id_n1t
    FROM (
        SELECT  /*+ MAPJOIN(update_date) */ concat('tuse#', id) as wx_msg_id, -- 2016 音乐   2017 视屏号消息  10000 系统消息尚未翻译
               tuse_msg_type as wx_msg_type,
               CASE WHEN b.admin_user_id IS NOT NULL THEN 1
                    WHEN c.shop_id_strs IS NOT NULL THEN 1
                    WHEN b.shop_id_strs IS NOT NULL THEN 2 END as wx_msg_send_type,
               CASE WHEN b.admin_user_id IS NOT NULL THEN b.chat_id
                    WHEN c.admin_user_id IS NOT NULL THEN c.chat_id END as qw_chat_id,
               CASE WHEN b.shop_id_strs IS NOT NULL THEN b.chat_id
                    WHEN c.shop_id_strs IS NOT NULL THEN c.chat_id END as gw_chat_id,
               tuse_msg_time as wx_msg_time,
               NULL  as wx_room_id,
               tuse_msg_content as wx_msg_content,
               tuse_msg_content,
               tuse_meta_msg_content as wx_meta_data,
               create_time as wx_msg_create_time,
               edit_time as wx_msg_edit_time,
               'tuse' as wx_msg_data_source,
               id as tuse_msg_id,
               a.rand_id,
               CASE WHEN tuse_msg_type = 2013 THEN get_json_object(tuse_msg_content, '$.title') ELSE replace(replace(tuse_msg_content, '[', ''), ']', '') END as adjust_content
        FROM (
            SELECT *,
                   - rand()* 1000 - 40000 as rand_id
            FROM dwd_crm_tuse_qw_personal_msg_d
            WHERE dayid = yt_date_format(date_sub(CURRENT_DATE, 1), 'yyyyMMdd')
            AND is_deleted = 0
            AND substr(edit_time, 1, 8) <= '${v_date}'
            AND substr(edit_time, 1, 8) >= '${v_15_days_ago}'
        ) a
        JOIN update_date d ON substr(a.tuse_msg_time, 1, 8) = d.date_id
        LEFT JOIN dim_wx_chat b ON nvl(a.from_chat_id, a.rand_id) = b.chat_id
        LEFT JOIN dim_wx_chat c ON nvl(a.to_chat_id, a.rand_id) = c.chat_id
    ) t1
) ---企微消息和涂色消息进行匹配，能匹配上的进行匹配
,

qw_msg_extend1 as (
    SELECT a.*,
           b.tuse_msg_id as tuse_msg_id,
           b.tuse_msg_content,
           b.black_reply_msg_id_n1t
    FROM (
        SELECT *,
               row_number() OVER (PARTITION BY nvl(qw_chat_id, rand_id), nvl(gw_chat_id, rand_id), nvl(wx_msg_content, rand_id), nvl(wx_msg_type, rand_id) ORDER BY wx_msg_time, wx_msg_id) as msg_rank
        FROM qw_msg
    ) a
    LEFT JOIN (
        SELECT *,
               row_number() OVER (PARTITION BY nvl(qw_chat_id, rand_id), nvl(gw_chat_id, rand_id), nvl(adjust_content, rand_id), nvl(wx_msg_type, rand_id) ORDER BY wx_msg_time, wx_msg_id) as msg_rank
        FROM tuse_msg
    ) b ON nvl(a.qw_chat_id, a.rand_id) = nvl(b.qw_chat_id, b.rand_id) AND nvl(a.gw_chat_id, a.rand_id) = nvl(b.gw_chat_id, b.rand_id) AND nvl(a.wx_msg_content, a.rand_id) = nvl(b.adjust_content, b.rand_id) AND nvl(a.wx_msg_type, a.rand_id) = nvl(b.wx_msg_type, b.rand_id) AND abs(yt_date_diff(a.wx_msg_time, b.wx_msg_time, 'seconds')) <= 15 AND a.msg_rank = b.msg_rank
) -- 当天企微官方每小时已经存在的数据
,

qw_msg_hour as (
    SELECT qw_chat_id,
           gw_chat_id,
           substr(wx_msg_time, 1, 10) as msg_hour,
           yt_date_sub(min(wx_msg_time), 5, 'minutes') as min_msg_time,
           yt_date_add(max(wx_msg_time), 5, 'minutes') as max_msg_time
    FROM qw_msg
    GROUP BY qw_chat_id,
             gw_chat_id,
             substr(wx_msg_time, 1, 10)
) -- 企微中未授权，但是涂色消息存在的这部分消息
,

gw_msg_other as (
    SELECT a.*
    FROM tuse_msg a
    LEFT JOIN qw_msg_hour b ON a.qw_chat_id = b.qw_chat_id AND a.gw_chat_id = b.gw_chat_id AND a.wx_msg_time >= b.min_msg_time AND a.wx_msg_time <= b.max_msg_time
    WHERE b.qw_chat_id IS NULL
) -- 企微和个微的消息合并
,

wx_msg_tmp1 as (
    SELECT wx_msg_id,
           wx_msg_type,
           wx_msg_send_type,
           qw_chat_id,
           gw_chat_id,
           wx_msg_time,
           wx_room_id,
           wx_msg_content,
           wx_meta_data,
           wx_msg_create_time,
           wx_msg_edit_time,
           wx_msg_data_source,
           qw_msg_id,
           tuse_msg_id,
           rand_id,
           tuse_msg_content,
           black_reply_msg_id_n1t
    FROM qw_msg_extend1

    UNION ALL

    SELECT wx_msg_id,
           wx_msg_type,
           wx_msg_send_type,
           qw_chat_id,
           gw_chat_id,
           wx_msg_time,
           wx_room_id,
           wx_msg_content,
           wx_meta_data,
           wx_msg_create_time,
           wx_msg_edit_time,
           wx_msg_data_source,
           NULL  as qw_msg_id,
           tuse_msg_id,
           rand_id,
           tuse_msg_content,
           black_reply_msg_id_n1t
    FROM gw_msg_other
),

content as (
    SELECT task_id,
           content
    FROM ytdw.dwd_touch_task_content_d LATERAL VIEW explode(split(regexp_replace(substr(content_template, 2, length(content_template) - 2), '\}\,', '\}\;\;\;'), '\;\;\;')) tmp as content
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
),

parse as (
    SELECT task_id,
           content1
    FROM content LATERAL VIEW explode(split(get_json_object(content, '$.content'), '\{')) tmp as content1
    WHERE get_json_object(content, '$.type') = 1
),

task_item_tmp as (
    SELECT task_id,
           concat_ws(',', collect_set(split(split(content1, '}')[0], ';')[4])) as item_ids
    FROM parse
    WHERE content1 LIKE '%}%'
    AND split(split(content1, '}')[0], ';')[0] = 'price'
    GROUP BY task_id
),

dw_ytj_sel_touch_task_detail_tmp as (
    SELECT a.*,
           - rand()* 1000 - 20000 as rand_id,
           split(parse_url(concat('file://', regexp_replace(get_json_object(file_name, '$.miniProgramPath'), '^/', '')), 'QUERY', 'link'), '%2F') as ytms_link_array,
           if(get_json_object(file_name, '$.miniProgramPath') LIKE '%packageDetail/pages/detail/index%', parse_url(concat('file://', regexp_replace(get_json_object(file_name, '$.miniProgramPath'), '^/', '')), 'QUERY', 'id'), NULL) as item_id,
           b.item_ids as item_ids,
           CASE WHEN get_json_object(file_name, '$.miniProgramPath') LIKE '%price-table-new.html%' THEN '奶粉价格表'
                WHEN get_json_object(file_name, '$.miniProgramPath') LIKE '%packageDetail/pages/detail/index%' THEN '商详'
                WHEN get_json_object(file_name, '$.miniProgramPath') LIKE '%market.hipac.cn%%' THEN 'YTMS' END as wx_msg_scence_touch_detail
    FROM dw_ytj_sel_touch_task_detail_d a
    LEFT JOIN task_item_tmp b ON a.touch_task_id = b.task_id
    WHERE dayid = yt_date_format(date_sub(CURRENT_DATE, 1), 'yyyyMMdd')
    AND substr(touch_task_detailedit_time, 1, 8) <= '${v_date}'
    AND substr(touch_task_detailedit_time, 1, 8) >= '${v_15_days_ago}' --  and substr(tuse_msg_time,1,8)<='${v_date}'
)-- 做一些指标加工，方便后续一些逻辑判断
,

wx_msg_tmp2 as ( --    select a.*
    --    ,nvl(b.touch_task_detail_id,c.touch_task_detail_id) as touch_task_detail_id
    --    ,count(if(nvl(b.touch_task_detail_id,c.touch_task_detail_id) is null,a.wx_msg_id,null)) over(partition by nvl(a.qw_chat_id,a.rand_id),a.wx_msg_content order by unix_timestamp(a.wx_msg_time,'yyyyMMddHHmmss') range between 60 preceding and 60 following ) as same_msg_send_cnt_60s
    --    ,if(a.black_reply_msg_id_n1t  is not null,-9,1) as wx_msg_send_status
    --    ,coalesce(b.pkl,c.pkl,a.content_pkl) as pkl
    --    -- 输入： https%3A%2F%2Fmarket.hipac.cn%2Fs%2Fpage%2Fqwhyfl.html 对应的array
    --    -- 获取最后一个 Fqwhyfl.html
    --    -- 再去除.html，获取到 Fqwhyfl
    --    ,if(size(ytms_link_array)>0,regexp_replace(ytms_link_array[size(ytms_link_array)-1],'.html',''),null) as ytms_code
    SELECT a.*,
           nvl(b.touch_task_detail_id, c.touch_task_detail_id) as touch_task_detail_id,
           count(if(nvl(b.touch_task_detail_id, c.touch_task_detail_id) IS NULL, a.wx_msg_id, NULL)) OVER (PARTITION BY nvl(a.qw_chat_id, a.rand_id), a.wx_msg_content ORDER BY unix_timestamp(a.wx_msg_time, 'yyyyMMddHHmmss') RANGE BETWEEN 60 PRECEDING
    AND 60 FOLLOWING) as same_msg_send_cnt_60s, -- 非触达中心消息，一分钟内发送同样消息数>=5,视为群发
           if(a.black_reply_msg_id_n1t IS NOT NULL, - 9, 1) as wx_msg_send_status,
           coalesce(b.pkl, c.pkl, a.content_pkl) as pkl -- 输入： https%3A%2F%2Fmarket.hipac.cn%2Fs%2Fpage%2Fqwhyfl.html 对应的array
    -- 获取最后一个 Fqwhyfl.html
    -- 再去除.html，获取到 Fqwhyfl
    -- ,if(size(coalesce(a.ytms_link_array,b.ytms_link_array,c.ytms_link_array) >0,regexp_replace(ytms_link_array[size(ytms_link_array)-1],'.html',''),null) as ytms_code
       ,
           CASE WHEN size(c.ytms_link_array) > 0 THEN regexp_replace(c.ytms_link_array[size(c.ytms_link_array) - 1], '.html', '')
                WHEN size(b.ytms_link_array) > 0 THEN regexp_replace(b.ytms_link_array[size(b.ytms_link_array) - 1], '.html', '')
                WHEN size(a.ytms_link_array) > 0 THEN regexp_replace(a.ytms_link_array[size(a.ytms_link_array) - 1], '.html', '')
                ELSE NULL END as ytms_code,
           coalesce(c.item_id, b.item_id, a.item_id) as item_id_3_source,
           coalesce(c.item_ids, b.item_ids) as item_ids,
           coalesce(b.wx_msg_scence_touch_detail, c.wx_msg_scence_touch_detail) as wx_msg_scence_touch_detail
    FROM (
        SELECT *,
               if(wx_msg_content LIKE '%hpc%', substr(wx_msg_content, instr(wx_msg_content, '&') + 1, 10), NULL) as content_pkl -- 解析小程序YTMS 对应的link
        -- 从/pages/web/index.html?link=https%3A%2F%2Fmarket.hipac.cn%2Fs%2Fpage%2Fqwhyfl.html&wxwwork_userid=13282187526
        -- 解析出对应的 link=https%3A%2F%2Fmarket.hipac.cn%2Fs%2Fpage%2Fqwhyfl.html
        -- 核心是获取 Fqwhyfl
       ,
               if(wx_msg_type = 2013, split(parse_url(concat('file://', regexp_replace(get_json_object(tuse_msg_content, '$.pagepath'), '^/', '')), 'QUERY', 'link'), '%2F'), NULL) as ytms_link_array, -- 解析商详页对应的item_id
               if(wx_msg_type = 2013 AND get_json_object(tuse_msg_content, '$.pagepath') LIKE '%packageDetail/pages/detail/index%', parse_url(concat('file://', regexp_replace(get_json_object(tuse_msg_content, '$.pagepath'), '^/', '')), 'QUERY', 'id'), NULL) as item_id
        FROM wx_msg_tmp1
    ) a -- 和触达中心关联，通过涂色消息判断哪些消息是触达中心发送的
    LEFT JOIN dw_ytj_sel_touch_task_detail_tmp b ON nvl(a.tuse_msg_id, a.rand_id) = nvl(b.tuse_wx_msg_id, b.rand_id) -- 和触达中心关联，通过企微消息判断哪些消息是触达中心发送的
    LEFT JOIN dw_ytj_sel_touch_task_detail_tmp c ON nvl(a.qw_msg_id, a.rand_id) = nvl(c.qw_msg_id, c.rand_id)
)

INSERT OVERWRITE TABLE dw_ytj_sel_wx_msg_di PARTITION (dayid)
SELECT  /*+ MAPJOIN(b,dim_wx_chat,e,f) */ a.wx_msg_id,
       a.wx_msg_type,
       b.tuse_msg_type_name as wx_msg_type_name,
       CASE WHEN a.touch_task_detail_id IS NOT NULL THEN 2
            WHEN a.same_msg_send_cnt_60s >= 5 THEN 3
            ELSE 1 END as wx_msg_source,
       CASE WHEN a.touch_task_detail_id IS NOT NULL THEN '触达中心发送'
            WHEN a.same_msg_send_cnt_60s >= 5 THEN '企微群发'
            ELSE '个人发送' END as wx_msg_source_name,
       a.wx_msg_send_status as wx_msg_send_status,
       CASE WHEN a.wx_msg_send_status = - 9 THEN '被拉黑，拒收'
            WHEN a.wx_msg_send_status = 1 THEN '发送成功' END as wx_msg_send_status_name,
       a.wx_msg_send_type,
       CASE WHEN a.wx_msg_send_type = 1 THEN '小二发送给门店'
            WHEN a.wx_msg_send_type = 2 THEN '门店发送给小二' END as wx_msg_send_type_name,
       a.qw_chat_id as qw_chat_id,
       c.wx_name as qw_nick_name,
       c.admin_user_id as qw_admin_user_id,
       c.admin_user_real_name as qw_admin_user_real_name,
       a.gw_chat_id,
       d.wx_name as gw_nick_name,
       d.shop_id_strs as gw_shop_id_strs,
       d.shop_name_strs as gw_shop_name_strs,
       a.wx_msg_time,
       a.wx_room_id as wx_room_id,
       a.wx_msg_content,
       a.wx_meta_data,
       a.wx_msg_create_time,
       a.wx_msg_edit_time,
       a.wx_msg_data_source,
       a.pkl,
       a.qw_msg_id,
       a.tuse_msg_id,
       a.tuse_msg_content,
       CASE WHEN a.pkl IS NOT NULL THEN '拍口令'
            WHEN a.wx_msg_type = 2013 AND (get_json_object(a.wx_msg_content, '$.des_1') LIKE '%海拍客%' OR get_json_object(a.wx_meta_data, '$.weapp.description') LIKE '%海拍客%' OR get_json_object(a.wx_meta_data, '$.weapp.displayname') LIKE '%海拍客%') THEN '海拍客小程序'
            WHEN a.wx_msg_type = 2013 THEN '其他小程序'
            WHEN a.wx_msg_type = 2001 THEN '普通文字'
            ELSE '其他' END as wx_msg_scence1,
       CASE WHEN a.pkl IS NOT NULL THEN e.pkl_biz_type_name -- 微信官方消息的小程序没有路径，只能用涂色的

            WHEN a.wx_msg_type = 2013 AND (get_json_object(a.tuse_msg_content, '$.pagepath') LIKE '%price-table-new.html%' OR wx_msg_scence_touch_detail = '奶粉价格表') THEN '奶粉价格表'
            WHEN a.wx_msg_type = 2013 AND (get_json_object(a.tuse_msg_content, '$.pagepath') LIKE '%packageDetail/pages/detail/index%' OR wx_msg_scence_touch_detail = '商详') THEN '商详'
            WHEN a.wx_msg_type = 2013 AND (get_json_object(a.tuse_msg_content, '$.pagepath') LIKE '%market.hipac.cn%%' OR wx_msg_scence_touch_detail = 'YTMS') THEN 'YTMS' END as wx_msg_scence2,
       a.item_id_3_source as item_id,
       if(ytms_code IS NOT NULL, concat('905.10.', f.id, '.'), NULL) as ytms_log_code,
       a.item_ids,
       substr(a.wx_msg_time, 1, 8) as dayid
FROM wx_msg_tmp2 a
LEFT JOIN (
    SELECT enum_key as tuse_msg_type,
           enum_value as tuse_msg_type_name
    FROM dw_met_enum_detail_d
    WHERE dayid = yt_date_format(date_sub(CURRENT_DATE, 1), 'yyyyMMdd')
    AND enum_detail_status = 1
    AND enum_code = 'tuse_msg_type'
) b ON a.wx_msg_type = b.tuse_msg_type
LEFT JOIN dim_wx_chat c ON a.qw_chat_id = c.chat_id
LEFT JOIN dim_wx_chat d ON a.gw_chat_id = d.chat_id
LEFT JOIN (
    SELECT *
    FROM dim_ytj_prm_pai_secret_key_d
    WHERE dayid = yt_date_format(date_sub(CURRENT_DATE, 1), 'yyyyMMdd')
) e ON a.pkl = e.secret_key
LEFT JOIN  -- ytms的配置，业务配置好id后，在日志里，会上报至第三个点位，即905.10.7377.0.0 ,即7377
-- 在小程序的ytms页面里，会上报路径，路径及name
-- 如： https%3A%2F%2Fmarket.hipac.cn%2Fs%2Fpage%2Fqwhyfl.html
(    SELECT id,
           name
    FROM dwd_yt_page_d
    WHERE dayid = yt_date_format(date_sub(CURRENT_DATE, 1), 'yyyyMMdd')
    AND substr(createdat, 1, 8) <= '${v_date}'
) f ON nvl(a.ytms_code, a.rand_id) = f.name
DISTRIBUTE BY dayid;