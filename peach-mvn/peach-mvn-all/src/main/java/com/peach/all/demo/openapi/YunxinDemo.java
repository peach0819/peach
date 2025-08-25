package com.peach.all.demo.openapi;

import com.alibaba.fastjson.JSON;
import com.peach.all.demo.yunxin.HttpsService;
import com.winnerlook.model.PrivacyBindBodyAxb;
import com.winnerlook.util.Base64;
import com.winnerlook.util.MD5Util;

/**
 * @author feitao.zt
 * @date 2025/8/22
 */
public class YunxinDemo {

    private static String appId = "772079";
    private static String token = "bf4dbe8f39c148cd85fd5455bf1bb355";

    public static void main(String[] args) throws Exception {
        YunxinDemo demo = new YunxinDemo();
        Object o = demo.httpsPrivacyBindAxb();
    }

    public Object httpsPrivacyBindAxb() throws Exception {
        /** AXB模式小号绑定接口地址*/
        String url = "https://101.37.133.245:11008/voice/1.0.0/middleNumberAXB";

        PrivacyBindBodyAxb bindBodyAxb = new PrivacyBindBodyAxb();

        /** 设定绑定的隐私小号*/
        bindBodyAxb.setMiddleNumber("01086482607");
        /** 设定与该隐私小号绑定的号码A*/
        bindBodyAxb.setBindNumberA("15336528373");
        /** 设定与该隐私小号绑定的号码B*/
        bindBodyAxb.setBindNumberB("13116757534");
        /** 设置是否开启通话录音  1:开启，0:关闭*/
        bindBodyAxb.setCallRec(0);
        /** 设置绑定关系有效时长 ,为空表示绑定关系永久，单位:秒*/
        bindBodyAxb.setMaxBindingTime(300);
        /** 设置是否透传主叫的号码到A  0:不透传; 1: 透传，不填默认不透传*/
        bindBodyAxb.setPassthroughCallerToA(0);
        /** 设置是否透传主叫的号码到B  0:不透传; 1: 透传，不填默认不透传*/
        bindBodyAxb.setPassthroughCallerToB(0);
        /** 设置用于接收呼叫结果的服务地址*/
        bindBodyAxb.setCallbackUrl("http://myip../...");

        /** 获取当前系统时间戳*/
        long timestamp = System.currentTimeMillis();
        /** 生成Base64转码后的参数authorization*/
        String authorization = Base64.encodeBase64(appId + ":" + timestamp);
        /** 生成加密参数sig*/
        String sig = MD5Util.getMD5(appId + token + timestamp);

        /** 生成最终接口访问地址*/
        url = url + "/" + appId + "/" + sig;

        String body = JSON.toJSONString(bindBodyAxb);

        /** 调用接口*/
        HttpsService httpsService = new HttpsService();
        String result = httpsService.doPost(url, authorization, body, "UTF-8");
        System.out.println(result);
        return result;
    }

}
