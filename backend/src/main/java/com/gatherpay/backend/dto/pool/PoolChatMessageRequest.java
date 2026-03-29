package com.gatherpay.backend.dto.pool;

import jakarta.validation.constraints.NotBlank;

public record PoolChatMessageRequest(
        @NotBlank(message = "Message is required")
        String message
) {
}
