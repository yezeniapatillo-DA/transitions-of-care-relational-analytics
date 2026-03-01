# transitions-of-care-relational-analytics
Executive Summary

This project delivers a normalized relational database schema designed to support structured analytics across transitions of care workflows. The model enables reliable reporting on follow-up task completion, documentation patterns, and medication reconciliation by enforcing referential integrity, controlled vocabularies, and duplicate prevention constraints.
The database was engineered to answer three operational questions:
1.	Which patients discharged in the past 30 days have incomplete or unassigned follow-up tasks?
2.	Where do medication discrepancies exist between discharge and outpatient documentation?
3.	What problems are most frequently documented in outpatient encounters?
Problem Context
Transitions of care involve multiple encounters, clinical documents, follow-up tasks, and provider assignments. Fragmented or poorly structured data can result in incomplete task tracking and unreliable documentation analytics.
To support consistent reporting and integrity, this project models:
•	Patient-level events (encounters)
•	Authored documentation
•	Follow-up workflow artifacts
•	Standardized clinical concepts (problems, medications, allergies)
•	Provider attribution and care team membership
Data Model Overview
The relational model follows an event-based documentation design.

Core entities:
•	PATIENT
•	ENCOUNTER
•	DOCUMENT
•	FOLLOW_UP_TASK
•	PROVIDER
Supporting vocabulary entities:
•	PROBLEM
•	MEDICATION
•	ALLERGY
•	DOCUMENT_TYPE
Junction tables handle many-to-many relationships:
•	DOCUMENT_PROBLEM
•	DOCUMENT_MEDICATION
•	DOCUMENT_ALLERGY
The grain of the DOCUMENT table is:
One row represents one authored clinical document tied to a single patient and single encounter.
The grain of the FOLLOW_UP_TASK table is:
One row represents one discrete follow-up action linked to exactly one document.
An ERD diagram is included in this repository.
Key Design Decisions
1. Normalization
The model adheres to third normal form (3NF), separating entities and eliminating redundant storage.
2. Junction Tables
Many-to-many relationships between DOCUMENT and clinical concepts are implemented through junction tables with composite uniqueness constraints:
•	UQ(document_id, problem_id)
•	UQ(document_id, medication_id)
•	UQ(document_id, allergy_id)
This prevents duplicate concept associations.
3. Controlled Identifiers
Business identifiers such as MRN, NPI, encounter_number, and document_identifier are enforced via UNIQUE constraints.
4. Nullable Logic

Lifecycle attributes reflect real-world workflow states:
•	assigned_provider_id may be NULL (unassigned tasks)
•	end_date and completed_datetime are nullable for active records
Analytical Use Cases
Use Case 1: Incomplete or Unassigned Tasks Within 30 Days
Objective:
Identify follow-up tasks linked to discharge encounters that remain incomplete or lack provider assignment within 30 days.
Key tables:
PATIENT, ENCOUNTER, DOCUMENT, FOLLOW_UP_TASK
Metric produced:
Count and rate of incomplete or unassigned tasks per discharge event.
Use Case 2: Medication Reconciliation Discrepancies
Objective:
Compare medication lists between discharge and outpatient documentation.
Key tables:
DOCUMENT, DOCUMENT_MEDICATION, MEDICATION
Metric produced:
Discrepancy count and rate between documentation contexts.
Use Case 3: Frequently Associated Problems in Outpatient Encounters
Objective:
Analyze recurring problems documented in outpatient settings.
Key tables:
DOCUMENT, DOCUMENT_PROBLEM, PROBLEM, ENCOUNTER
Metric produced:
Frequency distribution of problem codes by encounter type.
Data Quality & Integrity Controls
•	All foreign keys enforced
•	Junction tables enforce the uniqueness of document-concept associations
•	Referential integrity prevents orphan tasks or concept links
•	Unique constraints enforce clean business identifiers
Future Improvements
•	Add indexing strategy for performance optimization
•	Introduce audit trail fields (created_at, updated_at)
•	Expand medication list-type modeling into a controlled coded domain
•	Implement role-based access patterns
Files in This Repository
•	schema.sql — DDL for table creation and constraints
•	analytical_queries.sql — Core query patterns for the three use cases
•	ERD.png — Entity-relationship diagram
•	data_dictionary.md — Field-level metadata

<img width="468" height="652" alt="image" src="https://github.com/user-attachments/assets/ee61680b-bce2-46d9-bda5-c5cb2a8adcf2" />

