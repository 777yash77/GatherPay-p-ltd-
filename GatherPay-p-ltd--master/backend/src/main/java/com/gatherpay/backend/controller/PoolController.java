package com.gatherpay.backend.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.gatherpay.backend.dto.pool.ContributionRequest;
import com.gatherpay.backend.dto.pool.PayoutRequest;
import com.gatherpay.backend.dto.pool.PoolChatMessageRequest;
import com.gatherpay.backend.dto.pool.PoolChatMessageResponse;
import com.gatherpay.backend.dto.pool.PoolRequest;
import com.gatherpay.backend.dto.pool.PoolResponse;
import com.gatherpay.backend.security.AuthenticatedUser;
import com.gatherpay.backend.service.PoolService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/pools")
public class PoolController {

    private final PoolService poolService;

    public PoolController(PoolService poolService) {
        this.poolService = poolService;
    }

    @GetMapping
    public List<PoolResponse> getAllPools(@AuthenticationPrincipal AuthenticatedUser user) {
        return poolService.getAllPools(user.getUsername());
    }

    @GetMapping("/{poolId}")
    public PoolResponse getPool(@PathVariable UUID poolId, @AuthenticationPrincipal AuthenticatedUser user) {
        return poolService.getPool(poolId, user.getUsername());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PoolResponse createPool(
            @Valid @RequestBody PoolRequest request,
            @AuthenticationPrincipal AuthenticatedUser user
    ) {
        return poolService.createPool(request, user.getUsername());
    }

    @PutMapping("/{poolId}")
    public PoolResponse updatePool(
            @PathVariable UUID poolId,
            @Valid @RequestBody PoolRequest request,
            @AuthenticationPrincipal AuthenticatedUser user
    ) {
        return poolService.updatePool(poolId, request, user.getUsername());
    }

    @PostMapping("/{poolId}/contributions")
    public PoolResponse contribute(
            @PathVariable UUID poolId,
            @Valid @RequestBody ContributionRequest request,
            @AuthenticationPrincipal AuthenticatedUser user
    ) {
        return poolService.contribute(poolId, request, user.getUsername());
    }

    @GetMapping("/{poolId}/chat")
    public List<PoolChatMessageResponse> getChatMessages(
            @PathVariable UUID poolId,
            @AuthenticationPrincipal AuthenticatedUser user
    ) {
        return poolService.getChatMessages(poolId, user.getUsername());
    }

    @PostMapping("/{poolId}/chat")
    @ResponseStatus(HttpStatus.CREATED)
    public PoolChatMessageResponse addChatMessage(
            @PathVariable UUID poolId,
            @Valid @RequestBody PoolChatMessageRequest request,
            @AuthenticationPrincipal AuthenticatedUser user
    ) {
        return poolService.addChatMessage(poolId, request, user.getUsername());
    }

    @PostMapping("/{poolId}/payout")
    public PoolResponse payout(
            @PathVariable UUID poolId,
            @RequestBody(required = false) PayoutRequest request,
            @AuthenticationPrincipal AuthenticatedUser user
    ) {
        return poolService.payout(poolId, request == null ? new PayoutRequest(false) : request, user.getUsername());
    }

    @DeleteMapping("/{poolId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deletePool(@PathVariable UUID poolId, @AuthenticationPrincipal AuthenticatedUser user) {
        poolService.deletePool(poolId, user.getUsername());
    }
}
