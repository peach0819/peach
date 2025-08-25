package com.peach.all.demo.openapi;

import com.winnerlook.model.PrivacyBindBodyAxb;
import com.winnerlook.model.TwoWayCallBody;
import com.winnerlook.model.VoiceResponseResult;
import com.winnerlook.service.VoiceSender;

/**
 * @Author: FrankZhang
 * @Description:
 * @Date: 1/25/2018
 * @Modified by:
 **/
public class TwowayCallTest {

    public static void main(String[] args) throws Exception {
        /*请修改为平台分配的accountId*/
        String accountId="";
        /*请修改为平台分配的token*/
        String token="";
        /*请修改为平台分配的主显号码*/
        String displayNumber="02557914556";
        /*请修改为需要推送话单的URL地址*/
        String callbackUrl="";

        PrivacyBindBodyAxb bindBodyAxb = new PrivacyBindBodyAxb();
        //bindBodyAxb.set



        ///**/
        //TwoWayCallBody callBody = new TwoWayCallBody();
        ///*设置已经分配的主显号码*/
        ////callBody.setDisplayNumber(displayNumber);
        ///*设置话单推送地址*/
        //callBody.setCallbackUrl(callbackUrl);
        ///*是否需要录音 :1 需要录音; 0: 不需要录音*/
        //callBody.setCallRec(1);
        ///*设置被叫号码*/
        //callBody.setCalleeNumber("");
        ///*设置主叫号码*/
        //callBody.setCallerNumber("");
        ///*设置允许的最大呼叫时长*/
        //callBody.setMaxDuration(3600);
        //
        //VoiceResponseResult result = VoiceSender.httpsSendTwoWayCall(callBody, accountId, token);
        //
        //System.out.println("result = " + result);

    }
}
