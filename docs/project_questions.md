# India Agricultural Price Intelligence System

## Mission
Quantify spatial price inefficiency in Indian agricultural commodity 
markets to identify arbitrage opportunities for small entrepreneurs 
operating within a 2-day transport window constraint.

## Dataset
This analysis is based on modal prices for tomato across Uttar Pradesh 
mandis for the intended date range 01-01-2025 to 31-12-2025. Data is 
sourced from the Agriculture Marketing Information System portal 
(agmarknet.gov.in), published by the Directorate of Marketing and 
Inspection, Department of Agriculture and Farmers Welfare, 
Government of India.

## Analytical Questions
1. Which mandi pairs show a statistically persistent price difference 
   greater than estimated transport cost for the same commodity, 
   variety, and grade on a 2-day lag basis?
2. Which commodity-mandi combinations have sufficient arrival volume 
   to be operationally viable — filtering out thin markets where 
   price signals are unreliable?
3. Which mandi pairs show this price gap consistently across at least 
   3 months, indicating structural inefficiency rather than seasonal 
   noise?
4. Does price inefficiency follow seasonal patterns — and if so, 
   when is the optimal procurement window for each commodity?

## Constraints
- Missing reporting dates for many mandis
- Within-state analysis only — interstate price dynamics excluded
- Variety and grade inconsistency across mandis requiring 
  standardization before direct comparison
- Low arrival volume mandis produce noisy price signals — 
  thin markets will be filtered
- Transport cost data unavailable — will be estimated using mandi 
  distance, 1-ton vehicle fuel consumption, labor for 2, and 
  packaging as explicit documented assumptions

## End Deliverable
A ranked list of mandi pairs by average 2-day price differential, 
filtered for volume viability and 3-month consistency, used by a 
small entrepreneur before a seasonal procurement cycle to validate 
whether an arbitrage route covers overhead and logistics costs.
