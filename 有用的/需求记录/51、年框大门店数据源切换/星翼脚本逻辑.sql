WITH shop_rebate_activity AS (
	SELECT up.rebate_id,
           up.shop_id,
           up.amount,
           up.quantity,
           up.pay_amount,
           up.accumulate_material_amount,
           up.rebate_total_amount,
           up.rebate_usable_amount,
           up.rebate_withdrawal_amount,
           up.deduct_total_amount,
           up.deducted_amount,
           up.not_deducted_amount,
           pa.act_name,
           pa.act_type,
           pa.act_type_tag,
           pa.act_desc,
           pa.start_time,
           pa.end_time,
           pa.status,
           pa.period_end_time
	FROM ytdw.dwd_hmc_rebate_user_quantity_d up
	LEFT JOIN ytdw.dwd_smc_promotion_activity_d pa ON up.rebate_id = pa.id
	WHERE pa.dayid = '${v_date}'
	AND up.dayid = '${v_date}'
	AND pa.is_deleted = 0
	AND pa.status = 2
	AND pa.act_type = 18
	AND pa.start_time <= date_format(now(), 'yyyyMMddHHmmss')
	AND pa.end_time >= date_format(now(), 'yyyyMMddHHmmss')
	AND pa.bu_id = 0
	AND pa.act_type_tag in (16,17,18,19)
),

activity_scope AS (
	SELECT act_id,
           concat('[', concat_ws(',', collect_set(to_json(named_struct('scopeType', scope_type, 'scopeTypeValue', scope_type_value)))), ']') AS scope
	FROM shop_rebate_activity ra
	LEFT JOIN ytdw.dwd_smc_promotion_scope_d s ON s.act_id = ra.rebate_id
	WHERE s.dayid = '${v_date}'
	AND s.is_deleted = 0
	AND s.act_type = 18
	GROUP BY act_id
),

activity_tool AS (
	SELECT DISTINCT t.id,
           t.act_id
	FROM shop_rebate_activity ra
	LEFT JOIN ytdw.dwd_smc_promotion_tool_d t ON ra.rebate_id = t.act_id
	WHERE t.dayid = '${v_date}'
	AND t.tool_code = 18
	AND t.is_deleted = 0
),

condition_mode AS (
	SELECT condition.act_id,
           concat('[', concat_ws(',', collect_set(to_json(named_struct('total', condition.total, 'type', mode.type, 'discountAmount', mode.discount_amount, 'giftOuterId', mode.gift_outer_id, 'giftBizTitle', mode.gift_biz_title)))), ']') AS mode
	FROM (
		SELECT tool.act_id,
               pc.total,
               pc.act_mode_id
		FROM activity_tool tool
		LEFT JOIN ytdw.dwd_smc_promotion_condition_d pc ON tool.id = pc.act_tool_id
		WHERE pc.dayid = '${v_date}'
		AND pc.is_deleted = 0
		AND pc.condition_code = 18
	) condition
	LEFT JOIN (
		SELECT pm.id,
               pm.type,
               pm.discount_amount,
               pm.gift_outer_id,
               pm.gift_biz_title
		FROM activity_tool tool
		LEFT JOIN ytdw.dwd_smc_promotion_mode_d pm ON tool.id = pm.act_tool_id
		WHERE pm.dayid = '${v_date}'
		AND pm.is_deleted = 0
		AND pm.mode_code = 18
	) mode ON condition.act_mode_id = mode.id
	GROUP BY condition.act_id
)

SELECT act.rebate_id,
       act.shop_id,
       act.amount,
       act.quantity,
       act.pay_amount,
       act.accumulate_material_amount,
       act.rebate_total_amount,
       act.rebate_usable_amount,
       act.rebate_withdrawal_amount,
       act.deduct_total_amount,
       act.deducted_amount,
       act.not_deducted_amount,
       act.act_name,
       act.act_type,
       act.act_type_tag,
       act.act_desc,
       act.start_time,
       act.end_time,
       act.status,
       act.period_end_time,
       sc.scope,
       cm.mode
FROM shop_rebate_activity act
LEFT JOIN activity_scope sc ON act.rebate_id = sc.act_id
LEFT JOIN condition_mode cm ON act.rebate_id = cm.act_id
ORDER BY act.rebate_id DESC