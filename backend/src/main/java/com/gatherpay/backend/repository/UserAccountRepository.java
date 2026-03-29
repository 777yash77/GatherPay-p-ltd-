package com.gatherpay.backend.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.gatherpay.backend.entity.UserAccount;

public interface UserAccountRepository extends JpaRepository<UserAccount, UUID> {

    Optional<UserAccount> findByEmailIgnoreCase(String email);

    Optional<UserAccount> findByMobileNumber(String mobileNumber);

    List<UserAccount> findAllByMobileNumberIn(List<String> mobileNumbers);

    @Query("""
            select u from UserAccount u
            where lower(u.name) like lower(concat('%', :query, '%'))
               or u.mobileNumber like concat('%', :query, '%')
               or lower(u.email) like lower(concat('%', :query, '%'))
            order by u.name asc
            """)
    List<UserAccount> searchDirectory(@Param("query") String query);

    boolean existsByEmailIgnoreCase(String email);

    boolean existsByMobileNumber(String mobileNumber);
}
