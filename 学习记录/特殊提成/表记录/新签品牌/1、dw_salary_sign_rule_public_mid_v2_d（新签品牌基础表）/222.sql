
create table if not exists dw_order_d (
trade_id string comment '交易ID'
,trade_no string comment '交易编号(展示使用)'
,parent_trade_id string comment '父交易ID'
,out_trade_id string comment '外部交易号，第三方系统生成'
,parent_shop_id string comment '父店铺ID'
,open_id string comment '消费者微信openId
,主要用于微小店业务'
,third_order_time string comment '第三方交易时间'
,trade_type tinyint comment '交易类型0:普通订单1:卡券订单2:补差价'
,trade_source  tinyint  comment '交易来源1:线下实体2:淘宝店铺3:微信4:微信自助下单'
,trade_status  tinyint  comment '交易状态0:待支付1:已支付3:交易成功4:交易关闭'
,trade_remark  string   comment '交易备注'
,shop_remark   string   comment '门店备注'
,clerk_name    string   comment '店员姓名'
,clerk_phone   string   comment '店员手机号'
,order_pro_id  string   comment '收货省份ID'
,order_pro_name      string   comment '收货省份'
,order_city_id string   comment '收货城市ID'
,order_city_name     string   comment '收货城市'
,order_area_id string   comment '收货区域ID'
,order_area_name     string   comment '收货区域'
,address_id    bigint   comment '收货地址ID'
,detail_address      string   comment '收货地址'
,delivery_name string   comment '收货人姓名'
,delivery_phone      string   comment '收货电话'
,customer_id   string   comment '消费者ID'
,customer_id_card    string   comment '消费者身份证号'
,customer_name string   comment '消费者姓名'
,customer_phone      string   comment '消费者手机号码'
,is_cart       tinyint  comment '是否购物车订单'
,trade_attribute     string   comment '扩展属性格式k1:v1；k2:v2'
,has_parent    tinyint  comment '0:无父交易1:有父交易'
,hide    tinyint  comment '0:不隐藏1:隐藏，对店铺可见2:隐藏，对店铺不可见，对管理员可见'
,order_id      bigint   comment '订单编号，外部生成'
,order_no      string   comment '订单编号，展示使用'
,shop_id       string   comment '店铺ID'
,shop_name     string   comment '店铺名称'
,shop_pro_id   string   comment '门店省份ID'
,shop_pro_name string   comment '门店省份'
,shop_city_id  string   comment '门店城市ID'
,shop_city_name      string   comment '门店城市'
,shop_area_id  string   comment '门店区域ID'
,shop_area_name      string   comment '门店区域'
,supply_id     string   comment '供应商id'
,supply_num    string   comment '供应商编号'
,supply_name   string   comment '供应商名称'
,item_id       bigint   comment '商品id'
,brand_id      bigint   comment '品牌ID'
,brand_no      string   comment '品牌编号'
,brand_name    string   comment '品牌名称'
,item_snapshot_version        int      comment '商品快照版本'
,item_name     string   comment '订单快照商品名称'
,item_type     tinyint  comment '1=保税商品2=一般贸易3=海外直邮'
,item_type_name      string   comment '贸易类型名称'
,category_id_first   bigint   comment '一级类目ID'
,category_id_first_name       string   comment '一级类目名称'
,category_id_second  bigint   comment '二级类目ID'
,category_id_second_name      string   comment '二级类目名称'
,category_id_third   bigint   comment '三级类目ID'
,category_id_third_name       string   comment '三级类目名称'
,category      bigint   comment '四级类目ID'
,category_name string   comment '四级类目名称'
,item_style    tinyint  comment '商品标签类型默认是0：A类1：B类'
,item_barcode  string   comment '商品条形码'
,item_count    int      comment '商品的数量(件数*规格)'
,origin_single_item_amount    decimal(11,2)  comment '商品原始价格(元)'
,pay_amount    decimal(11,2)  comment '实付款金额，包含了Hi卡的金额(元)'
,total_pay_amount    decimal(11,2)  comment 'gmv(pay_amount+coupon_amount)'
,tax_amount    decimal(11,2)  comment '税额(货币的最小单位)'
,item_actual_amount  decimal(18,2)  comment '商品的总金额(件数*规格金额)元'
,customer_amount     decimal(18,2)  comment '微信下单消费者付款金额(元)'
,sharing_amount      decimal(18,2)  comment '总分店利润分成金额(元)'
,logistic_type tinyint  comment '运费类型'
,logistic_pay_type   tinyint  comment '运费支付方式1:线上付2:到付'
,logistic_amount     decimal(11,2)  comment '运费金额'
,attribute     string   comment '扩展属性，格式k1:v1；k2:v2'
,spu_feature   string   comment '商品spu特性(json串)'
,spec    int      comment '商品规格'
,spec_desc     string   comment '商品规格描述'
,item_picture  string   comment '商品图片'
,promotion_attr      string   comment '优惠相关的属性信息'
,order_status  string   comment '订单状态0:买家未支付1:商家待支付2:交易完成3:交易关闭6:已支付7:支付处理中9:海关清关不通过10:已发货16:已受理19:买家已支付20:已出库'
,order_status_name   string   comment '订单状态名称'
,biz_id  bigint   comment '目前记录的是营销活动的ID'
,biz_type      tinyint  comment '业务类型0:普通订单1:拼团订单2:巨划算订单3:限时购订单4:秒杀订单5:活动订单'
,biz_type_name string   comment '业务类型名称'
,out_attr      string   comment '外部系统的快照json格式'
,bonded_area_id      int      comment '保税区ID'
,bonded_area   string   comment '保税区'
,tags    string   comment '标记'
,accept_time   string   comment '接单时间'
,pay_time      string   comment '付款时间'
,stock_out_time      string   comment '出库时间'
,delivery_time string   comment '发货时间'
,end_time      string   comment '完成时间'
,is_deleted    tinyint  comment '0:正常1:删除'
,creator       string   comment '创建者'
,editor  string   comment '修改者'
,order_create_time   string   comment '订单表记录创建时间'
,order_edit_time     string   comment '订单表记录修改时间'
,coupon_owner_id     bigint   comment '优惠券持有者id'
,coupon_amount decimal(11,2)  comment '优惠券金额'
,hi_amount     decimal(11,2)  comment 'HI卡金额'
,offline_sale_id     string   comment '线下销售ID'
,offline_sale_name   string   comment '线下销售名称'
,online_operator_id  string   comment '在线运营ID'
,online_operator_name   string   comment '在线运营名称'
,brand_manager_id    string   comment '品牌经理ID'
,brand_manager_name  string   comment '品牌经理名称'
,offline_sale_id_freezed      string   comment '线下销售名称(冻结)'
,offline_sale_name_freezed    string   comment '线下销售名称(冻结)'
,online_operator_id_freezed   string   comment '在线运营ID(冻结)'
,online_operator_name_freezed       string   comment '在线运营名称(冻结)'
,brand_manager_id_freezed     string   comment '品牌经理ID(冻结)'
,brand_manager_name_freezed   string   comment '品牌经理名称(冻结)'
,batch_id      int      comment '批次id'
,batch_no      string   comment '批次编号'
,production_time     string   comment '生产日期'
,pre_tax_price decimal(11,2)  comment '税前采购价'
,batch_price   decimal(11,2)  comment '批次价格'
,preference    decimal(11,2)  comment '利润'
,current_stock int      comment '当前库存'
,version       int      comment '批次版本号'
,start_exp_date      string   comment '效期开始时间'
,end_exp_date  string   comment '效期结束时间'
,is_pause      int      comment '是否停售'
,batch_status  tinyint  comment '0初始化,1待生效,2且is_pause=0生效，2且is_pause=1停售生效，3自动失效，4手工销毁'
,batch_status_name   string   comment '批次状态名称'
,settle_no     string   comment '结算编号'
,settle_status tinyint  comment '订单结算状态(0,未结算1,已结算2,结算中3,无需结算)'
,settle_status_name  string   comment '订单结算状态名称'
,settle_time   string   comment '结算时间'
,bill_unique_no      string   comment '订单入账账单编号'
,bill_time     string   comment '订单入账账单时间'
,refund_settle_status   tinyint  comment '退款结算状态(0,未结算1,已结算2,结算中3,无需结算)'
,refund_settle_status_name    string   comment '退款结算状态名称'
,refund_settle_time  string   comment '退款结算时间'
,settle_logistic_flag   tinyint  comment '是否结算运费'
,settle_logistic_amount       decimal(11,2)  comment '结算运费金额'
,settle_pack_flag    tinyint  comment '是否打包'
,settle_pack_amount  decimal(11,2)  comment '结算打包费'
,settle_tax_flag     tinyint  comment '是否包税'
,settle_tax_amount   decimal(11,2)  comment '结算商品税额'
,settle_item_flag    tinyint  comment '是否结算货款'
,settle_item_amount  decimal(11,2)  comment '结算订单商品金额'
,refund_id     bigint   comment '退款ID'
,refund_num    string   comment '订单退款编号'
,refund_item_count   decimal(18,2)  comment '退货数量'
,refund_apply_amount decimal(18,2)  comment '申请退款金额'
,refund_actual_amount   decimal(18,2)  comment '实际退款金额'
,refund_apply_count  int      comment '申请退款次数'
,refund_type   int      comment '退款类型(1:仅退款,2:退款退货,3:换货)'
,refund_type_name    string   comment '退款类型名称'
,refund_status int      comment '退款状态1.待审核,2.审核通过,3.审核拒绝,4.已提交,5.退款已发送,6.退款关闭,7待确认,8.已受理9.退款成功,10.退款失败'
,refund_status_name  string   comment '退款状态名称'
,refund_cause  int      comment '退款理由'
,refund_cause_name   string   comment '退款理由名称'
,refund_remark string   comment '备注内容'
,refund_transit_amount        decimal(18,2)  comment '退款运费金额'
,refund_return_time  string   comment '退款回执时间'
,refund_create_time  string   comment '退款创建时间'
,refund_edit_time    string   comment '退款修改时间'
,refund_operator     string   comment '退款工单处理人'
,refund_order_status string   comment '退款时订单状态    0.待买家支付，1.待支付，2.已完成，3.已关闭，6.已支付，9.海关清关不通过，10.已发货，11.已收货，12.退款中，13.已退货，14.已分账，16.已受理)'
,refund_order_status_name     string   comment '退款时订单状态名称'
,refund_remark2      string   comment '小二备注'
,refund_refuse_type  tinyint  comment '拒绝退款类型(1,退款申请审核拒绝 2,物流审核拒绝)'
,refund_refuse_type_name      string   comment '退款拒绝类型名称'
,refund_person tinyint  comment '退款承担者(0,海拍客承担1,供应商承担)'
,refund_person_name  string   comment '退款承担者名称'
,supply_refund_amount   decimal(18,2)  comment '供应商承担退款金额'
,supply_refund_logistic_amount      decimal(18,2)  comment '供应商承担运费金额'
,refund_sub_type     tinyint  comment '退款类型分两种(1:补偿,2:仅退款)'
,refund_sub_type_name   string   comment '退款承担类型名称'
,refund_is_special   string   comment '是否已特殊处理:，0：否，1：是'
,refund_special_manager       string   comment '退款特殊处理人'
,refund_special_cause   string   comment '特殊订单退款/退货理由'
,refund_is_disputed  tinyint  comment '退款是否纠纷工单：0否，1是'
,refund_is_priority_payment   tinyint  comment '退款是否先行赔付：0否，1是'
,refund_payment_type tinyint  comment '退款先行赔付类型'
,refund_logistics_company_amount    decimal(18,2)  comment '退款物流商承担费用'
,refund_name   string   comment '退款支付宝账号姓名'
,refund_hi_card_amount        decimal(18,2)  comment 'hi卡退款金额'
,refund_tags   string   comment '退款打标,格式k1:v1；k2:v2'
,refund_docking_user string   comment '退款客服对接人,格式k1:v1；k2:v2'
,refund_supply_deduct_amount  decimal(18,2)  comment '退款供应商扣除费用'
,batch_spec_price    decimal(11,2)  comment '采购货款金额'
,item_logistic_amount   decimal(11,2)  comment '商品运费'
,packing_amount      decimal(11,2)  comment '打包费'
,supply_preferential_amount   decimal(11,2)  comment '供应商承担优惠金额'
,seller_support_coupon_amount       decimal(11,2)  comment '供应商承担优惠券金额'
,rebate_amount decimal(11,2)  comment '供应商返利'
,pay_type_amount     decimal(11,2)  comment '手续费'
,gift_cash_coupon_amt   decimal(18,2)  comment '礼包现金券金额'
,pure_pay_amt  decimal(18,2)  comment '净支付金额'
,out_trade_no  string   comment '第三方支付机构流水号'
,pay_type      int      comment '支付渠道'
,pay_type_name string   comment '支付渠道名称'
,op_order_id   string   comment '支付编号'
,shop_num      string   comment '店铺编号'
,supply_item_no      string   comment '供应商商品编号'
,shop_create_time    string   comment '门店创建时间'
,shop_open_time      string   comment '门店开通时间'
,store_type    string   comment '门店类型'
,store_type_name     string   comment '门店类型名称'
,hipac_refund_amount decimal(18,2)  comment '海拍客承担退款金额'
,sp_id   bigint   comment '服务商id'
,sp_name       string   comment '服务商名称'
,shop_type     string   comment '账号类型'
,shop_type_name      string   comment '账号类型名称'
,sub_status    tinyint  comment '订单子状态,退款工单状态 1,退款中,2,部分退款完成,3,全额退款完成,4,退款关闭,5,待用户退款'
,sub_status_name     string   comment '订单子状态名称（退款工单状态名称）'
,coupon_amount_platform       decimal(11,2)  comment '平台优惠券金额'
,coupon_amount_store decimal(11,2)  comment '店铺优惠券金额'
,coupon_owner_id_store        bigint   comment '店铺优惠券标识id'
,multi_bd_id   MAP<STRING,STRING>  comment '门店服务人员id'
,multi_bd_name MAP<STRING,STRING>  comment '门店服务人员名称'
,multi_bd_id_freezed MAP<STRING,STRING>  comment '门店服务人员id冻结'
,multi_bd_name_freezed        MAP<STRING,STRING>  comment '门店服务人员名称冻结'
,logistic_type_name  string   comment '运费类型名称'
,service_info  string   comment '门店多职能信息'
,service_info_freezed   string   comment '门店多职能冻结信息'
,business_unit string   comment '业务域'
,refund_end_time     string   comment '退款结束时间（退款成功或者退款关闭时间）'
,user_id       string   comment '用户id'
,is_hi_bill    string   comment '是否hi呗账期订单'
,hi_bill_repay_status   tinyint  comment 'hi呗账期还款状态，（0，未还款 1,部分还款 2,已还款）'
,hi_bill_repay_status_name    string   comment 'hi呗账期还款状态名称，（0，未还款 1,部分还款 2,已还款）'
,hi_bill_repay_finish_time    string   comment 'hi呗账期还款时间'
,hi_bill_overdue_day int      comment 'hi呗账期逾期天数'
,is_hi_bill_overdue  tinyint  comment '是否hi呗账期订单逾期'
,bu_id   int      comment '业务类型'
,coupon_id     bigint   comment '优惠券id'
,coupon_title  string   comment '优惠券标题'
,coupon_type   string   comment '优惠券类型'
,coupon_creator      string   comment '优惠券创建人'
,hipac_preferential_amount    decimal(18,2)  comment '海拍客承担优惠金额'
,hipac_coupon_amount decimal(18,2)  comment '海拍客承担优惠券金额'
,brand_coupon_amount decimal(18,2)  comment '品牌承担优惠券金额'
,goods_gmv     decimal(11,2)  comment '实货gmv'
,pay_day       string   comment '支付天'
,pay_month     string   comment '支付月'
,sys_category_id_first        int      COMMENT  '系统一级类目ID'
,sys_category_id_first_name   string   COMMENT  '系统一级类目名称'
,sys_category_id_second       int      COMMENT    '系统二级类目ID'
,sys_category_id_second_name  string   COMMENT '系统二级类目名称'
,sys_category_id_third        int      COMMENT '系统三级类目ID'
,sys_category_id_third_name   string   COMMENT '系统三级类目名称'
,sys_category  int      COMMENT '系统四级类目ID'
,sys_category_name   string   COMMENT '系统四级类目名称'
,item_sub_style      string   comment '商品子类型'
,shop_address_id     int      comment '门店街道id'
,shop_address_name   string   comment '门店街道名称'
,item_style_freezed  int      comment '冻结AB类型'
,item_sub_style_freezed       string   comment '冻结AB子类型'
,business_group_code string   comment '业务组'
,business_group_name string   comment '业务组名称'
,delivery_storehouse string   comment '发货仓'
,delivery_province_name       string   comment '发货省'
,settle_sum_amount   decimal(11,2)  comment '结算总金额'
,order_street_id     string   comment '收货街道id'
,order_street_name string   comment '收货街道'
,pickup_card_amount      decimal(11,2)  COMMENT '提货hi卡支付金额'
,is_pickup_order   int      COMMENT '是否通过提货hi卡支付 1 是 0 否'
,refund_pickup_card_amount        decimal(11,2)  COMMENT '提货卡退款金额'
,is_pickup_recharge_order   int      comment '是否为充值提货hi卡订单 1 是 0 否'
,pickup_category_id_first   bigint   comment '提货hi卡一级类目id'
,pickup_category_id_first_name    string   comment '提货hi卡一级类目名'
,pickup_category_id_second        bigint   comment '提货hi卡二级类目id'
,pickup_category_id_second_name   string   comment '提货hi卡二级类目名'
,pickup_category_id_third   bigint   comment '提货hi卡三级类目id'
,pickup_category_id_third_name    string   comment '提货hi卡三级类目名'
,pickup_brand_id   bigint   comment '提货hi卡品牌'
,pickup_brand_name string   comment '提货hi卡品牌名'
,sp_operator_id_freezed  string   COMMENT '冻结服务商经理id'
,sp_operator_name_freezed   string   COMMENT '冻结服务商经理名字'
,apply_type  tinyint  COMMENT '门店来源ID'
,apply_type_name   string   COMMENT '门店来源名称'
,sale_dc_id  int      comment '分销订单标识'
,sale_team_name    string   comment '销售团队标识 1:电销部 2:BD部 3:大客户部 4:服务商部 5:美妆销售团队'
,sale_team_freezed_name  string   comment '冻结销售团队标识 1:电销部 2:BD部 3:大客户部 4:服务商部 5:美妆销售团队'
,supply_total_amount     decimal(18,2)  comment '供应商承担退款总金额'
,order_item_snapshot_name   string   comment '订单商品快照名称'
,properties  string   comment '商品属性'
,coupon_first_dep_name   string   comment '优惠券海拍客费用归属一级部门'
,coupon_second_dep_name  string   comment '优惠券海拍客费用归属二级部门'
,coupon_type_key   tinyint  comment '优惠券类型'
,sku_id      bigint   comment 'sku_id'
,trade_tags  string   comment '交易打标'
,sub_store_type    int      comment '门店子类型'
,sub_store_type_name     string   comment '门店子类型'
)
comment '订单基础明细宽表'
partitioned by (dayid string)
stored as orc
location '/dw/ytdw/dw/dw_order_d';


