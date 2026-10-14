-- ============================================================================
-- GERDHero Migration 002: Additions & Fixes
-- Jalankan SETELAH 001_gerdhero_schema.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FIX 1: gerd_level — ubah tipe dari NUMERIC(5,2) CHECK(0-100)
--         menjadi NUMERIC(6,4) untuk menyimpan Certainty Factor (0.0–1.0)
-- ----------------------------------------------------------------------------
ALTER TABLE gerdhero.daily_logs
    DROP CONSTRAINT IF EXISTS daily_logs_gerd_level_check;

ALTER TABLE gerdhero.daily_logs
    ALTER COLUMN gerd_level TYPE NUMERIC(6, 4);

ALTER TABLE gerdhero.daily_logs
    ADD CONSTRAINT daily_logs_gerd_level_check
        CHECK (gerd_level IS NULL OR (gerd_level >= 0 AND gerd_level <= 1));

COMMENT ON COLUMN gerdhero.daily_logs.gerd_level IS
    'Certainty Factor score (0.0–1.0) dari algoritma D1';

-- ----------------------------------------------------------------------------
-- FIX 2: Tambah kolom pdf_url ke tabel reports
-- ----------------------------------------------------------------------------
ALTER TABLE gerdhero.reports
    ADD COLUMN IF NOT EXISTS pdf_url TEXT;

COMMENT ON COLUMN gerdhero.reports.pdf_url IS
    'URL file PDF hasil generate — Supabase Storage URL atau path lokal';

-- ----------------------------------------------------------------------------
-- FIX 3: Tambah kolom pdf_generated_at ke tabel reports
-- ----------------------------------------------------------------------------
ALTER TABLE gerdhero.reports
    ADD COLUMN IF NOT EXISTS pdf_generated_at TIMESTAMPTZ;

COMMENT ON COLUMN gerdhero.reports.pdf_generated_at IS
    'Timestamp saat PDF berhasil di-generate';

-- ----------------------------------------------------------------------------
-- FIX 4: Tambah kolom streak_days ke tabel users
--         (untuk fitur B5: chip streak hari berturut-turut log)
-- ----------------------------------------------------------------------------
ALTER TABLE gerdhero.users
    ADD COLUMN IF NOT EXISTS streak_days INTEGER NOT NULL DEFAULT 0;

ALTER TABLE gerdhero.users
    ADD COLUMN IF NOT EXISTS last_log_date DATE;

COMMENT ON COLUMN gerdhero.users.streak_days IS
    'Jumlah hari berturut-turut pengguna mengisi log harian (fitur B5)';

COMMENT ON COLUMN gerdhero.users.last_log_date IS
    'Tanggal log harian terakhir — dipakai untuk kalkulasi streak dan state maskot';

-- ----------------------------------------------------------------------------
-- FIX 5: Constraint gender — batasi ke nilai valid
-- ----------------------------------------------------------------------------
ALTER TABLE gerdhero.users
    DROP CONSTRAINT IF EXISTS users_gender_check;

ALTER TABLE gerdhero.users
    ADD CONSTRAINT users_gender_check
        CHECK (gender IS NULL OR gender IN ('male', 'female', 'other'));

-- ----------------------------------------------------------------------------
-- NEW TABLE: analytics_cache — cache hasil kalkulasi analitik
--            agar tidak menghitung ulang setiap request
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS gerdhero.analytics_cache (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID        NOT NULL REFERENCES gerdhero.users(id) ON DELETE CASCADE,
    period_type  TEXT        NOT NULL CHECK (period_type IN ('weekly', 'monthly')),
    period_start DATE        NOT NULL,
    period_end   DATE        NOT NULL,
    cache_data   JSONB       NOT NULL,
    ai_summary   TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at   TIMESTAMPTZ NOT NULL DEFAULT (now() + INTERVAL '1 hour'),
    CONSTRAINT analytics_cache_period_valid CHECK (period_start <= period_end),
    CONSTRAINT analytics_cache_user_period_key UNIQUE (user_id, period_type, period_start, period_end)
);

COMMENT ON TABLE gerdhero.analytics_cache IS
    'Cache kalkulasi analitik E1-E5 untuk mengurangi beban komputasi berulang';

CREATE INDEX IF NOT EXISTS idx_analytics_cache_user_period
    ON gerdhero.analytics_cache (user_id, period_type, period_start DESC);

ALTER TABLE gerdhero.analytics_cache ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own analytics cache"
    ON gerdhero.analytics_cache;
CREATE POLICY "Users can manage their own analytics cache"
    ON gerdhero.analytics_cache FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- GRANT untuk tabel baru
-- ----------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE
    ON gerdhero.analytics_cache TO authenticated;
