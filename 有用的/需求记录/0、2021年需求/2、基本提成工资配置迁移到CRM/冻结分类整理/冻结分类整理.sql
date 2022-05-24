 case  when (is_split='大BD' or is_split='BD') and is_pickup_recharge_order=0 and is_spec_brand=0 then (
          case when (category_id_first=10 and is_celeron=1)
                    or category_id_first in (7999)
                    or category_id_second in (2807,2721,2712,6820)
                    or brand_id = 13818 then '分类01'
  	           when (category_id_first=542 and brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and category_id_second not in (6820,2807)) then '分类02'
  		         when category_id_first=12 or category_id_third=11191 then '分类03'
  		         when brand_id in (2068,7324,10726,9566,7888) then '分类09'
  	           else '分类04' end)
        --大BD/BD、提货卡、 非专供品（特殊提点品牌）
        when (is_split='大BD' or is_split='BD') and is_pickup_recharge_order=1 and  is_spec_brand=0 then (
          case when (pickup_category_id_first=10 and is_celeron=1)
                    or pickup_category_id_first in (7999)
                    or pickup_category_id_second in (2807,2721,2712,6820)
                    or pickup_brand_id = 13818 then '分类01'
  	           when (pickup_category_id_first=542 and pickup_brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (pickup_category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and pickup_category_id_second not in (6820,2807))then '分类02'
  		         when pickup_category_id_first=12 or pickup_category_id_third=11191 then '分类03'
  		         when pickup_brand_id in (2068,7324,10726,9566,7888) then '分类09'
  	           else '分类04' end)
        --大BD/BD、非提货卡、 专供品（特殊提点品牌）
        when is_split='大BD' and is_pickup_recharge_order=0 and is_spec_brand=1 then (
          case when (category_id_first=10 and is_celeron=1)
                    or category_id_first in (7999)
                    or category_id_second in (2807,2721,2712,6820) then '分类05'
      	       when (category_id_first=542 and brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and category_id_second not in (6820,2807)) then '分类06'
      		     when category_id_first=12 or category_id_third=11191 then '分类07'
      	       else '分类08' end)
        --大BD/BD、提货卡、 专供品（特殊提点品牌）
        when is_split='大BD' and is_pickup_recharge_order=1 and is_spec_brand=1 then (
          case when (pickup_category_id_first=10 and is_celeron=1)
                    or pickup_category_id_first in (7999)
                    or pickup_category_id_second in (2807,2721,2712,6820) then '分类05'
        	     when (pickup_category_id_first=542 and pickup_brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (pickup_category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and pickup_category_id_second not in (6820,2807)) then '分类06'
        		   when pickup_category_id_first=12 or pickup_category_id_third=11191 then '分类07'
        	     else '分类08' end)
        else ''
  end as class_number,








  case  when (is_split='大BD' or is_split='BD') and is_pickup_recharge_order=0 and is_spec_brand=0 then (
          case when (category_id_first=10 and is_celeron=1)
                    or category_id_first in (7999)
                    or category_id_second in (2807,2721,2712,6820)
                    or brand_id = 13818 then '低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（通用品）（元）'
  	           when (category_id_first=542 and brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and category_id_second not in (6820,2807)) then '营养品（除纽瑞优系列、BuffX品牌、佑伉力），用品玩具，服纺，洗护（通用品）（元）'
  		         when category_id_first=12 or category_id_third=11191 then '奶粉及面包/蛋糕（通用品）（元）'
  		         when brand_id in (2068,7324,10726,9566,7888) then '纽瑞优系列，佑伉力（通用品）（元）'
  	           else '中端和高端尿不湿，辅食，其他品类（通用品）' end)
        --大BD/BD、提货卡、 非专供品（特殊提点品牌）
        when (is_split='大BD' or is_split='BD') and is_pickup_recharge_order=1 and  is_spec_brand=0 then (
          case when (pickup_category_id_first=10 and is_celeron=1)
                    or pickup_category_id_first in (7999)
                    or pickup_category_id_second in (2807,2721,2712,6820)
                    or pickup_brand_id = 13818 then '低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（通用品）（元）'
  	           when (pickup_category_id_first=542 and pickup_brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (pickup_category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and pickup_category_id_second not in (6820,2807))then '营养品（除纽瑞优系列、BuffX品牌、佑伉力），用品玩具，服纺，洗护（通用品）（元）'
  		         when pickup_category_id_first=12 or pickup_category_id_third=11191 then '奶粉及面包/蛋糕（通用品）(元)'
  		         when pickup_brand_id in (2068,7324,10726,9566,7888) then '纽瑞优系列，佑伉力（通用品）（元）'
  	           else '中端和高端尿不湿，辅食，其他品类（通用品）' end)
        --大BD/BD、非提货卡、 专供品（特殊提点品牌）
        when is_split='大BD' and is_pickup_recharge_order=0 and is_spec_brand=1 then (
          case when (category_id_first=10 and is_celeron=1)
                    or category_id_first in (7999)
                    or category_id_second in (2807,2721,2712,6820) then '低端和超低端尿不湿，洗衣液，干湿纸巾（大BD专供品）'
      	       when (category_id_first=542 and brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and category_id_second not in (6820,2807)) then '营养品（除纽瑞优系列、BuffX品牌、佑伉力），用品玩具，服纺，洗护（大BD专供品）'
      		     when category_id_first=12 or category_id_third=11191 then '奶粉及面包/蛋糕(元)（大BD专供品）'
      	       else '中端和高端尿不湿，辅食，其他品类（大BD专供品）' end)
        --大BD/BD、提货卡、 专供品（特殊提点品牌）
        when is_split='大BD' and is_pickup_recharge_order=1 and is_spec_brand=1 then (
          case when (pickup_category_id_first=10 and is_celeron=1)
                    or pickup_category_id_first in (7999)
                    or pickup_category_id_second in (2807,2721,2712,6820) then '低端和超低端尿不湿，洗衣液，干湿纸巾（大BD专供品）'
        	     when (pickup_category_id_first=542 and pickup_brand_id not in (13818,2068,7324,10726,9566,7888))
                    or (pickup_category_id_first in (4,2794,2627,8,2681,11,2560,2750,5) and pickup_category_id_second not in (6820,2807)) then '营养品（除纽瑞优系列、BuffX品牌、佑伉力），用品玩具，服纺，洗护（大BD专供品）'
        		   when pickup_category_id_first=12 or pickup_category_id_third=11191 then '奶粉及面包/蛋糕(元)（大BD专供品）'
        	     else '中端和高端尿不湿，辅食，其他品类（大BD专供品）' end)
        else ''
  end as class_number_info,