with shop_worth_level_month as (

    -- 8月采用手工上传数据
    select shop_id
    ,'202108' as date_ym
    from dwd_shop_external_import_data
    where tag='8月好店'

    union all

    -- 9月及以后的使用模型表
    select shop_id
    ,substr(dayid,1,6) as date_ym
    from dim_hpc_shp_shop_tag_d
    where dayid>='20210901' -- 9月及以后的采用
    and dayid<='$v_date'
    and shop_worth_level in (1,2) --1、线下皇冠，2线下金钻
    and (dayid=date_format(date_sub(add_months(to_date(substr(dayid,1,6),'yyyyMM'),1),1),'yyyyMMdd') or dayid='$v_date') -- 取月末那天，没到月末，用当天的数据
)

insert overwrite table dw_order_d partition (dayid = '$v_date')
select
t1.trade_id
,t1.trade_no,t1.parent_trade_id
,t1.out_trade_id
,t1.parent_shop_id
,t1.open_id
,t1.third_order_time
,t1.trade_type
,t1.trade_source
,t1.trade_status
,t1.trade_remark,t1.shop_remark,t1.clerk_name
,t1.clerk_phone
,t1.order_pro_id
,t1.order_pro_name
,t1.order_city_id
,t1.order_city_name
,t1.order_area_id
,t1.order_area_name
,t1.address_id
,t1.detail_address
,t1.delivery_name
,t1.delivery_phone
,t1.customer_id
,t1.customer_id_card
,t1.customer_name
,t1.customer_phone
,t1.is_cart
,t1.trade_attribute
,t1.has_parent
,t1.hide
,t1.order_id
,t1.order_no,t1.shop_id
,t1.shop_name
,t1.shop_pro_id
,t1.shop_pro_name
,t1.shop_city_id
,t1.shop_city_name
,t1.shop_area_id
,t1.shop_area_name
,t1.supply_id
,t1.supply_num
,t1.supply_name
,t1.item_id
,t1.brand_id
,t1.brand_no,t1.brand_name
,t1.item_snapshot_version
,t1.item_name
,t1.item_type
,t1.item_type_name
,t1.category_id_first
,t1.category_id_first_name
,t1.category_id_second
,t1.category_id_second_name
,t1.category_id_third
,t1.category_id_third_name
,t1.category
,t1.category_name
,t1.item_style
,t1.item_barcode
,t1.item_count
,t1.origin_single_item_amount
,t1.pay_amount
,t1.total_pay_amount
,t1.tax_amount
,t1.item_actual_amount
,t1.customer_amount
,t1.sharing_amount
,t1.logistic_type
,t1.logistic_pay_type
,t1.logistic_amount
,t1.attribute
,t1.spu_feature
,t1.spec,t1.spec_desc,t1.item_picture
,t1.promotion_attr,t1.order_status
,t1.order_status_name
,t1.biz_id
,t1.biz_type
,t1.biz_type_name
,t1.out_attr,t1.bonded_area_id
,t1.bonded_area,t1.tags
,t1.accept_time
,t1.pay_time
,t1.stock_out_time
,t1.delivery_time
,t1.end_time
,t1.is_deleted
,t1.creator,t1.editor,t1.create_time
,t1.edit_time
,t1.coupon_owner_id
,t1.coupon_amount
,t1.hi_amount
,t1.offline_sale_id
,t1.offline_sale_name
,t1.online_operator_id
,t1.online_operator_name
,t1.brand_manager_id
,t1.brand_manager_name
,t1.offline_sale_id_freezed
,t1.offline_sale_name_freezed
,t1.online_operator_id_freezed
,t1.online_operator_name_freezed
,t1.brand_manager_id_freezed
,t1.brand_manager_name_freezed
,t1.batch_id
,t1.batch_no,t1.production_time
,t1.pre_tax_price
,t1.batch_price
,t1.preference
,t1.current_stock,t1.version
,t1.start_exp_date
,t1.end_exp_date
,t1.is_pause
,t1.batch_status
,t1.batch_status_name
---------------------------
,t2.settle_no,t2.settle_status
,t2.settle_status_name
,t2.settle_time
,t2.bill_unique_no,t2.bill_time
,t2.refund_settle_status
,t2.refund_settle_status_name
,t2.refund_settle_time
,t2.settle_logistic_flag,t2.settle_logistic_amount
,t2.settle_pack_flag,t2.settle_pack_amount
,t2.settle_tax_flag,t2.settle_tax_amount
,t2.settle_item_flag,t2.settle_item_amount
---------------------------
,t3.refund_id
,t3.refund_num
,t3.refund_item_count
,t3.refund_apply_amount
,t3.refund_actual_amount
,t3.refund_apply_count
,t3.refund_type
,t3.refund_type_name
,t3.refund_status
,t3.refund_status_name
,t3.refund_cause
,t3.refund_cause_name
,t3.refund_remark,t3.refund_transit_amount
,t3.refund_return_time
,t3.refund_create_time
,t3.refund_edit_time
,t3.refund_operator,t3.refund_order_status
,t3.refund_order_status_name
,t3.refund_remark2,t3.refund_refuse_type
,t3.refund_refuse_type_name
,t3.refund_person
,t3.refund_person_name
,t3.supply_refund_amount
,t3.supply_refund_logistic_amount
,t3.refund_sub_type
,t3.refund_sub_type_name
,t3.refund_is_special
,t3.refund_special_manager
,t3.refund_special_cause
,t3.refund_is_disputed
,t3.refund_is_priority_payment
,t3.refund_payment_type
,t3.refund_logistics_company_amount
,t3.refund_name
,t3.refund_hi_card_amount
,t3.refund_tags
,t3.refund_docking_user
,t3.refund_supply_deduct_amount
,---------------------------
t4.batch_spec_price
,t4.logistic_amount
,t4.packing_amount
,t4.supply_preferential_amount
,t4.seller_support_coupon_amount
,t4.rebate_amount
--业务已经废弃
,t4.pay_type_amount
,t4.gift_cash_coupon_amt
,t4.pure_pay_amt
,t4.out_trade_no,t4.pay_type
,t4.pay_type_name
,t4.op_order_id
,t1.shop_num
,t1.supply_item_no,t1.shop_create_time
,t1.shop_open_time
,t1.store_type
,t1.store_type_name
,t3.hipac_refund_amount
,t1.sp_id
,t1.sp_name
,t1.shop_type
,t1.shop_type_name
,t4.sub_status
,t4.sub_status_name
,t1.coupon_amount_platform
,t1.coupon_amount_store
,t1.coupon_owner_id_store
,t1.multi_bd_id
,t1.multi_bd_name
,t1.multi_bd_id_freezed
,t1.multi_bd_name_freezed
,t1.logistic_type_name
,t1.service_info,t1.service_info_freezed
,t1.business_unit
,t3.refund_end_time
,t4.user_id
,t4.is_hi_bill,t4.hi_bill_repay_status
,t4.hi_bill_repay_status_name
,t4.hi_bill_repay_finish_time
,t4.hi_bill_overdue_day
,t4.is_hi_bill_overdue
,t4.bu_id
,t4.coupon_id_platform
,t4.coupon_title_platform
,t4.coupon_type_platform
,t4.coupon_creator_platform
,t4.hipac_preferential_amount
,t4.hipac_coupon_amount
,t4.brand_coupon_amount
,t1.goods_gmv
,t1.pay_day
,t1.pay_month
,t1.sys_category_id_first
,t1.sys_category_id_first_name
,t1.sys_category_id_second
,t1.sys_category_id_second_name
,t1.sys_category_id_third
,t1.sys_category_id_third_name
,t1.sys_category
,t1.sys_category_name
,t1.item_sub_style
,t1.shop_address_id
,t1.shop_address_name
,t4.item_style_freezed
,t4.item_sub_style_freezed
,t1.business_group_code
,t1.business_group_name
,t1.delivery_storehouse
,t1.delivery_province_name
,t1.settle_sum_amount
,t1.order_street_id
,t1.order_street_name
,nvl(t1.pickup_card_amount,0) as pickup_card_amount
,t1.is_pickup_order
,nvl(t3.refund_pickup_card_amount,0) as refund_pickup_card_amount
,t4.is_pickup_recharge_order
,t4.pickup_category_id_first ,t4.pickup_category_id_first_name
,t4.pickup_category_id_second
,t4.pickup_category_id_second_name
,t4.pickup_category_id_third
,t4.pickup_category_id_third_name
,t4.pickup_brand_id
,t4.pickup_brand_name
,t1.sp_operator_id_freezed
,t1.sp_operator_name_freezed
,t1.apply_type
,t1.apply_type_name
,t1.sale_dc_id
-- v7版本，参见：http://k.yangtuojia.com/pages/viewpage.action?pageId=70339920
,case when t4.bu_id != 0 then null -- 1. 只统计海拍客业务的销售团队归属,bu_id!=0，归属为空
     when t1.sale_dc_id != -1 then null --2. 分销订单没有销售团队,sale_dc_id ! = -1，归属为空
     when t5.shop_id is not null then '直播店' --3. 门店分组 为 TOC外部合作对接系统门店(ID: 1750)，归属为7-直播点
     when t1.item_style=0 and t1.business_unit not in ('卡券票','其他') and (t1.sub_store_type in (11102,11104) or t1.sp_id is not null) then '服务商部' -- 4. 普通类目时,当且AB类型为A 且 (门店子类型为 '服务商伙伴店'  或者 是否服务商为 是)，归属为服务商部
     when t1.business_unit not in ('卡券票','其他') and t1.store_type =11 and t1.item_style = 1 and t1.sp_id is not null then '服务商部' -- 5. 普通类目时,当门店类型为 伙伴店 且AB类型为B 且是否服务商为 是,归属为 4 服务商部
     when t1.sp_id is not null then '服务商部' --5.5 新增逻辑 by  阿雷 2021.08.10
     when t1.store_type in (9,11) then null -- 6. 伙伴店和员工店没有销售团队 归属为 空
     when (t1.store_type =3 and ytdw.get_service_info('service_feature_id:12',t1.service_info_freezed,'service_user_name') is not null)
           or (t1.store_type =3 and ytdw.get_service_info('service_feature_id:14',t1.service_info_freezed,'service_user_name') is not null) then '美妆BD' -- 7. 符合以下任意一条条件,则判断为对应的归属部门 1) 当 门店类型='美妆店'  且 冻结美妆BD 不为空 2) 当 门店类型='美妆店'  且 冻结美妆BD新签 不为空
     when (t1.store_type =3 and ytdw.get_service_info('service_feature_id:13',t1.service_info_freezed,'service_user_name') is not null)
           or (t1.store_type =3 and ytdw.get_service_info('service_feature_id:15',t1.service_info_freezed,'service_user_name') is not null )
           or (t1.store_type =3 and ytdw.get_service_info('service_feature_id:19',t1.service_info_freezed,'service_user_name') is not null ) then '美妆电销' -- 8.  符合以下任意一条条件,则判断为对应的归属部门 1) 当 门店类型='美妆店'  且 冻结美妆电销 不为空 2) 当 门店类型='美妆店'  且 冻结美妆电销新签 不为空 3) 当 门店类型='美妆店'  且 冻结美妆EPS 不为空
     when t1.store_type =3 then '美妆BD' --9 当 门店类型='美妆店'

     ---- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>以上为v6版本，以下为v7版本新增  20210805<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

     when t1.business_group_code = 'cw9' then null -- 12. 生活服务组没有销售人员
     when t1.business_unit in ('卡券票','其他') and t1.item_style = 0 then null --13 需要同时符合以下条件 1) AB类型=  A类 2) 业务域= 卡券票和其他
     when t1.item_style=1 and t1.business_unit in ('卡券票','其他') and t4.is_pickup_recharge_order = 0 then null-- 14 需要同时符合以下条件 1) AB类型=  B类 2) 业务域= 卡券票和其他 3) 是否为 提货卡充值订单为 否
     when t4.is_pickup_recharge_order = 1 and t4.pickup_category_id_first not in (10,12) and ytdw.get_service_info('service_feature_name:KBD',t1.service_info,'service_user_name') is not null then 'KBD部'-- 15 需要同时符合以下条件 1) 是否为提货卡充值订单为 是 2) 提货卡一级类目 != '奶粉' 和 '尿不湿' 3) 库内KBD 不为空
     when t4.is_pickup_recharge_order = 0 and t1.category_id_first not in (10,12) and ytdw.get_service_info('service_feature_name:KBD',t1.service_info,'service_user_name') is not null then 'KBD部'-- 16. 需要同时符合以下条件 1) 是否为提货卡充值订单为 否 2) 一级类目 != '奶粉' 和 '尿不湿' 3) 库内KBD 不为空
     when t4.is_pickup_recharge_order = 1 and t1.item_style = 1 and t4.pickup_category_id_first in (6098,6,13) then 'CBD部'-- 17. 需要同时符合以下条件 1) 是否为提货卡充值订单为 是  2) AB类型为 'B类'' 3) 提货卡一级类目 为 6098-'婴童零食',13-'婴童辅食',6-'食品'
     when t1.item_style = 1 and t1.category_id_first in (6098,6,13) then 'CBD部'--18 需要同时符合以下条件 1) AB类型为 'B类' 2) 一级类目 为 '婴童零食','婴童辅食','食品'
     when t1.item_style = 0 and t1.category_id_first in (6098,6,13) and ytdw.get_service_info('service_feature_name:CBD',t1.service_info,'service_user_name') is not null then 'CBD部'-- 需要同时符合以下条件 1) AB类型为 'A类'' 2) 一级类目 为 '婴童零食','婴童辅食','食品' 3) 库内CBD 不为空
     when t6.big_shop_business_level!=1 and t1.item_style=0 then '电销部'-- 21 需要同时符合以下条 1) 大门店业务分层 != '好店'  2) [商品最新ab类型名称]= 'A类'
     when t6.big_shop_business_level=3 and t1.item_style=1 then '电销部'-- 22需要同时符合以下条件 1) 最新大门店业务分层 = '尾部门店' 2) [商品最新ab类型名称]= 'B类'
     when t6.big_shop_business_level=4 and t1.item_style=1 then '大BD部' -- 23 需要同时符合以下条件 1) 最新大门店业务分层 = '大BD门店' 2) AB类型 = B类
     when t6.big_shop_business_level=1 and t1.item_style=0 then 'BD部' -- 24 需要同时符合以下条件 1) 最新大门店业务分层 = '好店' 2) AB类型 = 'A类'
     when t6.big_shop_business_level in (1,2) and t1.item_style=1 then 'BD部'-- 25  需要同时符合以下条件 1) 最新大门店业务分层  = 'B类头部非好店'  或者 '好店' 2) AB类型 = 'B类'
     else null -- 27 其他为空
