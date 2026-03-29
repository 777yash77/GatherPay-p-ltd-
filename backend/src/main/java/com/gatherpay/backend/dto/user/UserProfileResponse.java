package com.gatherpay.backend.dto.user;

import java.time.Instant;
import java.util.UUID;

public record UserProfileResponse(
        UUID id,
        String name,
        String email,
        String mobileNumber,
        String city,
        String upiId,
        boolean profileCompleted,
        Instant createdAt
) {
}
