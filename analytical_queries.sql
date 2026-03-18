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
    AND e.end_datetime >= '2024-11-01'
    -- Task is incomplete OR unassigned
    AND (
        t.assigned_provider_id IS NULL
        OR t.completion_status_code <> 'complete'
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
    SUM(CASE WHEN t.completion_status_code <> 'complete' THEN 1 ELSE 0 END) AS incomplete_task_count
FROM encounter e
JOIN document d
    ON d.encounter_id = e.encounter_id
JOIN follow_up_task t
    ON t.document_id = d.document_id
WHERE
    e.end_datetime IS NOT NULL
    AND e.discharge_disposition_code IS NOT NULL
    AND e.end_datetime >= '2024-11-01'
    AND (
        t.assigned_provider_id IS NULL
        OR t.completion_status_code <> 'complete'
    )
GROUP BY
    e.encounter_id,
    e.encounter_number,
    e.end_datetime
ORDER BY
    e.end_datetime DESC;

-- ============================================================
-- Use Case 2
-- For a given patient, which documents show inconsistencies between
-- the discharge medication list and medication lists recorded in
-- later outpatient encounters?
-- ============================================================
    
-- Query 2A: Medications on discharge documents not present in later outpatient documents
SELECT
    p.patient_id,
    p.mrn,
    p.given_name,
    p.family_name,
    d_dc.document_id AS discharge_document_id,
    d_dc.authored_datetime AS discharge_datetime,
    m.medication_id,
    m.medication_code,
    m.medication_display
FROM patient p
JOIN encounter e_dc
    ON e_dc.patient_id = p.patient_id
JOIN document d_dc
    ON d_dc.encounter_id = e_dc.encounter_id
JOIN document_medication dm_dc
    ON dm_dc.document_id = d_dc.document_id
    AND dm_dc.med_list_type_code = 'discharge'
JOIN medication m
    ON m.medication_id = dm_dc.medication_id
WHERE NOT EXISTS (
    SELECT 1
    FROM encounter e_op
    JOIN document d_op
        ON d_op.encounter_id = e_op.encounter_id
    JOIN document_medication dm_op
        ON dm_op.document_id = d_op.document_id
        AND dm_op.med_list_type_code = 'outpatient'
    JOIN medication m_op
        ON m_op.medication_id = dm_op.medication_id
    WHERE e_op.patient_id = p.patient_id
    AND d_op.authored_datetime > d_dc.authored_datetime
    AND m_op.medication_id = m.medication_id
)
ORDER BY
    p.patient_id,
    d_dc.authored_datetime;

-- ============================================================
-- Use Case 3
-- Which providers produce documents with the highest frequency of
-- missing or uncoded problem entries, grouped by document type?
-- ============================================================

-- Query 3A: Provider-level frequency of missing or uncoded problem entries
SELECT
    pr.provider_id,
    pr.npi,
    pr.given_name AS provider_given_name,
    pr.family_name AS provider_family_name,
    pr.specialty_code,
    dt.document_type_display,
    COUNT(d.document_id) AS total_documents,
    SUM(CASE WHEN dp.document_problem_id IS NULL THEN 1 ELSE 0 END) AS missing_problem_count,
    ROUND(
        SUM(CASE WHEN dp.document_problem_id IS NULL THEN 1 ELSE 0 END) * 100.0
        / COUNT(d.document_id), 2
    ) AS missing_problem_pct
FROM provider pr
JOIN document d
    ON d.provider_id = pr.provider_id
JOIN document_type dt
    ON dt.document_type_id = d.document_type_id
LEFT JOIN document_problem dp
    ON dp.document_id = d.document_id
GROUP BY
    pr.provider_id,
    pr.npi,
    pr.given_name,
    pr.family_name,
    pr.specialty_code,
    dt.document_type_display
ORDER BY
    missing_problem_pct DESC,
    total_documents DESC;
