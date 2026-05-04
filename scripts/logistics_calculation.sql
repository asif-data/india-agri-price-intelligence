/*
===================================================================
   Analysis Layer: logistics_calculation
   Purpose: Estimate one-way road transport cost for a 3 MT truck
   between each mandi pair using distance and standardised cost
   assumptions.

   Vehicle Assumptions:
   - Truck capacity : 3 MT (30 quintals)
   - Fuel efficiency: 4 km per litre
   - Fuel price     : INR 92 per litre

   Per-Trip Fixed Costs:
   - Loading & unloading : INR 800 per mandi = INR 1,600 total
   - Crate rental        : 120 crates x INR 5 = INR 600
   - Weighing charges    : INR 300 per mandi = INR 600 total
   - Driver base allowance (food): INR 200 flat

   Per-KM Variable Costs:
   - Toll charges        : INR 5/km (standardised approximation;
                           actual toll varies by plaza and route)
   - Maintenance charges : INR 3/km
   - Driver & assistant  : INR 1/km

   Distance Logic:
   - MAX distance used where Gemini returned conflicting values
   - Rationale: accounts for local/non-highway route scenarios
     which represent the conservative (higher cost) case

===================================================================
*/

CREATE TABLE IF NOT EXISTS logistics_calculation AS

WITH distance_resolved AS (
-- Resolve duplicate distance estimates by taking MAX
-- MAX chosen to account for local route scenarios (conservative assumption)
    SELECT
        mandi_pair,
        MAX(distance_km) AS distance_km
    FROM mandi_pair_distance
    GROUP BY mandi_pair
)

, cost_components AS (
-- Calculate each cost component separately for transparency
    SELECT
        mandi_pair,
        distance_km,
        ROUND((distance_km / 4.0) * 92, 2)     AS fuel_cost,
        ROUND(distance_km * 5, 2)               AS toll_charges,
        ROUND(distance_km * 3, 2)               AS maintenance_charges,
        1600                                     AS loading_unloading_charges,
        600                                      AS crate_rental_charges,
        600                                      AS weighing_charges,
        ROUND(200 + (distance_km * 1), 2)       AS labour_charges
    FROM distance_resolved
)

SELECT
    mandi_pair,
    distance_km,
    fuel_cost,
    toll_charges,
    maintenance_charges,
    loading_unloading_charges,
    crate_rental_charges,
    weighing_charges,
    labour_charges,
    ROUND(
        fuel_cost + toll_charges + maintenance_charges +
        loading_unloading_charges + crate_rental_charges +
        weighing_charges + labour_charges
    , 2)                                         AS total_transport_cost
FROM cost_components
