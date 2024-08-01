package message.parser.weixin09;

import com.ytgw.common.util.StringUtil;
import com.ytgw.core.shared.exception.code.ParserErrorCode;
import com.ytgw.core.shared.message.domain.SupergwMessage;
import com.ytgw.core.shared.service.message.parser.TextMessageParser;
import com.ytgw.core.shared.message.domain.json.MessageJsonConvert;
import groovy.json.JsonSlurper;
import com.ytgw.common.util.JsonUtil;

/**
 * 微信信息-生成urllink
 */
public class weixin09099901 extends TextMessageParser {

    public SupergwMessage parse(String message) {
        SupergwMessage gw = new SupergwMessage();
        message = StringUtil.trim(message);
        if (StringUtil.isBlank(message)) {
            gw.setChannelResponseCode(ParserErrorCode.EMPTY_MESSAGE.getCode());
            gw.setBusinessResultCode(ParserErrorCode.EMPTY_MESSAGE.getCode());
            gw.setChannelResponseMessage("空报文！");
            return gw;
        }
        String responseCode = "SUCCESS";
        String businessResultCode = "SUCCESS";
        String responseMessage = "成功";
        String resJson = "{\"res\":"+message+"}";
        SupergwMessage outMessage = MessageJsonConvert.toObject(resJson);
        addFieldMappings(gw,outMessage);
        gw.addField("origResponse",message);
        gw.setChannelResponseCode(responseCode);
        gw.setBusinessResultCode(businessResultCode);
        gw.setChannelResponseMessage(responseMessage);
        gw.addField("CHANNEL_RESPONSE_TYPE", "SUCCESS");
        return gw;
    }

    /**
     * outMessage: 从外面请求到hipac的消息
     * inMessage: 网关发送给后端的消息
     **/
    public void addFieldMappings(SupergwMessage inMessage, SupergwMessage outMessage){
        inMessage.addField("errcode",outMessage.g("errcode"));
        inMessage.addField("url_link",outMessage.g("url_link"));
        inMessage.addField("errmsg",outMessage.g("errmsg"));

    }

    public void share(SupergwMessage inMessage, SupergwMessage outMessage) {
        inMessage.addField("outOrderNo", outMessage.g("orderNo"));
    }
}
