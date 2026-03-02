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

| Column | Type | Null | Constraints | Definition | Example |
|---|---|---|---|---|---|
| patient_id | INT | NOT NULL | PK | Surrogate identifier | 1001 |
| mrn | VARCHAR | NOT NULL | UQ | Medical record number | MRN-445892 |
| given_name | VARCHAR | NOT NULL |  | First name | Jane |
| family_name | VARCHAR | NOT NULL |  | Last name | Doe |
| birth_date | DATE | NOT NULL |  | Date of birth | 1990-04-12 |
| sex_at_birth | VARCHAR | NOT NULL |  | Biological sex | F |
| race_code | VARCHAR | NULL |  | Race code | 2106-3 |
| ethnicity_code | VARCHAR | NULL |  | Ethnicity code | 2186-5 |


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

# Junction Tables

## TABLE: DOCUMENT_PROBLEM

**Purpose:** Links documents to problems (many-to-many).  
**Grain:** One row represents one association between a document and a clinical problem.  
**Primary Key:** `document_problem_id`  
**Foreign Keys:**
- `document_id → DOCUMENT.document_id`
- `problem_id → PROBLEM.problem_id`  
**Unique Constraints:** `UQ (document_id, problem_id)`  

## TABLE: DOCUMENT_MEDICATION

**Purpose:** Links documents to documented medications (many-to-many).  
**Grain:** One row represents one association between a document and a medication entry.  
**Primary Key:** `document_medication_id`  
**Foreign Keys:**
- `document_id → DOCUMENT.document_id`
- `medication_id → MEDICATION.medication_id`  
**Unique Constraints:** `UQ (document_id, medication_id)`

### Columns

| Column | Type | Null | Constraints | Definition |
|---|---|---|---|---|
| document_medication_id | INT | NOT NULL | PK | Surrogate identifier |
| document_id | INT | NOT NULL | FK | Linked document |
| medication_id | INT | NOT NULL | FK | Referenced medication |
| med_list_type_code | VARCHAR | NOT NULL |  | Context of medication list |

## TABLE: DOCUMENT_ALLERGY

**Purpose:** Links documents to documented allergies (many-to-many).  
**Grain:** One row represents one association between a document and an allergy entry.  
**Primary Key:** `document_allergy_id`  
**Foreign Keys:**
- `document_id → DOCUMENT.document_id`
- `allergy_id → ALLERGY.allergy_id`  
**Unique Constraints:** `UQ (document_id, allergy_id)`

### Columns

| Column | Type | Null | Constraints | Definition |
|---|---|---|---|---|
| document_allergy_id | INT | NOT NULL | PK | Surrogate identifier |
| document_id | INT | NOT NULL | FK | Linked document |
| allergy_id | INT | NOT NULL | FK | Referenced allergy |

## TABLE: PROVIDER

**Purpose:** Stores provider identity and attributes used for authorship, assignment, and care team membership.  
**Grain:** One row represents one unique provider record.  
**Primary Key:** `provider_id`  
**Unique Constraints:** `UQ (npi)`  

### Columns

| Column | Type | Null | Constraints | Definition |
|---|---|---|---|---|
| provider_id | INT | NOT NULL | PK | Surrogate provider identifier |
| npi | VARCHAR | NOT NULL | UQ | National Provider Identifier |
| given_name | VARCHAR | NOT NULL |  | Provider first name |
| family_name | VARCHAR | NOT NULL |  | Provider last name |
| specialty_code | VARCHAR | NULL |  | Specialty classification code |
| organization_name | VARCHAR | NULL |  | Affiliated organization name |

## TABLE: DOCUMENT_TYPE

**Purpose:** Defines allowable document classifications used by DOCUMENT.  
**Grain:** One row represents one document type definition.  
**Primary Key:** `document_type_id`  
**Unique Constraints:** `UQ (document_type_code)`  

### Columns

