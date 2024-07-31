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

SELECT shop_rebate_activity.rebate_id,
       shop_rebate_activity.shop_id,
       shop_rebate_activity.amount,
       shop_rebate_activity.quantity,
       shop_rebate_activity.pay_amount,
       shop_rebate_activity.accumulate_material_amount,
       shop_rebate_activity.rebate_total_amount,
       shop_rebate_activity.rebate_usable_amount,
       shop_rebate_activity.rebate_withdrawal_amount,
       shop_rebate_activity.deduct_total_amount,
       shop_rebate_activity.deducted_amount,
       shop_rebate_activity.not_deducted_amount,
       shop_rebate_activity.act_name,
       shop_rebate_activity.act_type,
       shop_rebate_activity.act_type_tag,
       shop_rebate_activity.act_desc,
       shop_rebate_activity.start_time,
       shop_rebate_activity.end_time,
       shop_rebate_activity.status,
       shop_rebate_activity.period_end_time,
       activity_scope.scope,
       condition_mode.mode
FROM shop_rebate_activity
LEFT JOIN activity_scope ON shop_rebate_activity.rebate_id = activity_scope.act_id
LEFT JOIN condition_mode ON shop_rebate_activity.rebate_id = condition_mode.act_id
ORDER BY shop_rebate_activity.rebate_id DESC