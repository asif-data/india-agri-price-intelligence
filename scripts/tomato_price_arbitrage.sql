
/*
===================================================================
   Staging Layer: tomato_price_arbitrage
   Source: price_analysis_staging (Layer 2 — Staging)
   
   Purpose: Identify directional mandi pair price comparisons
   where a statistically meaningful arbitrage opportunity exists
   within a feasible transport window.
   
   Cross Join Logic:
   - Source mandi price on date X vs destination mandi on date X+N
   - Match restricted to same analysis_grade only
   - Both directions captured (A→B and B→A are separate rows)
   
   Filters Applied:
   - Minimum arrival quantity: 6 tonnes (minimum viable 
     procurement threshold for small entrepreneur)
   - Same mandi exclusion: composite key state-district-market
   - Grade matching: FAQ vs FAQ, Local vs Local, Other vs Other
   - Minimum price gap: Rs. 100/quintal (Rs. 1/kg minimum 
     viable arbitrage signal)
   - Transport window: 1-7 days (assumption — will be tightened 
     dynamically using inter-mandi distance in downstream layer)
   
   Output: 1,685,459 rows | 37,062 distinct mandi pairs
====================================================================
*/

CREATE TABLE IF NOT EXISTS tomato_price_arbitrage AS
WITH 

-- Base comparison pool: one row per mandi per date
-- Volume filter applied here to restrict to operationally 
-- viable mandis only (>= 6 tonnes arrival)
viable_mandis AS (
    SELECT
        pas.state || '-' || pas.district || '-' || pas.market  AS mandi_key
        , pas.state
        , pas.variety
        , pas.analysis_grade
        , pas.modal_price
        , pas.arrival_quantity
        , pas.arrival_date
    FROM price_analysis_staging pas
    WHERE pas.arrival_quantity >= 6
)

-- Directional cross join: source mandi on date X vs 
-- destination mandi on date X+N (1 to 7 days)
SELECT
    'From ' || src.mandi_key 
        || ' to ' || dest.mandi_key                        AS mandi_pair
    , src.mandi_key                                         AS source_mandi_key
    , dest.mandi_key                                        AS destination_mandi_key
    , CASE
        WHEN src.state = dest.state THEN 'Within State'
        ELSE 'Between States'
      END                                                   AS transport_type
    , src.variety                                           AS source_variety
    , dest.variety                                          AS destination_variety
    , src.analysis_grade                                    AS analysis_grade
    , CAST(src.modal_price AS NUMERIC)                      AS source_price
    , CAST(dest.modal_price AS NUMERIC)                     AS destination_price
    , dest.modal_price - src.modal_price                    AS price_arbitrage
    , src.arrival_quantity                                  AS source_quantity
    , dest.arrival_quantity                                 AS destination_quantity
    , src.arrival_date                                      AS source_date
    , dest.arrival_date                                     AS destination_date
    -- Transport window in days between source and destination date
    , JULIANDAY(dest.arrival_date) 
        - JULIANDAY(src.arrival_date)                       AS transport_window
FROM viable_mandis AS src
CROSS JOIN viable_mandis AS dest
WHERE
    -- Match on same grade category only
    src.analysis_grade = dest.analysis_grade
    -- Exclude self-comparisons using composite mandi identity
    AND src.mandi_key != dest.mandi_key
    -- Transport window: 1-7 days (assumption, to be refined 
    -- with distance data in downstream layer)
    AND JULIANDAY(dest.arrival_date) 
        - JULIANDAY(src.arrival_date) BETWEEN 1 AND 7
    -- Minimum viable price gap: Rs. 100/quintal = Rs. 1/kg
    AND dest.modal_price - src.modal_price > 100
    
    
