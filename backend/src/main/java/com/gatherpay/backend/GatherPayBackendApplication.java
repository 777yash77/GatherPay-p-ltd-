package com.gatherpay.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class GatherPayBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(GatherPayBackendApplication.class, args);
    }
}
