select
shop_id,
shop_name,
shop_linker,
string(ytdw.aes_decrypt(unbase64(shop_phone),'zCYO1pCbgfWfyNW1')) as shop_phone,
store_type_name,
shop_type_name,
shop_address_name,
chain_type
from dw_shop_base_d
where dayid='$v_date'
and shop_id in
(

)