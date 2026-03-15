# Transitions of Care Relational Analytics

Overview<br>
This repository contains a normalized relational database model designed to support workflow and documentation analytics in transitions-of-care processes. The schema enforces referential integrity, controlled vocabularies, and composite uniqueness constraints to ensure reliable analytical outputs.<br>
The model was engineered to support time-windowed queries, reconciliation comparisons, and task lifecycle tracking.<br>
Project Objective<br>
Design a relational schema capable of answering structured operational questions across patient encounters, authored documentation, and follow-up workflows.<br>
Validate integrity through constraint enforcement and explicit handling of nullable lifecycle states.
<br><br>
Core Analytical Use Cases<br>
1.	Identify discharge-related follow-up tasks that remain incomplete or unassigned within 30 days.<br>
2.	Detect medication discrepancies across documentation contexts (discharge vs. outpatient).<br>
3.	Analyze frequency distributions of documented problems by encounter type.<br><br>
Data Model Overview<br>
The model follows an event-based documentation design.<br><br>
Grain Definitions<br>
DOCUMENT<br>
One row represents one authored clinical document for a single patient during a single encounter.<br>
FOLLOW_UP_TASK<br>
One row represents one discrete follow-up action linked to exactly one document and optionally assigned to a provider.<br>
Core Entities<br>
•	PATIENT<br>
•	ENCOUNTER<br>
•	DOCUMENT<br>
•	FOLLOW_UP_TASK<br>
•	PROVIDER<br><br>
Reference Entities<br>
•	DOCUMENT_TYPE<br>
•	PROBLEM<br>
•	MEDICATION<br>
•	ALLERGY<br><br>
Junction Tables<br>
•	DOCUMENT_PROBLEM<br>
•	DOCUMENT_MEDICATION<br>
•	DOCUMENT_ALLERGY<br>
Design Decisions<br>
Normalization<br>
Tables are structured to third normal form (3NF) to eliminate redundant storage and maintain clean relational integrity.<br>
Controlled Identifiers<br>
Business identifiers (MRN, NPI, encounter_number, document_identifier, problem_code, medication_code) are enforced with UNIQUE constraints.<br>
Many-to-Many Relationships<br>
Junction tables enforce composite uniqueness constraints to prevent duplicate document-to-concept associations.<br>
Lifecycle State Modeling<br>
Nullable fields explicitly represent workflow state:<br>
•	assigned_provider_id may be NULL (unassigned tasks)<br>
•	end_date and completed_datetime may be NULL for active records<br>
Data Integrity Controls<br>
•	All foreign keys enforced<br>
•	Composite uniqueness constraints applied to junction tables<br>
•	No orphan records permitted<br>
•	Referential consistency maintained across all event relationships<br><br>
Repository Structure<br>
•	schema.sql — Data definition language (DDL)<br>
•	analytical_queries.sql — Use-case query logic<br>
•	ERD.png — Entity-relationship diagram<br>
•	data_dictionary.md — Column-level metadata
