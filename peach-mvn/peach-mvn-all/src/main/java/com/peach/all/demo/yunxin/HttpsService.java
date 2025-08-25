package com.peach.all.demo.yunxin;

import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.BufferedHttpEntity;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.net.URI;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

public class HttpsService {

    private SSLContext sslContext;
    private X509TrustManager tm;
    private CloseableHttpClient httpClient;

    public HttpsService()
            throws Exception {
        sslContext = SSLContext.getInstance("TLS");
        tm = new X509TrustManager() {

            @Override
            public void checkClientTrusted(X509Certificate[] x509Certificates, String s) throws CertificateException {

            }

            @Override
            public void checkServerTrusted(X509Certificate[] x509Certificates, String s) throws CertificateException {

            }

            @Override
            public X509Certificate[] getAcceptedIssuers() {
                return new X509Certificate[0];
            }
        };
        sslContext.init(null, new TrustManager[]{ tm },
                new java.security.SecureRandom());
        httpClient = HttpClients.custom()
                .setSSLContext(sslContext).build();
    }

    public String doPost(String path, String headerStr,
            String requestBody, String encoding) throws Exception {
        String resultString = "";
        CloseableHttpResponse response = null;
        HttpPost httpPost = null;
        try {
            URI uri = new URI(path);
            httpPost = new HttpPost(uri);
            httpPost.setHeader("Content-type", "application/json; charset=utf-8");

            /** 报文头中设置Authorization参数*/
            httpPost.setHeader("Authorization", headerStr);

            /** 设置请求报文体*/
            httpPost.setEntity(new StringEntity(requestBody, encoding));

            response = httpClient.execute(httpPost);
            HttpEntity httpEntity = response.getEntity();
            httpEntity = new BufferedHttpEntity(httpEntity);
            resultString = EntityUtils.toString(httpEntity);
        } catch (Exception e) {
            throw e;
        } finally { //释放连接

            if (null != response)
                response.close();
            if (httpPost != null)
                httpPost.releaseConnection();

        }
        return resultString;
    }

}
