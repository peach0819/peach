package com.peach.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Arrays;
import java.util.Collection;

@EqualsAndHashCode(callSuper = true)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SecurityUser extends AbstractDomain implements UserDetails {
    private static final long serialVersionUID = 938727535400190498L;

    private Integer id;
    private String name;
    private String userName;
    private String password;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Arrays.asList(new SimpleGrantedAuthority("READER"));  //赋予该类的实例READER属性
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return userName;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;  //永不过期
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;   //账户永不锁定
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;   //不会被注销
    }

    @Override
    public boolean isEnabled() {
        return true;  //可用
    }
}
