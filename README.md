# Healthcare Analytics Database (MySQL)

A full relational database system for a hospital/clinic, modeling patients, doctors, appointments, admissions, diagnoses, prescriptions, lab results, and billing with business-intelligence style queries built directly in SQL to power a real operations dashboard.

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)

---

##  Why This Project

Most SQL portfolio projects query a pre-built sample database (Chinook, Northwind, etc.). This one is different: **I designed the schema myself** — 10 interconnected tables with proper relationships, constraints, and referential integrity rules then built analytical queries on top that mirror what a real hospital operations dashboard would need: daily revenue, doctor workload, medication inventory alerts, and data-quality health checks.

---

##  Database Schema

10 tables modeling a realistic hospital data model:

| Table | Purpose |
|---|---|
| `departments` | Hospital departments (beds, location, active status) |
| `doctors` | Doctor profiles, specialization, department, fees |
| `patients` | Patient records, insurance info, chronic conditions, allergies |
| `diagnoses` | ICD-10 coded diagnosis reference table |
| `medications` | Medication catalog with drug class, cost, prescription requirements |
| `appointments` | Scheduled/completed/cancelled/no-show appointments |
| `admissions` | Hospital admissions, discharge tracking, billing charges |
| `patient_diagnoses` | Junction table linking patients to diagnoses with severity |
| `prescriptions` | Prescriptions linking patients, doctors, and medications |
| `lab_tests` / `lab_results` | Lab test catalog and patient results, with critical-value flagging |
| `billing` | Patient billing, insurance coverage, payment status |

**Design decisions worth calling out:**
- Foreign keys use deliberate `ON DELETE` behavior  `CASCADE` where child records genuinely shouldn't outlive the parent (e.g. a patient's appointments), `SET NULL` where the relationship is informational (e.g. a doctor leaving shouldn't delete their department's other data), and `RESTRICT` where deletion should be blocked entirely (e.g. can't delete a medication that's actively prescribed)
- `ENUM` types used for controlled-vocabulary fields (appointment status, admission type, blood type) instead of free-text, to keep the data clean and query-friendly

---

## What the Analysis Section Does

Built as a set of report-style query blocks, each mimicking a real dashboard panel:

1. **Doctor Workload Dashboard** :- today's appointments, prescriptions, and admissions per active doctor
2. **Revenue Dashboard**:- total, insurance-covered, and patient-payable revenue broken out by Today / This Week / This Month
3. **Medication Inventory Alerts** :- flags medications as `LOW USAGE`, `HIGH USAGE - RESTOCK`, or `ACTIVE - MONITOR` based on prescription volume and recency
4. **Patient Satisfaction Indicators** — appointment completion rate, average hospital stay length, medication adherence rate, each with a status flag (`EXCELLENT` / `GOOD` / `NEEDS IMPROVEMENT`)
5. **All Scheduled Appointments** — full appointment list joined across patients, doctors, and departments, flagged as upcoming or past
6. **System Health Check** — data-integrity checks for orphaned records, unbilled discharges, stale pending lab results, and low-usage medication stock

---

## Techniques Used


- Multi-table `JOIN`s across up to 4 tables per query
- `CASE WHEN` logic for status flags and thresholds
- Correlated subqueries and `NULLIF` for safe percentage calculations (avoiding divide-by-zero)
- `UNION ALL` to combine multiple metrics into a single readable report output
- `TIMESTAMPDIFF` / `DATEDIFF` for age, length-of-stay, and recency calculations
- `HAVING` clauses to filter aggregated results (e.g. only show doctors with activity today)
- Foreign key constraints with intentional `CASCADE` / `SET NULL` / `RESTRICT` behavior

---

##  How to Run

1. Open `healthcare_analytics.sql` in MySQL Workbench
2. Run the full script (⚡) it creates the database, all 10 tables with foreign keys, seeds sample data, then runs through all 10 analysis sections in order
3. Each section prints a labeled header (e.g. `'6. REVENUE DASHBOARD'`) so you can follow along with what's being calculated as it runs

---

## 🔗 Connect

[LinkedIn](https://www.linkedin.com/in/nashrah-khan-82056b332)
