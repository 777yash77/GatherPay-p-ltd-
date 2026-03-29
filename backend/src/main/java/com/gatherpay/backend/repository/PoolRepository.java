package com.gatherpay.backend.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gatherpay.backend.entity.Pool;

public interface PoolRepository extends JpaRepository<Pool, UUID> {

    List<Pool> findDistinctByMembersPhoneNumberOrderByCreatedAtDesc(String phoneNumber);
}
