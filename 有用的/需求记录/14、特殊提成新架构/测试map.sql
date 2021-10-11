select mid,
       tags['电影'] as movie,
       tags['音乐'] as music
from (
         select mid,
                str_to_map(concat_ws(',', collect_list(concat(key, ":", value)))) as tags
         from (
                  select mid,
                         key,
                         concat_ws('-', collect_list(value)) as value
                  from (
                           select 1 as mid, '电影' as key, '惊悚' as value
                           union ALL
                           select 1 as mid, '音乐' as key, '摇滚' as value
                           union ALL
                           select 1 as mid, '电影' as key, '喜剧' as value
                       ) a
                  group by mid, key
              ) t
         group by mid
     ) tt;

--简化sql
with t as (
    select 1 as mid, '电影' as key, '惊悚' as value
    union ALL
    select 1 as mid, '音乐' as key, '摇滚' as value
)

select mid,
       str_to_map(concat_ws(',', collect_list(concat(key, ":", value)))) as tags
from t
group by mid;

select
    to_json(sort_array(collect_set(named_struct('BOSS_MONTH_1', str_to_map(concat('order_id:', '123456')),'PERIOD_1', str_to_map(concat('order_id:', '121212'))))))