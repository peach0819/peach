select serial.out_biz_id as trade_id,
       template.hi_card_type,
       row_number() over(partition by serial.out_biz_id order by serial.card_fund_serial_id desc) as rn --最近的模板id
from (
    select out_biz_id,
           template_card_id,
           card_fund_serial_id
    from ods_t_card_fund_serial_details_d
    where dayid='$v_date'
) serial
inner join (
    select id,
           hi_card_type
    from ods_t_hi_card_template_d
    where dayid ='$v_date'
    and is_deleted <> 99
) template on serial.template_card_id=template.id
having rn = 1