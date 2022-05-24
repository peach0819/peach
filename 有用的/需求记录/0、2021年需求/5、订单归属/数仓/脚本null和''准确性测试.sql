

SELECT
       case when get_json_object(result_data, '$.no_channel') = 'true'
                then '无归属'
            when get_json_object(result_data, '$.user_id') != null
                then get_json_object(result_data, '$.user_id')
            when (get_json_object(result_data, '$.user_feature') != null
                 and get_json_object(result_data, '$.user_feature') = '0')
                then '服务商经理'
            when get_json_object(result_data, '$.user_feature') != null
                then '门店职能'
            else '没结果'
            end as result_user_id,
       result_data,
       get_json_object(result_data, '$.user_feature') as feature,
       case when get_json_object(result_data, '$.user_feature') = '1' then '真' else '假' end as test1,
       case when get_json_object(result_data, '$.user_feature') = 1 then '真' else '假' end as test2,
       case when get_json_object(result_data, '$.user_feature') != ''  then '真' else '假' end as test3,
        case when (get_json_object(result_data, '$.user_feature') != null and get_json_object(result_data, '$.user_feature') = '1') then '真' else '假' end as test4

       FROM (
SELECT '{"user_feature":"1","ruleId":"11"}' as result_data

       ) rule_execute_result