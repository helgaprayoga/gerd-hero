-- GERDHero Migration 004: Remove the unsupported "other" gender value.
-- Jalankan setelah 003_onboarding_status.sql.

UPDATE gerdhero.users
SET gender = NULL
WHERE gender = 'other';

ALTER TABLE gerdhero.users
    DROP CONSTRAINT IF EXISTS users_gender_check;

ALTER TABLE gerdhero.users
    ADD CONSTRAINT users_gender_check
    CHECK (gender IS NULL OR gender IN ('male', 'female'));
