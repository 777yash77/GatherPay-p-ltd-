package com.gatherpay.backend.dto.auth;

import com.gatherpay.backend.dto.user.UserProfileResponse;

public record AuthResponse(
        String accessToken,
        String tokenType,
        UserProfileResponse user
) {
}
