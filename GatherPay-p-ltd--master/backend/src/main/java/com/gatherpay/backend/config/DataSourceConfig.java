package com.gatherpay.backend.config;

import java.net.URI;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("!test")
public class DataSourceConfig {

    @Value("${app.database.url}")
    private String databaseUrl;

    @Value("${app.database.username:}")
    private String databaseUsername;

    @Value("${app.database.password:}")
    private String databasePassword;

    @Bean
    public DataSource dataSource() {
        DatabaseConnectionProperties properties = normalize(databaseUrl, databaseUsername, databasePassword);
        return DataSourceBuilder.create()
                .driverClassName("org.postgresql.Driver")
                .url(properties.url())
                .username(properties.username())
                .password(properties.password())
                .build();
    }

    private DatabaseConnectionProperties normalize(String rawUrl, String rawUsername, String rawPassword) {
        if (rawUrl.startsWith("jdbc:postgresql://")) {
            return new DatabaseConnectionProperties(enforceSslIfNeeded(rawUrl), rawUsername, rawPassword);
        }

        if (rawUrl.startsWith("postgresql://") || rawUrl.startsWith("postgres://")) {
            URI uri = URI.create(rawUrl);
            String[] credentials = uri.getUserInfo() == null ? new String[0] : uri.getUserInfo().split(":", 2);
            String username = !rawUsername.isBlank()
                    ? rawUsername
                    : credentials.length > 0 ? credentials[0] : "";
            String password = !rawPassword.isBlank()
                    ? rawPassword
                    : credentials.length > 1 ? credentials[1] : "";
            String jdbcUrl = "jdbc:postgresql://" + uri.getHost()
                    + (uri.getPort() > 0 ? ":" + uri.getPort() : "")
                    + uri.getPath()
                    + querySuffix(uri.getQuery());
            jdbcUrl = enforceSslIfNeeded(jdbcUrl);
            return new DatabaseConnectionProperties(jdbcUrl, username, password);
        }

        return new DatabaseConnectionProperties(rawUrl, rawUsername, rawPassword);
    }

    private String querySuffix(String query) {
        if (query == null || query.isBlank()) {
            return "";
        }
        return "?" + query;
    }

    private String enforceSslIfNeeded(String jdbcUrl) {
        boolean isRenderHost = jdbcUrl.contains("render.com");
        boolean alreadyHasSslMode = jdbcUrl.contains("sslmode=");

        if (isRenderHost && !alreadyHasSslMode) {
            return jdbcUrl.contains("?")
                    ? jdbcUrl + "&sslmode=require"
                    : jdbcUrl + "?sslmode=require";
        }

        return jdbcUrl;
    }

    private record DatabaseConnectionProperties(String url, String username, String password) {
    }
}
