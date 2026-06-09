-- 当月拜访频次达标率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "denominator",
      "name": "目标拜访频次"
    },
    {
      "code": "numerator",
      "name": "已拜访频次"
    },
    {
      "code": "indicator",
      "name": "达成率"
    },
    {
      "code": "reach",
      "name": "是否达标"
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
      "name": "覆盖次数"
    },
    {
      "code": "reach",
      "name": "是否达标"
    }
  ]
}'
WHERE id = 140;

-- 当月专职NC门店拜访达成率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "denominator",
      "name": "名下门店数"
    },
    {
      "code": "numerator",
      "name": "已拜访门店数"
    },
    {
      "code": "indicator",
      "name": "达成率"
    },
    {
      "code": "reach",
      "name": "是否达标"
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
      "code": "target",
      "name": "目标覆盖次数"
    },
    {
      "code": "indicator",
      "name": "覆盖次数"
    },
    {
      "code": "reach",
      "name": "是否达标"
    }
  ]
}'
WHERE id = 141;

--当月服务商拜访达成率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "denominator",
      "name": "目标拜访服务商数"
    },
    {
      "code": "numerator",
      "name": "已达标服务商数"
    },
    {
      "code": "indicator",
      "name": "达成率"
    },
    {
      "code": "reach",
      "name": "是否达标"
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
      "name": "覆盖次数"
    }
  ]
}'
WHERE id = 142;

-- 当季服务商拜访覆盖率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "denominator",
      "name": "名下服务商数"
    },
    {
      "code": "numerator",
      "name": "已拜访服务商数"
    },
    {
      "code": "indicator",
      "name": "达成率"
    },
    {
      "code": "reach",
      "name": "是否达标"
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
      "name": "覆盖次数"
    }
  ]
}'
WHERE id = 143;

-- 当月星级门店拜访达成率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "denominator",
      "name": "名下门店数"
    },
    {
      "code": "numerator",
      "name": "已拜访门店数"
    },
    {
      "code": "indicator",
      "name": "达成率"
    },
    {
      "code": "reach",
      "name": "是否达标"
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
      "code": "target",
      "name": "目标覆盖次数"
    },
    {
      "code": "indicator",
      "name": "覆盖次数"
    },
    {
      "code": "reach",
      "name": "是否达标"
    }
  ]
}'
WHERE id = 144;

-- 当月门店拜访达成率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "denominator",
      "name": "目标拜访门店数"
    },
    {
      "code": "numerator",
      "name": "已拜访门店数"
    },
    {
      "code": "indicator",
      "name": "达成率"
    },
    {
      "code": "reach",
      "name": "是否达标"
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
      "name": "覆盖次数"
    }
  ]
}'
WHERE id = 145;

-- 当季全渠道重点门店拜访覆盖率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "denominator",
      "name": "名下门店数"
    },
    {
      "code": "numerator",
      "name": "已拜访门店数"
    },
    {
      "code": "indicator",
      "name": "达成率"
    },
    {
      "code": "reach",
      "name": "是否达标"
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
      "name": "覆盖次数"
    }
  ]
}'
WHERE id = 146;

-- 当月院线店拜访达成率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "denominator",
      "name": "名下门店数"
    },
    {
      "code": "numerator",
      "name": "已拜访门店数"
    },
    {
      "code": "indicator",
      "name": "达成率"
    },
    {
      "code": "reach",
      "name": "是否达标"
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
      "code": "target",
      "name": "目标覆盖次数"
    },
    {
      "code": "indicator",
      "name": "覆盖次数"
    },
    {
      "code": "reach",
      "name": "是否达标"
    }
  ]
}'
WHERE id = 147;
