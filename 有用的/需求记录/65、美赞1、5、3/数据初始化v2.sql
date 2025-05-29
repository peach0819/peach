--删除原先的院线店拜访
DELETE FROM t_crm_visit_indicator WHERE id = 123;
DELETE FROM t_crm_visit_indicator_visible_v2 WHERE indicator_id = 123;

--新增三个院线店拜访指标
INSERT INTO t_crm_visit_indicator(`id`, `creator`, `editor`, `indicator_code`, `indicator_name`, `indicator_unit`, `indicator_type`, `indicator_display_type`)
VALUES (129, 'system', 'system', 'month_gt_hospital_shop_visit_valid_rate', '月度GT渠道院线店拜访覆盖率', '%', 1, 'ratio'),
       (130, 'system', 'system', 'quar_gt_hospital_shop_visit_valid_rate', '季度GT渠道院线店拜访覆盖率', '%', 1, 'ratio'),
       (131, 'system', 'system', 'month_hospital_visit_valid_rate', '院线店拜访覆盖率', '%', 1, 'ratio');

--月度GT渠道院线店拜访覆盖率
INSERT INTO t_crm_visit_indicator_visible_v2(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 4, 129),
       ('system', 'system', 0, 15, 4, 129),
       ('system', 'system', 0, 13, 4, 129);

--季度GT渠道院线店拜访覆盖率
INSERT INTO t_crm_visit_indicator_visible_v2(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 4, 130),
       ('system', 'system', 0, 15, 4, 130),
       ('system', 'system', 0, 13, 4, 130);

--院线店拜访覆盖率
INSERT INTO t_crm_visit_indicator_visible_v2(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 2, 131),
       ('system', 'system', 0, 5, 1, 131);

--月度GT渠道院线店拜访覆盖率、季度GT渠道院线店拜访覆盖率
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
WHERE id IN (129, 130, 131);

--指标名称调整
update t_crm_visit_indicator set indicator_name = '当月门店拜访频次达成率' WHERE id = 120;
update t_crm_visit_indicator set indicator_name = '当月NKA专职NC门店拜访达成率' WHERE id = 121;
update t_crm_visit_indicator set indicator_name = '当月RKA专职NC门店拜访达成率' WHERE id = 122;
update t_crm_visit_indicator set indicator_name = '当月门店拜访覆盖率' WHERE id = 124;
update t_crm_visit_indicator set indicator_name = '当月院线店拜访覆盖率' WHERE id = 131;

update t_crm_visit_indicator set indicator_name = '当月服务商拜访达成率' WHERE id = 125;
update t_crm_visit_indicator set indicator_name = '当月GT渠道门店拜访覆盖率' WHERE id = 127;
update t_crm_visit_indicator set indicator_name = '当月GT渠道院线店拜访覆盖率' WHERE id = 129;

update t_crm_visit_indicator set indicator_name = '当季服务商拜访达成率' WHERE id = 126;
update t_crm_visit_indicator set indicator_name = '当季GT渠道门店拜访覆盖率' WHERE id = 128;
update t_crm_visit_indicator set indicator_name = '当季GT渠道院线店拜访覆盖率' WHERE id = 130;

--第二轮调整
update t_crm_visit_indicator set indicator_name = '当月院线店拜访达成率' WHERE id = 131;

--调整当月门店拜访覆盖率排序
update t_crm_visit_indicator_visible_v2 set visiable_sort = 91 WHERE indicator_id = 124;

--当月门店拜访覆盖率团队明细
UPDATE t_crm_visit_indicator
SET indicator_desc =
'{
  "teamColumnList": [
    {
      "code": "numerator",
      "name": "覆盖门店数"
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
WHERE id IN (124);