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
     * 统一信用代码
     */
    private String uscc;

    /**
     * 审核结果 true通过 false不通过
     */
    private Boolean auditResult;

    /**
     * 审核信息
     */
    private String auditMsg;
}
