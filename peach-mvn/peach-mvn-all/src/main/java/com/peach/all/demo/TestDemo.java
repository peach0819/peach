package com.peach.all.demo;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.TypeReference;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/2/21
 */
public class TestDemo {

    static String a = "{\n"
            + "  \"teamColumnList\": [\n"
            + "    {\n"
            + "      \"code\": \"numerator\",\n"
            + "      \"name\": \"已拜访频次\"\n"
            + "    },\n"
            + "    {\n"
            + "      \"code\": \"denominator\",\n"
            + "      \"name\": \"目标拜访频次\"\n"
            + "    },\n"
            + "    {\n"
            + "      \"code\": \"indicator\",\n"
            + "      \"name\": \"达成率\"\n"
            + "    },\n"
            + "    {\n"
            + "      \"code\": \"reach\",\n"
            + "      \"name\": \"是否达标\"\n"
            + "    }\n"
            + "  ],\n"
            + "  \"detailColumnList\": [\n"
            + "    {\n"
            + "      \"code\": \"service_obj_id\",\n"
            + "      \"name\": \"拜访对象编码\"\n"
            + "    },\n"
            + "    {\n"
            + "      \"code\": \"service_obj_name\",\n"
            + "      \"name\": \"拜访对象名称\"\n"
            + "    },\n"
            + "    {\n"
            + "      \"code\": \"indicator\",\n"
            + "      \"name\": \"覆盖次数\"\n"
            + "    },\n"
            + "    {\n"
            + "      \"code\": \"reach\",\n"
            + "      \"name\": \"是否达标\"\n"
            + "    }\n"
            + "  ]\n"
            + "}";

    public static void main(String[] args) {
        String trim = a.trim();
        System.out.println(trim);
    }

}
