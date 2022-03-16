SELECT
  fail_type, max(fail_rate) as fail_rate, max(fail_count) as fail_count
FROM (SELECT
        case when fail_detail.fail_type = 1 then '任务发送时间在不可发送时间段'
             when fail_detail.fail_type = 2 then '该企微帐号不存在于涂色系统'
             when fail_detail.fail_type = 3 then '涂色机器人已离线'
             when fail_detail.fail_type = 4 then '触达异常'
             when fail_detail.fail_type = 5 then '超过单日最大次数'
             when fail_detail.fail_type = 6 then '涂色机器人初始化中'
             when fail_detail.fail_type = 7 then '商品变量对应顺序的商品不存在'
             when fail_detail.fail_type = 8 then '内容生成异常'
             when fail_detail.fail_type = 9 then '发送内容类型不支持'
             when fail_detail.fail_type = 10 then '涂色消息发送失败'
             when fail_detail.fail_type = 11 then '任务被取消'
             when fail_detail.fail_type = 12 then '该客户不存在于涂色系统 tuse_fre_id不存在'
             when fail_detail.fail_type = 13 then '涂色内私聊的客户不存在 tuse_fre_id存在，但是无效'
             when fail_detail.fail_type = 14 then '已被客户删除好友'
             when fail_detail.fail_type = 15 then '已被客户拉黑'
             when fail_detail.fail_type = 16 then '变量内容不存在'
             when fail_detail.fail_type = 17 then '素材获取失败'
             when fail_detail.fail_type = 96 then '涂色接口调用超时'
             when fail_detail.fail_type = 97 then '系统响应超时'
             when fail_detail.fail_type = 98 then '触达通道未开放'
             when fail_detail.fail_type = 99 then '未知的涂色异常'
             else '不计入统计'
        end as fail_type,
       max(fail_detail.fail_count/total.count) as fail_rate,
       max(fail_detail.fail_count) as fail_count
FROM (
    SELECT count(*) as fail_count, d.fail_type
    FROM t_touch_task_detail d
    INNER JOIN t_touch_task t ON d.task_id = t.id AND date_format(t.start_time, '%Y-%m-%d') = date_format(now(), '%Y-%m-%d')
    WHERE d.detail_status = 3
    AND d.fail_type != 11
    group by d.fail_type
) fail_detail
cross join (
    SELECT count(*) as count
    FROM t_touch_task_detail d
    INNER JOIN t_touch_task t ON d.task_id = t.id AND date_format(t.start_time, '%Y-%m-%d') = date_format(now(), '%Y-%m-%d')
    WHERE d.detail_status = 3
    AND d.fail_type != 11
) total ON 1 = 1
group by fail_detail.fail_type
) T
group by fail_type
