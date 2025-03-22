package com.peach.all.demo.openapi;

import lombok.Data;

import java.io.Serializable;

/**
 * @author feitao.zt
 * @date 2024/12/25
 */
@Data
public class ElnVersionForm implements Serializable {

    private static final long serialVersionUID = -6583974990716336096L;

    /**
     * 版本类型 1:SPC打卡数据 2:SPC陈列数据 3:POS库存数据 4:POS订单数据
     */
    private Integer versionType;
}
