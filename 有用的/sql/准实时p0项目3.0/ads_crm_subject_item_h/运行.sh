v_date=$1

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;
CREATE TABLE if not exists ads_crm_subject_item_h (
  subject_id string comment '项目id',
  item_id string comment '商品id'
)
comment '项目对应的商品范围'
partitioned by (dayid string)
stored as orc;

WITH all_item AS (
    select item_style,
           cast(id as string) as item_id,
           cast(category_id_first as string) as category_id_first,
           cast(item_type as string) as item_type,
           cast(brand as string) as brand_id
    from rtdw.ods_vf_t_item
    where inuse = 1
    and bu_id = 0
),

subject as (
    SELECT id,
           feature_type
    FROM rtdw.ods_vf_t_p0_subject
    WHERE status = 1
    AND is_deleted = 0
),

subject_item as (
    SELECT subject_id,
           collect_list(if(object_type = 1, to_json(named_struct('include_flag', include_flag, 'biz_ids', biz_ids)), null)) as filter_brand,
           collect_list(if(object_type = 2, to_json(named_struct('include_flag', include_flag, 'biz_ids', biz_ids)), null)) as filter_item,
           collect_list(if(object_type = 3, to_json(named_struct('include_flag', include_flag, 'biz_ids', biz_ids)), null)) as filter_category,
           collect_list(if(object_type = 4, to_json(named_struct('include_flag', include_flag, 'biz_ids', biz_ids)), null)) as filter_item_type
    FROM rtdw.ods_vf_t_p0_subject_item
    WHERE is_deleted = 0
    group by subject_id
),

--用作主表，表示一个项目下的筛选条件
subject_main as (
    SELECT subject.id,
           if(subject.feature_type = 1, 1, 0) as item_style,
           get_json_object(subject_item.filter_brand[0], '$.biz_ids') as filter_brand_ids,
           get_json_object(subject_item.filter_brand[0], '$.include_flag') as filter_brand_include_flag,
           get_json_object(subject_item.filter_item[0], '$.biz_ids') as filter_item_ids,
           get_json_object(subject_item.filter_item[0], '$.include_flag') as filter_item_include_flag,
           get_json_object(subject_item.filter_category[0], '$.biz_ids') as filter_category_ids,
           get_json_object(subject_item.filter_category[0], '$.include_flag') as filter_category_include_flag,
           get_json_object(subject_item.filter_item_type[0], '$.biz_ids') as filter_item_type_ids,
           get_json_object(subject_item.filter_item_type[0], '$.include_flag') as filter_item_type_include_flag
    FROM subject
    LEFT JOIN subject_item ON subject.id = subject_item.subject_id
)

INSERT OVERWRITE TABLE ads_crm_subject_item_h partition (dayid='$v_date')
SELECT subject_main.id as subject_id,
       all_item.item_id
FROM subject_main
CROSS JOIN all_item ON subject_main.item_style = all_item.item_style
WHERE (subject_main.filter_brand_include_flag is null OR subject_main.filter_brand_include_flag = if(array_contains(split(subject_main.filter_brand_ids, ','), all_item.brand_id), 1, 2))
AND (subject_main.filter_item_include_flag is null OR subject_main.filter_item_include_flag = if(array_contains(split(subject_main.filter_item_ids, ','), all_item.item_id), 1, 2))
AND (subject_main.filter_category_include_flag is null OR subject_main.filter_category_include_flag = if(array_contains(split(subject_main.filter_category_ids, ','), all_item.category_id_first), 1, 2))
AND (subject_main.filter_item_type_include_flag is null OR subject_main.filter_item_type_include_flag = if(array_contains(split(subject_main.filter_item_type_ids, ','), all_item.item_type), 1, 2))
"