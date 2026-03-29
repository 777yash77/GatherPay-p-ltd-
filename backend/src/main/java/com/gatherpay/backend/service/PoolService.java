package com.gatherpay.backend.service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gatherpay.backend.domain.PoolMemberRole;
import com.gatherpay.backend.dto.pool.ContributionRequest;
import com.gatherpay.backend.dto.pool.PoolMemberRequest;
import com.gatherpay.backend.dto.pool.PoolMemberResponse;
import com.gatherpay.backend.dto.pool.PoolRequest;
import com.gatherpay.backend.dto.pool.PoolResponse;
import com.gatherpay.backend.entity.Pool;
import com.gatherpay.backend.entity.PoolMember;
import com.gatherpay.backend.entity.UserAccount;
import com.gatherpay.backend.exception.BadRequestException;
import com.gatherpay.backend.exception.NotFoundException;
import com.gatherpay.backend.repository.PoolRepository;
import com.gatherpay.backend.repository.UserAccountRepository;

@Service
@Transactional
public class PoolService {

    private final PoolRepository poolRepository;
    private final UserAccountRepository userAccountRepository;
    private final NotificationService notificationService;

    public PoolService(
            PoolRepository poolRepository,
            UserAccountRepository userAccountRepository,
            NotificationService notificationService
    ) {
        this.poolRepository = poolRepository;
        this.userAccountRepository = userAccountRepository;
        this.notificationService = notificationService;
    }

