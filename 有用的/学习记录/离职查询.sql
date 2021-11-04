select id,  full_name, email, job_title, leave_time, join_time
from yt_ustone.t_user_admin
WHERE leave_time is not null
AND job_title not like '%经理%'
AND job_title not like '%代表%'
AND job_title not like '%客户%'
AND job_title not like '%推广%'
AND job_title not like '%主播%'
AND job_title not like '%直播%'
AND job_title not like '%客服%'
AND job_title not like '%财务%'
AND job_title not like '%运营%'
AND job_title not like '%品控%'
AND job_title not like '%物流%'
AND (job_title LIKE '%工程师%' OR job_title LIKE '%设计师%')
 order by leave_time desc