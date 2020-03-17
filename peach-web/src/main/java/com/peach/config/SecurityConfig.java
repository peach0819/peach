package com.peach.config;

//import com.peach.dao.UserDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

/**
 * 不使用Security包自带的安全认证，采用自定义的登录配置
 */
@Configuration
@EnableWebSecurity  //把该配置变成一个WebSecurityConfiguration 的@Bean
public class SecurityConfig extends WebSecurityConfigurerAdapter {

//    @Autowired
//    private UserDao userDao;

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
                .antMatchers("/").access("hasRole('READER')").antMatchers("/**").permitAll() //要求拥有READER角色
                .and()
                .formLogin().loginPage("/login").failureUrl("/login?error=true");  //设置登录表单的路径
    }

//    @Override
//    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
//        //定义userDetailService
//        auth.userDetailsService(username -> userDao.findSecurityUser(username));
//    }

}
