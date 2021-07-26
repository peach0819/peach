INSERT INTO `t_3rd_wechat` (`wx_id`, `alias`, `nickname`, `head_img`, `phone`)
VALUES ('test_qunkong1', 'qunkongtest1', '群控测试微信号1', 'http://wx.qlogo.cn/mmhead/ver_1/hum0UbOjVwNJCranI83QNWK1h6lRMAIl8catF4UYvyncMC5WibWM7UC0xEFcicjIfodDZeLE0uf8E0RnIovs8Vhg/0', '13355558888');
INSERT INTO `t_3rd_wechat` (`wx_id`, `alias`, `nickname`, `head_img`, `phone`)
VALUES ('test_qunkong2', 'qunkongtest2', '群控测试微信号2', 'http://wx.qlogo.cn/mmhead/ver_1/hum0UbOjVwNJCranI83QNWK1h6lRMAIl8catF4UYvyncMC5WibWM7UC0xEFcicjIfodDZeLE0uf8E0RnIovs8Vhg/0', '13355558889');


INSERT INTO `t_3rd_wechat_linker_relation` (`wx_id`, `linker_id`)
VALUES ('test_qunkong1', '2cc75755e1184b82b8be91afb97dd31f');
INSERT INTO `t_3rd_wechat_linker_relation` (`wx_id`, `linker_id`)
VALUES ('test_qunkong2', '2cc75755e1184b82b8be91afb97dd31f');
