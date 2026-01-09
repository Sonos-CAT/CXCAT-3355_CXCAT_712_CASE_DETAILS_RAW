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