| Column | Type | Null | Constraints | Definition |
|---|---|---|---|---|
| document_type_id | INT | NOT NULL | PK | Surrogate identifier |
| document_type_code | VARCHAR | NOT NULL | UQ | Document type code |
| document_type_display | VARCHAR | NOT NULL |  | Human-readable label |

## TABLE: PROBLEM

**Purpose:** Stores standardized problem concepts referenced by documents.  
**Grain:** One row represents one unique standardized problem concept.  
**Primary Key:** `problem_id`  
**Unique Constraints:** `UQ (problem_code)`  

### Columns

| Column | Type | Null | Constraints | Definition |
|---|---|---|---|---|
| problem_id | INT | NOT NULL | PK | Surrogate identifier |
| problem_code | VARCHAR | NOT NULL | UQ | Standardized problem code |
| problem_display | VARCHAR | NOT NULL |  | Problem display name |
| vocabulary_name | VARCHAR | NOT NULL |  | Source vocabulary (e.g., SNOMED, ICD-10) |

## TABLE: MEDICATION

**Purpose:** Stores standardized medication concepts referenced by documents.  
**Grain:** One row represents one unique standardized medication concept.  
**Primary Key:** `medication_id`  
**Unique Constraints:** `UQ (medication_code)`  

### Columns

| Column | Type | Null | Constraints | Definition |
|---|---|---|---|---|
| medication_id | INT | NOT NULL | PK | Surrogate identifier |
| medication_code | VARCHAR | NOT NULL | UQ | Standardized medication code |
| medication_display | VARCHAR | NOT NULL |  | Medication display name |
| vocabulary_name | VARCHAR | NOT NULL |  | Source vocabulary (e.g., RxNorm) |
| route_code | VARCHAR | NULL |  | Route of administration code |

## TABLE: ALLERGY

**Purpose:** Stores standardized allergy/substance concepts referenced by documents.  
**Grain:** One row represents one unique allergy/substance concept.  
**Primary Key:** `allergy_id`  
**Unique Constraints:** `UQ (substance_code)`  

### Columns

| Column | Type | Null | Constraints | Definition |
|---|---|---|---|---|
| allergy_id | INT | NOT NULL | PK | Surrogate identifier |
| substance_code | VARCHAR | NOT NULL | UQ | Standardized substance code |
| substance_display | VARCHAR | NOT NULL |  | Substance display name |
| reaction_description | VARCHAR | NULL |  | Documented reaction text |

## TABLE: CARE_TEAM

**Purpose:** Represents a named care team associated to a patient over a time window.  
**Grain:** One row represents one care team instance for one patient.  
**Primary Key:** `careteam_id`  
**Foreign Keys:** `patient_id → PATIENT.patient_id`  

### Columns

| Column | Type | Null | Constraints | Definition |
|---|---|---|---|---|
| careteam_id | INT | NOT NULL | PK | Surrogate identifier |
| patient_id | INT | NOT NULL | FK | Associated patient |
| careteam_name | VARCHAR | NOT NULL |  | Care team name/label |
| start_date | DATE | NOT NULL |  | Team start date |
| end_date | DATE | NULL |  | Team end date (NULL = active) |

## TABLE: CARE_TEAM_MEMBER

**Purpose:** Links providers to care teams with role and time window.  
**Grain:** One row represents one provider membership period on one care team.  
**Primary Key:** `careteam_member_id`  
**Foreign Keys:**
- `careteam_id → CARE_TEAM.careteam_id`
- `provider_id → PROVIDER.provider_id`  
**Unique Constraints:** `UQ (careteam_id, provider_id, start_date)`  

### Columns

| Column | Type | Null | Constraints | Definition |
|---|---|---|---|---|
| careteam_member_id | INT | NOT NULL | PK | Surrogate identifier |
| careteam_id | INT | NOT NULL | FK | Associated care team |
| provider_id | INT | NOT NULL | FK | Associated provider |
| role_code | VARCHAR | NOT NULL |  | Role on the care team |
| start_date | DATE | NOT NULL |  | Membership start date |
| end_date | DATE | NULL |  | Membership end date (NULL = active) |


