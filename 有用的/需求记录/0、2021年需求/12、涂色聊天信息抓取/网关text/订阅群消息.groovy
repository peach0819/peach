package message.parser.tuseqiwei09;

import com.ytgw.common.util.StringUtil;
import com.ytgw.core.shared.exception.code.ParserErrorCode;
import com.ytgw.core.shared.message.domain.SupergwMessage;
import com.ytgw.core.shared.service.message.parser.TextMessageParser;
import groovy.json.JsonSlurper

/**
 * 涂色企微-订阅群聊消息
 */
public class tuseqiwei09180206 extends TextMessageParser {

    public SupergwMessage parse(String message) {
        SupergwMessage gw = new SupergwMessage();
        message = StringUtil.trim(message);
        if (StringUtil.isBlank(message)) {
            gw.setChannelResponseCode(ParserErrorCode.EMPTY_MESSAGE.getCode());
            gw.setBusinessResultCode(ParserErrorCode.EMPTY_MESSAGE.getCode());
            gw.setChannelResponseMessage("空报文！");
            return gw;
        }
        def json = new JsonSlurper().parseText(message)
        String responseCode = "SUCCESS";
        String businessResultCode = "SUCCESS";
        String responseMessage = "成功";

        gw.addField("origResponse",message)
        gw.setChannelResponseCode(responseCode);
        gw.setBusinessResultCode(businessResultCode);
        gw.setChannelResponseMessage(responseMessage);
        gw.addField("CHANNEL_RESPONSE_TYPE", "SUCCESS");
        return gw;
    }

    public void share(SupergwMessage inMessage, SupergwMessage outMessage) {
        inMessage.addField("outOrderNo", outMessage.g("orderNo"));
    }
}