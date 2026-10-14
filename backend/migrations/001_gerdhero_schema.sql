-- ============================================================================
-- GERDHero Database Migration
-- Supabase PostgreSQL schema: gerdhero
--
-- Prerequisite:
--   The `gerdhero` schema must already exist.
--   Add `gerdhero` to Supabase Dashboard > Settings > API > Exposed schemas.
--
-- This migration follows the table names defined in the GERDHero PRD.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE SCHEMA IF NOT EXISTS gerdhero;

-- ============================================================================
-- 1. TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS gerdhero.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    name TEXT,
    nickname TEXT,
    birth_date DATE,
    gender TEXT,
    height NUMERIC(5, 1),
    weight NUMERIC(5, 1),
    bmi NUMERIC(4, 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT users_height_positive CHECK (height IS NULL OR height > 0),
    CONSTRAINT users_weight_positive CHECK (weight IS NULL OR weight > 0),
    CONSTRAINT users_bmi_positive CHECK (bmi IS NULL OR bmi > 0)
);

COMMENT ON TABLE gerdhero.users IS
    'Basic user profile linked to Supabase auth.users';

CREATE TABLE IF NOT EXISTS gerdhero.user_profiles_extended (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES gerdhero.users(id) ON DELETE CASCADE,
    smoking TEXT,
    alcohol TEXT,
    work_pattern TEXT,
    coffee BOOLEAN,
    medical_history JSONB NOT NULL DEFAULT '[]'::jsonb,
    routine_meds JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE gerdhero.user_profiles_extended IS
    'Extended habits, medical history, and routine medication profile';

CREATE TABLE IF NOT EXISTS gerdhero.gerdq_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES gerdhero.users(id) ON DELETE CASCADE,
    score INTEGER NOT NULL CHECK (score BETWEEN 0 AND 18),
    answers JSONB NOT NULL,
    result TEXT NOT NULL CHECK (result IN ('no_gerd', 'likely_gerd')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE gerdhero.gerdq_scores IS
    'GERD-Q questionnaire answers and machine-readable classification';

CREATE TABLE IF NOT EXISTS gerdhero.daily_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES gerdhero.users(id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    symptoms JSONB NOT NULL DEFAULT '[]'::jsonb,
    no_symptoms BOOLEAN NOT NULL DEFAULT false,
    symptom_description TEXT,
    triggers JSONB NOT NULL DEFAULT '{}'::jsonb,
    meal_frequency INTEGER,
    meal_times JSONB NOT NULL DEFAULT '[]'::jsonb,
    meal_time_consistent BOOLEAN,
    meal_frequency_consistent BOOLEAN,
    last_meal_to_sleep_gap_hours NUMERIC(4, 2),
    stress_level INTEGER CHECK (stress_level BETWEEN 1 AND 5),
    sleep_time TIME,
    wake_time TIME,
    sleep_duration_minutes INTEGER,
    medications JSONB NOT NULL DEFAULT '[]'::jsonb,
    took_medication BOOLEAN NOT NULL DEFAULT false,
    gerd_level NUMERIC(5, 2) CHECK (gerd_level BETWEEN 0 AND 100),
    ai_analysis JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT daily_logs_user_date_key UNIQUE (user_id, log_date),
    CONSTRAINT daily_logs_meal_frequency_positive
        CHECK (meal_frequency IS NULL OR meal_frequency > 0),
    CONSTRAINT daily_logs_sleep_duration_positive
        CHECK (sleep_duration_minutes IS NULL OR sleep_duration_minutes >= 0),
    CONSTRAINT daily_logs_gap_positive
        CHECK (last_meal_to_sleep_gap_hours IS NULL
            OR last_meal_to_sleep_gap_hours >= 0),
    CONSTRAINT daily_logs_no_symptoms_consistent
        CHECK (NOT no_symptoms OR symptoms = '[]'::jsonb),
    CONSTRAINT daily_logs_medication_consistent
        CHECK (took_medication OR medications = '[]'::jsonb)
);

COMMENT ON TABLE gerdhero.daily_logs IS
    'Daily GERD symptoms, triggers, meals, sleep, and medication log';

CREATE TABLE IF NOT EXISTS gerdhero.reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES gerdhero.users(id) ON DELETE CASCADE,
    report_number TEXT NOT NULL UNIQUE,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    report_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT reports_period_valid CHECK (period_start <= period_end)
);

COMMENT ON TABLE gerdhero.reports IS
    'Generated periodic reports for PDF export and doctor consultations';

-- ============================================================================
-- 2. INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_gerdq_scores_user_created
    ON gerdhero.gerdq_scores (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_daily_logs_user_log_date
    ON gerdhero.daily_logs (user_id, log_date DESC);

CREATE INDEX IF NOT EXISTS idx_reports_user_created
    ON gerdhero.reports (user_id, created_at DESC);

-- user_profiles_extended.user_id is already indexed by UNIQUE.

-- ============================================================================
-- 3. RLS POLICIES
-- ============================================================================

ALTER TABLE gerdhero.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE gerdhero.user_profiles_extended ENABLE ROW LEVEL SECURITY;
ALTER TABLE gerdhero.gerdq_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE gerdhero.daily_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE gerdhero.reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own user row" ON gerdhero.users;
CREATE POLICY "Users can view their own user row"
    ON gerdhero.users FOR SELECT
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert their own user row" ON gerdhero.users;
CREATE POLICY "Users can insert their own user row"
    ON gerdhero.users FOR INSERT
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own user row" ON gerdhero.users;
CREATE POLICY "Users can update their own user row"
    ON gerdhero.users FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can delete their own user row" ON gerdhero.users;
CREATE POLICY "Users can delete their own user row"
    ON gerdhero.users FOR DELETE
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can view their own extended profile"
    ON gerdhero.user_profiles_extended;
CREATE POLICY "Users can view their own extended profile"
    ON gerdhero.user_profiles_extended FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own extended profile"
    ON gerdhero.user_profiles_extended;
CREATE POLICY "Users can insert their own extended profile"
    ON gerdhero.user_profiles_extended FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own extended profile"
    ON gerdhero.user_profiles_extended;
CREATE POLICY "Users can update their own extended profile"
    ON gerdhero.user_profiles_extended FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own extended profile"
    ON gerdhero.user_profiles_extended;
CREATE POLICY "Users can delete their own extended profile"
    ON gerdhero.user_profiles_extended FOR DELETE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view their own gerdq scores"
    ON gerdhero.gerdq_scores;
CREATE POLICY "Users can view their own gerdq scores"
    ON gerdhero.gerdq_scores FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own gerdq scores"
    ON gerdhero.gerdq_scores;
CREATE POLICY "Users can insert their own gerdq scores"
    ON gerdhero.gerdq_scores FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own gerdq scores"
    ON gerdhero.gerdq_scores;
CREATE POLICY "Users can update their own gerdq scores"
    ON gerdhero.gerdq_scores FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own gerdq scores"
    ON gerdhero.gerdq_scores;
CREATE POLICY "Users can delete their own gerdq scores"
    ON gerdhero.gerdq_scores FOR DELETE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view their own daily logs"
    ON gerdhero.daily_logs;
CREATE POLICY "Users can view their own daily logs"
    ON gerdhero.daily_logs FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own daily logs"
    ON gerdhero.daily_logs;
CREATE POLICY "Users can insert their own daily logs"
    ON gerdhero.daily_logs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own daily logs"
    ON gerdhero.daily_logs;
CREATE POLICY "Users can update their own daily logs"
    ON gerdhero.daily_logs FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own daily logs"
    ON gerdhero.daily_logs;
CREATE POLICY "Users can delete their own daily logs"
    ON gerdhero.daily_logs FOR DELETE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view their own reports" ON gerdhero.reports;
CREATE POLICY "Users can view their own reports"
    ON gerdhero.reports FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own reports" ON gerdhero.reports;
CREATE POLICY "Users can insert their own reports"
    ON gerdhero.reports FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own reports" ON gerdhero.reports;
CREATE POLICY "Users can update their own reports"
    ON gerdhero.reports FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own reports" ON gerdhero.reports;
CREATE POLICY "Users can delete their own reports"
    ON gerdhero.reports FOR DELETE
    USING (auth.uid() = user_id);

-- RLS controls row access, while GRANT controls table access.
GRANT USAGE ON SCHEMA gerdhero TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE
    ON ALL TABLES IN SCHEMA gerdhero TO authenticated;
GRANT USAGE, SELECT
    ON ALL SEQUENCES IN SCHEMA gerdhero TO authenticated;

-- ============================================================================
-- 4. FUNCTIONS AND TRIGGERS
-- ============================================================================

CREATE OR REPLACE FUNCTION gerdhero.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = gerdhero, public
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_users_updated_at ON gerdhero.users;
CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON gerdhero.users
    FOR EACH ROW
    EXECUTE FUNCTION gerdhero.handle_updated_at();

DROP TRIGGER IF EXISTS trg_user_profiles_extended_updated_at
    ON gerdhero.user_profiles_extended;
CREATE TRIGGER trg_user_profiles_extended_updated_at
    BEFORE UPDATE ON gerdhero.user_profiles_extended
    FOR EACH ROW
    EXECUTE FUNCTION gerdhero.handle_updated_at();

DROP TRIGGER IF EXISTS trg_daily_logs_updated_at ON gerdhero.daily_logs;
CREATE TRIGGER trg_daily_logs_updated_at
    BEFORE UPDATE ON gerdhero.daily_logs
    FOR EACH ROW
    EXECUTE FUNCTION gerdhero.handle_updated_at();

CREATE OR REPLACE FUNCTION gerdhero.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = gerdhero, public
AS $$
BEGIN
    INSERT INTO gerdhero.users (id, email, name, nickname)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
        NEW.raw_user_meta_data->>'nickname'
    )
    ON CONFLICT (id) DO NOTHING;

    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION gerdhero.handle_new_user() FROM PUBLIC;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION gerdhero.handle_new_user();
