package com.peach;

import org.apache.catalina.core.ApplicationContext;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.ConfigurableApplicationContext;

@SpringBootApplication(scanBasePackages = "com.peach")
public class PeachApplication extends SpringBootServletInitializer {

    /**
     * 作用是，可以用来打包成war包
     */
    @Override
    public SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
        return builder.sources(PeachApplication.class);
    }

    public static void main(String[] args) {
        ConfigurableApplicationContext applicationContext = SpringApplication.run(PeachApplication.class, args);
        afterStart();
    }

    private static void afterStart() {
        System.out.println("peach最帅");
    }
}
