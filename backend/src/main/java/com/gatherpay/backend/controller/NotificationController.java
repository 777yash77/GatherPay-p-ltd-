package com.gatherpay.backend.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.gatherpay.backend.dto.notification.MarkNotificationReadRequest;
import com.gatherpay.backend.dto.notification.NotificationResponse;
import com.gatherpay.backend.security.AuthenticatedUser;
import com.gatherpay.backend.service.NotificationService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public List<NotificationResponse> getNotifications(@AuthenticationPrincipal AuthenticatedUser user) {
        return notificationService.getNotifications(user.getId());
    }

    @PatchMapping("/{notificationId}")
    public NotificationResponse markAsRead(
            @AuthenticationPrincipal AuthenticatedUser user,
            @PathVariable UUID notificationId,
            @Valid @RequestBody MarkNotificationReadRequest request
    ) {
        return notificationService.markAsRead(user.getId(), notificationId, request.read());
    }
}
