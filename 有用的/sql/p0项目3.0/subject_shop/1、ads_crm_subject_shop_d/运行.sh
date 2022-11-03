v_date=$1

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;

CREATE TABLE if not exists ads_crm_subject_shop_d (
    subject_id       bigint comment '项目id',
    shop_id          string comment '门店id',
    shop_name        string comment '门店名称',
    province_id      string comment '省份id',
    city_id          string comment '市id',
    area_id          string comment '区id',
    address_id       string comment '街道id',
    user_id          string comment '服务人员',
    dept_id          bigint comment '服务人员所属部门',
    parent_dept_id   bigint comment '服务人员所属部门上级',
    parent_2_dept_id bigint comment '服务人员所属部门上2级',
    latitude         string comment '纬度',
    longitude        string comment '经度'
) comment '项目门店数据表'
partitioned by (dayid string)
stored as orc;

with subject as (
    SELECT subject.id,
           subject.subject_name,
           subject.object_shop_type,
           subject.shop_cluster_id,
           if(subject.refresh_type = 0, log.create_date, '$v_date') as refresh_date,
           subject.feature_type
    FROM (
        SELECT id,
               subject_name,
               object_shop_type,
               shop_cluster_id,
               refresh_type,
               case when feature_type = 1 AND (nvl(group_type, 0) = 0 OR group_type = 3) then 'bd'
                    when feature_type = 1 AND group_type = 4 then 'cbd'
                    when feature_type = 2 AND (nvl(group_type, 0) = 0 OR group_type = 1) then 'ts'
                    when feature_type = 2 AND group_type = 2 then 'vs'
               end as feature_type
        FROM dwd_p0_subject_d
        WHERE dayid = '$v_date'
        AND status = 1
    ) subject
    LEFT JOIN (
        SELECT biz_id as subject_id,
               substr(create_time, 0, 8) as create_date
        FROM dwd_crm_log_d
        WHERE dayid = '$v_date'
        AND biz_type = 'P0_SUBJECT'
        AND operation_type = 'PUBLISH'
    ) log ON subject.id = log.subject_id
),

shop_user as (
    SELECT feature_type,
           shop_id,
           shop_name,
           province_id,
           city_id,
           area_id,
           address_id,
           user_id,
           dept_id,
           parent_dept_id,
           parent_2_dept_id,
           latitude,
           longitude
    FROM ads_crm_shop_user_d
    WHERE dayid = '$v_date'
),

shop_group as (
    SELECT group_id,
           shop_id,
           dayid
    FROM ads_dmp_group_data_d
    WHERE dayid > '0'
),

--门店统计范围为 指定圈选 的项目
with_dmp as (
    SELECT subject.id as subject_id,
           shop_user.shop_id,
           shop_user.shop_name,
           shop_user.province_id,
           shop_user.city_id,
           shop_user.area_id,
           shop_user.address_id,
           shop_user.user_id,
           shop_user.dept_id,
           shop_user.parent_dept_id,
           shop_user.parent_2_dept_id,
           shop_user.latitude,
           shop_user.longitude
    FROM subject
    INNER JOIN shop_user ON subject.feature_type = shop_user.feature_type
    INNER JOIN shop_group ON subject.refresh_date = shop_group.dayid AND subject.shop_cluster_id = shop_group.group_id AND shop_user.shop_id = shop_group.shop_id
    WHERE subject.object_shop_type = 2
),

--门店统计范围为 所有门店 的项目
without_dmp as (
    SELECT subject.id as subject_id,
           shop_user.shop_id,
           shop_user.shop_name,
           shop_user.province_id,
           shop_user.city_id,
           shop_user.area_id,
           shop_user.address_id,
           shop_user.user_id,
           shop_user.dept_id,
           shop_user.parent_dept_id,
           shop_user.parent_2_dept_id,
           shop_user.latitude,
           shop_user.longitude
    FROM subject
    INNER JOIN shop_user ON subject.feature_type = shop_user.feature_type
    WHERE subject.object_shop_type = 1
)

INSERT OVERWRITE TABLE ads_crm_subject_shop_d partition (dayid='$v_date')
SELECT * FROM with_dmp
UNION ALL
SELECT * FROM without_dmp
;
"