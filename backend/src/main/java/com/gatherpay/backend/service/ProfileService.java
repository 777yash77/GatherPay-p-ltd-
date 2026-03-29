package com.gatherpay.backend.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gatherpay.backend.dto.user.UpdateProfileRequest;
import com.gatherpay.backend.dto.user.UserProfileResponse;
import com.gatherpay.backend.entity.UserAccount;
import com.gatherpay.backend.exception.BadRequestException;
import com.gatherpay.backend.exception.NotFoundException;
import com.gatherpay.backend.repository.UserAccountRepository;

@Service
@Transactional
public class ProfileService {

    private final UserAccountRepository userAccountRepository;
    private final AuthService authService;

    public ProfileService(UserAccountRepository userAccountRepository, AuthService authService) {
        this.userAccountRepository = userAccountRepository;
        this.authService = authService;
    }

    @Transactional(readOnly = true)
    public UserProfileResponse getProfile(String email) {
        return authService.toProfile(findUser(email));
    }

    public UserProfileResponse updateProfile(String email, UpdateProfileRequest request) {
        UserAccount user = findUser(email);

        userAccountRepository.findByEmailIgnoreCase(request.email().trim())
                .filter(existing -> !existing.getId().equals(user.getId()))
                .ifPresent(existing -> {
                    throw new BadRequestException("Email already registered");
                });
        userAccountRepository.findByMobileNumber(request.mobileNumber().trim())
                .filter(existing -> !existing.getId().equals(user.getId()))
                .ifPresent(existing -> {
                    throw new BadRequestException("Mobile number already registered");
                });

        user.setName(request.name().trim());
        user.setEmail(request.email().trim().toLowerCase());
        user.setMobileNumber(request.mobileNumber().trim());
        user.setCity(blankToNull(request.city()));
        user.setUpiId(blankToNull(request.upiId()));
        user.setProfileCompleted(user.getCity() != null && user.getUpiId() != null);

        return authService.toProfile(userAccountRepository.save(user));
    }

    private UserAccount findUser(String email) {
        return userAccountRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new NotFoundException("User not found"));
    }

    private String blankToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
