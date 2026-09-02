--@exclude_input=prod_mdson.inf_upload_shop_star
INSERT OVERWRITE TABLE ads_crm_star_shop_d PARTITION (dayid = '${v_date}')
SELECT concat('1-', out_service_obj_id),
       star
FROM prod_mdson.inf_upload_shop_star