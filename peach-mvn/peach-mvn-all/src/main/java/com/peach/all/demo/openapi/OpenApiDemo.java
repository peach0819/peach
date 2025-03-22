package com.peach.all.demo.openapi;

import com.alibaba.fastjson.JSON;
import org.essentials4j.New;

/**
 * @author feitao.zt
 * @date 2024/7/29
 */
public class OpenApiDemo {

    public static void main(String[] args) {
        //ElnVersionForm versionForm = new ElnVersionForm();
        //versionForm.setVersionType(1);
        //String result = OpenApiUtil.syncPush("hipac.crm.shopdanonesync.createVersion", JSON.toJSONString(versionForm),
        //        OpenApiUtil.Env.PROD);

        ElnVersionSyncForm<ElnVersionSyncSpcDutyForm> form = new ElnVersionSyncForm<>();
        form.setVersionId(2L);
        form.setLastPage(false);
        form.setDataList(New.list(new ElnVersionSyncSpcDutyForm("REM2024082112244411065296", 0)));
        OpenApiUtil.syncPush("hipac.crm.shopdanonesync.syncSpcDuty", JSON.toJSONString(form), OpenApiUtil.Env.PROD);
    }

}
