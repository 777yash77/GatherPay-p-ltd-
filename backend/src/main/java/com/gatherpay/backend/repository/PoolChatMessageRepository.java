package com.gatherpay.backend.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gatherpay.backend.entity.PoolChatMessage;

public interface PoolChatMessageRepository extends JpaRepository<PoolChatMessage, UUID> {

    List<PoolChatMessage> findByPoolIdOrderByCreatedAtAsc(UUID poolId);
}
