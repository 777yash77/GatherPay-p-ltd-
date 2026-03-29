package com.gatherpay.backend.controller;

import java.util.List;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.gatherpay.backend.dto.user.UserDirectoryEntryResponse;
import com.gatherpay.backend.security.AuthenticatedUser;
import com.gatherpay.backend.service.UserDirectoryService;

@RestController
@RequestMapping("/api/users")
public class UserDirectoryController {

    private final UserDirectoryService userDirectoryService;

    public UserDirectoryController(UserDirectoryService userDirectoryService) {
        this.userDirectoryService = userDirectoryService;
    }

    @GetMapping("/search")
    public List<UserDirectoryEntryResponse> searchUsers(
            @RequestParam("q") String query,
            @AuthenticationPrincipal AuthenticatedUser user
    ) {
        return userDirectoryService.search(query, user.getUsername());
    }
}
