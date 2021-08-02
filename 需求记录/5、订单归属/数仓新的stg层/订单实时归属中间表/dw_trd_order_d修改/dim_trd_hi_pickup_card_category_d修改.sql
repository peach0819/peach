with trade as (
    select trade_id
    from ods_pt_trade_shop_d
    where dayid='$v_date'
    and regexp_extract(attribute,'(off:)([0-9]*)(\;?)',2) != '1'
    and item_dc_id=0
    and is_deleted=0
    and trade_type=1  --卡票券充值
),

serial as (
    select out_biz_id,
           template_card_id,
           card_fund_serial_id
    from ods_t_card_fund_serial_details_d
    where dayid='$v_date'
),

template as (
    select id,
           hi_card_type
    from ods_t_hi_card_template_d
    where dayid ='$v_date'
    and is_deleted <> 99
)

select serial.out_biz_id as trade_id,
       template.hi_card_type,
       row_number() over(partition by serial.out_biz_id order by serial.card_fund_serial_id desc) as rn --最近的模板id
from trade
join serial on serial.out_biz_id = trade.trade_id
join template on serial.template_card_id=template.id
having rn = 1;