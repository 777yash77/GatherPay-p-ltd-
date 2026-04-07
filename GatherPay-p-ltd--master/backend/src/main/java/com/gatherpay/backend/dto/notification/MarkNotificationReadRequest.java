package com.gatherpay.backend.dto.notification;

import jakarta.validation.constraints.NotNull;

public record MarkNotificationReadRequest(
        @NotNull(message = "Read status is required")
        Boolean read
) {
}
