use ytdw;
CREATE TABLE if not exists ytdw.ads_crm_subject_item_by_brand_h (
  subject_id string comment '项目id',
  item_id string comment '商品id'
)
  comment '项目根据品牌计算对应商品范围'
  partitioned by (dayid string)
stored as orc;

with
all_item as(
  select id as item_id,item_style,category_id_first,item_type, brand as brand_id
  from rtdw.ods_vf_t_item
  where inuse=1 and bu_id=0 --and dc_id=0
),

-- 包含品牌
subject_include_brand as (
  select subject_main.id as subject_id,all_item.item_id from (
    select id,
      case feature_type when 1 then 1 else 0 end as item_style
    from rtdw.ods_vf_t_p0_subject
    where is_deleted=0 and status=1
  ) subject_main
  join (
    select subject_id, item_style, brand_id
    from rtdw.ods_vf_t_p0_subject_item
      lateral view explode(split(biz_ids,',')) num as brand_id
    where is_deleted=0
      and object_type=1 and include_flag=1
  ) subject_brand
  on subject_main.id=subject_brand.subject_id
  join all_item
  on subject_main.item_style=subject_brand.item_style
    and all_item.brand_id=subject_brand.brand_id
),
-- 不包含品牌范围
subject_exclude_brand as (
  select subject_main.id as subject_id,all_item.item_id from (
    select id,
      case feature_type when 1 then 1 else 0 end as item_style
    from rtdw.ods_vf_t_p0_subject
    where is_deleted=0 and status=1
  ) subject_main
  join(
      select subject_id
      from rtdw.ods_vf_t_p0_subject_item
      where is_deleted=0
        and object_type=1 and include_flag=2
      group by subject_id
  ) exclude_subject
  on subject_main.id=exclude_subject.subject_id
  join all_item
  on subject_main.item_style=all_item.item_style
  left join (
    select subject_id, item_style, brand_id
    from rtdw.ods_vf_t_p0_subject_item
      lateral view explode(split(biz_ids,',')) num as brand_id
    where is_deleted=0
      and object_type=1 and include_flag=2
  ) subject_brand
  on subject_main.id=subject_brand.subject_id
    and all_item.brand_id=subject_brand.brand_id
  where subject_brand.subject_id is null
),

  -- 未配置品牌范围
subject_not_exist_brand as(
  select subject_item_style.subject_id, all_item.item_id
  from(
    select subject_main.id as subject_id, item_style from (
      select id, case feature_type when 1 then 1 else 0 end as item_style
      from rtdw.ods_vf_t_p0_subject
      where is_deleted=0 and status=1
    ) subject_main
    left join (
      select subject_id
      from rtdw.ods_vf_t_p0_subject_item
      where is_deleted=0
        and object_type=1
      group by subject_id
    ) subject_brand
    on subject_main.id=subject_brand.subject_id
    where subject_brand.subject_id is null
  ) subject_item_style
  join all_item
  on subject_item_style.item_style=all_item.item_style
)

insert overwrite table ytdw.ads_crm_subject_item_by_brand_h partition (dayid='$v_date')

select subject_id, item_id
from subject_include_brand
union all
select subject_id, item_id
from subject_exclude_brand
union all
select subject_id, item_id
from subject_not_exist_brand



