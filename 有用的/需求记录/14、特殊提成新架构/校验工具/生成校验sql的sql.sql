
--整体SQL如下

--SQL的头部SELECT部分

select -1 as select_seq,-1 as col_seq,'select * from (select '

union all

--差异字段列举

select 0 as select_seq,col_seq,

       case when data_type like 'decimal%' then

                concat('case when abs(coalesce(a.',column_name,',0) - coalesce(b.',column_name, ',0))>0.0003 then concat(''存在差异【'',a.',column_name,',''：'',b.',column_name,',''】'')

when coalesce(a.',column_name,',0) <> ','coalesce(b.',column_name, ',0) then concat(''少量差异【'',a.',column_name,',''：'',b.',column_name,',''】'') end as ',column_name,'_diff_flg,')

            else

                concat('case when coalesce(a.',column_name,',''#'') <> ','coalesce(b.',column_name, ',''#'') then concat(''存在差异【'',a.',column_name,',''：'',b.',column_name,',''】'') else ''无差异'' end as ',column_name,'_diff_flg,') end as str1



from column_info a1,

     (select 'dw_salary_backward_plan_sum_d' as primary_table_name,'dw_salary_backward_plan_sum_new_d' as leftjoin_table_name) a2

where a1.table_name =a2.primary_table_name and a1.db_name ='ytdw'

  and a1.column_name not in ('update_time', 'update_month', 'plan_name', 'plan_group_id', 'plan_group_name', 'real_coefficient_goal_rate')

union all

--比对的两个表

select 1 as select_seq,0 as col_seq,

       concat(' from ( select * from ',primary_table_name,' where dayid=''$v_date'' ) a

left join (select * from ',leftjoin_table_name, ' where dayid=''$v_date'' ) b on 1=1')  as str1

from (select 'dw_salary_backward_plan_sum_d' as primary_table_name,'dw_salary_backward_plan_sum_new_d' as leftjoin_table_name) par1_table_name

union all

--主键字段关联部分

select 2 as select_seq,col_seq,

       concat(' and coalesce(a.',column_name,',''#'') = ','coalesce(b.',column_name, ',''#'')')

from column_info a1,

     (select 'dw_salary_backward_plan_sum_d' as primary_table_name,'dw_salary_backward_plan_sum_new_d' as leftjoin_table_name) a2

where a1.table_name =a2.primary_table_name and a1.db_name ='ytdw' and data_type not like 'decimal%'

union all

select 3 as select_seq,1001 as col_seq,' ) t where '

union all

--过滤差异字段

select 4 as select_seq,col_seq,

       concat(' or ',column_name,'_diff_flg like ''存在差异%''')as str1

from column_info a1,

     (select 'dw_salary_backward_plan_sum_d' as primary_table_name,'dw_salary_backward_plan_sum_new_d' as leftjoin_table_name) a2

where a1.table_name =a2.primary_table_name and a1.db_name ='ytdw'

  and a1.column_name not in ('update_time', 'update_month', 'plan_name', 'plan_group_id', 'plan_group_name', 'real_coefficient_goal_rate')

order by select_seq, col_seq

limit 1000
