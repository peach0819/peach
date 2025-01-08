package com.peach.all.demo.openapi;

import lombok.Data;

import java.io.Serializable;

/**
 * @author feitao.zt
 * @date 2024/12/24
 */
@Data
public class ElnVersionSyncSpcDutyForm implements Serializable {

    private static final long serialVersionUID = -5978533439709414135L;

    /**
     * spc的employeeId
     */
    private String spcId;

    /**
     * 本月打卡次数
     */
    private Integer dutyCount;

    public ElnVersionSyncSpcDutyForm(String spcId, Integer dutyCount) {
        this.spcId = spcId;
        this.dutyCount = dutyCount;
    }
}
