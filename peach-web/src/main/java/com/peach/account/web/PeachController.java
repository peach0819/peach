package com.peach.account.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class PeachController {

    @GetMapping("/pangzi")
    public String helloWorld() {
        return "王青青是个胖子";
    }
}
