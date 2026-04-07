package com.gatherpay.backend.entity;

import java.util.UUID;

import com.gatherpay.backend.domain.PoolMemberRole;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "pool_members")
public class PoolMember {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "pool_id", nullable = false)
    private Pool pool;

    @Column(nullable = false, length = 120)
    private String name;

    @Column(nullable = false, length = 20)
    private String phoneNumber;

    @Column(nullable = false)
    private Long contributedAmount;

    @Column(nullable = false)
    private Integer approvalsGiven;

    @Column(nullable = false)
    private Integer activityScore;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PoolMemberRole role;

    public UUID getId() {
        return id;
    }

    public Pool getPool() {
        return pool;
    }

    public void setPool(Pool pool) {
        this.pool = pool;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public Long getContributedAmount() {
        return contributedAmount;
    }

    public void setContributedAmount(Long contributedAmount) {
        this.contributedAmount = contributedAmount;
    }

    public Integer getApprovalsGiven() {
        return approvalsGiven;
    }

    public void setApprovalsGiven(Integer approvalsGiven) {
        this.approvalsGiven = approvalsGiven;
    }

    public Integer getActivityScore() {
        return activityScore;
    }

    public void setActivityScore(Integer activityScore) {
        this.activityScore = activityScore;
    }

    public PoolMemberRole getRole() {
        return role;
    }

    public void setRole(PoolMemberRole role) {
        this.role = role;
    }
}
