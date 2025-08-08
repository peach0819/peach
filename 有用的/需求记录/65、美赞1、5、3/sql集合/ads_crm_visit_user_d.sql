with user_admin as (
    SELECT user_id,
           user_real_name,
           dept_id
    FROM p_mdson.dim_user_d
    WHERE dayid = '${v_date}'
    AND user_status = 1
),

dept as (
    SELECT id,
           concat(root_key, id) as root_key,
           charger
    FROM p_mdson.dwd_department_d
    WHERE dayid = '${v_date}'
),

root_dept as (
    SELECT id,
           root_key,
           dept_id,
           charger,
           row_number() over(partition by id) as cnt
    FROM dept
    LATERAL VIEW explode(split(root_key, '_')) dept_id AS dept_id
),

root_user as (
    SELECT user_admin.user_id,
           user_admin.user_real_name,
           base_dept.root_key,
           root_dept.dept_id,
           root_dept.cnt,
           dept.charger,
           charger.user_real_name as charger_name
    FROM user_admin
    LEFT JOIN dept base_dept ON user_admin.dept_id = base_dept.id
    LEFT JOIN root_dept ON user_admin.dept_id = root_dept.id
    LEFT JOIN dept ON root_dept.dept_id = dept.id
    LEFT JOIN user_admin charger ON dept.charger = charger.user_id
)

INSERT OVERWRITE TABLE ads_crm_visit_user_d PARTITION (dayid = '${v_date}')
SELECT user_id,
       user_real_name,
       root_key as user_dept_root_key,
       if(
           count(if(user_id != charger, 1, null)) > 0,
           concat(p_mdson.MapValueSorter(map_agg(if(user_id != charger, charger, NULL), cnt), 'asc'), '_', user_id),
           user_id
       ) as user_root_key,
       if(
           count(if(user_id != charger, 1, null)) > 0,
           concat(p_mdson.MapValueSorter(map_agg(if(user_id != charger, charger_name, NULL), cnt), 'asc'), '_', user_real_name),
           user_real_name
       ) as user_name_root_key,
       p_mdson.MapValueSorter(map_agg(if(user_id != charger, charger, NULL), cnt), 'asc') AS user_parent_root_key,
	   p_mdson.MapValueSorter(map_agg(if(user_id != charger, charger_name, NULL), cnt), 'asc') AS user_name_parent_root_key
FROM root_user
group by user_id,
         user_real_name,
         root_key
