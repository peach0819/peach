


TUSEQIWEI09  and    transTypeId: TUSEQIWEI09180208| select time_series(__time__, '1m', '%H:%i:%s' ,'0') as Time, avg(prossTime) as UV group by Time order by Time limit 10000