package com.gatherpay.backend.dto.pool;

import java.util.List;

import com.gatherpay.backend.domain.PoolSettlementMode;
import com.gatherpay.backend.domain.PoolStyle;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

public record PoolRequest(
        @NotBlank(message = "Pool name is required")
        String name,

        @NotBlank(message = "Pool description is required")
        String description,

        @Min(value = 1, message = "Target amount must be positive")
        long targetAmount,

        @NotBlank(message = "Category is required")
        String category,

        @NotNull(message = "Pool style is required")
        PoolStyle style,

        @NotNull(message = "Settlement mode is required")
        PoolSettlementMode settlementMode,

        @NotEmpty(message = "Pool must have at least one member")
        List<@Valid PoolMemberRequest> members
) {
}
