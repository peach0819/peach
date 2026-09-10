-- 当季COT/KA门店拜访覆盖率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "denominator",
      "name": "拜访对象数"
    },
    {
      "code": "numerator",
      "name": "已拜访对象数"
    },
    {
      "code": "indicator",
      "name": "季度达成率"
    },
    {
      "code": "reach",
      "name": "季度是否达标"
    }
  ],
  "detailColumnList": [
    {
      "code": "service_obj_id",
      "name": "拜访对象编码"
    },
    {
      "code": "service_obj_name",
      "name": "拜访对象名称"
    },
    {
      "code": "indicator",
      "name": "季度覆盖次数"
    }
  ]
}'
WHERE id = 148;

-- 当季GT星级门店拜访覆盖率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "denominator",
      "name": "拜访对象数"
    },
    {
      "code": "numerator",
      "name": "已拜访对象数"
    },
    {
      "code": "indicator",
      "name": "季度达成率"
    },
    {
      "code": "reach",
      "name": "季度是否达标"
    }
  ],
  "detailColumnList": [
    {
      "code": "service_obj_id",
      "name": "拜访对象编码"
    },
    {
      "code": "service_obj_name",
      "name": "拜访对象名称"
    },
    {
      "code": "indicator",
      "name": "季度覆盖次数"
    }
  ]
}'
WHERE id = 149;