package com.gatherpay.backend.dto.user;

public record UserDirectoryEntryResponse(
        String id,
        String name,
        String email,
        String mobileNumber,
        boolean registered
) {
}
