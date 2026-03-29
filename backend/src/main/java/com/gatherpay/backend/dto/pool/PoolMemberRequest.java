package com.gatherpay.backend.dto.pool;

import com.gatherpay.backend.domain.PoolMemberRole;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record PoolMemberRequest(
        @NotBlank(message = "Member name is required")
        String name,

        @NotBlank(message = "Member phone number is required")
        String phoneNumber,

        @Min(value = 0, message = "Contribution cannot be negative")
        long contributedAmount,

        @Min(value = 0, message = "Approvals cannot be negative")
        int approvalsGiven,

        @Min(value = 0, message = "Activity score cannot be negative")
        int activityScore,

        @NotNull(message = "Member role is required")
        PoolMemberRole role
) {
}
