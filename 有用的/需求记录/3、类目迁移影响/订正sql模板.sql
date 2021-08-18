

-------------------------------------迁移数据一个类目到另外一个类目
--没有已有数据的迁移
update t_sp_reward
SET third_cate_id = 4719, editor = '1290387026'
WHERE third_cate_id = 3148
and (sp_id, brand_id, first_cate_id, second_cate_id) not in (
  SELECT sp_id, brand_id, first_cate_id, second_cate_id
  from t_sp_reward
  where third_cate_id = 4719
  and is_deleted = 0
);

--存在已有数据的删除
update t_sp_reward
set is_deleted = 1, editor = '1290387026'
WHERE third_cate_id = 3148
and (sp_id, brand_id, first_cate_id, second_cate_id) in (
  SELECT sp_id, brand_id, first_cate_id, second_cate_id
  from t_sp_reward
  where third_cate_id = 4719
  and is_deleted = 0
);

----------------------------------- 删除一个类目
update t_sp_reward
set is_deleted = 1, editor = '1290387026'
WHERE third_cate_id = 3148


