SELECT count(*) FROM (

select b.sp_id, b.brand_id, ct.c, b.area_cnt
from t_sp_brand b
INNER JOIN (
SELECT count(*) as c, sp_id, brand_id
FROM t_sp_area_brand
WHERE status = 1
and is_deleted = 0
group by sp_id, brand_id
) ct ON b.sp_id = ct.sp_id and b.brand_id = ct.brand_id
WHERE b.area_cnt < ct.c

) temp


'000644ed14df405dacbce9923f749a71',
'001155e4f4154ee58b4deafca3ca8f24',
'0011d440275741648dab48c38bfd4bb7',
'0019d93de22d4b2f80d7b0f215383e70',
'001c44912c214228856e429c8f1f0c56',
'001d937b016e4d7a9843c77156bff74f',
'001f92602fab480bac7df8e438f4971b',
'0024f9a3c6cf4aeb925087c4ae343338',
'0028b53bb7414522888f33e83effacc9',
'002d72fb12834abca48567016e4f6a85',
'0031fd9f3e6147b7ac28a2ede76cc96a',
'0035d42f00714c31beb8725b61682f47',
'0037408a6e934a178f06a6934c10850c',
'003abfb19faa466e95336d65f52037c7'