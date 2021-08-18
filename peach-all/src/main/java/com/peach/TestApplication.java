package com.peach;

import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.essentials4j.New;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2021/6/28
 */
@Slf4j
public class TestApplication {

    public static void main(String[] args) {
        List<String> tagNameList = getTagNameList("1,2,3,4,5,6");
        System.out.println(tagNameList);
    }

    /**
     * 获取拆分后的标签列表
     */
    public static List<String> getTagNameList(String tag) {
        if (StringUtils.isBlank(tag)) {
            return new ArrayList<>();
        }
        return New.list(tag.split(","));
    }

    class AreaBrand {

        Long spId;
        String spName;
        Long areaId;
        Long brandId;

        String areaName;
        String brandName;
    }
}
