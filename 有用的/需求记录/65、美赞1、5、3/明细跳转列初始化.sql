
INSERT INTO t_crm_visit_indicator(`id`, `creator`, `editor`, `indicator_code`, `indicator_name`, `indicator_unit`, `indicator_type`, `indicator_display_type`)
VALUES (120, 'system', 'system', 'month_visit_freq_valid_rate', '门店拜访频次达成率', '%', 1, 'ratio'),
       (121, 'system', 'system', 'month_nka_nc_visit_valid_rate', 'NKA专职NC门店拜访达成率', '%', 1, 'ratio'),
       (122, 'system', 'system', 'month_rka_nc_visit_valid_rate', 'RKA专职NC门店拜访达成率', '%', 1, 'ratio'),
       (123, 'system', 'system', 'month_hospital_visit_valid_rate', '院线店拜访达成率', '%', 1, 'ratio'),
       (124, 'system', 'system', 'month_shop_visit_valid_rate', '门店拜访覆盖率', '%', 1, 'ratio'),
       (125, 'system', 'system', 'month_fws_visit_valid_rate', '月度服务商拜访达成率', '%', 1, 'ratio'),
       (126, 'system', 'system', 'quar_fws_visit_valid_rate', '季度服务商拜访达成率', '%', 1, 'ratio'),
       (127, 'system', 'system', 'month_gt_shop_visit_valid_rate', '月度GT渠道门店拜访覆盖率', '%', 1, 'ratio'),
       (128, 'system', 'system', 'quar_gt_shop_visit_valid_rate', '季度GT渠道门店拜访覆盖率', '%', 1, 'ratio');

--当月拜访人员达标率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "detailColumnList": [
    {
      "code": "reach",
      "name": "是否达标"
    }
  ]
}'
WHERE id = 101;

--门店拜访频次达成率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "numerator",
      "name": "已拜访频次"
    },
    {
      "code": "denominator",
      "name": "目标拜访频次"
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
WHERE id = 120;

--NKA专职NC门店拜访达成率、RKA专职NC门店拜访达成率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "numerator",
      "name": "已达标门店数"
    },
    {
      "code": "denominator",
      "name": "目标拜访门店数"
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
WHERE id IN (121, 122);

--院线店拜访达成率、门店拜访覆盖率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "numerator",
      "name": "已拜访门店数"
    },
    {
      "code": "denominator",
      "name": "名下门店数"
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
WHERE id IN (123, 124);

--月度服务商拜访达成率、季度服务商拜访达成率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "numerator",
      "name": "已拜访服务商数"
    },
    {
      "code": "denominator",
      "name": "名下服务商数"
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
WHERE id IN (125, 126);

--月度GT渠道门店拜访覆盖率、季度GT渠道门店拜访覆盖率
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "numerator",
      "name": "已拜访门店数"
    },
    {
      "code": "denominator",
      "name": "名下门店数"
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
WHERE id IN (127, 128);
