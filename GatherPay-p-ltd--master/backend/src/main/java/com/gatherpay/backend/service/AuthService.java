package com.gatherpay.backend.service;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gatherpay.backend.dto.auth.AuthResponse;
import com.gatherpay.backend.dto.auth.ForgotPasswordRequest;
import com.gatherpay.backend.dto.auth.LoginRequest;
import com.gatherpay.backend.dto.auth.RegisterRequest;
import com.gatherpay.backend.dto.user.UserProfileResponse;
import com.gatherpay.backend.entity.UserAccount;
import com.gatherpay.backend.exception.BadRequestException;
import com.gatherpay.backend.repository.UserAccountRepository;
import com.gatherpay.backend.security.JwtService;

@Service
@Transactional
public class AuthService {

    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;

    public AuthService(
            UserAccountRepository userAccountRepository,
            PasswordEncoder passwordEncoder,
            AuthenticationManager authenticationManager,
            JwtService jwtService
    ) {
        this.userAccountRepository = userAccountRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
    }

    public AuthResponse register(RegisterRequest request) {
        if (userAccountRepository.existsByEmailIgnoreCase(request.email())) {
            throw new BadRequestException("Email already registered");
        }
        if (userAccountRepository.existsByMobileNumber(request.mobileNumber())) {
            throw new BadRequestException("Mobile number already registered");
        }

        UserAccount user = new UserAccount();
        user.setName(request.name().trim());
        user.setEmail(request.email().trim().toLowerCase());
        user.setMobileNumber(request.mobileNumber().trim());
        user.setCity(blankToNull(request.city()));
        user.setUpiId(blankToNull(request.upiId()));
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setProfileCompleted(isProfileComplete(user));

        UserAccount savedUser = userAccountRepository.save(user);
        return toAuthResponse(savedUser);
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.email().trim().toLowerCase(),
                        request.password()
                )
        );

        UserAccount user = userAccountRepository.findByEmailIgnoreCase(request.email().trim())
                .orElseThrow(() -> new BadRequestException("Invalid email or password"));

        return toAuthResponse(user);
    }

    @Transactional(readOnly = true)
    public String forgotPassword(ForgotPasswordRequest request) {
        userAccountRepository.findByMobileNumber(request.mobileNumber().trim())
                .orElseThrow(() -> new BadRequestException("Mobile number not found"));
        return "OTP sent to " + request.mobileNumber();
    }

    public UserProfileResponse toProfile(UserAccount user) {
        return new UserProfileResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getMobileNumber(),
                user.getCity(),
                user.getUpiId(),
                user.isProfileCompleted(),
                user.getCreatedAt()
        );
    }

    private AuthResponse toAuthResponse(UserAccount user) {
        String token = jwtService.generateToken(user.getEmail());
        return new AuthResponse(token, "Bearer", toProfile(user));
    }

    private boolean isProfileComplete(UserAccount user) {
        return user.getCity() != null && !user.getCity().isBlank()
                && user.getUpiId() != null && !user.getUpiId().isBlank();
    }

    private String blankToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
