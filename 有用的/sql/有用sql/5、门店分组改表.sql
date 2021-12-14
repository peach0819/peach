SELECT shop_id,
           concat_ws(',' , sort_array(collect_set(cast(group_id as string)))) as group_id
    FROM (
        SELECT shop_id, group_id
        FROM dwd_shop_group_mapping_d
        WHERE dayid='$v_date'
        AND is_deleted = 0
        AND biz_type = 8 --仅门店圈选

        UNION ALL

        SELECT shop_id, group_id
        FROM dwd_rule_group_shop_mapping_d
        WHERE dayid = '$v_date'
        and inuse = 1
        AND is_deleted = 0
    ) union_shop_group
    group by shop_id

--测试重复sql
 with new as (
 SELECT shop_id, group_id
        FROM dwd_rule_group_shop_mapping_d
        WHERE dayid = '$v_date'
        and inuse = 1
        AND is_deleted = 0
 ),
 old as (
        SELECT shop_id, group_id
        FROM dwd_shop_group_mapping_d
        WHERE dayid='$v_date'
        AND is_deleted = 0
        AND biz_type = 8 --仅门店圈选
 )

 SELECT * FROM old INNER JOIN new ON old.shop_id = new.shop_id and old.group_id = new.group_id