select service_user_id,
       service_user_name,
       service_department_id,
       service_department_name,
       is_split,
       is_coefficient,
       unknown_scene_count,
       leave_time,
       coefficient_goal,                                                             --系数目标
       coefficient_summary,
       commission_summary,
       milk_commission_summary,
       diaper_commission_summary,
       shampoo_commission_summary,
       other_commission_summary,
       new_sign_shop_count,
       shop_count,
       reach_shop_goal,
       reach_shop_count,
       reach_shop_coefficient,
       a_coefficient_summary,
       b_coefficient_summary,
       update_time,
       a_target_finish,
       b_target_finish,
       cnt_silent_shop,
       cnt_brand_shop,
       num01_pure_b_pay_amount,
       num02_pure_b_pay_amount,
       num03_pure_b_pay_amount,
       num04_pure_b_pay_amount,
       num05_pure_b_pay_amount,
       num06_pure_b_pay_amount,
       class_number_info,
       pickup_card_coefficient_summary,--提货卡充值系数总和
       goods_coefficient_summary,--实货支付系数总和
       pickup_card_commission_summary,--提货卡充值提成总和
       goods_commission_summary,--实货支付提成总和
       coefficient_goal_rate,--系统计算目标完成率
       upload_coefficient,--当月手动上传完成率
       nvl(upload_coefficient, coefficient_goal_rate) as real_coefficient_goal_rate, --理论目标完成率
       num07_pure_b_pay_amount,
       num08_pure_b_pay_amount,
       num01_pure_b_pay_name,
       num02_pure_b_pay_name,
       num03_pure_b_pay_name,
       num04_pure_b_pay_name,
       num05_pure_b_pay_name,
       num06_pure_b_pay_name,
       num07_pure_b_pay_name,
       num08_pure_b_pay_name,
       province_dept,--省区
       zone_dept,--战区
       theoretical_commission_amt,                                                   --理论提成金额
       new_sign_commission_amt,                                                      --有效门店理论提成金额
       null                                           as kn_valid_visit_shop_cnt,
       num09_pure_b_pay_amount,
       num09_pure_b_pay_name
