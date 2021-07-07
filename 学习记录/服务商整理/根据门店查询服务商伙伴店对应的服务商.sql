-- 334 条数据、
SELECT
  tmp_shop.*,
  temp_user.user_id,
  temp_user.IS_MANAGER,
  temp_user.user_status,
  temp_user.USER_TYPE,
  temp_user.user_type_subdivide
  -- count(*)
FROM
  t_user as temp_user -- inner join
  INNER JOIN (
    SELECT
      shop.SHOP_ID AS SHOP_ID,
      shop.SHOP_NAME AS SHOP_NAME,
      -- shop.CREAT_TIME AS CREAT_TIME,
      shop.sub_store_type as shopsub_store_type,
      extra.sub_store_type AS sub_store_type,
      extra.biz_id AS biz_id
    FROM
      t_shop_extra extra
      INNER JOIN t_shop shop ON shop.SHOP_ID = extra.SHOP_ID ---- inner join
    WHERE
      shop.sub_store_type in (11102, 11104) --  11104 服务商老板店 , 11102服务商业务员店
      AND shop.store_type = 11
      AND extra.biz_id is NOT NULL
  ) as tmp_shop ON temp_user.user_id = tmp_shop.biz_id
WHERE
  temp_user.IS_MANAGER = 1  -- 是否管理员
  AND temp_user.USER_TYPE = 12  -- 是否服务商类型
 -- AND temp_user.user_status = 1   -- 是否启用