WITH dim_wx_chat as (
    SELECT a.chat_id,
           a.admin_user_id,
           a.admin_user_real_name,
           a.wx_name,
           a.chat_type_name,
           if(nvl(if(a.shop_id = ' ', '', a.shop_id), '') = '', NULL, a.shop_id) as shop_id,
           b.virtual_group_name_lv1,
           b.virtual_group_name_lv2,
           b.virtual_group_name_lv3,
           b.virtual_group_name_lv4,
           b.virtual_group_name_lv5,
           c.shop_name
    FROM (
        SELECT *,
               - rand()* 1000 as rand_id
        FROM dim_ytj_sel_chat_d LATERAL VIEW explode(split(nvl(shop_id_strs, ' '), ',')) shop_table as shop_id
        WHERE dayid = yt_date_format(date_sub(current_date, 1), 'yyyyMMdd')
    ) a
    LEFT JOIN dim_hpc_pub_user_admin b ON nvl(a.admin_user_id, a.rand_id) = b.user_id
    LEFT JOIN (
        SELECT *
        FROM dim_ytj_shp_shop_d
        WHERE dayid = yt_date_format(date_sub(current_date, 1), 'yyyyMMdd')
    ) c ON nvl(a.shop_id, a.rand_id) = c.shop_id
),

touch_task_detail_tmp as (
    SELECT a.*,
           b.admin_user_id,
           b.admin_user_real_name,
           b.wx_name,
           b.chat_type_name,
           c.virtual_group_name_lv1,
           c.virtual_group_name_lv2,
           c.virtual_group_name_lv3,
           c.virtual_group_name_lv4,
           c.virtual_group_name_lv5,
           d.wx_name as shop_wx_name,
           d.chat_type_name as shop_chat_type_name
    FROM (
        SELECT *
        FROM dw_ytj_sel_touch_task_detail_d
        WHERE dayid = yt_date_format(date_sub(current_date, 1), 'yyyyMMdd')
        AND substr(touch_task_detail_create_time, 1, 8) <= '${v_date}'
        AND tuse_wx_msg_id IS NOT NULL
    ) a
    LEFT JOIN (
        SELECT *
        FROM dim_ytj_sel_chat_dkan
        WHERE dayid = yt_date_format(date_sub(current_date, 1), 'yyyyMMdd')
    ) b ON a.admin_chat_id = b.chat_id
    LEFT JOIN (
        SELECT *
        FROM dim_ytj_pub_user_admin_d
        WHERE dayid <= substr('${v_date}', 1, 6)
    ) c ON b.admin_user_id = c.user_id AND substr(a.touch_task_detail_create_time, 1, 6) = c.dayid
    LEFT JOIN (
        SELECT *
        FROM dim_ytj_sel_chat_d
        WHERE dayid = yt_date_format(date_sub(current_date, 1), 'yyyyMMdd')
    ) d ON a.shop_chat_id = d.chat_id
),

msg_tmp as (
    SELECT wx_msg_id,
           wx_msg_time,
           wx_msg_content,
           contents
    FROM (
        SELECT wx_msg_id,
               wx_msg_time,
               wx_msg_content
        FROM dw_ytj_sel_wx_msg_di
        WHERE dayid <= '${v_date}'
        AND dayid >= yt_date_sub('${v_date}', 15)
        AND (wx_msg_scence1 = '普通文字'
        OR wx_msg_type_name = '文字')
    ) a LATERAL VIEW explode(split(wx_msg_content, '\n')) tmp as contents
),

