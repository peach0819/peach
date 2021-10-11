WITH detail as (
    SELECT id,
           no,
           name,
           remark,
           biz_group_id,
           biz_group_name,
           month,
           bounty_payout_object_id,
           bounty_rule_type,
           bounty_indicator_id,
           filter_config_json,
           payout_rule_type,
           payout_config_json,
           coefficient_config_json,
           payout_upper_limit,
           last_edit_time,
           creator,
           editor,
           create_time,
           edit_time,
           is_deleted,
           subject_id,
           owner_type,
           get_json_object(filter_config, '$.id') as filter_id,
           get_json_object(filter_config, '$.operator') as filter_operator,
           get_json_object(filter_config, '$.values') as filter_values
    FROM (
        SELECT *
        FROM dwd_bounty_plan_d
        lateral view explode(split(regexp_replace(substr(filter_config_json, 2, length(filter_config_json) - 2), '\},','\}\;'), '\;')) tmp as filter_config
        WHERE dayid = '$v_date'
    ) temp
),

filter as (
    SELECT id as filter_id,
           key as filter_key
    FROM dwd_bounty_filter_d
    WHERE dayid = '$v_date'
),

mid as (
    SELECT detail.id,
           detail.no,
           detail.name,
           detail.remark,
           detail.biz_group_id,
           detail.biz_group_name,
           detail.month,
           detail.bounty_payout_object_id,
           detail.bounty_rule_type,
           detail.bounty_indicator_id,
           detail.filter_config_json,
           detail.payout_rule_type,
           detail.payout_config_json,
           detail.coefficient_config_json,
           detail.payout_upper_limit,
           detail.last_edit_time,
           detail.creator,
           detail.editor,
           detail.create_time,
           detail.edit_time,
           detail.is_deleted,
           detail.subject_id,
           detail.owner_type,
           filter.filter_key,
           detail.filter_operator,
           detail.filter_values,
           named_struct('operator', detail.filter_operator, 'values', filter_values) as filter_struct
    FROM detail
    INNER JOIN filter ON detail.filter_id = filter.filter_id
)

SELECT id,
       filter_key,
       filter_operator,
       filter_values,
       filter_struct
FROM mid