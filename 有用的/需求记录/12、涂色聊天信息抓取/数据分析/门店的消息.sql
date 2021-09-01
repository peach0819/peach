

SELECT msg.id, shop.shop_id
FROM yt_crm.t_crm_tuse_qw_personal_msg msg
INNER JOIN yt_crm.t_crm_chat customer ON msg.from_chat_id = customer.id and customer.qw_external_user_id is not null
INNER JOIN yt_crm.t_crm_chat_bind bind ON customer.id = bind.chat_id and bind.type = 2
INNER JOIN yt_ustone.t_linker linker ON linker.linker_id = bind.biz_id
INNER JOIN yt_ustone.t_shop shop ON linker.linker_obj_id = shop.shop_id