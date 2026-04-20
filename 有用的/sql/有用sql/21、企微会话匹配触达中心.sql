with msg as (
SELECT id, msg_type, content, msg_time, admin_chat_id
FROM yt_crm.ads_crm_chat_msg_qw
WHERE msg_time > '20260301000000'
AND msg_time < '20260417000000'
AND qw_action = 'send'
AND direction = 1
AND msg_type = 'text'
),

admin_chat as (
    SELECT 24153712 AS admin_chat_id UNION ALL SELECT 24153713 AS admin_chat_id UNION ALL SELECT 206598 AS admin_chat_id UNION ALL SELECT 16430832 AS admin_chat_id UNION ALL SELECT 19541024 AS admin_chat_id UNION ALL SELECT 14625492 AS admin_chat_id UNION ALL SELECT 14625491 AS admin_chat_id UNION ALL SELECT 8717 AS admin_chat_id UNION ALL SELECT 8718 AS admin_chat_id UNION ALL SELECT 434710 AS admin_chat_id UNION ALL SELECT 203287 AS admin_chat_id UNION ALL SELECT 408082 AS admin_chat_id UNION ALL SELECT 24154212 AS admin_chat_id UNION ALL SELECT 24 AS admin_chat_id UNION ALL SELECT 25 AS admin_chat_id UNION ALL SELECT 17259806 AS admin_chat_id UNION ALL SELECT 3872289 AS admin_chat_id UNION ALL SELECT 15990255 AS admin_chat_id UNION ALL SELECT 30 AS admin_chat_id UNION ALL SELECT 8734 AS admin_chat_id UNION ALL SELECT 381466 AS admin_chat_id UNION ALL SELECT 8736 AS admin_chat_id UNION ALL SELECT 14852034 AS admin_chat_id UNION ALL SELECT 17134885 AS admin_chat_id UNION ALL SELECT 11078540 AS admin_chat_id UNION ALL SELECT 24153690 AS admin_chat_id UNION ALL SELECT 493356 AS admin_chat_id UNION ALL SELECT 4492136 AS admin_chat_id UNION ALL SELECT 379690 AS admin_chat_id UNION ALL SELECT 16179910 AS admin_chat_id UNION ALL SELECT 24151872 AS admin_chat_id UNION ALL SELECT 24154178 AS admin_chat_id UNION ALL SELECT 5446752 AS admin_chat_id UNION ALL SELECT 24153667 AS admin_chat_id UNION ALL SELECT 24153669 AS admin_chat_id UNION ALL SELECT 24153670 AS admin_chat_id UNION ALL SELECT 403005 AS admin_chat_id UNION ALL SELECT 61 AS admin_chat_id UNION ALL SELECT 8765 AS admin_chat_id UNION ALL SELECT 198717 AS admin_chat_id UNION ALL SELECT 428868 AS admin_chat_id UNION ALL SELECT 23013659 AS admin_chat_id UNION ALL SELECT 23013658 AS admin_chat_id UNION ALL SELECT 10546662 AS admin_chat_id UNION ALL SELECT 15107488 AS admin_chat_id UNION ALL SELECT 24151864 AS admin_chat_id UNION ALL SELECT 73 AS admin_chat_id UNION ALL SELECT 24151865 AS admin_chat_id UNION ALL SELECT 8780 AS admin_chat_id UNION ALL SELECT 6307885 AS admin_chat_id UNION ALL SELECT 7152672 AS admin_chat_id UNION ALL SELECT 24151871 AS admin_chat_id UNION ALL SELECT 8785 AS admin_chat_id UNION ALL SELECT 3743336 AS admin_chat_id UNION ALL SELECT 561246 AS admin_chat_id UNION ALL SELECT 3712622 AS admin_chat_id UNION ALL SELECT 8336680 AS admin_chat_id UNION ALL SELECT 8777949 AS admin_chat_id UNION ALL SELECT 17990474 AS admin_chat_id UNION ALL SELECT 8777948 AS admin_chat_id UNION ALL SELECT 359775 AS admin_chat_id UNION ALL SELECT 8795 AS admin_chat_id UNION ALL SELECT 17990473 AS admin_chat_id UNION ALL SELECT 24151852 AS admin_chat_id UNION ALL SELECT 3770972 AS admin_chat_id UNION ALL SELECT 513902 AS admin_chat_id UNION ALL SELECT 1467519 AS admin_chat_id UNION ALL SELECT 9790972 AS admin_chat_id UNION ALL SELECT 513900 AS admin_chat_id UNION ALL SELECT 513899 AS admin_chat_id UNION ALL SELECT 513898 AS admin_chat_id UNION ALL SELECT 714853 AS admin_chat_id UNION ALL SELECT 22648616 AS admin_chat_id UNION ALL SELECT 200305 AS admin_chat_id UNION ALL SELECT 512884 AS admin_chat_id UNION ALL SELECT 512883 AS admin_chat_id UNION ALL SELECT 7152665 AS admin_chat_id UNION ALL SELECT 513906 AS admin_chat_id UNION ALL SELECT 513904 AS admin_chat_id UNION ALL SELECT 7152666 AS admin_chat_id UNION ALL SELECT 400760 AS admin_chat_id UNION ALL SELECT 512888 AS admin_chat_id UNION ALL SELECT 24154098 AS admin_chat_id UNION ALL SELECT 23145447 AS admin_chat_id UNION ALL SELECT 23145446 AS admin_chat_id UNION ALL SELECT 1335964 AS admin_chat_id UNION ALL SELECT 8586 AS admin_chat_id UNION ALL SELECT 882563 AS admin_chat_id UNION ALL SELECT 201618 AS admin_chat_id UNION ALL SELECT 199569 AS admin_chat_id UNION ALL SELECT 5344451 AS admin_chat_id UNION ALL SELECT 19637680 AS admin_chat_id UNION ALL SELECT 10140 AS admin_chat_id UNION ALL SELECT 385443 AS admin_chat_id UNION ALL SELECT 17257134 AS admin_chat_id UNION ALL SELECT 493997 AS admin_chat_id UNION ALL SELECT 22651368 AS admin_chat_id UNION ALL SELECT 367287 AS admin_chat_id UNION ALL SELECT 436149 AS admin_chat_id UNION ALL SELECT 494003 AS admin_chat_id UNION ALL SELECT 407987 AS admin_chat_id UNION ALL SELECT 8641 AS admin_chat_id UNION ALL SELECT 17132226 AS admin_chat_id UNION ALL SELECT 6460074 AS admin_chat_id UNION ALL SELECT 23178411 AS admin_chat_id UNION ALL SELECT 8497738 AS admin_chat_id UNION ALL SELECT 18730960 AS admin_chat_id UNION ALL SELECT 3711479 AS admin_chat_id UNION ALL SELECT 8658 AS admin_chat_id UNION ALL SELECT 8662 AS admin_chat_id UNION ALL SELECT 113121 AS admin_chat_id UNION ALL SELECT 442086 AS admin_chat_id UNION ALL SELECT 8432224 AS admin_chat_id UNION ALL SELECT 24153744 AS admin_chat_id UNION ALL SELECT 113120 AS admin_chat_id UNION ALL SELECT 201954 AS admin_chat_id UNION ALL SELECT 8082590 AS admin_chat_id UNION ALL SELECT 8678 AS admin_chat_id UNION ALL SELECT 560110 AS admin_chat_id UNION ALL SELECT 442090 AS admin_chat_id UNION ALL SELECT 17830140 AS admin_chat_id UNION ALL SELECT 442091 AS admin_chat_id UNION ALL SELECT 15576579 AS admin_chat_id UNION ALL SELECT 913378 AS admin_chat_id UNION ALL SELECT 24151939 AS admin_chat_id UNION ALL SELECT 24151940 AS admin_chat_id UNION ALL SELECT 414195 AS admin_chat_id UNION ALL SELECT 24151941 AS admin_chat_id UNION ALL SELECT 24151942 AS admin_chat_id UNION ALL SELECT 24153736 AS admin_chat_id UNION ALL SELECT 560113 AS admin_chat_id UNION ALL SELECT 5677487 AS admin_chat_id UNION ALL SELECT 560114 AS admin_chat_id UNION ALL SELECT 24151946 AS admin_chat_id UNION ALL SELECT 560115 AS admin_chat_id UNION ALL SELECT 560116 AS admin_chat_id UNION ALL SELECT 24153742 AS admin_chat_id UNION ALL SELECT 2415374 AS admin_chat_id
),

task_detail as (
    SELECT touch_task_id, qw_msg_id
    FROM ytdw.dw_ytj_sel_touch_task_detail_d
    WHERE dayid='20260419'
    AND qw_msg_id is not null
),

task as (
    SELECT  t.id as task_id, u.user_real_name as creator
    FROM yt_crm.ads_touch_task  t
    LEFT JOIN ytdw.dwd_user_admin_d u ON t.creator = u.user_id
    WHERE u.dayid = '20260419'
)

SELECT count(*) as `总发送消息数`,
       sum(if(creator is not null, 1, 0)) as `通过触达中心发送消息数`,
       sum(if(creator is not null AND content NOT RLIKE '直供品牌|爱他美|领熠|卓傲|美赞臣|毛利率|a2|贝拉米|惠氏|可瑞康|美素佳儿|美赞臣|雀巢|雅培|南瓜树|阿米拉', 1, 0)) as `不包含电销主推触达中心发送消息数`
FROM msg
INNER JOIN admin_chat ON msg.admin_chat_id = admin_chat.admin_chat_id
LEFT JOIN task_detail ON msg.id = task_detail.qw_msg_id
LEFT JOIN task ON task_detail.touch_task_id = task.task_id