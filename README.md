# cfk-community-data-cleaning
SQL data cleaning scripts and database schema normalization for community program and health metrics data.
# CFK Community Data Systems — Relational Database Cleaning & Transformation (SQL)

## Project Overview
This project focuses on the end-to-end data cleaning, standardization, and schema normalization of three core community development datasets managed by CFK: **Health Clinic Visits**, **Beneficiary Profiles** and **Program Activities**. 

Using PostgreSQL, I developed advanced data transformation pipelines using views. These scripts convert raw, highly inconsistent administrative logs into fully optimized, clean relational tables ready for enterprise M&E (Monitoring & Evaluation) reporting and automated Power BI dashboard integrations.

---

##  Key Data Engineering Challenges Handled
* **Advanced Date Standardization:** Resolved critical data-entry inconsistencies where dates were stored in multiple mixed formats (`YYYY-MM-DD`, `DD-MM-YYYY`, `DD/MM/YYYY`, and raw text entries like `Jan 12 2024` or `March 2023`). I built robust cascading `CASE` statements utilizing conditional `LIKE` string pattern matching and `TO_DATE()` parsing.
* **Text Normalization & Whitespace Trimming:** Applied `INITCAP()`, `LOWER()`, and `TRIM()` functions across categorical text fields (e.g., `Gender`, `Village`, `Attendance`, `Staff`, and `Facilitator`) to remove trailing white spaces and fix case-sensitivity bugs that break relational queries.
* **Data Type Integrity & Currency Casting:** Fixed structural inconsistencies where numerical fees were recorded as text strings (e.g., transforming text entry `'One Fifty'` into integer `150`) allowing for mathematical aggregations.
* **Handling Unregistered Entities & Null Values:** Enforced programmatic default fallbacks using `COALESCE` for missing contact numbers and mapped corrupt/test records (e.g., ID anomalies like `CFK999` or `CFK888`) to clean system labels.

---

##  Data Transformation & Schema Mapping

### 1. `cfk_health_visits`  `health_visits` View
* **Before:** Dates were structurally mismatched, and fee columns contained a mixture of string words and integers.
* **After:** Enforced a strict `INTEGER` data type for fees and structural `DATE` fields.

### 2. `cfk_beneficiaries` ,`beneficiaries` View
* **Before:** Gender codes were completely unstandardized (`f`, `female`, `m`, `male`), and village names lacked casing uniformity.

| Raw State (Before) | Normalized State (After) | Data Solution |
| :--- | :--- | :--- |
| `f`, `female`, `m` | `Female` / `Male` | Standardized using conditional array mapping |
| `soweto east` | `Soweto East` | Capitalized layout using `INITCAP` |
| ` ` (Blank Age) | `0` | Handled missing metrics using `COALESCE` |

### 3. `cfk_program_activities` ,`program_activities` View
* **Before:** Flagged operational inconsistencies with test IDs and trailing spaces in system-generated column headers.

---

##  Tools & SQL Concepts Applied
* **Database Engine:** PostgreSQL / Supabase
* **SQL Mastery Demonstrated:** Relational database views (`CREATE VIEW`), structural pattern matching (`LIKE %`), data type manipulation (`CAST`), conditional sorting logic (`CASE WHEN`), character text trimming (`TRIM`), and cross-table entity normalization.
