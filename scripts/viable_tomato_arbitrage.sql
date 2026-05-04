/*
===================================================================
   Analysis Layer: viable_tomato_arbitrage
   Purpose: Estimate profit per trip between each mandi pair.

   Assumptions:
   - Truck capacity 	: 3 MT (30 quintals)
   - Spoilage 			: 3-5% tomatoes are spoiled during transport
   							when packaged into plastic crates. 
   							For this calculation, 5% is being used as
   							a conservative value for spoilage
   - Quantity Filter 	: An average 3 MT quantity difference between
   							the mandi pairs is being used since the
   							vehicle used in the assumption is of 3MT

   Exclusion: Mandi Commission (2% of Sale Value) since destination
   				mandi's arrival price is not available

===================================================================
*/
CREATE TABLE IF NOT EXISTS viable_tomato_arbitrage AS
WITH raw_trip_components as  (
SELECT 
	smp.mandi_pair
	, smp.analysis_grade
	, smp.consecutive_months
	, smp.avg_price_gap as avg_price_gap_per_quintal
	, smp.avg_price_gap * 10 as avg_price_gap_per_MT
	, smp.avg_price_gap * 30 as gross_price_advantage
	-- Accounting for 5% spoilage
	, smp.avg_price_gap * 30 * 0.05 as loss_to_spoilage
	, smp.avg_quantity_gap  as avg_quantity_gap_MT
FROM shortlisted_mandi_pairs smp 
WHERE avg_quantity_gap_MT > 3
)
, net_price_advantage_calculation AS (
SELECT 
	mandi_pair
	, analysis_grade 
	, consecutive_months 
	, avg_quantity_gap_MT 
	, gross_price_advantage
	, loss_to_spoilage 
	, gross_price_advantage - loss_to_spoilage as net_price_advantage
FROM raw_trip_components
)
SELECT 
	pc.mandi_pair
	, pc.analysis_grade 
	, pc.consecutive_months 
	, pc.avg_quantity_gap_MT 
	, pc.gross_price_advantage
	, pc.loss_to_spoilage
	, pc.net_price_advantage
	, lc.distance_km 
	, lc.total_transport_cost 
	, pc.net_price_advantage - lc.total_transport_cost as profit_per_trip
FROM net_price_advantage_calculation as pc
LEFT JOIN logistics_calculation as lc  
ON pc.mandi_pair = lc.mandi_pair 
ORDER BY profit_per_trip desc
