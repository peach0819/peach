package com.peach.all.demo.openapi;

import lombok.Data;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/12/24
 */
@Data
public class ElnVersionSyncSpcPhotoForm implements Serializable {

    private static final long serialVersionUID = 1830326772120066415L;

    /**
     * 达能门店编码code
     */
    private String elnStoreCode;

    /**
     * spc的employeeId
     */
    private String spcId;

    /**
     * 拍摄时间
     */
    private Date photoTime;

    /**
     * 照片所属月份 yyyyMM格式
     */
    private String photoMonth;

    /**
     * 图片链接
     */
    private String photoUrl;

    /**
     * 识别出的商品列表
     */
    private List<PhotoSkuForm> itemList;

    /**
     * 识别出的物料列表
     */
    private List<PhotoSkuForm> posList;

    @Data
    public static class PhotoSkuForm implements Serializable {

        private static final long serialVersionUID = -6805559068797908864L;

        /**
         * 达能skuId
         */
        private String skuId;

        /**
         * sku名称
         */
        private String skuName;

        /**
         * 数量
         */
        private Integer num;

    }

}
