package com.gatherpay.backend.dto.pool;

import java.time.Instant;
import java.util.UUID;

public record PoolChatMessageResponse(
        UUID id,
        String senderName,
        String senderPhoneNumber,
        String message,
        Instant createdAt
) {
}
