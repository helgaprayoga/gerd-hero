-- ============================================================================
-- GERDHero seed data: 20 hari daily logs untuk akun yang sedang menjalankan SQL
-- Jalankan di Supabase SQL Editor setelah migration 001-004.
--
-- Catatan:
-- - Query memakai auth.uid(), jadi hanya mengisi user yang sedang login.
-- - Query aman dijalankan ulang karena memakai ON CONFLICT.
-- - gerd_level mengikuti migration 002: nilai 0.0000 sampai 1.0000.
-- - Seed ini hanya mengisi daily_logs dan tidak mengubah streak user.
-- ============================================================================

WITH days AS (
    SELECT
        day::date AS log_date,
        (CURRENT_DATE - day::date) AS days_ago
    FROM generate_series(
        CURRENT_DATE - INTERVAL '19 days',
        CURRENT_DATE,
        INTERVAL '1 day'
    ) AS series(day)
),
seed AS (
    SELECT
        auth.uid() AS user_id,
        log_date,
        CASE days_ago % 6
            WHEN 0 THEN jsonb_build_array('Heartburn', 'Regurgitasi')
            WHEN 1 THEN jsonb_build_array('Kembung & gas')
            WHEN 2 THEN jsonb_build_array('Heartburn', 'Kembung & gas')
            WHEN 3 THEN '[]'::jsonb
            WHEN 4 THEN jsonb_build_array('Regurgitasi', 'Suara serak')
            ELSE jsonb_build_array('Nyeri dada')
        END AS symptoms,
        CASE days_ago % 6 WHEN 3 THEN true ELSE false END AS no_symptoms,
        CASE days_ago % 6
            WHEN 3 THEN NULL
            ELSE 'Data seed untuk pengujian laporan dan grafik.'
        END AS symptom_description,
        jsonb_build_object(
            'Pedas', (days_ago % 3 = 0),
            'Berlemak/gorengan', (days_ago % 4 = 0),
            'Asam', (days_ago % 5 = 0),
            'Berkafein', (days_ago % 2 = 0),
            'Bersoda', (days_ago % 7 = 0)
        ) AS triggers,
        CASE days_ago % 3 WHEN 0 THEN 3 WHEN 1 THEN 4 ELSE 2 END AS meal_frequency,
        CASE days_ago % 3
            WHEN 0 THEN jsonb_build_array('07:30', '12:30', '19:00')
            WHEN 1 THEN jsonb_build_array('08:00', '13:00', '19:30', '21:00')
            ELSE jsonb_build_array('07:00', '12:00')
        END AS meal_times,
        (days_ago % 4 <> 1) AS meal_time_consistent,
        (days_ago % 3 <> 2) AS meal_frequency_consistent,
        (2.0 + (days_ago % 3) * 0.5)::numeric(4, 2) AS last_meal_to_sleep_gap_hours,
        (1 + (days_ago % 5))::integer AS stress_level,
        CASE days_ago % 3
            WHEN 0 THEN '23:00'::time
            WHEN 1 THEN '22:30'::time
            ELSE '23:30'::time
        END AS sleep_time,
        CASE days_ago % 3
            WHEN 0 THEN '06:30'::time
            WHEN 1 THEN '06:00'::time
            ELSE '07:00'::time
        END AS wake_time,
        CASE days_ago % 3 WHEN 0 THEN 450 WHEN 1 THEN 450 ELSE 450 END AS sleep_duration_minutes,
        CASE
            WHEN days_ago % 4 = 0 THEN jsonb_build_array(
                jsonb_build_object('name', 'Omeprazole 20mg', 'schedule', 'Sebelum makan')
            )
            ELSE '[]'::jsonb
        END AS medications,
        (days_ago % 4 = 0) AS took_medication,
        CASE days_ago % 6
            WHEN 0 THEN 0.58
            WHEN 1 THEN 0.24
            WHEN 2 THEN 0.46
            WHEN 3 THEN 0.00
            WHEN 4 THEN 0.38
            ELSE 0.35
        END::numeric(6, 4) AS gerd_level
    FROM days
)
INSERT INTO gerdhero.daily_logs (
    user_id,
    log_date,
    symptoms,
    no_symptoms,
    symptom_description,
    triggers,
    meal_frequency,
    meal_times,
    meal_time_consistent,
    meal_frequency_consistent,
    last_meal_to_sleep_gap_hours,
    stress_level,
    sleep_time,
    wake_time,
    sleep_duration_minutes,
    medications,
    took_medication,
    gerd_level,
    ai_analysis,
    updated_at
)
SELECT
    user_id,
    log_date,
    symptoms,
    no_symptoms,
    symptom_description,
    triggers,
    meal_frequency,
    meal_times,
    meal_time_consistent,
    meal_frequency_consistent,
    last_meal_to_sleep_gap_hours,
    stress_level,
    sleep_time,
    wake_time,
    sleep_duration_minutes,
    medications,
    took_medication,
    gerd_level,
    NULL,
    now()
FROM seed
WHERE user_id IS NOT NULL
ON CONFLICT (user_id, log_date) DO UPDATE SET
    symptoms = EXCLUDED.symptoms,
    no_symptoms = EXCLUDED.no_symptoms,
    symptom_description = EXCLUDED.symptom_description,
    triggers = EXCLUDED.triggers,
    meal_frequency = EXCLUDED.meal_frequency,
    meal_times = EXCLUDED.meal_times,
    meal_time_consistent = EXCLUDED.meal_time_consistent,
    meal_frequency_consistent = EXCLUDED.meal_frequency_consistent,
    last_meal_to_sleep_gap_hours = EXCLUDED.last_meal_to_sleep_gap_hours,
    stress_level = EXCLUDED.stress_level,
    sleep_time = EXCLUDED.sleep_time,
    wake_time = EXCLUDED.wake_time,
    sleep_duration_minutes = EXCLUDED.sleep_duration_minutes,
    medications = EXCLUDED.medications,
    took_medication = EXCLUDED.took_medication,
    gerd_level = EXCLUDED.gerd_level,
    ai_analysis = EXCLUDED.ai_analysis,
    updated_at = now();
