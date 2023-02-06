package message.parser.weixin06

import com.ytgw.common.util.GrootOssAPI
import com.ytgw.core.shared.message.domain.SupergwMessage
import com.ytgw.core.shared.service.message.parser.TextMessageParser
import groovy.json.JsonSlurper
import org.apache.commons.lang3.StringUtils
import org.apache.http.HttpEntity
import org.apache.http.client.ResponseHandler
import org.apache.http.client.config.RequestConfig
import org.apache.http.client.methods.HttpPost
import org.apache.http.entity.ContentType
import org.apache.http.entity.mime.MultipartEntityBuilder
import org.apache.http.impl.client.BasicResponseHandler
import org.apache.http.impl.client.CloseableHttpClient
import org.apache.http.impl.client.HttpClients

/**
 * 讯飞-语音转写文件分片上传接口
 */
public class weixin06069902 extends TextMessageParser {

    private static final String ACTION_UPLOAD = "https://qyapi.weixin.qq.com/cgi-bin/media/upload";

    public SupergwMessage parse(String message) {
        SupergwMessage gw = new SupergwMessage();
        return gw;
    }

    public void share(SupergwMessage inMessage, SupergwMessage outMessage) {
        String taskId = outMessage.g("taskId");
        String fileName = outMessage.g("fileName");
        String ossPath = outMessage.g("ossPath");
        String accessToken = outMessage.g("sessionId");
        String type = outMessage.g("type");
        inMessage.addField("outOrderNo", taskId);
        String response = "";
        String responseCode = "SUCCESS";
        String responseMessage = "成功";
        try{
            response = doUpload(accessToken,fileName,type,ossPath);
            inMessage.addField("origResponse",response);
        }catch(Exception e ){
            logger.error("weixin06069902 {} 解析时发生异常",e);
            responseCode = "FAIL";
            responseMessage = e.getMessage()
        }
        inMessage.setChannelResponseCode(responseCode);
        inMessage.setBusinessResultCode(responseCode);
        inMessage.setChannelResponseMessage(responseMessage);
    }

    private String doUpload(String accessToken,String fileName, String fileType,String ossPath) throws Exception {
        byte[] data = readFromOssPath(ossPath);
        MultipartEntityBuilder entityBuilder = MultipartEntityBuilder.create();
        entityBuilder.addBinaryBody("media", data, ContentType.APPLICATION_OCTET_STREAM,fileName);
        return doPost(ACTION_UPLOAD,accessToken,fileType,entityBuilder.build());
    }


    private String doPost(String requestUrl, String accessToken,String type,HttpEntity entity) throws Exception {
        // 使用post方式提交数据
        HttpPost httpPost = new HttpPost(requestUrl+"?access_token="+accessToken+"&type="+type);
        httpPost.setEntity(entity);
        RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(5000).setConnectTimeout(5000).build();
        httpPost.setConfig(requestConfig);
        ResponseHandler<String> responseHandler = new BasicResponseHandler();

        String result = null;
        CloseableHttpClient httpClient = null;
        try {
            httpClient = HttpClients.createDefault();
            result = httpClient.execute(httpPost, responseHandler);
        }finally{
            if(httpClient!=null){
                httpClient.close();
            }
        }
        return result;
    }

    private byte[] readFromOssPath(String ossPath) throws Exception {
        def inp;
        try {
            inp = GrootOssAPI.getInputStreamByPath(ossPath);
            if (inp == null) {
                return new byte[0];
            }
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int len = -1;
            while ((len = inp.read(buffer)) != -1) {
                output.write(buffer, 0, len);
            }
            output.flush();
            return output.toByteArray();
        } finally {
            if ( inp != null ) {
                inp.close()
            }
        }
    }

    private String handleNull(Object obj){
        if(obj==null){
            return "";
        }
        return obj.toString()
    }
}