
select  t.owner_user_name , table_name, enable_rule_num
from monitor_info i
LEFT JOIN prod_edp.task t ON t.task_name = i.table_name
WHERE i.db_name = 'ytdw'
AND i.enable_rule_num > 0
AND (
  owner_user_name NOT IN ('周益男', '赵陶', '张志伟', '王新',
'覃先骁','钱黎明','阮开洁','王权儒','陈少剑','桑波','薛雷','李耀','张素斌','孙德超','陈恋昶','王顺',
'龙强',
'章曜',
'王新博',
'叶礼伦',
'徐丽',
'唐明强',
'包旭成',
'陈恩奇',
'单泽军',
'李智龙',
'冯国强',
'杜彦永',
'刘嫣',
'张沛东',
'王聪聪'
)
)
order by enable_rule_num desc limit 100