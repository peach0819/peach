-- 业务进展
select * from
(
    select
        dept_name as `电销组名`,
        user_real_name as `电销姓名`,
        bind_qw_user_id as `电销企微账号`,
        count(distinct fre_chat_id) as `企微好友数量实时数据`,
        knShop.cnt as `CRM库容门店数量实时数据`,
        count(distinct shop_id) as `销售微信绑定门店数（企微好友绑定门店）`
    FROM
    (
        SELECT
            dianxiao.dept_name,
            dianxiao.user_id,
            dianxiao.user_real_name,
            bindUser.bind_qw_user_id,
            qwFre.biz_id as fre_chat_id,
            bindLinker.biz_id as linker_id,
            linker.linker_obj_id as shop_id
        FROM
        (
            SELECT dept.name as dept_name,userAdmin.user_id,userAdmin.user_real_name FROM
            (select user_id,user_real_name,dept_id from yt_ustone.t_user_admin where user_status=1)userAdmin
            INNER JOIN
            (select id,name from yt_ustone.t_department where parent_id in (1464,1723,1656,1451,1437))dept on dept.id=userAdmin.dept_id
            order by dept.name desc,user_real_name desc
        )dianxiao
        left JOIN
        (select bind_qw_user_id,bind_user_id from yt_crm.t_crm_work_phone)bindUser on bindUser.bind_user_id=dianxiao.user_id
        left JOIN
        (select id,qw_user_id from yt_crm.t_crm_chat)qwChat on qwChat.qw_user_id=bindUser.bind_qw_user_id
        left JOIN
        (select chat_id,biz_id from yt_crm.t_crm_chat_bind where type=1 and is_deleted=0)qwFre on qwChat.id=qwFre.chat_id
        left JOIN
        (select chat_id,biz_id from yt_crm.t_crm_chat_bind where type=2 and is_deleted=0)bindLinker on qwFre.biz_id=bindLinker.chat_id
        left JOIN
        (select linker_id,linker_obj_id from yt_ustone.t_linker)linker on linker.linker_id=bindLinker.biz_id
    )summary
    left JOIN
    (select user_id,count(DISTINCT shop_id) as cnt from yt_ustone.t_shop_pool_server where is_enabled=1 group by user_id)knShop on knShop.user_id= summary.user_id
    group by user_real_name,user_id
)tmp
order by `电销组名` desc,`电销姓名` desc;


-- 进展明细
select
    dept_name as `电销组名`,
    user_real_name as `电销姓名`,
    dxkn.shop_id as `门店id`,
    shop_name as `门店名称`,
    pro_name as `门店省`,
    city_name as `门店市`,
    case
        WHEN bindShop.shop_id is not NULL then '已绑定'
        else '未绑定'
    end as `状态（是否绑定库容门店）`
from
(
    select
        dept_name,
        user_real_name,
        knShop.shop_id,
        shop.shop_name,
        province.AREA_NAME as pro_name,
        city.AREA_NAME as city_name
    from
    (
        SELECT dept.name as dept_name,userAdmin.user_id,userAdmin.user_real_name FROM
        (select user_id,user_real_name,dept_id from yt_ustone.t_user_admin where user_status=1)userAdmin
        INNER JOIN
        (select id,name from yt_ustone.t_department where parent_id in (1464,1723,1656,1451,1437))dept on dept.id=userAdmin.dept_id
        order by dept.name desc,user_real_name desc
    )dianxiao
    left JOIN
    (select user_id,shop_id from yt_ustone.t_shop_pool_server where is_enabled=1)knShop on knShop.user_id= dianxiao.user_id
    left JOIN
    (select shop_id,shop_name,PROVINCEAREA_ID,CITYAREA_ID from yt_ustone.t_shop)shop on knShop.shop_id= shop.shop_id
    left JOIN
    (select area_id,AREA_NAME from yt_ustone.t_area)province on province.area_id=shop.PROVINCEAREA_ID
    left JOIN
    (select area_id,AREA_NAME from yt_ustone.t_area)city on city.area_id=shop.CITYAREA_ID
)dxkn
LEFT JOIN
(
    SELECT
        linker.linker_obj_id as shop_id
    FROM
    (select chat_id,biz_id from yt_crm.t_crm_chat_bind where type=2 and is_deleted=0)bindLinker
    left JOIN
    (select linker_id,linker_obj_id from yt_ustone.t_linker)linker on linker.linker_id=bindLinker.biz_id
    group by linker_obj_id
)bindShop
on bindShop.shop_id=dxkn.shop_id