package com.gatherpay.backend.entity;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.gatherpay.backend.domain.PoolSettlementMode;
import com.gatherpay.backend.domain.PoolStyle;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.JoinColumn;

@Entity
@Table(name = "pools")
public class Pool {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 120)
    private String name;

    @Column(nullable = false, length = 500)
    private String description;

    @Column(nullable = false)
    private Long targetAmount;

    @Column(nullable = false, length = 80)
    private String category;

    @Column(nullable = false, length = 120)
    private String adminName;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by_user_id")
    private UserAccount createdByUser;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private PoolStyle style;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private PoolSettlementMode settlementMode;

    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @OneToMany(mappedBy = "pool", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<PoolMember> members = new ArrayList<>();

    @PrePersist
    public void prePersist() {
        createdAt = Instant.now();
    }

    public UUID getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Long getTargetAmount() {
        return targetAmount;
    }

    public void setTargetAmount(Long targetAmount) {
        this.targetAmount = targetAmount;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getAdminName() {
        return adminName;
    }

    public void setAdminName(String adminName) {
        this.adminName = adminName;
    }

    public UserAccount getCreatedByUser() {
        return createdByUser;
    }

    public void setCreatedByUser(UserAccount createdByUser) {
        this.createdByUser = createdByUser;
    }

    public PoolStyle getStyle() {
        return style;
    }

    public void setStyle(PoolStyle style) {
        this.style = style;
    }

    public PoolSettlementMode getSettlementMode() {
        return settlementMode;
    }

    public void setSettlementMode(PoolSettlementMode settlementMode) {
        this.settlementMode = settlementMode;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public List<PoolMember> getMembers() {
        return members;
    }

    public void setMembers(List<PoolMember> members) {
        this.members.clear();
        for (PoolMember member : members) {
            member.setPool(this);
            this.members.add(member);
        }
    }
}
