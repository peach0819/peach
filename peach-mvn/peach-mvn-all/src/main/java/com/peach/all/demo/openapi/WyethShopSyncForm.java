package com.peach.all.demo.openapi;

import lombok.Data;

import java.io.Serializable;

/**
 * @author feitao.zt
 * @date 2025/8/1
 */
@Data
public class WyethShopSyncForm implements Serializable {

    private static final long serialVersionUID = 1003337898764984842L;

    /**
     * 惠氏门店编码
     */
    private String wyethStoreCode;

    /**
     * 审核结果 true通过 false不通过
     */
    private Boolean auditResult;

    /**
     * 审核信息
     */
    private String auditMsg;
}