end as sale_team_name
,case when substr(t1.create_time,1,6)<='202107' then
----->>>>>>>如果是202107及之前的订单，采用v6版本计算：http://k.yangtuojia.com/pages/viewpage.action?pageId=70339918 <<<<<<<<<<<<<<<
    case when t4.bu_id != 0 then null
   when t1.sale_dc_id != -1 then null
   when t1.shop_id = 'bcfb591b919e48e1804fcdce670c6b55' then '直播店'
   when t5.shop_id is not null then '直播店'
	     when t1.item_style=0 and t1.business_unit not in ('卡券票','其他') and (t1.sub_store_type in (11102,11104) or t1.sp_id is not null) then '服务商部'
   when t1.business_unit not in ('卡券票','其他') and t1.store_type =11 and t1.item_style = 1 and t1.sp_id is not null then '服务商部'
   when t1.store_type in (9,11) then null
   when (t1.store_type =3 and ytdw.get_service_info('service_feature_id:12',t1.service_info_freezed,'service_user_name') is not null)
        or (t1.store_type =3 and ytdw.get_service_info('service_feature_id:14',t1.service_info_freezed,'service_user_name') is not null) then '美妆BD'
   when (t1.store_type =3 and ytdw.get_service_info('service_feature_id:13',t1.service_info_freezed,'service_user_name') is not null)
        or (t1.store_type =3 and ytdw.get_service_info('service_feature_id:15',t1.service_info_freezed,'service_user_name') is not null )
        or (t1.store_type =3 and ytdw.get_service_info('service_feature_id:19',t1.service_info_freezed,'service_user_name') is not null ) then '美妆电销'
   when t1.store_type =3 then '美妆BD'
   when t1.business_unit not in ('卡券票','其他') and t1.store_type !=3 and t1.item_style = 0 and t1.business_group_code != 'cw9' and t1.sp_id is null  then '电销部'
   when t1.business_unit not in ('卡券票','其他') and t1.store_type !=3 and t1.item_style = 1 and t1.sp_id is not null then '服务商部'
   when t1.business_unit not in ('卡券票','其他') and t1.store_type !=3 and t1.item_style = 1 and t1.sp_id is null and t1.is_bigbd_freezed = '是' and t1.store_type !=10  then '大客户部'
   when t1.business_unit not in ('卡券票','其他') and t1.store_type !=3 and t1.item_style = 1 and t1.sp_id is null and t1.is_bigbd_freezed = '否' and t1.store_type !=10 then 'BD部'
   when t1.business_unit = '卡券票' and t4.is_pickup_recharge_order = 1 and t1.sp_id is null and t1.is_bigbd_freezed = '是' and t1.store_type !=10 then '大客户部'
   when t1.business_unit = '卡券票' and t4.is_pickup_recharge_order = 1 and t1.sp_id is null and t1.is_bigbd_freezed = '否' and t1.store_type !=10 then 'BD部'
   else null
   end