    @Transactional(readOnly = true)
    public List<PoolResponse> getAllPools(String userEmail) {
        UserAccount currentUser = findUser(userEmail);
        return poolRepository.findDistinctByMembersPhoneNumberOrderByCreatedAtDesc(currentUser.getMobileNumber())
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public PoolResponse getPool(UUID poolId, String userEmail) {
        UserAccount currentUser = findUser(userEmail);
        Pool pool = findPool(poolId);
        ensurePoolMember(pool, currentUser);
        return toResponse(pool);
    }

    public PoolResponse createPool(PoolRequest request, String userEmail) {
        UserAccount currentUser = findUser(userEmail);
        validatePoolRequest(request, currentUser);

        Pool pool = new Pool();
        pool.setCreatedByUser(currentUser);
        applyRequest(pool, request);
        Pool savedPool = poolRepository.save(pool);
        notifyMembersAboutPool(savedPool, currentUser, true);
        return toResponse(savedPool);
    }

    public PoolResponse updatePool(UUID poolId, PoolRequest request, String userEmail) {
        UserAccount currentUser = findUser(userEmail);
        Pool pool = findPool(poolId);
        ensureAdmin(pool, currentUser);
        validatePoolRequest(request, currentUser);

        applyRequest(pool, request);
        Pool savedPool = poolRepository.save(pool);
        notifyMembersAboutPool(savedPool, currentUser, false);
        return toResponse(savedPool);
    }

    public PoolResponse contribute(UUID poolId, ContributionRequest request, String userEmail) {
        UserAccount currentUser = findUser(userEmail);
        Pool pool = findPool(poolId);
        ensurePoolMember(pool, currentUser);

        long collectedAmount = collectedAmount(pool);
        long remainingAmount = pool.getTargetAmount() - collectedAmount;
        if (request.amount() > remainingAmount) {
            throw new BadRequestException("Contribution amount exceeds the remaining target");
        }

        PoolMember member = pool.getMembers().stream()
                .filter(item -> item.getPhoneNumber().equals(currentUser.getMobileNumber()))
                .findFirst()
                .orElseThrow(() -> new BadRequestException("Contributor is not part of this pool"));

        member.setContributedAmount(member.getContributedAmount() + request.amount());
        member.setActivityScore(member.getActivityScore() + 2);

        if (request.upiId() != null && !request.upiId().isBlank()) {
            currentUser.setUpiId(request.upiId().trim());
            userAccountRepository.save(currentUser);
        }

        Pool savedPool = poolRepository.save(pool);
        notificationService.createContributionNotification(currentUser, savedPool.getName(), request.amount());
        return toResponse(savedPool);
    }

    public void deletePool(UUID poolId, String userEmail) {
        UserAccount currentUser = findUser(userEmail);
        Pool pool = findPool(poolId);
        ensureAdmin(pool, currentUser);
        poolRepository.delete(pool);
    }

    private void applyRequest(Pool pool, PoolRequest request) {
        pool.setName(request.name().trim());
        pool.setDescription(request.description().trim());
        pool.setTargetAmount(request.targetAmount());
        pool.setCategory(request.category().trim());
        pool.setStyle(request.style());
        pool.setSettlementMode(request.settlementMode());

        List<PoolMember> members = request.members().stream()
                .map(this::toEntity)
                .toList();

        String adminName = members.stream()
                .filter(member -> member.getRole() == PoolMemberRole.ADMIN)
                .findFirst()
                .map(PoolMember::getName)
                .orElseThrow(() -> new BadRequestException("Exactly one admin is required"));

        pool.setAdminName(adminName);
        pool.setMembers(members);
    }

    private PoolMember toEntity(PoolMemberRequest request) {
        PoolMember member = new PoolMember();
        member.setName(request.name().trim());
        member.setPhoneNumber(request.phoneNumber().trim());
        member.setContributedAmount(request.contributedAmount());
        member.setApprovalsGiven(request.approvalsGiven());
        member.setActivityScore(request.activityScore());
        member.setRole(request.role());
        return member;
    }

    private void validatePoolRequest(PoolRequest request, UserAccount currentUser) {
        long adminCount = request.members().stream()
                .filter(member -> member.role() == PoolMemberRole.ADMIN)
                .count();
        if (adminCount != 1) {
            throw new BadRequestException("Exactly one admin is required");
        }

        Set<String> phoneNumbers = new HashSet<>();
        for (PoolMemberRequest member : request.members()) {
            String normalizedPhone = member.phoneNumber().trim();
            if (!phoneNumbers.add(normalizedPhone)) {
                throw new BadRequestException("Duplicate member phone numbers are not allowed");
            }
        }

        boolean currentUserIncluded = request.members().stream()
                .anyMatch(member -> member.phoneNumber().trim().equals(currentUser.getMobileNumber()));
        if (!currentUserIncluded) {
            throw new BadRequestException("The signed-in user must stay in the pool");
        }
    }

    private void ensurePoolMember(Pool pool, UserAccount currentUser) {
        boolean isMember = pool.getMembers().stream()
                .anyMatch(member -> member.getPhoneNumber().equals(currentUser.getMobileNumber()));
        if (!isMember) {
            throw new NotFoundException("Pool not found");
        }
    }

    private void ensureAdmin(Pool pool, UserAccount currentUser) {
        boolean isAdmin = pool.getMembers().stream()
                .anyMatch(member -> member.getPhoneNumber().equals(currentUser.getMobileNumber())
                        && member.getRole() == PoolMemberRole.ADMIN);
        if (!isAdmin) {
            throw new BadRequestException("Only a pool admin can perform this action");
        }
    }

    private void notifyMembersAboutPool(Pool pool, UserAccount actor, boolean created) {
        List<String> phoneNumbers = pool.getMembers().stream()
                .map(PoolMember::getPhoneNumber)
                .distinct()
                .toList();

        userAccountRepository.findAllByMobileNumberIn(phoneNumbers).forEach(user -> {
            if (user.getId().equals(actor.getId())) {
                return;
            }

            if (created) {
                notificationService.createPoolAddedNotification(user, pool.getName(), actor.getName());
            } else {
                notificationService.createPoolUpdatedNotification(user, pool.getName());
            }
        });
    }

    private UserAccount findUser(String email) {
        return userAccountRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new NotFoundException("User not found"));
    }

    private Pool findPool(UUID poolId) {
        return poolRepository.findById(poolId)
                .orElseThrow(() -> new NotFoundException("Pool not found"));
    }

    private PoolResponse toResponse(Pool pool) {
        long collectedAmount = collectedAmount(pool);
        long remainingAmount = Math.max(0L, pool.getTargetAmount() - collectedAmount);
        double progress = pool.getTargetAmount() == 0
                ? 0.0
                : Math.min(1.0, (double) collectedAmount / pool.getTargetAmount());

        List<PoolMemberResponse> members = pool.getMembers().stream()
                .map(member -> new PoolMemberResponse(
                        member.getId(),
                        member.getName(),
                        member.getPhoneNumber(),
                        member.getContributedAmount(),
                        member.getApprovalsGiven(),
                        member.getActivityScore(),
                        member.getRole()
                ))
                .toList();

        return new PoolResponse(
                pool.getId(),
                pool.getName(),
                pool.getDescription(),
                pool.getTargetAmount(),
                collectedAmount,
                remainingAmount,
                progress,
                pool.getCategory(),
                pool.getAdminName(),
                pool.getStyle(),
                pool.getSettlementMode(),
                pool.getCreatedAt(),
                members
        );
    }

    private long collectedAmount(Pool pool) {
        return pool.getMembers().stream()
                .mapToLong(PoolMember::getContributedAmount)
                .sum();
    }
}
