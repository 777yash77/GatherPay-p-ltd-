package com.gatherpay.backend.dto.pool;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import com.gatherpay.backend.domain.PoolSettlementMode;
import com.gatherpay.backend.domain.PoolStyle;

public record PoolResponse(
        UUID id,
        String name,
        String description,
        long targetAmount,
        long collectedAmount,
        long remainingAmount,
        double progress,
        String category,
        String adminName,
        PoolStyle style,
        PoolSettlementMode settlementMode,
        Instant createdAt,
        List<PoolMemberResponse> members
) {
}
