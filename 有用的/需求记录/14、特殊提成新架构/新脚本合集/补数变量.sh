v_date=$1

source ../sql_variable.sh $1

export file_timestamp="${v_date}_$(date +"%Y%m%d-%H")"

export common_where_parts=$(cat <<EOF
dayid = '$v_date'
and is_deleted =0
 -- 状态为开启中
and status = 1
 -- 方案月份近12个月的，才纳入计算
and month >= substr(add_months('$v_op_month', -12), 1, 7)
 -- 昨天新建的
and substr(create_time, 1, 8) > replace(date_add('$v_op_time', -1), '-', '')
EOF
)

export pre_month_where=$(cat <<EOF
$common_where_parts
 -- 上个月创建的方案
and months_between('$v_op_month', month) >= 1
EOF
)

export pre_pre_month_where=$(cat <<EOF
$common_where_parts
 -- 上上个月创建的方案
and months_between('$v_op_month', month) = 2
EOF
)

## 需要不熟的所有方案类型
## 因为补数方案是少数，而一次补数消耗时间过长，没有必要都跑，先查出今天需要跑的补数类型。可以跳过一些任务
## 这里使用了文件作为缓存（1小时级），用来复用结算结果
## TODO 因为引用该脚本的任务较多，而他们分别会被分配到不同的机器上，可能导致缓存利用效率较低（优化方式：将计算结果缓存到 hdfs 就或者 oss，使用完成删除掉）
## TODO 缓存及时失效，也仅是重新计算一次。
## TODO 缓存失效时间为一个小时，在由于 dw_bounty_plan_d 数据有问题的情况下，任务重跑可能会有坑
if [[ -e /tmp/pre_types_${file_timestamp}.txt ]]
then
       export pre_types=$(cat /tmp/pre_types_${file_timestamp}.txt)
else
       export pre_types=$(apache-spark-sql -e "
         select collect_list(bounty_rule_type) from (
             select
                 bounty_rule_type
             from ytdw.dw_bounty_plan_d
             where ${common_where_parts}
             -- 创建了补数方案
             and months_between('$v_op_month', month) >= 1
             group by bounty_rule_type
          ) d
       ")
       echo $pre_types > /tmp/pre_types_${file_timestamp}.txt
fi

if [[ -e /tmp/pre_pre_types_${file_timestamp}.txt ]]
then
      export pre_pre_types=$(cat /tmp/pre_pre_types_${file_timestamp}.txt)
else
      export pre_pre_types=$(apache-spark-sql -e "
        select collect_list(bounty_rule_type) from (
            select
                bounty_rule_type
            from ytdw.dw_bounty_plan_d
            where ${common_where_parts}
            -- 创建了补数方案
            and months_between('$v_op_month', month) = 2
            group by bounty_rule_type
        ) d
      ")
      echo $pre_pre_types > /tmp/pre_pre_types_${file_timestamp}.txt
fi

# 上月最后一天
export pre_month_last_day=$(date -d "${v_cur_month}01 -1 days" "+%Y%m%d")
# 上上月最后一天
export pre_pre_month_last_day=$(date -d "${v_cur_month}01 -1 month -1 days" "+%Y%m%d")