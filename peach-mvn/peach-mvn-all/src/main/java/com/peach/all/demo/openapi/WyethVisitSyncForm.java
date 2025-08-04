package com.peach.all.demo.openapi;

import lombok.Data;

import java.io.Serializable;

/**
 * @author feitao.zt
 * @date 2025/7/29
 */
@Data
public class WyethVisitSyncForm implements Serializable {

    private static final long serialVersionUID = -2881557676263154553L;

    /**
     * 拜访小记id
     */
    private String visitId;

    /**
     * 审核结果 true通过 false不通过
     */
    private Boolean auditResult;

    /**
     * 审核信息
     */
    private String auditMsg;
}
