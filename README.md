# Transitions of Care Relational Analytics

<b>Overview<b>
This repository contains a normalized relational database model designed to support workflow and documentation analytics in transitions-of-care processes. The schema enforces referential integrity, controlled vocabularies, and composite uniqueness constraints to ensure reliable analytical outputs.
The model was engineered to support time-windowed queries, reconciliation comparisons, and task lifecycle tracking.
<br><b>Project Objective<b>
Design a relational schema capable of answering structured operational questions across patient encounters, authored documentation, and follow-up workflows.
Validate integrity through constraint enforcement and explicit handling of nullable lifecycle states.
Core Analytical Use Cases
1.	Identify discharge-related follow-up tasks that remain incomplete or unassigned within 30 days.
2.	Detect medication discrepancies across documentation contexts (discharge vs. outpatient).
3.	Analyze frequency distributions of documented problems by encounter type.
<br><b>Data Model Overview<b>
The model follows an event-based documentation design.
<br><b>Grain Definitions<b>
<br>DOCUMENT
<br>One row represents one authored clinical document for a single patient during a single encounter.
<br>FOLLOW_UP_TASK
<br>One row represents one discrete follow-up action linked to exactly one document and optionally assigned to a provider.
<br><b>Core Entities<b><br>
•	PATIENT
•	ENCOUNTER
•	DOCUMENT
•	FOLLOW_UP_TASK
•	PROVIDER
<br><b>Reference Entities<b><br>
•	DOCUMENT_TYPE
•	PROBLEM
•	MEDICATION
•	ALLERGY
<br><b>Junction Tables<b><br>
•	DOCUMENT_PROBLEM
•	DOCUMENT_MEDICATION
•	DOCUMENT_ALLERGY
<br><b>Design Decisions<b><br>
Normalization<br>
Tables are structured to third normal form (3NF) to eliminate redundant storage and maintain clean relational integrity.
Controlled Identifiers
<br>Business identifiers (MRN, NPI, encounter_number, document_identifier, problem_code, medication_code) are enforced with UNIQUE constraints.
<br>Many-to-Many Relationships<br>
Junction tables enforce composite uniqueness constraints to prevent duplicate document-to-concept associations.
<br>Lifecycle State Modeling<br>
<br>Nullable fields explicitly represent workflow state:
•	assigned_provider_id may be NULL (unassigned tasks)
•	end_date and completed_datetime may be NULL for active records
<br>Data Integrity Controls<br>
•	All foreign keys enforced
•	Composite uniqueness constraints applied to junction tables
•	No orphan records permitted
•	Referential consistency maintained across all event relationships
<br>Repository Structure<br>
•	schema.sql — Data definition language (DDL)
•	analytical_queries.sql — Use-case query logic
•	ERD.png — Entity-relationship diagram
•	data_dictionary.md — Column-level metadata