item_tmp as (
    SELECT wx_msg_id,
           max(wx_msg_content),
           concat_ws(',', collect_set(item_id)) as analysis_item_ids
    FROM (
        SELECT wx_msg_id,
               wx_msg_content,
               regexp_extract(contents, '(\\d+)', 1) as item_id
        FROM msg_tmp
        WHERE contents RLIKE '#\\d+|^APP搜|^app搜|\\d+#|^ID|^id|^商品id|^商品ID'

        UNION ALL

        SELECT wx_msg_id,
               wx_msg_content,
               item_id_analyze as item_id
        FROM dw_ytj_sel_wx_msg_di LATERAL VIEW explode(split(item_ids, ',')) tmp as item_id_analyze
        WHERE dayid <= '${v_date}'
        AND dayid >= yt_date_sub('${v_date}', 15)
    ) a
    GROUP BY wx_msg_id
) -- 当消息是触达中心时，直接通过触达中心和门店进行一对一关联
-- 当消息不是触达中心时，通过chat_id和门店一对多关联


INSERT OVERWRITE TABLE dw_ytj_sel_admin_shop_wx_msg_di PARTITION (dayid)
SELECT concat(a.wx_msg_id, '#', nvl(coalesce(b.shop_id, c.shop_id, d.shop_id), '')) as sel_shop_wx_msg_id,
       a.wx_msg_id as wx_msg_id,
       coalesce(b.admin_user_id, c.admin_user_id, d.admin_user_id) as admin_user_id,
       coalesce(b.shop_id, c.shop_id, d.shop_id) as shop_id, --消息相关属性
       a.wx_msg_send_type,
       a.wx_msg_send_type_name,
       a.wx_msg_type,
       a.wx_msg_type_name,
       a.wx_msg_time,
       a.wx_msg_content,
       a.wx_meta_data,
       a.pkl,
       a.wx_msg_source,
       a.wx_msg_source_name,
       a.wx_msg_send_status,
       a.wx_msg_send_status_name,
       a.qw_msg_id,
       a.tuse_msg_id, -- 小二相关属性
       a.qw_chat_id as admin_chat_id,
       a.qw_admin_user_real_name as admin_user_real_name,
       coalesce(b.wx_name, c.wx_name) as admin_wx_nick_name,
       coalesce(b.virtual_group_name_lv1, c.virtual_group_name_lv1) as admin_user_virtual_group_name_lv1,
       coalesce(b.virtual_group_name_lv2, c.virtual_group_name_lv2) as admin_user_virtual_group_name_lv2,
       coalesce(b.virtual_group_name_lv3, c.virtual_group_name_lv3) as admin_user_virtual_group_name_lv3,
       coalesce(b.virtual_group_name_lv4, c.virtual_group_name_lv4) as admin_user_virtual_group_name_lv4,
       coalesce(b.virtual_group_name_lv5, c.virtual_group_name_lv5) as admin_user_virtual_group_name_lv5, --门店相关属性
       if(d.shop_id IS NOT NULL, a.gw_chat_id, NULL) as shop_chat_id,
       CASE WHEN b.tuse_wx_msg_id IS NOT NULL THEN b.shop_wx_name
            WHEN d.shop_id IS NOT NULL THEN d.wx_name END as shop_wx_nick_name,
       coalesce(b.shop_name, d.shop_name) as shop_name,
       a.wx_msg_scence1,
       a.wx_msg_scence2,
       a.item_id,
       a.ytms_log_code,
       e.analysis_item_ids,
       a.dayid
FROM (
    SELECT *
    FROM dw_ytj_sel_wx_msg_di
    WHERE dayid <= '${v_date}'
    AND dayid >= yt_date_sub('${v_date}', 15)
) a
LEFT JOIN touch_task_detail_tmp b ON a.wx_msg_id = b.tuse_wx_msg_id
LEFT JOIN dim_wx_chat c ON a.qw_chat_id = c.chat_id AND b.tuse_wx_msg_id IS NULL 
LEFT JOIN dim_wx_chat d ON a.gw_chat_id = d.chat_id AND b.tuse_wx_msg_id IS NULL 
LEFT JOIN item_tmp e ON a.wx_msg_id = e.wx_msg_id
DISTRIBUTE BY dayid