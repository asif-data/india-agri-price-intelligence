/*
===================================================================
   Staging Layer: price_analysis_staging
   Source: Daily_Price_Arrival_Report (Layer 1 — Raw)
   
   Transformations Applied:
   1. Grade standardization — reclassified into three analytical 
      categories based on market significance:
      - FAQ: Government of India standard grade
      - Local: High volume, consistent market behavior
      - Other: Grade A, Grade B, Non-FAQ, Medium
      - NA: Excluded (insufficient volume or inconsistent labeling)
   2. Modal price — comma-formatted TEXT converted to NUMERIC
   3. Arrival quantity — comma-formatted TEXT converted to NUMERIC
   4. Arrival date — reformatted from DD-MM-YYYY to YYYY-MM-DD
   
   Exclusions:
   - Grade NA rows (non-standard or unclassifiable grades). NA grades were 
   	excluded because their low arrival volume — under 1% of total — means that 
   	prices reflect individual trader behavior, not market consensus.
   - NULL arrival dates (unreportable records)
   
   Output: 39,074 rows
====================================================================
*/

CREATE TABLE IF NOT EXISTS price_analysis_staging AS
SELECT
    dpar.State                                              AS state
    , dpar.District                                         AS district
    , dpar.Market                                           AS market
    , dpar.Variety                                          AS variety
    -- Grade reclassification into analytical categories
    , CASE
        WHEN dpar.Grade = 'FAQ'                             THEN 'FAQ'
        WHEN dpar.Grade = 'Local'                           THEN 'Local'
        WHEN dpar.Grade IN (
            'Grade A', 'Grade B', 'Non-FAQ', 'Medium')      THEN 'Other'
        ELSE 'NA'
      END                                                   AS analysis_grade
    -- Fix: Modal price stored as comma-formatted TEXT in Layer 1
    , CAST(REPLACE(dpar."Modal Price", ',', '') 
        AS NUMERIC(10,2))                                   AS modal_price
    -- Fix: Arrival quantity stored as comma-formatted TEXT in Layer 1
    , CAST(REPLACE(dpar."Arrival Quantity", ',', '') 
        AS NUMERIC(10,2))                                   AS arrival_quantity
    -- Date conversion: DD-MM-YYYY → YYYY-MM-DD for SQLite compatibility
    , SUBSTR(dpar."Arrival Date", 7, 4) || '-' 
        || SUBSTR(dpar."Arrival Date", 4, 2) || '-' 
        || SUBSTR(dpar."Arrival Date", 1, 2)                AS arrival_date
FROM Daily_Price_Arrival_Report dpar
-- Exclude unclassifiable grades and missing dates
WHERE analysis_grade != 'NA'
AND dpar."Arrival Date" IS NOT NULL
