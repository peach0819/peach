package com.peach.all.demo.openapi;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/12/24
 */
@Data
public class ElnVersionSyncForm<T> implements Serializable {

    private static final long serialVersionUID = 481833093573034891L;

    /**
     * 版本id
     */
    private Long versionId;

    /**
     * 是否最后一页
     */
    private boolean isLastPage;

    /**
     * 数据集合
     */
    private List<T> dataList;

}
