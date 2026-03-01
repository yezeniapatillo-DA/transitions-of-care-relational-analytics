# Data Dictionary


This document defines table structure, grain, constraints, and column-level metadata for the **Transitions of Care Relational Analytics** schema.

---

# Core Entities

---

## TABLE: PATIENT

**Purpose:** Stores demographic identity information.  
**Grain:** One row represents one unique patient record.  
**Primary Key:** `patient_id`  
**Unique Constraints:** `UQ (mrn)`  

**Business Rules:**
- MRN must be globally unique.
- Each patient may participate in multiple encounters and documents.

### Columns

| Column          | Type     | Null     | Constraints | Definition | Example
|-----------------|----------|----------|------------|------------|-----------
| patient_id      | INT      | NOT NULL | PK         | Surrogate identifier |1001 |
| mrn             | VARCHAR  | NOT NULL | UQ         | Medical record number | MRN-445892 |
| given_name      | VARCHAR  | NOT NULL |            | First name | Jane |
| family_name     | VARCHAR  | NOT NULL |            | Last name | Doe |
| birth_date      | DATE     | NOT NULL |            | Date of birth | 1990-04-12 |
| sex_at_birth    | VARCHAR  | NOT NULL |            | Biological sex | F |
| race_code       | VARCHAR  | NULL     |            | Race code | 2106-3 |
| ethnicity_code  | VARCHAR  | NULL     |            | Ethnicity code | 2186-5 |


---

## TABLE: ENCOUNTER

**Purpose:** Represents healthcare interaction events.  
**Grain:** One row represents one distinct patient encounter event.  
**Primary Key:** `encounter_id`  
**Foreign Keys:** `patient_id → PATIENT.patient_id`  
**Unique Constraints:** `UQ (encounter_number)`  


### Columns

| Column | Type | Null | Constraints | Definition | Example |
|---|---|---|---|---|---|
| encounter_id | INT | NOT NULL | PK | Surrogate encounter identifier | 2001 |
| encounter_number | VARCHAR | NOT NULL | UQ | Unique encounter identifier | ENC-000234 |
| patient_id | INT | NOT NULL | FK | Associated patient | 1001 |
| encounter_type | VARCHAR | NOT NULL |  | Visit classification | OUTPATIENT |
| start_datetime | DATETIME | NOT NULL |  | Encounter start timestamp | 2026-03-01 10:00 |
| end_datetime | DATETIME | NULL |  | Encounter end timestamp | 2026-03-01 11:00 |
| discharge_disposition_code | VARCHAR | NULL |  | Discharge outcome classification | HOME |

---

## TABLE: DOCUMENT

**Purpose:** Stores authored clinical documentation artifacts.  
**Grain:** One row represents one authored clinical document for a single patient during one encounter.  
**Primary Key:** `document_id`  
**Foreign Keys:**
- `patient_id → PATIENT.patient_id`
- `encounter_id → ENCOUNTER.encounter_id`
- `provider_id → PROVIDER.provider_id`
- `document_type_id → DOCUMENT_TYPE.document_type_id`  
**Unique Constraints:** `UQ (document_identifier)`  


### Columns

| Column | Type | Null | Constraints | Definition | Example |
|---|---|---|---|---|---|
| document_id | INT | NOT NULL | PK | Surrogate identifier | 3001 |
| patient_id | INT | NOT NULL | FK | Associated patient | 1001 |
| encounter_id | INT | NOT NULL | FK | Related encounter | 2001 |
| provider_id | INT | NOT NULL | FK | Authoring provider | 501 |
| document_type_id | INT | NOT NULL | FK | Classification identifier | 2 |
| document_identifier | VARCHAR | NOT NULL | UQ | External document ID | DOC-2026-0193 |
| authored_datetime | DATETIME | NOT NULL |  | Author timestamp | 2026-03-01 10:30 |
| status_code | VARCHAR | NOT NULL |  | Workflow status | FINAL |
| narrative_text | TEXT | NULL |  | Unstructured content | — |

---

## TABLE: FOLLOW_UP_TASK

**Purpose:** Tracks workflow tasks generated from documents.  
**Grain:** One row represents one discrete follow-up action linked to exactly one document.  
**Primary Key:** `task_id`  
**Foreign Keys:**
- `document_id → DOCUMENT.document_id`
- `assigned_provider_id → PROVIDER.provider_id` (nullable)  
**Unique Constraints:** `UQ (document_id, task_description, due_date)`  


### Columns

| Column | Type | Null | Constraints | Definition | Example |
|---|---|---|---|---|---|
| task_id | INT | NOT NULL | PK | Surrogate task identifier | 4001 |
| document_id | INT | NOT NULL | FK | Source document | 3001 |
| assigned_provider_id | INT | NULL | FK | Provider responsible | 501 |
| task_description | VARCHAR | NOT NULL |  | Description of action | Schedule follow-up |
| due_date | DATE | NOT NULL |  | Required completion date | 2026-03-15 |
| completion_status_code | VARCHAR | NOT NULL |  | Status indicator | INCOMPLETE |
| completed_datetime | DATETIME | NULL |  | Completion timestamp | 2026-03-10 09:00 |

---

# Vocabulary & Reference Tables

Provide similar structure for:
- PROVIDER
- CARE_TEAM
- CARE_TEAM_MEMBER
- DOCUMENT_TYPE
- PROBLEM
- MEDICATION
- ALLERGY

---

# Junction Tables

## TABLE: DOCUMENT_PROBLEM

**Purpose:** Links documents to problems (many-to-many).  
**Grain:** One row represents one association between a document and a clinical problem.  
**Primary Key:** `document_problem_id`  
**Foreign Keys:**
- `document_id → DOCUMENT.document_id`
- `problem_id → PROBLEM.problem_id`  
**Unique Constraints:** `UQ (document_id, problem_id)`  



