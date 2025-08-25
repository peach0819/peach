package com.peach.all.demo.openapi;

import com.alibaba.fastjson.JSON;

/**
 * @author feitao.zt
 * @date 2024/7/29
 */
public class OpenApiDemo {

    public static void main(String[] args) {
        WyethVisitSyncForm form = new WyethVisitSyncForm();
        form.setVisitId("59903786091023104");
        form.setAuditResult(true);
        OpenApiUtil.syncPush("hipac.crm.open.wyeth.visitSyncPush", JSON.toJSONString(form), OpenEnv.WYETH_PRE);

        //WyethShopSyncForm form = new WyethShopSyncForm();
        //form.setUscc("1234531232");
        //form.setAuditResult(true);
        //OpenApiUtil.syncPush("hipac.crm.open.wyeth.storeAuditNotify", JSON.toJSONString(form), OpenEnv.WYETH_MASTER);
    }

}
