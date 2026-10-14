-- ============================================================================
-- GERDHero Migration 002: Additions & Fixes
-- Jalankan SETELAH 001_gerdhero_schema.sql
-- Target: Supabase SQL Editor
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS gerdhero;

-- ============================================================================
-- FIX 1: gerd_level — Certainty Factor 0.0000–1.0000
-- ============================================================================

ALTER TABLE gerdhero.daily_logs
    DROP CONSTRAINT IF EXISTS daily_logs_gerd_level_check;

ALTER TABLE gerdhero.daily_logs
    ALTER COLUMN gerd_level TYPE NUMERIC(6, 4)
    USING CASE
        WHEN gerd_level IS NULL THEN NULL
        WHEN gerd_level > 1 THEN gerd_level / 100.0
        ELSE gerd_level
    END;

ALTER TABLE gerdhero.daily_logs
    ADD CONSTRAINT daily_logs_gerd_level_check
    CHECK (gerd_level IS NULL OR (gerd_level >= 0 AND gerd_level <= 1));

COMMENT ON COLUMN gerdhero.daily_logs.gerd_level IS
    'Certainty Factor score (0.0000–1.0000) dari algoritma D1. '
    'Frontend dapat mengalikan nilai ini dengan 100 untuk menampilkan persentase.';

-- ============================================================================
-- FIX 2: Kolom PDF pada reports
-- ============================================================================

ALTER TABLE gerdhero.reports
    ADD COLUMN IF NOT EXISTS pdf_url TEXT;

ALTER TABLE gerdhero.reports
    ADD COLUMN IF NOT EXISTS pdf_generated_at TIMESTAMPTZ;

COMMENT ON COLUMN gerdhero.reports.pdf_url IS
    'URL file PDF — Supabase Storage path atau URL absolut';

COMMENT ON COLUMN gerdhero.reports.pdf_generated_at IS
    'Timestamp saat PDF berhasil di-generate (NULL = belum di-generate)';

-- ============================================================================
-- FIX 3: Streak harian pada users
-- ============================================================================

ALTER TABLE gerdhero.users
    ADD COLUMN IF NOT EXISTS streak_days INTEGER NOT NULL DEFAULT 0;

ALTER TABLE gerdhero.users
    ADD COLUMN IF NOT EXISTS last_log_date DATE;

COMMENT ON COLUMN gerdhero.users.streak_days IS
    'Jumlah hari berturut-turut pengguna mengisi log harian';

COMMENT ON COLUMN gerdhero.users.last_log_date IS
    'Tanggal log harian terakhir untuk kalkulasi streak dan state maskot';

-- ============================================================================
-- FIX 4: Constraint gender
-- ============================================================================

ALTER TABLE gerdhero.users
    DROP CONSTRAINT IF EXISTS users_gender_check;

ALTER TABLE gerdhero.users
    ADD CONSTRAINT users_gender_check
    CHECK (gender IS NULL OR gender IN ('male', 'female', 'other'));

-- ============================================================================
-- NEW TABLE: analytics_cache
-- ============================================================================

CREATE TABLE IF NOT EXISTS gerdhero.analytics_cache (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL
                        REFERENCES gerdhero.users(id) ON DELETE CASCADE,
    period_type         TEXT NOT NULL,
    period_start        DATE NOT NULL,
    period_end          DATE NOT NULL,
    cache_data          JSONB NOT NULL DEFAULT '{}'::jsonb,
    ai_summary          TEXT,
    ai_recommendations  JSONB DEFAULT '[]'::jsonb,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at          TIMESTAMPTZ NOT NULL
                        DEFAULT (now() + INTERVAL '1 hour'),
    CONSTRAINT analytics_cache_period_valid
        CHECK (period_start <= period_end),
    CONSTRAINT analytics_cache_user_period_key
        UNIQUE (user_id, period_type, period_start, period_end)
);

-- Upgrade an analytics_cache table created by an earlier draft of migration 002.
ALTER TABLE gerdhero.analytics_cache
    ADD COLUMN IF NOT EXISTS ai_recommendations JSONB;

UPDATE gerdhero.analytics_cache
SET cache_data = '{}'::jsonb
WHERE cache_data IS NULL;

UPDATE gerdhero.analytics_cache
SET ai_recommendations = '[]'::jsonb
WHERE ai_recommendations IS NULL;

ALTER TABLE gerdhero.analytics_cache
    ALTER COLUMN cache_data SET DEFAULT '{}'::jsonb,
    ALTER COLUMN cache_data SET NOT NULL,
    ALTER COLUMN ai_recommendations SET DEFAULT '[]'::jsonb;

ALTER TABLE gerdhero.analytics_cache
    DROP CONSTRAINT IF EXISTS analytics_cache_period_type_check;

ALTER TABLE gerdhero.analytics_cache
    ADD CONSTRAINT analytics_cache_period_type_check
    CHECK (period_type IN ('weekly', 'monthly', 'custom'));

COMMENT ON TABLE gerdhero.analytics_cache IS
    'Cache kalkulasi analitik E1–E5. Expired setelah 1 jam atau '
    'di-invalidate saat daily log baru masuk.';

CREATE INDEX IF NOT EXISTS idx_analytics_cache_user_expires
    ON gerdhero.analytics_cache (user_id, expires_at DESC);

ALTER TABLE gerdhero.analytics_cache ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own analytics cache"
    ON gerdhero.analytics_cache;
DROP POLICY IF EXISTS "Users can view their own analytics cache"
    ON gerdhero.analytics_cache;
DROP POLICY IF EXISTS "Users can insert their own analytics cache"
    ON gerdhero.analytics_cache;
DROP POLICY IF EXISTS "Users can update their own analytics cache"
    ON gerdhero.analytics_cache;
DROP POLICY IF EXISTS "Users can delete their own analytics cache"
    ON gerdhero.analytics_cache;

CREATE POLICY "Users can view their own analytics cache"
    ON gerdhero.analytics_cache FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own analytics cache"
    ON gerdhero.analytics_cache FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own analytics cache"
    ON gerdhero.analytics_cache FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own analytics cache"
    ON gerdhero.analytics_cache FOR DELETE
    USING (auth.uid() = user_id);

GRANT SELECT, INSERT, UPDATE, DELETE
    ON gerdhero.analytics_cache TO authenticated;

-- ============================================================================
-- FUNCTION/TRIGGER: invalidate overlapping analytics cache entries
-- ============================================================================

CREATE OR REPLACE FUNCTION gerdhero.invalidate_analytics_cache()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = gerdhero, public
AS $$
BEGIN
    DELETE FROM gerdhero.analytics_cache
    WHERE user_id = NEW.user_id
      AND period_start <= NEW.log_date
      AND period_end >= NEW.log_date;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_invalidate_analytics_on_log
    ON gerdhero.daily_logs;

CREATE TRIGGER trg_invalidate_analytics_on_log
    AFTER INSERT OR UPDATE ON gerdhero.daily_logs
    FOR EACH ROW
    EXECUTE FUNCTION gerdhero.invalidate_analytics_cache();
