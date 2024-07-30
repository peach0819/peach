package com.peach.all.demo;

import java.io.Serializable;

/**
 * 达能门店信息同步Form
 *
 * @author kai.kingS
 * @create by 2024/7/25 13:35
 **/
public class ElnShopForm implements Serializable {

    private static final long serialVersionUID = -8908544027177024120L;

    /**
     * 业务操作类型
     * 1、达能门店新增
     * 2、达能门店变更
     */
    private Integer bizType;

    /**
     * 达能门店编码
     */
    private String elnStoreCode;

    /**
     * 达能门店名称
     */
    private String elnStoreName;

    /**
     * 达能门店状态
     * 0.正常,1.审核中,2.审核失败,3.冻结,4.关店,5.待审核
     */
    private Integer elnStoreStatus;

    /**
     * 达能门店类型
     * 0:直接订货门店，1：总仓配货门店，2：总仓和门店
     */
    private Integer elnStoreType;

    /**
     * 达能登录帐号
     */
    private String elnLoginAccount;

    /**
     * 达能登录密码
     */
    private String elnLoginPassword;

    /**
     * 门店营业执照编码(统一社会信用代码)
     */
    private String licenseCode;

    /**
     * 营业执照名称
     */
    private String licenseName;

    /**
     * 营业执照图片
     */
    private String licensePhoto;

    /**
     * 营业执照法人
     */
    private String licensePerson;

    /**
     * 营业执照法人身份证号
     */
    private String licensePersonCardId;

    /**
     * 店外门头照片
     */
    private String photoFront;

    /**
     * 店内陈列照片
     */
    private String photoInner;

    /**
     * 联系人名称
     */
    private String linkerName;

    /**
     * 联系人电话
     */
    private String linkerPhone;

    /**
     * 省
     */
    private String province;

    /**
     * 市
     */
    private String city;

    /**
     * 区
     */
    private String area;

    /**
     * 街道
     */
    private String street;

    /**
     * 完整门店地址
     */
    private String address;

    /**
     * 经度
     */
    private String longitude;

    /**
     * 纬度
     */
    private String latitude;

    /**
     * SPC是否存在 0存在 1不存在
     */
    private Integer hasSpc;

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

    public String getElnStoreName() {
        return elnStoreName;
    }

    public void setElnStoreName(String elnStoreName) {
        this.elnStoreName = elnStoreName;
    }

    public Integer getElnStoreStatus() {
        return elnStoreStatus;
    }

    public void setElnStoreStatus(Integer elnStoreStatus) {
        this.elnStoreStatus = elnStoreStatus;
    }

    public Integer getElnStoreType() {
        return elnStoreType;
    }

    public void setElnStoreType(Integer elnStoreType) {
        this.elnStoreType = elnStoreType;
    }

    public String getElnLoginAccount() {
        return elnLoginAccount;
    }

    public void setElnLoginAccount(String elnLoginAccount) {
        this.elnLoginAccount = elnLoginAccount;
    }

    public String getElnLoginPassword() {
        return elnLoginPassword;
    }

    public void setElnLoginPassword(String elnLoginPassword) {
        this.elnLoginPassword = elnLoginPassword;
    }

    public String getLicenseCode() {
        return licenseCode;
    }

    public void setLicenseCode(String licenseCode) {
        this.licenseCode = licenseCode;
    }

    public String getLicenseName() {
        return licenseName;
    }

    public void setLicenseName(String licenseName) {
        this.licenseName = licenseName;
    }

    public String getLicensePhoto() {
        return licensePhoto;
    }

    public void setLicensePhoto(String licensePhoto) {
        this.licensePhoto = licensePhoto;
    }

    public String getLicensePerson() {
        return licensePerson;
    }

    public void setLicensePerson(String licensePerson) {
        this.licensePerson = licensePerson;
    }

    public String getLicensePersonCardId() {
        return licensePersonCardId;
    }

    public void setLicensePersonCardId(String licensePersonCardId) {
        this.licensePersonCardId = licensePersonCardId;
    }

    public String getPhotoFront() {
        return photoFront;
    }

    public void setPhotoFront(String photoFront) {
        this.photoFront = photoFront;
    }

    public String getPhotoInner() {
        return photoInner;
    }

    public void setPhotoInner(String photoInner) {
        this.photoInner = photoInner;
    }

    public String getLinkerName() {
        return linkerName;
    }

    public void setLinkerName(String linkerName) {
        this.linkerName = linkerName;
    }

    public String getLinkerPhone() {
        return linkerPhone;
    }

    public void setLinkerPhone(String linkerPhone) {
        this.linkerPhone = linkerPhone;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public String getStreet() {
        return street;
    }

    public void setStreet(String street) {
        this.street = street;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getLongitude() {
        return longitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }

    public String getLatitude() {
        return latitude;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }

    public Integer getHasSpc() {
        return hasSpc;
    }

    public void setHasSpc(Integer hasSpc) {
        this.hasSpc = hasSpc;
    }
}
