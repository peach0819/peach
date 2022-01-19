with plan as (
    SELECT *
    FROM dw_bounty_plan_schedule_d
    lateral view explode(split(backward_date,',')) temp as schedule_date
    WHERE create_time > concat('$v_180_days_ago', '000000')
    AND schedule_date <= '$v_date'
    AND schedule_date != split(backward_date, ',')[0]
),

plan_sum as (
    SELECT * FROM dw_salary_backward_plan_sum_d WHERE dayid > '20200301'
)

SELECT no, schedule_date, row_number() over(partition by no order by schedule_date desc) as rank
FROM (
    SELECT plan.no, plan.schedule_date, count(distinct plan_sum.grant_object_user_id) as count
    FROM plan
    LEFT JOIN plan_sum ON plan_sum.dayid = plan.schedule_date AND plan_sum.planno = plan.no
    group by plan.no, plan.schedule_date
) t
HAVING rank = 1 AND count < 1
ORDER BY no desc