----->>>>>>>采用v6版本结束，202108及之后的，采用v7版本：http://k.yangtuojia.com/pages/viewpage.action?pageId=70339918 <<<<<<<<<<<<<<<
     when t4.bu_id != 0 then null -- 1. 只统计海拍客业务的销售团队归属
     when t1.sale_dc_id != -1 then null -- 2. 分销订单没有销售团队
     when t5.shop_id is not null then '直播店' -- 3. 门店分组 为 TOC外部合作对接系统门店(ID: 1750)
	 when t1.item_style=0 and t1.business_unit not in ('卡券票','其他') and (t1.sub_store_type in (11102,11104) or t1.sp_id is not null) then '服务商部' -- 4. 普通类目时,当且AB类型为A 且 (门店子类型为 '服务商伙伴店'  或者 是否服务商为 是)
     when t1.business_unit not in ('卡券票','其他') and t1.store_type =11 and t1.item_style = 1 and t1.sp_id is not null then '服务商部' -- 5. 普通类目时,当门店类型为 伙伴店 且AB类型为B 且是否服务商为 是
     when t1.sp_id is not null then '服务商部' --5.5 新增逻辑 by  阿雷 2021.08.10

     when t1.store_type in (9,11) then null --6. 伙伴店和员工店没有销售团队
     when (t1.store_type =3 and ytdw.get_service_info('service_feature_id:12',t1.service_info_freezed,'service_user_name') is not null)
    or (t1.store_type =3 and ytdw.get_service_info('service_feature_id:14',t1.service_info_freezed,'service_user_name') is not null) then '美妆BD' --7. 符合以下任意一条条件,则判断为对应的归属部门 1) 当 门店类型='美妆店'  且 冻结美妆BD 不为空 2) 当 门店类型='美妆店'  且 冻结美妆BD新签 不为空
     when (t1.store_type =3 and ytdw.get_service_info('service_feature_id:13',t1.service_info_freezed,'service_user_name') is not null)
  or (t1.store_type =3 and ytdw.get_service_info('service_feature_id:15',t1.service_info_freezed,'service_user_name') is not null )
  or (t1.store_type =3 and ytdw.get_service_info('service_feature_id:19',t1.service_info_freezed,'service_user_name') is not null ) then '美妆电销' --8. 符合以下任意一条条件,则判断为对应的归属部门 1) 当 门店类型='美妆店'  且 冻结美妆电销 不为空 2) 当 门店类型='美妆店'  且 冻结美妆电销新签 不为空 3) 当 门店类型='美妆店'  且 冻结美妆EPS 不为空
     when t1.store_type =3 then '美妆BD' --9. 当 门店类型='美妆店'
     ---- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>以上为v6版本，以下为v7版本新增  20210805<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
     when t1.business_group_code = 'cw9' then null -- 12. 生活服务组没有销售人员
     when t1.item_style = 0 and t1.business_unit in ('卡券票','其他') then null -- 13. 需要同时符合以下条件 1) AB类型=  A类 2) 业务域= 卡券票和其他
     when t1.item_style=1 and t1.business_unit in ('卡券票','其他') and t4.is_pickup_recharge_order = 0 then null -- 14. 需要同时符合以下条件 1) AB类型=  B类 2) 业务域= 卡券票和其他 3) 是否为 提货卡充值订单为 否
     when t4.is_pickup_recharge_order = 1 and t4.pickup_category_id_first not in (10,12) and ytdw.get_service_info('service_feature_name:KBD',t1.service_info_freezed,'service_user_name') is not null then 'KBD部'-- 15. 需要同时符合以下条件 1) 是否为提货卡充值订单为 是 2) 提货卡一级类目 != '奶粉' 和 '尿不湿' 3) 冻结KBD 不为空
     when t4.is_pickup_recharge_order = 0 and t1.category_id_first not in (10,12) and ytdw.get_service_info('service_feature_name:KBD',t1.service_info_freezed,'service_user_name') is not null then 'KBD部'-- 16. 需要同时符合以下条件 1) 是否为提货卡充值订单为 否 2) 一级类目 != '奶粉' 和 '尿不湿' 3) 冻结KBD 不为空
     when t4.is_pickup_recharge_order = 1 and t1.item_style = 1 and t4.pickup_category_id_first in (6098,6,13) then 'CBD部'-- 17. 需要同时符合以下条件 1) 是否为提货卡充值订单为 是 2) AB类型为 'B类'' 3) 提货卡一级类目 为 '婴童零食','婴童辅食','食品
     when t1.item_style = 1 and t1.category_id_first in (6098,6,13) then 'CBD部'--18 .需要同时符合以下条件 1) AB类型为 'B类' 2) 一级类目 为 '婴童零食','婴童辅食','食品'
     when t1.item_style = 0 and t1.category_id_first in (6098,6,13) then 'CBD部'-- 19. 需要同时符合以下条件 1) AB类型为 'A类'' 2) 一级类目 为 '婴童零食','婴童辅食','食品'
     when t1.item_style = 0 and t7.shop_id is null then '电销部'    -- 21. 需要同时符合以下条件 1) [商品最新ab类型名称]= 'A类' 2) 创建时间当月分区的 '门店线下分层' != '线下皇冠','线下金钻'
     when t1.item_style = 1 and t1.is_bigbd_freezed = '否' and t7.shop_id is null and t8.is_b_top_shop=0 then '电销部' -- 22. 需要同时符合以下条件 1) [商品最新ab类型名称]= 'B类' 2) 冻结大BD 为空 3) 创建时间当月分区的 '门店线下分层' != '线下皇冠','线下金钻' 4) 创建时间当月分区的 'B类头部门店' 为 否.
     when t1.is_bigbd_freezed = '是' and t1.item_style = 1 then '大BD部'--23. 需要同时符合以下条件 1) 冻结大BD 不为空  2) AB类型 = B类
     when t1.item_style = 0 and t1.is_bigbd_freezed = '否' and t7.shop_id is not null then 'BD部'--24. 需要同时符合以下条件 1) AB类型 = 'A类'   2) 冻结大BD 为空 3) 创建时间当月分区的 '门店线下分层' = '线下皇冠','线下金钻'
     when t1.item_style = 1 and t1.is_bigbd_freezed = '否' and (t7.shop_id is not null or t8.is_b_top_shop=1) then 'BD部' --25. 需要同时符合以下条件 1) AB类型 = 'B类' 2) 冻结大BD 为空 3) 创建时间当月分区的 '门店线下分层' = '线下皇冠','线下金钻'   或者  创建时间当月分区的 'B类头部门店' 为 '是'
     else null --27,其他为空
     end as sale_team_freezed_name
