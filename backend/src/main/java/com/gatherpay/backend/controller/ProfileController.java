package com.gatherpay.backend.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.gatherpay.backend.dto.user.UpdateProfileRequest;
import com.gatherpay.backend.dto.user.UserProfileResponse;
import com.gatherpay.backend.security.AuthenticatedUser;
import com.gatherpay.backend.service.ProfileService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/profile")
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @GetMapping
    public UserProfileResponse getProfile(@AuthenticationPrincipal AuthenticatedUser user) {
        return profileService.getProfile(user.getUsername());
    }

    @PutMapping
    public UserProfileResponse updateProfile(
            @AuthenticationPrincipal AuthenticatedUser user,
            @Valid @RequestBody UpdateProfileRequest request
    ) {
        return profileService.updateProfile(user.getUsername(), request);
    }
}
