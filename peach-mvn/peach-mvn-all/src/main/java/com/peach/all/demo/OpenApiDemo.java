package com.peach.all.demo;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/7/29
 */
public class OpenApiDemo {

    private static final String APP_KEY = "HIPAC91";
    private static final String SECRET = "11c80b2461aed9c663ea89d144784634";
    private static final String API = "hipac.crm.shopdanone.elnShopSyncPush"; //api
    private static final String ENV = "master"; //测试环境master , 正式环境prod
    private static final String HOST = "https://master-openapi.hipac.cn"; //测试环境master-openapi , 正式环境openapi

    public static void main(String[] args) {
        try {
            String result = syncPush("{}");
            System.out.println("结果：" + result);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("接口调用异常：" + e.getMessage());
        }
    }

    public static String syncPush(String data) {
        //第一步 .构建参数
        Map<String, String> paramMap = buildParamsMap(data);

        //第二步.接口调用
        return HttpUtil.doPost(HOST, paramMap);
    }

    private static Map<String, String> buildParamsMap(String data) {
        Map<String, String> paramMap = new HashMap<>();
        paramMap.put("route", ENV);
        paramMap.put("api", API);
        paramMap.put("appKey", APP_KEY);
        paramMap.put("v", "1.0.0");
        paramMap.put("format", "json");
        paramMap.put("signMethod", "md5");
        paramMap.put("data", data);
        String signContent = getSignContent(paramMap);
        String signed = MD5Util.getMD5(MD5Util.getMD5(signContent) + SECRET);
        paramMap.put("sign", signed);
        return paramMap;
    }

    private static String getSignContent(Map<String, String> paramMap) {
        StringBuilder content = new StringBuilder();
        List<String> keys = new ArrayList<>(paramMap.keySet());
        Collections.sort(keys);
        for (String key : keys) {
            String value = paramMap.get(key);
            if (StringUtils.isNotEmpty(key) && StringUtils.isNotEmpty(value)) {
                content.append(key).append(value);
            }
        }
        content.append(SECRET);
        return content.toString();
    }

    static class HttpUtil {

        /**
         * post 方式(推荐)
         */
        private static String doPost(String url, Map<String, String> map) {
            try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
                HttpPost httpPost = new HttpPost(url);
                //设置参数
                List<NameValuePair> list = new ArrayList<>();
                for (Map.Entry<String, String> entry : map.entrySet()) {
                    if (StringUtils.isNotBlank(entry.getKey()) && StringUtils.isNotBlank(entry.getValue())) {
                        list.add(new BasicNameValuePair(entry.getKey(), entry.getValue()));
                    }
                }
                if (list.size() > 0) {
                    httpPost.setEntity(new UrlEncodedFormEntity(list, "utf-8"));
                }
                HttpResponse response = httpClient.execute(httpPost);
                if (response != null) {
                    HttpEntity resEntity = response.getEntity();
                    if (resEntity != null) {
                        return EntityUtils.toString(resEntity, "utf-8");
                    }
                }
                return null;
            } catch (Throwable e) {
                e.printStackTrace();
                System.out.println("接口调用异常，问题:" + e.getMessage());
                return null;
            }
        }
    }

    static class MD5Util {

        public static String getMD5(String input) {
            try {
                MessageDigest md = MessageDigest.getInstance("MD5");
                byte[] digest = md.digest(input.getBytes());

                StringBuilder sb = new StringBuilder();
                for (byte b : digest) {
                    sb.append(String.format("%02x", b & 0xff));
                }
                return sb.toString();
            } catch (NoSuchAlgorithmException e) {
                throw new RuntimeException(e);
            }
        }
    }
}