from (
         select salary_users.service_user_id                                           as service_user_id,
                salary_users.service_user_name                                         as service_user_name,
                salary_users.service_department_id                                     as service_department_id,
                salary_users.service_department_name                                   as service_department_name,
                salary_users.is_split,
                salary_users.is_coefficient,
                0                                                                      as unknown_scene_count,
                from_unixtime(unix_timestamp(user.leave_time, 'yyyyMMddHHmmss'))       as leave_time,
                user_target.target                                                     as coefficient_goal,     --系数目标
                kn_pure_gmv.coefficient_summary,
                frozen_pure_gmv.commission_summary,
                frozen_pure_gmv.milk_commission_summary,
                frozen_pure_gmv.diaper_commission_summary,
                frozen_pure_gmv.shampoo_commission_summary,
                frozen_pure_gmv.other_commission_summary,
                table3.new_sign_shop_count,
                table2.kn_shop_count                                                   as shop_count,
                null                                                                   as reach_shop_goal,
                table4.da_gmv_biao_shop_count                                          as reach_shop_count,
                null                                                                   as reach_shop_coefficient,
                kn_pure_gmv.a_coefficient_summary,
                kn_pure_gmv.b_coefficient_summary,
                from_unixtime(unix_timestamp(current_timestamp()))                     as update_time,
                kn_pure_gmv.a_target_finish,
                kn_pure_gmv.b_target_finish,
                cnt_silent_shop,
                cnt_brand_shop,
                frozen_pure_gmv.num01_pure_b_pay_amount,
                frozen_pure_gmv.num02_pure_b_pay_amount,
                frozen_pure_gmv.num03_pure_b_pay_amount,
                frozen_pure_gmv.num04_pure_b_pay_amount,
                frozen_pure_gmv.num05_pure_b_pay_amount,
                frozen_pure_gmv.num06_pure_b_pay_amount,
                --20200505
                --  '分类01：低端，超低端尿不湿,洗衣液,纸巾（BD和大BD通用）\；分类02：营养品,辅食,服纺，婴童洗护 （BD和大BD通用）\；分类03：奶粉（BD和大BD通用）\；分类04：其他（BD和大BD通用）\;
                --分类05：低端，超低端尿不湿,洗衣液,纸巾（大BD专供，BD不计提成）\；分类06：营养品,辅食,服纺，婴童洗护（大BD专供，BD不计提成）\；分类07：奶粉（大BD专供，BD不计提成）\；分类08：其他（大BD专供，BD不计提成）\;' as class_number_info,
                --20200724
                case
                    when is_split = 'BD'
                        then '分类01：低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（通用品）（元）\；分类02：营养品，用品玩具，服纺，洗护（通用品）\；分类03奶粉及面包/蛋糕(元)（通用品）\；分类04：中端和高端尿不湿，辅食，其他品类（通用品）\；分类09：纽瑞优系列，佑伉力（元）'
                    when is_split = '大BD'
                        then '分类01：低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（通用品）（元）\；分类02：营养品，用品玩具，服纺，洗护（通用品）\；分类03奶粉及面包/蛋糕(元)（通用品）\；分类04：中端和高端尿不湿，辅食，其他品类（通用品）\；分类05：低端和超低端尿不湿，洗衣液，干湿纸巾（大BD专供品）\；分类06：营养品，用品玩具，服纺，洗护 （大BD专供品）\；分类07：奶粉及面包/蛋糕(元)（大BD专供品）\；分类08：中端和高端尿不湿，辅食，其他品类（大BD专供品）\；分类09：纽瑞优系列，佑伉力（元）'
                    else '' end
                                                                                       as class_number_info,
                kn_pure_gmv.pickup_card_coefficient_summary,--提货卡充值系数总和
                kn_pure_gmv.goods_coefficient_summary,--实货支付系数总和
                frozen_pure_gmv.pickup_card_commission_summary,--提货卡充值提成总和
                frozen_pure_gmv.goods_commission_summary,--实货支付提成总和
                case
                    when nvl(kn_pure_gmv.coefficient_summary, 0) != 0 and nvl(user_target.target, 0) != 0
                        then round(kn_pure_gmv.coefficient_summary / user_target.target, 4)
                    else null end                                                      as coefficient_goal_rate,--系统计算目标完成率
                round(sales_coefficient.coefficient, 4)                                as upload_coefficient,--当月手动上传完成率
                frozen_pure_gmv.num07_pure_b_pay_amount,
                frozen_pure_gmv.num08_pure_b_pay_amount,
                frozen_pure_gmv.num09_pure_b_pay_amount,
                frozen_pure_gmv.num01_pure_b_pay_name,
                frozen_pure_gmv.num02_pure_b_pay_name,
                frozen_pure_gmv.num03_pure_b_pay_name,
                frozen_pure_gmv.num04_pure_b_pay_name,
                frozen_pure_gmv.num05_pure_b_pay_name,
                frozen_pure_gmv.num06_pure_b_pay_name,
                frozen_pure_gmv.num07_pure_b_pay_name,
                frozen_pure_gmv.num08_pure_b_pay_name,
                frozen_pure_gmv.num09_pure_b_pay_name,
                --省区
                case when salary_users.is_split = 'BD' then dept.dep_2name else '' end as province_dept,
                --战区
                case when salary_users.is_split = 'BD' then dept.dep_3name else '' end as zone_dept,
                --提成金额
                case
                    when salary_users.is_split = 'BD' or salary_users.is_split = '大BD'
                        then nvl(frozen_pure_gmv.num01_pure_b_pay_amount, 0) * 0.03
                        + nvl(frozen_pure_gmv.num02_pure_b_pay_amount, 0) * 0.05
                        + nvl(frozen_pure_gmv.num03_pure_b_pay_amount, 0) * 0.025
                        + nvl(frozen_pure_gmv.num04_pure_b_pay_amount, 0) * 0.04
                        + nvl(frozen_pure_gmv.num05_pure_b_pay_amount, 0) * 0.03
                        + nvl(frozen_pure_gmv.num06_pure_b_pay_amount, 0) * 0.05
                        + nvl(frozen_pure_gmv.num07_pure_b_pay_amount, 0) * 0.025
                        + nvl(frozen_pure_gmv.num08_pure_b_pay_amount, 0) * 0.04
                        + nvl(frozen_pure_gmv.num09_pure_b_pay_amount, 0) * 0.01
                    else null
                    end                                                                as theoretical_commission_amt,
                case
                    when salary_users.is_split = 'BD' then nvl(table3.new_sign_shop_count, 0) * 50
                    else null
                    end                                                                as new_sign_commission_amt,
                null                                                                   as kn_valid_visit_shop_cnt
         from (
                  select sales.service_user_id,
                         user_info.user_real_name   as service_user_name,
                         user_info.dept_id          as service_department_id,
                         user_info.dept_name        as service_department_name,
                         salary_user.is_split       as is_split,
                         salary_user.is_coefficient as is_coefficient
                  from (
                           select service_user_id
                           from (
                                    select service_user_id
                                    from ads_salary_biz_frozen_pure_gmv_d
                                    where dayid = '$v_date'
                                      and service_user_id is not null
                                      and service_user_id != ''
                                    group by service_user_id
                                    union all
                                    select service_user_id
                                    from ads_salary_biz_kn_pure_gmv_d
                                    where dayid = '$v_date'
                                      and service_user_id is not null
                                      and service_user_id != ''
                                    group by service_user_id
                                ) tmp
                           group by service_user_id
                       ) sales
                           left join
                       (
                           select user_id,
                                  user_real_name,
                                  dept_id,
                                  dept_name
                           from dim_usr_user_d
                           where dayid = '$v_date'
                       ) user_info on user_info.user_id = sales.service_user_id
                           --销售是否拆分，是否有系数
                           left join
                       (select user_name, is_split, is_coefficient
                        from ads_salary_base_user_d
                        where dayid = '$v_date') salary_user
                       on salary_user.user_name = user_info.user_real_name
              ) salary_users
                  left join
              (
                  select service_user_id,
                         commission_summary,
                         milk_commission_summary,
                         diaper_commission_summary,
                         shampoo_commission_summary,
                         other_commission_summary,
                         num01_pure_b_pay_amount,
                         num02_pure_b_pay_amount,
                         num03_pure_b_pay_amount,
                         num04_pure_b_pay_amount,
                         num05_pure_b_pay_amount,
                         num06_pure_b_pay_amount,
                         num07_pure_b_pay_amount,
                         num08_pure_b_pay_amount,
                         num09_pure_b_pay_amount,
                         pickup_card_commission_summary,--提货卡充值提成总和
                         goods_commission_summary,--实货支付提成总和
                         num01_pure_b_pay_name,
                         num02_pure_b_pay_name,
                         num03_pure_b_pay_name,
                         num04_pure_b_pay_name,
                         num05_pure_b_pay_name,
                         num06_pure_b_pay_name,
                         num07_pure_b_pay_name,
                         num08_pure_b_pay_name,
                         num09_pure_b_pay_name
                  from ads_salary_biz_frozen_pure_gmv_d
                  where dayid = '$v_date'
              ) frozen_pure_gmv on salary_users.service_user_id = frozen_pure_gmv.service_user_id
                  left join
              (
                  select service_user_id,
                         coefficient_summary,
                         a_coefficient_summary,
                         b_coefficient_summary,
                         a_target_finish,
                         b_target_finish,
                         pickup_card_coefficient_summary,--提货卡充值系数总和
                         goods_coefficient_summary--实货支付系数总和
                  from ads_salary_biz_kn_pure_gmv_d
                  where dayid = '$v_date'
              ) kn_pure_gmv on salary_users.service_user_id = kn_pure_gmv.service_user_id
                  --库内门店数
                  left join
              (
                  select ytdw.get_service_info('service_type:销售', bd_service_info,
                                               'service_user_id') as service_user_id,
                         count(distinct shop_id)                     kn_shop_count
                  from (
                           select *
                           from dw_shop_base_d
                                    lateral view explode(split(
                                            regexp_replace(ytdw.get_service_info('service_type:销售', service_info),
                                                           '\}\,', '\}\;'), '\;')) tmp as bd_service_info
                           where dayid = '$v_date'
                             and bu_id = 0
                             and store_type not in (9, 10, 11)
                             and shop_status in (1, 2, 3, 4, 5)
                       ) tbl
                  group by ytdw.get_service_info('service_type:销售', bd_service_info, 'service_user_id')
              ) table2 on table2.service_user_id = salary_users.service_user_id
                  --有效新开
                  --20200525新增approve_status_name：'真实性认证成功'
                  left join
              (
                  select service_user_id,
                         count(distinct shop_id) as new_sign_shop_count --有效新开门店数
                  from ytdw.dw_salary_shop_data_d
                  where dayid = '$v_date'
                    and substr(new_sign_pay_day, 1, 6) = '$v_cur_month'
                    and approve_status_name in ('审核成功', '审核成功（无资质）', '真实性认证成功')
                    and min_pay_month = '$v_cur_month'
                  group by service_user_id
              ) table3 on table3.service_user_id = salary_users.service_user_id

                  --达标门店数
                  left join
              (
                  select service_user_id,
                         count(case when cur_month_is_reach = '达标' then shop_id else null end) da_gmv_biao_shop_count
                  from ads_salary_base_shop_d
                           lateral view explode(split(bd_user_ids, ',')) tmp as service_user_id
                  where dayid = '$v_date'
                  group by service_user_id
              ) table4 on table4.service_user_id = salary_users.service_user_id
                  --离职时间
                  left join
              (
                  select *
                  from dim_usr_user_d
                  where dayid = '$v_date'
              ) user
         on user.user_id=salary_users.service_user_id
             --激活门店数
             left join
             (
             select is_silent_service_user_id,count(distinct shop_id) as cnt_silent_shop from ads_salary_base_shop_d where dayid ='$v_date' group by is_silent_service_user_id
             ) silent_shop on silent_shop.is_silent_service_user_id=salary_users.service_user_id
             left join
             --多品进店数
             (
             select is_brand_service_user_id ,count(distinct shop_id) as cnt_brand_shop from ads_salary_base_shop_d where dayid ='$v_date' group by is_brand_service_user_id
             ) brand_shop on brand_shop.is_brand_service_user_id=salary_users.service_user_id
             left join
             --人工上传系数
             (
             select
             sales_user_name as user_name,coefficient
             from ads_salary_base_sales_coefficient_d
             where dayid ='$v_date'
             group by sales_user_name,coefficient
             ) sales_coefficient on sales_coefficient.user_name=salary_users.service_user_name
             left join
             --当月设置系数
             (
             select
             user_id,target
             from
             (
             select user_id,target,row_number() over (partition by user_id order by create_time) as rn
             from dwd_kpi_indicator_target_d
             where dayid = '$v_date'
             and is_deleted=0
             and substr(create_time,1,6)='$v_cur_month'
             ) sales_coefficient
             where rn=1
             ) user_target on user_target.user_id=salary_users.service_user_id
             --取dep_2name省区和dep_3name战区
             left join
             (
             select user_id,dep_id,dep_1name,dep_2name,dep_3name
             from dim_employee_dep_d
             where dayid='$v_date'
             group by user_id,dep_id,dep_1name,dep_2name,dep_3name
             ) dept on salary_users.service_user_id = dept.user_id
     ) salary_summary