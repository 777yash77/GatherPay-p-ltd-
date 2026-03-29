package com.gatherpay.backend.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gatherpay.backend.dto.user.UserDirectoryEntryResponse;
import com.gatherpay.backend.repository.UserAccountRepository;

@Service
@Transactional(readOnly = true)
public class UserDirectoryService {

    private final UserAccountRepository userAccountRepository;

    public UserDirectoryService(UserAccountRepository userAccountRepository) {
        this.userAccountRepository = userAccountRepository;
    }

    public List<UserDirectoryEntryResponse> search(String query, String currentUserEmail) {
        String normalizedQuery = query == null ? "" : query.trim();
        if (normalizedQuery.isEmpty()) {
            return List.of();
        }

        return userAccountRepository.searchDirectory(normalizedQuery).stream()
                .filter(user -> !user.getEmail().equalsIgnoreCase(currentUserEmail))
                .limit(20)
                .map(user -> new UserDirectoryEntryResponse(
                        user.getId().toString(),
                        user.getName(),
                        user.getEmail(),
                        user.getMobileNumber(),
                        true
                ))
                .toList();
    }
}
