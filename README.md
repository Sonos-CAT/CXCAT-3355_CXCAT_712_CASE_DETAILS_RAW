# CXCAT-3355: Trinity Flags & Support Case Correlation

**Jira Ticket:** [CXCAT-3355](https://jira.sonos.com/browse/CXCAT-3355)  
**Requester:** Adam McCord  
**Status:** In Development / Exploratory

## Overview
This project correlates specific unhealthy product usage events ("Trinity Flags") with Customer Experience (CX) support cases. The goal is to determine how often users experience specific product errors (e.g., Setup Wizard failure, Playback failure) and subsequently contact support within a defined window.

The resulting data feeds a Tableau dashboard allowing stakeholders to visualize error volumes and drill down into specific case details.

## Methodology

### Attribution Logic
* **Trigger Event:** A user registers an "Unhealthy" event (e.g., `measure_wizard_finish_time` failure).
* **Correlation Window:** A support case is attributed to an error if the case was created **within 7 days** following the error event.
* **User Matching:** Matches are performed on `SONOS_ID`.
* **Exclusions:** Records with `SONOS_ID = 0` (unidentified/system logs) are excluded to prevent false positives and data skew.

### Primary Data Sources
* `PRODUCT_OWNER.RELIABILITY.HHH_DAILY_BY_ACTIVITY_NAME_SONOS_ID_AND_UNHEALTHY_ERRORS` (Source of Trinity Error Flags)
* `DATA_WAREHOUSE.WAREHOUSE_CUSTOMER.VIZ_OWNER_CSX_CONTACT_CASES_VOC` (Source of Support Cases)
* `DATA_WAREHOUSE.WAREHOUSE_SURVEY.VIZ_POST_CONTACT_SURVEY` (Source of Post-Contact Survey data)

---

## SQL Artifacts & Views

The analysis is built using a layered view approach in Snowflake (`CX_ANALYTICS_DEV.JEREMIAH_DEV_EXPLORATORY`).

### 1. Base Logic Table
**Object:** `CXCAT_712_DATA_TRINITY_FLAGS`
* **Grain:** User (`SONOS_ID`) per Day (`DATE_KEY`).
* **Purpose:** Flags specific error types (1/0) and checks if a case or survey exists for that user within the 7-day window.

### 2. Aggregation View (Intermediate)
**Object:** `CXCAT_712_DAILY_AGGREGATED_TRINITY_FLAGS_CASES_ONLY`
* **Grain:** Day (`DATE_KEY`).
* **Purpose:** Aggregates total error counts and distinct users *only* for users who had a confirmed support case.

### 3. Tableau Presentation View
**Object:** `CXCAT_712_DAILY_AGGREGATED_TRINITY_FLAGS_TALL`
* **Grain:** Day (`DATE_KEY`) per Error Type.
* **Purpose:** Unpivots the data into a "Tall" format (Error Name, Error Count) to support dynamic filtering and visualization in Tableau.

### 4. Detail / Drill-Down View (For Exports)
**Object:** `CXCAT_712_CASE_DETAILS_RAW`
* **Grain:** Row-level Case Data.
* **Purpose:** Provides raw case attributes (Subject, Description, Status, etc.) for confirmed matches.
* **Usage:** Used in Tableau Dashboard Actions to allow users to click a date/error spike and see the underlying support tickets. Includes logic to filter out `SONOS_ID = 0`.

---

## User Export Script
Use the script below in Snowflake to export raw case details for a specific date range.

### Instructions for Business Users:
1.  Copy the code block below into a Snowflake Worksheet.
2.  Change the dates in the `SET START_DATE` and `SET END_DATE` lines to your desired range.
3.  Select all (Ctrl+A) and Run.
4.  Download the results to CSV/Excel.

```sql
/*************************************************************************
 * TRINITY FLAGS CASE EXTRACTOR (CXCAT-3355)
 * * INSTRUCTIONS:
 * 1. Change the dates in the "STEP 1" section below.
 * 2. Highlight ALL the code (Ctrl+A).
 * 3. Click the "Run" (Play) button.
 * 4. Download results to Excel/CSV.
 *************************************************************************/

-- =======================================================================
-- STEP 1: SET YOUR DATE RANGE HERE
-- =======================================================================
-- Format must be 'YYYY-MM-DD'
SET START_DATE = '2023-10-01'; 
SET END_DATE   = '2023-10-31';

-- =======================================================================
-- STEP 2: AUTOMATED EXTRACT QUERY
-- =======================================================================
SELECT * FROM 
    CX_ANALYTICS_DEV.JEREMIAH_DEV_EXPLORATORY.CXCAT_712_CASE_DETAILS_RAW
WHERE 
    ORIGINATING_EVENT_DATE >= $START_DATE 
    AND ORIGINATING_EVENT_DATE <= $END_DATE
ORDER BY 
    ORIGINATING_EVENT_DATE DESC;
