package com.gatherpay.backend.dto.pool;

import java.util.UUID;

import com.gatherpay.backend.domain.PoolMemberRole;

public record PoolMemberResponse(
        UUID id,
        String name,
        String phoneNumber,
        long contributedAmount,
        int approvalsGiven,
        int activityScore,
        PoolMemberRole role
) {
}
