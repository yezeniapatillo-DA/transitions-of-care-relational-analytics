# Data Dictionary

Data Dictionary
<br>This document defines table structure, grain, constraints, and column-level metadata for the Transitions of Care Relational Analytics schema.
<br>Core Entities
<br>TABLE: PATIENT
<br>Purpose: Stores demographic identity information.
<br>Grain: One row represents one unique patient record.
<br>Primary Key: patient_id
<br>Unique Constraints: UQ mrn
<br>Business Rules:
<br>•	MRN must be globally unique.
<br>•	Each patient may participate in multiple encounters and documents.

<br>Columns
<br>Column	Type	Null	Constraints	Definition	Example
<br>patient_id	INT	NOT NULL	PK	Surrogate unique identifier	1001
<br>mrn	VARCHAR	NOT NULL	UQ	Medical record number	MRN-445892
<br>given_name	VARCHAR	NOT NULL		Patient first name	Jane
<br>family_name	VARCHAR	NOT NULL		Patient last name	Doe
<br>birth_date	DATE	NOT NULL		Date of birth	1990-04-12
<br>sex_at_birth	VARCHAR	NOT NULL		Biological sex	F
<br>race_code	VARCHAR	NULL		Race classification	2106-3
<br>ethnicity_code	VARCHAR	NULL		Ethnicity classification	2186-5
<br>
<br>TABLE: ENCOUNTER
<br>Purpose: Represents healthcare interaction events.
<br>Grain: One row represents one distinct patient encounter event.
<br>Primary Key: encounter_id
<br>Foreign Keys: patient_id → PATIENT.patient_id
<br>Unique Constraints: UQ encounter_number
<br>
<br>Columns
<br>Column	Type	Null	Constraints	Definition	Example
<br>encounter_id	INT	NOT NULL	PK	Surrogate encounter identifier	2001
<br>encounter_number	VARCHAR	NOT NULL	UQ	Unique encounter identifier	ENC-000234
<br>patient_id	INT	NOT NULL	FK	Associated patient	1001
<br>encounter_type	VARCHAR	NOT NULL		Visit classification	OUTPATIENT
<br>start_datetime	DATETIME	NOT NULL		Encounter start timestamp	2026-03-01 10:00
<br>end_datetime	DATETIME	NULL		Encounter end timestamp	2026-03-01 11:00
<br>discharge_disposition_code	VARCHAR	NULL		Discharge outcome classification	HOME
<br>
<br>TABLE: DOCUMENT
<br>Purpose: Stores authored clinical documentation artifacts.
<br>Grain: One row represents one authored clinical document for a single patient during one encounter.
<br>Primary Key: document_id
<br>Foreign Keys:
<br>•	patient_id → PATIENT.patient_id
<br>•	encounter_id → ENCOUNTER.encounter_id
<br>•	provider_id → PROVIDER.provider_id
<br>•	document_type_id → DOCUMENT_TYPE.document_type_id
<br>Unique Constraints: UQ document_identifier
<br>
<br>Columns
<br>Column	Type	Null	Constraints	Definition	Example
<br>document_id	INT	NOT NULL	PK	Surrogate identifier	3001
<br>patient_id	INT	NOT NULL	FK	Associated patient	1001
<br>encounter_id	INT	NOT NULL	FK	Related encounter	2001
<br>provider_id	INT	NOT NULL	FK	Authoring provider	501
<br>document_type_id	INT	NOT NULL	FK	Classification identifier	2
<br>document_identifier	VARCHAR	NOT NULL	UQ	External document ID	DOC-2026-0193
<br>authored_datetime	DATETIME	NOT NULL		Author timestamp	2026-03-01 10:30
<br>status_code	VARCHAR	NOT NULL		Workflow status	FINAL
<br>narrative_text	TEXT	NULL		Unstructured content	—
<br>
<br>TABLE: FOLLOW_UP_TASK
<br>Purpose: Tracks workflow tasks generated from documents.
<br>Grain: One row represents one discrete follow-up action linked to exactly one document.
<br>Primary Key: task_id
<br>Foreign Keys:
<br>•	document_id → DOCUMENT.document_id
<br>•	assigned_provider_id → PROVIDER.provider_id (nullable)
<br>Unique Constraints: UQ (document_id, task_description, due_date)

<br>Columns
<br>Column	Type	Null	Constraints	Definition	Example
<br>task_id	INT	NOT NULL	PK	Surrogate task identifier	4001
<br>document_id	INT	NOT NULL	FK	Source document	3001
<br>assigned_provider_id	INT	NULL	FK	Provider responsible	501
<br>task_description	VARCHAR	NOT NULL		Description of action	Schedule follow-up
<br>due_date	DATE	NOT NULL		Required completion date	2026-03-15
<br>completion_status_code	VARCHAR	NOT NULL		Status indicator	INCOMPLETE
<br>completed_datetime	DATETIME	NULL		Completion timestamp	2026-03-10 09:00
<br>
<br>Vocabulary & Reference Tables
<br>Provide similar compact structure for:
<br>•	PROVIDER
<br>•	CARE_TEAM
<br>•	CARE_TEAM_MEMBER
<br>•	DOCUMENT_TYPE
<br>•	PROBLEM
<br>•	MEDICATION
<br>•	ALLERGY

<br>Junction Tables
<br>TABLE: DOCUMENT_PROBLEM
<br>Grain: One row represents one association between a document and a clinical problem.
<br>Primary Key: document_problem_id
<br>Foreign Keys:
<br>•	document_id → DOCUMENT.document_id
<br>•	problem_id → PROBLEM.problem_id
<br>Unique Constraints: UQ (document_id, problem_id)
<br>Repeat similar format for:
<br>•	DOCUMENT_MEDICATION
<br>•	DOCUMENT_ALLERGY
<br>Formatting Notes
<br>Keep:
<br>•	Data types consistent
<br>•	Nullability explicit
<br>•	Examples concrete
<br>•	Definitions concise
<img width="468" height="633" alt="image" src="https://github.com/user-attachments/assets/22f63c12-9493-4df5-ba52-c61485d05267" />

