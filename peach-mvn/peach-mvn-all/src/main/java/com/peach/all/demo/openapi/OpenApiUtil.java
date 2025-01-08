package com.peach.all.demo.openapi;

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
 * @date 2025/1/8
 */
public class OpenApiUtil {

    public static String syncPush(String api, String data, Env env) {
        try {
            //第一步 .构建参数
            Map<String, String> paramMap = new HashMap<>();
            paramMap.put("route", env.getEnv());
            paramMap.put("api", api);
            paramMap.put("appKey", env.getAppKey());
            paramMap.put("v", "1.0.0");
            paramMap.put("format", "json");
            paramMap.put("signMethod", "md5");
            paramMap.put("data", data);
            String signContent = getSignContent(paramMap, env.getSecret());
            String signed = MD5Util.getMD5(MD5Util.getMD5(signContent) + env.getSecret());
            paramMap.put("sign", signed);

            //第二步.接口调用
            String result = HttpUtil.doPost(env.getHost(), paramMap);
            System.out.println("结果：" + result);
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("接口调用异常：" + e.getMessage());
            throw e;
        }
    }

    private static String getSignContent(Map<String, String> paramMap, String secret) {
        StringBuilder content = new StringBuilder();
        List<String> keys = new ArrayList<>(paramMap.keySet());
        Collections.sort(keys);
        for (String key : keys) {
            String value = paramMap.get(key);
            if (StringUtils.isNotEmpty(key) && StringUtils.isNotEmpty(value)) {
                content.append(key).append(value);
            }
        }
        content.append(secret);
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
                if (!list.isEmpty()) {
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

    enum Env {

        MASTER("HIPAC91", "11c80b2461aed9c663ea89d144784634", "master", "https://master-openapi.hipac.cn"),

        PROD("HIPAC2018050210020252", "1d63a1267912731d8224a54c402e464c", "prod", "https://openapi.hipac.cn");

        private final String appKey;
        private final String secret;
        private final String env;
        private final String host;

        public String getAppKey() {
            return appKey;
        }

        public String getSecret() {
            return secret;
        }

        public String getEnv() {
            return env;
        }

        public String getHost() {
            return host;
        }

        Env(String appKey, String secret, String env, String host) {
            this.appKey = appKey;
            this.secret = secret;
            this.env = env;
            this.host = host;
        }
    }
}
