package com.peach.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public abstract class AbstractDomain {
    private Integer createUserId;
    private Date createTime;
    private Integer lastUpdateId;
    private Date lastUpdateTime;
}
