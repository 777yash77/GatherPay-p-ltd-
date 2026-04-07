package com.gatherpay.backend.service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gatherpay.backend.dto.notification.NotificationResponse;
import com.gatherpay.backend.entity.AppNotification;
import com.gatherpay.backend.entity.UserAccount;
import com.gatherpay.backend.exception.NotFoundException;
import com.gatherpay.backend.repository.AppNotificationRepository;
import com.gatherpay.backend.repository.PoolRepository;
import com.gatherpay.backend.repository.UserAccountRepository;

@Service
@Transactional
public class NotificationService {

    private static final ZoneId INDIA = ZoneId.of("Asia/Kolkata");

    private final AppNotificationRepository notificationRepository;
    private final UserAccountRepository userAccountRepository;
    private final PoolRepository poolRepository;

    public NotificationService(
            AppNotificationRepository notificationRepository,
            UserAccountRepository userAccountRepository,
            PoolRepository poolRepository
    ) {
        this.notificationRepository = notificationRepository;
        this.userAccountRepository = userAccountRepository;
        this.poolRepository = poolRepository;
    }

    @Transactional(readOnly = true)
    public List<NotificationResponse> getNotifications(UUID userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public NotificationResponse markAsRead(UUID userId, UUID notificationId, boolean read) {
        AppNotification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new NotFoundException("Notification not found"));

        if (!notification.getUser().getId().equals(userId)) {
            throw new NotFoundException("Notification not found");
        }

        notification.setRead(read);
        return toResponse(notificationRepository.save(notification));
    }

    public void createPoolAddedNotification(UserAccount user, String poolName, String adminName) {
        create(user, "POOL_ADDED", "You were added to a pool", "You were added to " + poolName + " by " + adminName + ".");
    }

    public void createPoolUpdatedNotification(UserAccount user, String poolName) {
        create(user, "POOL_UPDATED", "Pool updated", poolName + " was updated. Check the latest rules and members.");
    }

    public void createContributionNotification(UserAccount user, String poolName, long amount) {
        create(user, "CONTRIBUTION", "Contribution recorded", "Your contribution of Rs." + amount + " was added to " + poolName + ".");
    }

    public void createShareReceivedNotification(UserAccount user, String poolName, long amount) {
        create(
                user,
                "PAYOUT_SHARE_RECEIVED",
                "Share received",
                "Your share of Rs." + amount + " from " + poolName + " has been released."
        );
    }

    public void createAdminReceivedNotification(UserAccount user, String poolName, long amount) {
        create(
                user,
                "PAYOUT_ADMIN_RECEIVED",
                "Admin received pool amount",
                "You received Rs." + amount + " from " + poolName + " as the pool admin."
        );
    }

    public void createAdminControlledPayoutNotice(UserAccount user, String poolName, String adminName, long amount) {
        create(
                user,
                "PAYOUT_ADMIN_CONTROL",
                "Pool amount sent to admin",
                adminName + " received Rs." + amount + " from " + poolName + " under admin control."
        );
    }

    public void createPayoutReleasedNotification(UserAccount user, String poolName, long amount, boolean forced) {
        String reason = forced ? " after an admin force payout." : ".";
        create(
                user,
                "PAYOUT_RELEASED",
                "Payout released",
                "Payout of Rs." + amount + " was released for " + poolName + reason
        );
    }

    @Scheduled(cron = "0 0 9 * * *", zone = "Asia/Kolkata")
    public void createDailyReminders() {
        LocalDate today = LocalDate.now(INDIA);
        Instant start = today.atStartOfDay(INDIA).toInstant();
        Instant end = today.plusDays(1).atStartOfDay(INDIA).toInstant();

        userAccountRepository.findAll().forEach(user -> {
            boolean hasPool = !poolRepository.findDistinctByMembersPhoneNumberOrderByCreatedAtDesc(user.getMobileNumber()).isEmpty();
            boolean reminderExists = notificationRepository.existsByUserIdAndTypeAndCreatedAtBetween(
                    user.getId(),
                    "DAILY_REMINDER",
                    start,
                    end
            );

            if (hasPool && !reminderExists) {
                create(
                        user,
                        "DAILY_REMINDER",
                        "Daily pool reminder",
                        "Check your active pools today for contributions, approvals, and updates."
                );
            }
        });
    }

    private void create(UserAccount user, String type, String title, String message) {
        AppNotification notification = new AppNotification();
        notification.setUser(user);
        notification.setType(type);
        notification.setTitle(title);
        notification.setMessage(message);
        notificationRepository.save(notification);
    }

    private NotificationResponse toResponse(AppNotification notification) {
        return new NotificationResponse(
                notification.getId(),
                notification.getType(),
                notification.getTitle(),
                notification.getMessage(),
                notification.isRead(),
                notification.getCreatedAt()
        );
    }
}
