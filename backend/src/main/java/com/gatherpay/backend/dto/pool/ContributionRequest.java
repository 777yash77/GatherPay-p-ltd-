package com.gatherpay.backend.dto.pool;

import jakarta.validation.constraints.Min;
public record ContributionRequest(
        @Min(value = 1, message = "Contribution amount must be at least 1")
        long amount,

        String upiId
) {
}
