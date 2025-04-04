package com.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.net.InetAddress;
import java.net.UnknownHostException;

@RestController
public class HelloController {

    @GetMapping("/")
    public String hello() {
        try {
            String hostname = InetAddress.getLocalHost().getHostName();
            return "<h1>Hello from Java multi-stage build! 🚀</h1>" +
                   "<p>Container hostname: " + hostname + "</p>";
        } catch (UnknownHostException e) {
            return "<h1>Hello from Java multi-stage build! 🚀</h1>" +
                   "<p>Container hostname: unknown</p>";
        }
    }

    @GetMapping("/health")
    public String health() {
        return "OK";
    }
} 