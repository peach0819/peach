package com.peach.common.util;

import com.google.common.base.CaseFormat;

public class CamelUtil {

    /**
     * 驼峰转下划线
     * testData -> test_data
     */
    public static String camel2underscore(String str) {
        return CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, str);
    }

    /**
     * 下划线转驼峰
     * test_data -> testData
     */
    public static String underscore2camel(String str) {
        return CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, str);
    }
}
