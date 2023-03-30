package com.peach.all.util;

import java.lang.reflect.Field;

public class MybatisUtil {

    // 获取bean的属性 根据属性评价 resultMap
    public static String getResultMap(Class<?> cls) {
        String str = "";
        // 每一行字符串 <result column="BID_SECTION_CODE" property="BID_SECTION_CODE" jdbcType="VARCHAR" />
        String linestr = "";
        Field[] declaredFields = cls.getDeclaredFields();
        for (Field field : declaredFields) {
            if (field.getType().getName().equals("java.lang.String")) {
                linestr = "<result column=\"" + field.getName() + "\" property=\"" + field.getName()
                        + "\" jdbcType=\"VARCHAR\" />";
            } else {
                linestr = "<result column=\"" + field.getName() + "\" property=\"" + field.getName()
                        + "\" jdbcType=\"INTEGER\" />";
            }
            System.out.println(linestr);
        }
        return str;
    }

    // 获取bean的属性 根据属性评价 resultMap 并将驼峰修改为'_'
    public static String getResultMapNew(Class<?> cls) {
        // 头部 <resultMap id="BaseResultMap" type="com.huajie.entity.sys.SysMenuinfo">
        StringBuilder str = new StringBuilder(
                "<resultMap id=" + cls.getSimpleName() + "ResultMap type=" + cls.getName() + "> \r\n");
        // 每一行字符串
        String linestr = "";
        Field[] declaredFields = cls.getDeclaredFields();
        for (Field field : declaredFields) {
            if (field.getType().getName().equals("java.lang.String")) {
                linestr = "<result column=\"" + CamelUtil.camel2underscore(field.getName()) + "\" property=\"" + field.getName()
                        + "\" jdbcType=\"VARCHAR\" />";
            } else {
                linestr = "<result column=\"" + CamelUtil.camel2underscore(field.getName()) + "\" property=\"" + field.getName()
                        + "\" jdbcType=\"INTEGER\" />";
            }
            linestr += "\r\n";
            str.append(linestr);
        }
        str.append("</resultMap>");
        return str.toString();
    }

    // 获取Base_Column_List sql语句字段
    public static String getColumnList(Class<?> cls) {
        // 每一行字符串 <result column="BID_SECTION_CODE" property="BID_SECTION_CODE" jdbcType="VARCHAR" />
        StringBuilder linestr = new StringBuilder();
        Field[] declaredFields = cls.getDeclaredFields();
        for (Field field : declaredFields) {
            linestr.append(field.getName()).append(",");
        }
        String str = linestr.substring(0, linestr.length() - 1);
        System.out.println(str);
        return str;
    }

    /**
     * 输出字符串中的大写字母
     */
    private static String getColumnListNew(Class<?> cls) {
        // 每一行字符串 <result column="BID_SECTION_CODE" property="BID_SECTION_CODE" jdbcType="VARCHAR" />
        StringBuilder linestr = new StringBuilder();
        Field[] declaredFields = cls.getDeclaredFields();
        for (Field field : declaredFields) {
            linestr.append(CamelUtil.camel2underscore(field.getName())).append(",");
        }
        String str = linestr.substring(0, linestr.length() - 1);
        System.out.println(str);
        return str;
    }

}
