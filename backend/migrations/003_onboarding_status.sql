-- GERDHero Migration 003: Persistent onboarding state
-- Run after 001_gerdhero_schema.sql and 002_gerdhero_additions.sql.

ALTER TABLE gerdhero.users
    ADD COLUMN IF NOT EXISTS profile_onboarding_status TEXT NOT NULL DEFAULT 'pending',
    ADD COLUMN IF NOT EXISTS gerdq_onboarding_status TEXT NOT NULL DEFAULT 'pending',
    ADD COLUMN IF NOT EXISTS onboarding_completed_at TIMESTAMPTZ;

ALTER TABLE gerdhero.users
    DROP CONSTRAINT IF EXISTS users_profile_onboarding_status_check;

ALTER TABLE gerdhero.users
    ADD CONSTRAINT users_profile_onboarding_status_check
    CHECK (profile_onboarding_status IN ('pending', 'completed', 'skipped'));

ALTER TABLE gerdhero.users
    DROP CONSTRAINT IF EXISTS users_gerdq_onboarding_status_check;

ALTER TABLE gerdhero.users
    ADD CONSTRAINT users_gerdq_onboarding_status_check
    CHECK (gerdq_onboarding_status IN ('pending', 'completed', 'skipped'));

COMMENT ON COLUMN gerdhero.users.profile_onboarding_status IS
    'Initial profile onboarding state: pending, completed, or skipped';

COMMENT ON COLUMN gerdhero.users.gerdq_onboarding_status IS
    'Initial GERD-Q onboarding state: pending, completed, or skipped';

COMMENT ON COLUMN gerdhero.users.onboarding_completed_at IS
    'Timestamp when both initial onboarding steps are completed or skipped';

-- Preserve the onboarding state for existing users whose profile is already complete.
UPDATE gerdhero.users
SET profile_onboarding_status = 'completed'
WHERE profile_onboarding_status = 'pending'
  AND (name IS NOT NULL OR nickname IS NOT NULL)
  AND birth_date IS NOT NULL
  AND gender IS NOT NULL;

-- Existing GERD-Q records mean the initial questionnaire has been completed.
UPDATE gerdhero.users AS u
SET gerdq_onboarding_status = 'completed'
WHERE gerdq_onboarding_status = 'pending'
  AND EXISTS (
      SELECT 1
      FROM gerdhero.gerdq_scores AS q
      WHERE q.user_id = u.id
  );

UPDATE gerdhero.users
SET onboarding_completed_at = COALESCE(onboarding_completed_at, now())
WHERE profile_onboarding_status <> 'pending'
  AND gerdq_onboarding_status <> 'pending'
  AND onboarding_completed_at IS NULL;
