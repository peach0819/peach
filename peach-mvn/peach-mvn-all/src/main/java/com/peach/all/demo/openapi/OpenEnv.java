package com.peach.all.demo.openapi;

/**
 * @author feitao.zt
 * @date 2025/8/4
 */
public enum OpenEnv {

    DANONE_MASTER("HIPAC91", "11c80b2461aed9c663ea89d144784634", "master", "https://master-openapi.hipac.cn"),

    DANONE_PROD("HIPAC2018050210020252", "1d63a1267912731d8224a54c402e464c", "prod", "https://openapi.hipac.cn"),

    WYETH_MASTER("HIPAC106", "b497bd1570365eb2cab207a8de9b8c2e", "master", "https://master-openapi.hipac.cn"),

    WYETH_PROD("HIPAC2018050210020332", "9de69327281943583a20c3dbd58338b3", "prod", "https://openapi.hipac.cn"),

    WYETH_PRE("HIPAC2018050210020332", "9de69327281943583a20c3dbd58338b3", "pre", "https://pre-openapi.hipac.cn");

    private final String appKey;
    private final String secret;
    private final String env;
    private final String host;

    public String getAppKey() {
        return appKey;
    }

    public String getSecret() {
        return secret;
    }

    public String getEnv() {
        return env;
    }

    public String getHost() {
        return host;
    }

    OpenEnv(String appKey, String secret, String env, String host) {
        this.appKey = appKey;
        this.secret = secret;
        this.env = env;
        this.host = host;
    }
}
