package com.peach.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class PeachController {

    @GetMapping("/pangzi/{name}")
    public String pangzi(@PathVariable String name) {
        return name + "是个胖子";
    }
}
