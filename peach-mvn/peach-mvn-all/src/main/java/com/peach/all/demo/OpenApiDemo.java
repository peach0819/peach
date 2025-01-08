package com.peach.all.demo;

import com.alibaba.fastjson.JSON;
import com.google.common.collect.Lists;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/7/29
 */
public class OpenApiDemo {

    public static void main(String[] args) {
        Map<String, Object> map = new HashMap<>();
        map.put("versionId", 7);
        map.put("isLastPage", false);
        String json = "{\"photoMonth\":\"202212\",\"photoUrl\":\"https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/71845458d6c64e98b3ca7663abddaf32.jpg,https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/50f99a429985407d80b68936c6c582d9.jpg,https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/83463960f03d4a96b2bfe93ba4db7189.jpg,https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/14ff9ef3a6b14b3ebbc1f4b8bb35b98a.jpg,https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/74c44d1c1f7d4270a189a80959511e6c.jpg,https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/36de51ceba2445adb82ee38f02987ff5.jpg,https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/2aa5e807fa8948a791251b6bc98e8564.jpg,https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/704b8dc884654dd185a73af6430387ed.jpg,https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/16578c88402c483c9ba24beb82e6d8da.jpg,https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/52b69f4312be4c56b596bd14790d0cde.jpg,https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/051a5ddc8ab940f9b99b4dabaa10544e.jpg,https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/a79a430155ac4a0b95634240756d5671.jpg,https://wyeth-r2c.oss-cn-hangzhou.aliyuncs.com/prod/29e098e2682448a883a5e2cd25da401a.jpg\",\"elnStoreCode\":\"120099122\",\"itemList\":[{\"skuName\":\"AP3\",\"num\":108},{\"skuName\":\"NC3\",\"num\":108},{\"skuName\":\"AP1MINI\",\"num\":108},{\"skuName\":\"AP2\",\"num\":108},{\"skuName\":\"AP1\",\"num\":108},{\"skuName\":\"AC3\",\"num\":108},{\"skuName\":\"NC Tin 2\",\"num\":108},{\"skuName\":\"AC4\",\"num\":108},{\"skuName\":\"NC Tin 3\",\"num\":108},{\"skuName\":\"AC2\",\"num\":108},{\"skuName\":\"NC Tin 1\",\"num\":108},{\"skuName\":\"AP2MINI\",\"num\":108},{\"skuName\":\"AC1\",\"num\":108},{\"skuName\":\"YH 3\",\"num\":108}],\"photoTime\":\"2023-01-31 15:37:31\"}";
        map.put("dataList", Lists.newArrayList(JSON.parseObject(json)));

        OpenApiUtil.syncPush("hipac.crm.shopdanonesync.syncSpcPhoto", JSON.toJSONString(map), OpenApiUtil.Env.MASTER);
    }

}
