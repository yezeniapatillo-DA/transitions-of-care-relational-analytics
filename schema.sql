-- schema.sql
-- Transitions of Care Relational Analytics
-- Dialect: PostgreSQL

-- ============================================================
-- Core entities
-- ============================================================

CREATE TABLE patient (
    patient_id INT GENERATED ALWAYS AS IDENTITY,
    mrn VARCHAR(50) NOT NULL,
    given_name VARCHAR(100) NOT NULL,
    family_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    sex_at_birth VARCHAR(20) NOT NULL,
    race_code VARCHAR(20),
    ethnicity_code VARCHAR(20),

    PRIMARY KEY (patient_id),

    UNIQUE (mrn)
);

CREATE TABLE provider (
    provider_id INT GENERATED ALWAYS AS IDENTITY,
    npi VARCHAR(20) NOT NULL,
    given_name VARCHAR(100) NOT NULL,
    family_name VARCHAR(100) NOT NULL,
    specialty_code VARCHAR(50),
    organization_name VARCHAR(150),

    PRIMARY KEY (provider_id),

    UNIQUE (npi)
);

CREATE TABLE document_type (
    document_type_id INT GENERATED ALWAYS AS IDENTITY,
    document_type_code VARCHAR(50) NOT NULL,
    document_type_display VARCHAR(150) NOT NULL,

    PRIMARY KEY (document_type_id),

    UNIQUE (document_type_code)
);

CREATE TABLE encounter (
    encounter_id INT GENERATED ALWAYS AS IDENTITY,
    encounter_number VARCHAR(50) NOT NULL,
    patient_id INT NOT NULL,
    encounter_type VARCHAR(50) NOT NULL,
    start_datetime TIMESTAMP NOT NULL,
    end_datetime TIMESTAMP,
    discharge_disposition_code VARCHAR(50),

    PRIMARY KEY (encounter_id),

    FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id),

    UNIQUE (encounter_number)
);

CREATE TABLE document (
    document_id INT GENERATED ALWAYS AS IDENTITY,
    patient_id INT NOT NULL,
    encounter_id INT NOT NULL,
    provider_id INT NOT NULL,
    document_type_id INT NOT NULL,
    document_identifier VARCHAR(80) NOT NULL,
    authored_datetime TIMESTAMP NOT NULL,
    status_code VARCHAR(30) NOT NULL,
    narrative_text TEXT,

    PRIMARY KEY (document_id),

    FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id),

    FOREIGN KEY (encounter_id)
        REFERENCES encounter(encounter_id),

    FOREIGN KEY (provider_id)
        REFERENCES provider(provider_id),

    FOREIGN KEY (document_type_id)
        REFERENCES document_type(document_type_id),

    UNIQUE (document_identifier)
);

-- ============================================================
-- Vocabulary / reference entities
-- ============================================================

CREATE TABLE problem (
    problem_id INT GENERATED ALWAYS AS IDENTITY,
    problem_code VARCHAR(50) NOT NULL,
    problem_display VARCHAR(200) NOT NULL,
    vocabulary_name VARCHAR(50) NOT NULL,

    PRIMARY KEY (problem_id),

    UNIQUE (problem_code)
);

CREATE TABLE medication (
    medication_id INT GENERATED ALWAYS AS IDENTITY,
    medication_code VARCHAR(50) NOT NULL,
    medication_display VARCHAR(200) NOT NULL,
    vocabulary_name VARCHAR(50) NOT NULL,
    route_code VARCHAR(50),

    PRIMARY KEY (medication_id),

    UNIQUE (medication_code)
);

CREATE TABLE allergy (
    allergy_id INT GENERATED ALWAYS AS IDENTITY,
    substance_code VARCHAR(50) NOT NULL,
    substance_display VARCHAR(200) NOT NULL,
    reaction_description VARCHAR(255),

    PRIMARY KEY (allergy_id),

    UNIQUE (substance_code)
);

-- ============================================================
-- Care team entities
-- ============================================================

CREATE TABLE care_team (
    careteam_id INT GENERATED ALWAYS AS IDENTITY,
    patient_id INT NOT NULL,
    careteam_name VARCHAR(150) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,

    PRIMARY KEY (careteam_id),

    FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id)
);

CREATE TABLE care_team_member (
    careteam_member_id INT GENERATED ALWAYS AS IDENTITY,
    careteam_id INT NOT NULL,
    provider_id INT NOT NULL,
    role_code VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,

    PRIMARY KEY (careteam_member_id),

    FOREIGN KEY (careteam_id)
        REFERENCES care_team(careteam_id),

    FOREIGN KEY (provider_id)
        REFERENCES provider(provider_id),

    UNIQUE (careteam_id, provider_id, start_date)
);

-- ============================================================
-- Follow-up tasks
-- ============================================================

CREATE TABLE follow_up_task (
    task_id INT GENERATED ALWAYS AS IDENTITY,
    document_id INT NOT NULL,
    assigned_provider_id INT,
    task_description VARCHAR(255) NOT NULL,
    due_date DATE NOT NULL,
    completion_status_code VARCHAR(30) NOT NULL,
    completed_datetime TIMESTAMP,

    PRIMARY KEY (task_id),

    FOREIGN KEY (document_id)
        REFERENCES document(document_id),

    FOREIGN KEY (assigned_provider_id)
        REFERENCES provider(provider_id),

    UNIQUE (document_id, task_description, due_date)
);

-- ============================================================
-- Junction tables (document ↔ concepts)
-- ============================================================

CREATE TABLE document_problem (
    document_problem_id INT GENERATED ALWAYS AS IDENTITY,
    document_id INT NOT NULL,
    problem_id INT NOT NULL,
    is_primary_indicator BOOLEAN,

    PRIMARY KEY (document_problem_id),

    FOREIGN KEY (document_id)
        REFERENCES document(document_id),

    FOREIGN KEY (problem_id)
        REFERENCES problem(problem_id),

    UNIQUE (document_id, problem_id)
);

CREATE TABLE document_medication (
    document_medication_id INT GENERATED ALWAYS AS IDENTITY,
    document_id INT NOT NULL,
    medication_id INT NOT NULL,
    med_list_type_code VARCHAR(30) NOT NULL,

    PRIMARY KEY (document_medication_id),

    FOREIGN KEY (document_id)
        REFERENCES document(document_id),

    FOREIGN KEY (medication_id)
        REFERENCES medication(medication_id),

    UNIQUE (document_id, medication_id)
);

CREATE TABLE document_allergy (
    document_allergy_id INT GENERATED ALWAYS AS IDENTITY,
    document_id INT NOT NULL,
    allergy_id INT NOT NULL,

    PRIMARY KEY (document_allergy_id),

    FOREIGN KEY (document_id)
        REFERENCES document(document_id),

    FOREIGN KEY (allergy_id)
        REFERENCES allergy(allergy_id),

    UNIQUE (document_id, allergy_id)
);