,t3.supply_total_amount
,t1.order_item_snapshot_name
,t1.properties
,t4.coupon_first_dep_name
,t4.coupon_second_dep_name
,t4.coupon_type as coupon_type_key
,t1.sku_id
,t1.trade_tags
,t1.sub_store_type
,--门店子类型
t1.sub_store_type_name
from
dw_order_tmp1 t1
left join
dw_order_tmp2 t2
on t1.order_id = t2.order_id
left join
dw_order_tmp3 t3
on t1.order_id = t3.order_id
left join
dw_order_tmp4 t4
on t1.order_id = t4.order_id
left join
  (select shop_id
   from dwd_shop_data_cluster_mapping_d
   where dayid ='$v_date'
   and inuse = 1
   and cluster_id in (1750)
   and is_deleted=0
   group by shop_id
  ) t5
on t1.shop_id = t5.shop_id
left join
  (select *
   from dim_hpc_shp_shop_tag_d
   where dayid='$v_date'
  ) t6
on t1.shop_id=t6.shop_id
left join shop_worth_level_month t7
on t1.shop_id=t7.shop_id
and substr(t1.create_time
,1,6)=t7.date_ym -- 冻结，取月末数据
left join
  (select *
   from dim_hpc_shp_shop_tag_d
   where dayid<='$v_date'
   and (dayid=date_format(date_sub(add_months(to_date(substr(dayid,1,6),'yyyyMM'),1),1),'yyyyMMdd') or dayid='$v_date') -- 取月末那天 ，没到月末用当天的
  ) t8
on t1.shop_id=t8.shop_id
and substr(t1.create_time,1,6)=substr(t8.dayid,1,6) -- 冻结，取月末数据
;

