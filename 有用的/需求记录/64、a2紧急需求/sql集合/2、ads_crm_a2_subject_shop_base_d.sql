with subject as (
    SELECT subject_id,
           subject_name,
           subject_desc,
           subject_status,
           subject_type,
           subject_month,
           subject_start_time,
           subject_end_time,
           dmp_id,
           need_stats,
           shop_type
    FROM yt_crm.ads_crm_a2_subject_base_d
    WHERE dayid = '${v_date}'
),

dmp_data as (
    SELECT group_id,
           shop_id
    FROM ytdw.ads_dmp_group_data_d
    WHERE dayid = DATE_FORMAT(DATE_SUB(CURRENT_DATE, 1), 'yyyyMMdd')  --这里永远取最新的分区数据
),

shop_base as (
    SELECT shop_id,
           shop_num as shop_code,
           shop_name,
           shop_pro_id as province_id,
           shop_pro_name as province_name,
           shop_city_id as city_id,
           shop_city_name as city_name,
           shop_area_id as area_id,
           shop_area_name as area_name,
           shop_address_id as street_id,
           shop_address_name as street_name
    FROM ytdw.dw_shop_base_d
    WHERE dayid = DATE_FORMAT(DATE_SUB(CURRENT_DATE, 1), 'yyyyMMdd')  --这里永远取最新的分区数据
),

ord as (
    SELECT shop_id,
           imf_order_spec_count
    FROM yt_biz.ads_brand_a2_shop_stats_data_d
    WHERE dayid = '${v_date}'
),

pool_server as (
    SELECT shop_id,
           user_id
    FROM ytdw.dwd_shop_pool_server_d
    WHERE dayid = DATE_FORMAT(DATE_SUB(CURRENT_DATE, 1), 'yyyyMMdd')  --这里永远取最新的分区数据
    AND is_deleted = 0
    AND is_enabled = 1
    AND group_id IN (2,6,7)
),

user as (
    SELECT id,
           user_id,
           user_real_name
    FROM ytdw.dwd_user_d
    WHERE dayid = DATE_FORMAT(DATE_SUB(CURRENT_DATE, 1), 'yyyyMMdd')
),

visit as (
    SELECT object_id as shop_id,
           count(case when record_type = 3 then 1 else null end) as bd_visit_count,
           count(case when record_type = 3 AND visit_mode = 1 then 1 else null end) as bd_valid_visit_count,
           count(case when record_type = 4 then 1 else null end) as sale_visit_count,
           count(case when record_type = 4 AND visit_mode = 1 then 1 else null end) as sale_valid_visit_count
    FROM ytdw.dwd_visit_record_d
    WHERE dayid = DATE_FORMAT(DATE_SUB(CURRENT_DATE, 1), 'yyyyMMdd')
    AND record_type IN (3, 4)  --3BD拜访 4电销拜访
    AND substr(visit_time, 1, 6) = substr('${v_date}', 1, 6)
    group by object_id
),

shop as (
    SELECT shop_base.shop_id,
           shop_base.shop_code,
           shop_base.shop_name,
           shop_base.province_id,
           shop_base.province_name,
           shop_base.city_id,
           shop_base.city_name,
           shop_base.area_id,
           shop_base.area_name,
           shop_base.street_id,
           shop_base.street_name,
           pool_server.user_id as sale_id,
           user.user_real_name as sale_name,
           user.id as sale_user_id,
           nvl(visit.bd_visit_count, 0) as bd_visit_count,
           nvl(visit.bd_valid_visit_count, 0) as bd_valid_visit_count,
           nvl(visit.sale_visit_count, 0) as sale_visit_count,
           nvl(visit.sale_valid_visit_count, 0) as sale_valid_visit_count,
           nvl(ord.imf_order_spec_count, 0) as offtake
    FROM shop_base
    LEFT JOIN pool_server ON shop_base.shop_id = pool_server.shop_id
    LEFT JOIN user ON pool_server.user_id = user.user_id
    LEFT JOIN visit ON shop_base.shop_id = visit.shop_id
    LEFT JOIN ord ON shop_base.shop_id = ord.shop_id
),

cur as (
    SELECT subject.subject_id,
           subject.subject_type,
           case when subject.subject_type = '新签' then 1
                when subject.subject_type = '复购' then 2
                end as subject_type_id,
           subject.subject_month,
           subject.need_stats,
           subject.shop_type,
           dmp_data.shop_id,
           shop.shop_code,
           shop.shop_name,
           shop.province_id,
           shop.province_name,
           shop.city_id,
           shop.city_name,
           shop.area_id,
           shop.area_name,
           shop.street_id,
           shop.street_name,
           shop.sale_id,
           shop.sale_name,
           shop.sale_user_id,
           if(case when subject.subject_type = '新签' then shop.bd_visit_count
                   when subject.subject_type = '复购' then shop.sale_visit_count
                   end > 0, 1, 0) as has_visit,
           if(case when subject.subject_type = '新签' then shop.bd_valid_visit_count
                   when subject.subject_type = '复购' then shop.sale_valid_visit_count
                   end > 0, 1, 0) as has_valid_visit,
           if(case when subject.subject_type = '新签' then shop.bd_valid_visit_count
                   when subject.subject_type = '复购' then shop.sale_valid_visit_count
                   end > 0, if(shop.offtake > 0, 1, 0), 0) as has_order,
           if(case when subject.subject_type = '新签' then shop.bd_valid_visit_count
                   when subject.subject_type = '复购' then shop.sale_valid_visit_count
                   end > 0, shop.offtake, 0) as offtake
    FROM subject
    INNER JOIN dmp_data ON dmp_data.group_id = subject.dmp_id
    INNER JOIN shop ON dmp_data.shop_id = shop.shop_id
)

INSERT OVERWRITE TABLE ads_crm_a2_subject_shop_base_d PARTITION (dayid = '${v_date}')
SELECT subject_id,
       subject_type,
       subject_type_id,
       subject_month,
       need_stats,
       shop_type,
       shop_id,
       shop_code,
       shop_name,
       province_id,
       province_name,
       city_id,
       city_name,
       area_id,
       area_name,
       street_id,
       street_name,
       sale_id,
       sale_name,
       sale_user_id,
       if(need_stats = 0, 0, has_visit) as has_visit,
       if(need_stats = 0, 0, has_valid_visit) as has_valid_visit,
       if(need_stats = 0, 0, has_order) as has_order,
       if(need_stats = 0, 0, offtake) as offtake
FROM cur
