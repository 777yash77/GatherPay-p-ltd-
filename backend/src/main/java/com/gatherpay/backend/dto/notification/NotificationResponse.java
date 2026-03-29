package com.gatherpay.backend.dto.notification;

import java.time.Instant;
import java.util.UUID;

public record NotificationResponse(
        UUID id,
        String type,
        String title,
        String message,
        boolean isRead,
        Instant createdAt
) {
}
