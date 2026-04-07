package com.gatherpay.backend.config;

import java.util.List;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
@Profile("!test")
public class SchemaMigrationRunner {

    @Bean
    CommandLineRunner ensureGatherPaySchema(JdbcTemplate jdbcTemplate) {
        return args -> {
            List<String> statements = List.of(
                    "ALTER TABLE pools ADD COLUMN IF NOT EXISTS payout_completed boolean NOT NULL DEFAULT false",
                    "ALTER TABLE pools ADD COLUMN IF NOT EXISTS payout_type varchar(40)",
                    "ALTER TABLE pools ADD COLUMN IF NOT EXISTS payout_amount bigint",
                    "ALTER TABLE pools ADD COLUMN IF NOT EXISTS payout_triggered_by varchar(160)",
                    "ALTER TABLE pools ADD COLUMN IF NOT EXISTS payout_triggered_at timestamp with time zone",
                    """
                    CREATE TABLE IF NOT EXISTS pool_chat_messages (
                        id uuid PRIMARY KEY,
                        pool_id uuid NOT NULL REFERENCES pools(id) ON DELETE CASCADE,
                        sender_name varchar(120) NOT NULL,
                        sender_phone_number varchar(20) NOT NULL,
                        message varchar(1000) NOT NULL,
                        created_at timestamp with time zone NOT NULL
                    )
                    """
            );

            for (String statement : statements) {
                jdbcTemplate.execute(statement);
            }
        };
    }
}
