SELECT case when ${supply_mode} != '' then 'supply'
            when ${today_mode} != '' then 'not_supply'
            else '' end,