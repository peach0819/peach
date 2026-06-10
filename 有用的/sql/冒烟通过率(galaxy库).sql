SELECT a.deptFullName, --a.realName,
       sum(if(a.verify_result = "Pass", a.num, 0)) as pass,
       sum(if(a.verify_result = "Fail", a.num, 0)) as fail,
       sum(if(a.verify_result = "Block", a.num, 0)) as block,
       sum(if(a.verify_result IS NULL, a.num, 0)) as notrun,
       sum(a.num) as total,
       (sum(if(a.verify_result = "Pass", a.num, 0)) + sum(if(a.verify_result = "Block", a.num, 0))) / (sum(a.num) - sum(if(a.verify_result IS NULL, a.num, 0))) * 100 as rate
FROM (
    SELECT m.deptFullName,
           m.realName,
           m.verify_result,
           count(1) as num
    FROM (
        SELECT tcl.id,
               tcl.verify_result,
               au.deptFullName,
               au.realName
        FROM test_case_executor tce
        INNER JOIN admin_user au ON tce.`executor_id` = au.userId
        INNER JOIN test_case_laboratory tcl ON tce.lab_id = tcl.id
        INNER JOIN test_case_record tcr ON tcl.record_id = tcr.id
        WHERE tcr.is_deleted = 0
        AND tcl.is_deleted = 0
        AND au.deptFullName LIKE "%商品%"
        AND tce.gmt_create >= "2021-07-01 00:00:00"
        AND tce.gmt_create < "2022-01-01 00:00:00"
    ) as m
    GROUP BY m.realName,
             m.verify_result
) as a --GROUP BY a.realName
GROUP BY a.deptFullName