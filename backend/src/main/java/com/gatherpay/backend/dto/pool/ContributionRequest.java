package com.gatherpay.backend.dto.pool;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record ContributionRequest(
        @NotBlank(message = "Contributor phone number is required")
        String contributorPhoneNumber,

        @Min(value = 1, message = "Contribution amount must be at least 1")
        long amount,

        String upiId
) {
}
