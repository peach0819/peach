

ALTER TABLE ytdw.dw_salary_gmv_rule_public_mid_v2_d add columns (pickup_pay_gmv_less_refund decimal(18, 2) comment '提货卡口径gmv-退款') CASCADE;
ALTER TABLE ytdw.dw_salary_gmv_rule_public_mid_v2_d add columns (pickup_pay_gmv decimal(18, 2) comment '提货卡口径gmv') CASCADE;
ALTER TABLE ytdw.dw_salary_gmv_rule_public_mid_v2_d add columns (pickup_pay_pay_amount decimal(18, 2) comment '提货卡口径支付金额') CASCADE;
ALTER TABLE ytdw.dw_salary_gmv_rule_public_mid_v2_d add columns (pickup_pay_pay_amount_less_refund decimal(18, 2) comment '提货卡口径支付金额-退款') CASCADE;
ALTER TABLE ytdw.dw_salary_gmv_rule_public_mid_v2_d add columns (pickup_recharge_gmv_less_refund decimal(18, 2) comment '提货卡充值gmv-退款') CASCADE;
ALTER TABLE ytdw.dw_salary_gmv_rule_public_mid_v2_d add columns (pickup_recharge_gmv decimal(18, 2) comment '提货卡充值gmv') CASCADE;
ALTER TABLE ytdw.dw_salary_gmv_rule_public_mid_v2_d add columns (pickup_recharge_pay_amount decimal(18, 2) comment '提货卡充值支付金额') CASCADE;
ALTER TABLE ytdw.dw_salary_gmv_rule_public_mid_v2_d add columns (pickup_recharge_pay_amount_less_refund decimal(18, 2) comment '提货卡充值支付金额-退款') CASCADE;
ALTER TABLE ytdw.dw_salary_gmv_rule_public_d add columns (extra string comment '冗余字段') CASCADE;

ALTER TABLE ytdw.dw_salary_gmv_rule_public_mid_v2_d add columns (is_pickup_recharge_order int comment '是否为充值提货hi卡订单 1 是 0 否') CASCADE;