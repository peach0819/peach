

with t as (
    SELECT
        '$v_date' as update_deadline,--数据更新时间
        grant_object_user_id, --BD
        user_real_name,  --BD名
        service_job_name,
        service_feature_name,
        area_trans.department_name,--主管辖区
        shop_supervisor_name,--主管
        shop_region_dept_name,--省区
        shop_region_manager_name,--省长
        shop_theater_dept_name,--战区
        shop_theater_manager_name,--战长
        count(DISTINCT if(compare_brand_shop_num>0, shop_service1.shop_id, null)) as compare_shop_num, --期初有效下单门店数
        count(DISTINCT if(current_brand_shop_num>0, shop_service1.shop_id, null)) as current_shop_num, --期末有效下单门店数
        round(count(DISTINCT if(current_brand_shop_num>0, shop_service1.shop_id, null))/count(DISTINCT if(compare_brand_shop_num>0, shop_service1.shop_id, null)),4) as ratio,
        sum(compare_brand_shop_num) as  compare_brand_shop_num,  --期初分
        sum(current_brand_shop_num) as  current_brand_shop_num,  --期末分
        sum(brand_shop_score) as brand_shop_score,  -- 多品进店积分
        sum(current_brand_shop_num)-sum(compare_brand_shop_num)-sum(brand_shop_score) as without_0_1_num, --剔除0到1的有效品牌数（期末分-期初分-得分）
        case when sum(brand_shop_score)>0 and sum(brand_shop_score) <= 10 then 30
             when sum(brand_shop_score)>10  and sum(brand_shop_score) <= 20 then 50
             when sum(brand_shop_score)>20 then 80 end as every_reward
    FROM (
        SELECT *
        FROM dw_salary_brand_shop_sum_d
        WHERE dayid = '$v_date'
        AND pltype = 'cur'
        AND planno = 14716
    ) brand_shop_sum

    LEFT JOIN (
        SELECT *
        FROM dim_hpc_pub_user_admin
    ) admin ON brand_shop_sum.grant_object_user_id = admin.user_id

    --取人员门店、部门岗位,部门,职能等
    left join (
        select shop_id,
               split(ytdw.get_service_info('service_type:销售',shop_service_info,'service_user_id'),',')[0] as service_user_id,
               split(ytdw.get_service_info('service_type:销售',shop_service_info,'service_user_name'),',')[0] as service_user_name ,
               split(ytdw.get_service_info('service_type:销售',shop_service_info,'service_department_name'),',')[0] as department_name,
               split(ytdw.get_service_info('service_type:销售',shop_service_info,'service_job_name'),',')[0] as service_job_name,
               split(ytdw.get_service_info('service_type:销售',shop_service_info,'service_feature_name'),',')[0] as service_feature_name
        from ytdw.dim_ytj_shp_shop_service_d
        where dayid='$v_date'
        and split(ytdw.get_service_info('service_type:销售',shop_service_info,'service_feature_name'),',')[0] in ('BD')
        and split(ytdw.get_service_info('service_type:销售',shop_service_info,'service_feature_name'),',')[0] is not null
    ) shop_service1 on brand_shop_sum.grant_object_user_id=shop_service1.service_user_id

    --门店维表，取门店信息
    left join (
        select * from ytdw.dim_ytj_shp_shop_d where dayid='$v_date'
    ) shp_shop on shp_shop.shop_id=shop_service1.shop_id

    --大区主管及战区信息
    left join (
        select bd_manager_dep_name as department_name,--主管辖区
               bd_manager_name as shop_supervisor_name,--主管
               area_manager_dep_name as shop_region_dept_name,--省区
               area_manager_name as shop_region_manager_name,--省长
               war_zone_dep_name as shop_theater_dept_name,--战区
               war_zone_name as shop_theater_manager_name,--战长
               *
        from ytdw.dw_sales_achievement_area_trans_d where dayid='$v_date'
    ) area_trans on area_trans.pro_area_id = shp_shop.shop_prov_id
                 and area_trans.city_area_id = shp_shop.shop_city_id
                 and area_trans.area_id = shp_shop.shop_area_id
                 and area_trans.address_area_id=shp_shop.shop_street_id

    group by     grant_object_user_id, --BD
                 user_real_name,  --BD名
                 service_job_name,
                 service_feature_name,
                 area_trans.department_name,--主管辖区
                 shop_supervisor_name,--主管
                 shop_region_dept_name,--省区
                 shop_region_manager_name,--省长
                 shop_theater_dept_name,--战区
                 shop_theater_manager_name--战长
)

select update_deadline,
       grant_object_user_id,
       user_real_name,
       service_job_name,
       service_feature_name,
       department_name,--主管辖区
       shop_supervisor_name,--主管
       shop_region_dept_name,--省区
       shop_region_manager_name,--省长
       shop_theater_dept_name,--战区
       shop_theater_manager_name,--战长
       compare_shop_num,
       current_shop_num,
       ratio,
       case when ratio >= 0.8 then '是' else '否' end as if_not,
       compare_brand_shop_num,
       current_brand_shop_num,
       brand_shop_score,
       without_0_1_num,
       nvl(every_reward, 0)                         as every_reward,
       case when nvl(every_reward, 0) * brand_shop_score >= 6000 and ratio >= 0.8 then 6000
            when nvl(every_reward, 0) * brand_shop_score >= 0 and ratio >= 0.8 then nvl(every_reward, 0) * brand_shop_score
            else 0 end as total_reward
from t