-- analytical_queries.sql
-- Purpose: Query patterns supporting core analytical use cases for the
-- Transitions of Care Relational Analytics schema.
--
-- Assumptions:
-- 1) "Discharged" encounter = ENCOUNTER.end_datetime IS NOT NULL
--    AND ENCOUNTER.discharge_disposition_code IS NOT NULL
-- 2) "Past 30 days" is relative to CURRENT_DATE
-- 3) A task is considered "unassigned" when FOLLOW_UP_TASK.assigned_provider_id IS NULL
-- 4) A task is considered "incomplete" when completion_status_code <> 'COMPLETED'
--    (Adjust this list if your system uses different status codes.)

-- ============================================================
-- Use Case 1
-- Which patients discharged in the past 30 days have follow-up tasks
-- that remain incomplete OR have no assigned provider?
-- ============================================================

-- Query 1A: Patient-level list of outstanding tasks linked to recent discharges
SELECT
    p.patient_id,
    p.mrn,
    p.given_name,
    p.family_name,
    e.encounter_id,
    e.encounter_number,
    e.end_datetime AS discharge_datetime,
    e.discharge_disposition_code,
    d.document_id,
    d.document_identifier,
    d.authored_datetime,
    t.task_id,
    t.task_description,
    t.due_date,
    t.completion_status_code,
    t.completed_datetime,
    t.assigned_provider_id
FROM encounter e
JOIN patient p
    ON p.patient_id = e.patient_id
JOIN document d
    ON d.encounter_id = e.encounter_id
JOIN follow_up_task t
    ON t.document_id = d.document_id
WHERE
    -- Discharged in the past 30 days
    e.end_datetime IS NOT NULL
    AND e.discharge_disposition_code IS NOT NULL
    AND e.end_datetime >= (CURRENT_DATE - INTERVAL '30 days')
    -- Task is incomplete OR unassigned
    AND (
        t.assigned_provider_id IS NULL
        OR t.completion_status_code <> 'COMPLETED'
    )
ORDER BY
    e.end_datetime DESC,
    p.patient_id,
    t.due_date;

-- Query 1B: Summary metrics (counts) by encounter for outstanding tasks
SELECT
    e.encounter_id,
    e.encounter_number,
    e.end_datetime AS discharge_datetime,
    COUNT(*) AS outstanding_task_count,
    SUM(CASE WHEN t.assigned_provider_id IS NULL THEN 1 ELSE 0 END) AS unassigned_task_count,
    SUM(CASE WHEN t.completion_status_code <> 'COMPLETED' THEN 1 ELSE 0 END) AS incomplete_task_count
FROM encounter e
JOIN document d
    ON d.encounter_id = e.encounter_id
JOIN follow_up_task t
    ON t.document_id = d.document_id
WHERE
    e.end_datetime IS NOT NULL
    AND e.discharge_disposition_code IS NOT NULL
    AND e.end_datetime >= (CURRENT_DATE - INTERVAL '30 days')
    AND (
        t.assigned_provider_id IS NULL
        OR t.completion_status_code <> 'COMPLETED'
    )
GROUP BY
    e.encounter_id,
    e.encounter_number,
    e.end_datetime
ORDER BY
    e.end_datetime DESC;
