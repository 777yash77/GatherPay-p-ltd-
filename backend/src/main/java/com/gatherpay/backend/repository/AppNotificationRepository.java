package com.gatherpay.backend.repository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gatherpay.backend.entity.AppNotification;

public interface AppNotificationRepository extends JpaRepository<AppNotification, UUID> {

    List<AppNotification> findByUserIdOrderByCreatedAtDesc(UUID userId);

    boolean existsByUserIdAndTypeAndCreatedAtBetween(UUID userId, String type, Instant start, Instant end);
}
