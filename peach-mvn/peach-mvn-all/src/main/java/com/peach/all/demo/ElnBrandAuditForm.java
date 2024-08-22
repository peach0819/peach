package com.peach.all.demo;

import java.io.Serializable;

public class ElnBrandAuditForm implements Serializable {

    private static final long serialVersionUID = -3632802796033177582L;

    /**
     * 4、达能门店品牌开通审批结果
     * 5、达能门店品牌关闭审批结果
     */
    private Integer bizType;

    /**
     * 达能门店编码
     */
    private String elnStoreCode;

    /**
     * e购开通品牌
     */
    private String signBrand;

    /**
     * 审核是否通过
     */
    private Boolean auditSuccess;

    /**
     * 审核结果信息
     */
    private String auditMsg;

    public Integer getBizType() {
        return bizType;
    }

    public void setBizType(Integer bizType) {
        this.bizType = bizType;
    }

    public String getElnStoreCode() {
        return elnStoreCode;
    }

    public void setElnStoreCode(String elnStoreCode) {
        this.elnStoreCode = elnStoreCode;
    }

    public String getSignBrand() {
        return signBrand;
    }

    public void setSignBrand(String signBrand) {
        this.signBrand = signBrand;
    }

    public Boolean getAuditSuccess() {
        return auditSuccess;
    }

    public void setAuditSuccess(Boolean auditSuccess) {
        this.auditSuccess = auditSuccess;
    }

    public String getAuditMsg() {
        return auditMsg;
    }

    public void setAuditMsg(String auditMsg) {
        this.auditMsg = auditMsg;
    }
}