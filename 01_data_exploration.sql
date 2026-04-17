-- ============================================================
-- Supply Chain Analytics — Data Exploration Queries
-- Author: Jay Sangani
-- Run these first before the KPI queries
-- ============================================================


-- ── STEP 1: Understand the table structure ───────────────────────────

-- Check all columns and row count
SELECT COUNT(*) AS total_rows FROM supply_chain;

-- Sample 10 rows to understand the data
SELECT * FROM supply_chain LIMIT 10;

-- Check for nulls across all key columns
SELECT
    SUM(CASE WHEN product_type       IS NULL THEN 1 ELSE 0 END) AS null_product_type,
    SUM(CASE WHEN sku                IS NULL THEN 1 ELSE 0 END) AS null_sku,
    SUM(CASE WHEN price              IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN revenue_generated  IS NULL THEN 1 ELSE 0 END) AS null_revenue,
    SUM(CASE WHEN supplier_name      IS NULL THEN 1 ELSE 0 END) AS null_supplier,
    SUM(CASE WHEN shipping_costs     IS NULL THEN 1 ELSE 0 END) AS null_shipping_costs,
    SUM(CASE WHEN defect_rates       IS NULL THEN 1 ELSE 0 END) AS null_defect_rates,
    SUM(CASE WHEN lead_times         IS NULL THEN 1 ELSE 0 END) AS null_lead_times
FROM supply_chain;


-- ── STEP 2: Distribution of key categorical fields ───────────────────

-- Product type distribution
SELECT
    product_type,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM supply_chain
GROUP BY product_type
ORDER BY count DESC;

-- Supplier distribution
SELECT
    supplier_name,
    COUNT(*) AS shipments
FROM supply_chain
GROUP BY supplier_name
ORDER BY shipments DESC;

-- Transportation mode split
SELECT
    transportation_modes,
    COUNT(*)                                   AS shipments,
    ROUND(AVG(shipping_costs), 2)              AS avg_cost,
    ROUND(AVG(lead_times), 1)                  AS avg_lead_days
FROM supply_chain
GROUP BY transportation_modes
ORDER BY shipments DESC;

-- Routes used
SELECT
    routes,
    COUNT(*) AS uses,
    ROUND(AVG(shipping_costs), 2) AS avg_cost
FROM supply_chain
GROUP BY routes
ORDER BY uses DESC;


-- ── STEP 3: Numeric column ranges ────────────────────────────────────

SELECT
    ROUND(MIN(price), 2)              AS min_price,
    ROUND(MAX(price), 2)              AS max_price,
    ROUND(AVG(price), 2)              AS avg_price,
    ROUND(MIN(revenue_generated), 2)  AS min_revenue,
    ROUND(MAX(revenue_generated), 2)  AS max_revenue,
    ROUND(AVG(revenue_generated), 2)  AS avg_revenue,
    ROUND(MIN(shipping_costs), 2)     AS min_ship_cost,
    ROUND(MAX(shipping_costs), 2)     AS max_ship_cost,
    ROUND(AVG(shipping_costs), 2)     AS avg_ship_cost,
    ROUND(MIN(defect_rates), 4)       AS min_defect,
    ROUND(MAX(defect_rates), 4)       AS max_defect,
    ROUND(AVG(defect_rates), 4)       AS avg_defect,
    ROUND(MIN(lead_times), 0)         AS min_lead_days,
    ROUND(MAX(lead_times), 0)         AS max_lead_days,
    ROUND(AVG(lead_times), 1)         AS avg_lead_days
FROM supply_chain;


-- ── STEP 4: Identify data quality issues ─────────────────────────────

-- Negative or zero prices (should not exist)
SELECT COUNT(*) AS bad_price_rows
FROM supply_chain
WHERE price <= 0;

-- Negative revenue (returns or errors)
SELECT COUNT(*) AS negative_revenue_rows
FROM supply_chain
WHERE revenue_generated < 0;

-- Defect rates outside 0-100% range
SELECT COUNT(*) AS bad_defect_rows
FROM supply_chain
WHERE defect_rates < 0 OR defect_rates > 100;

-- Shipping time longer than 3x lead time (potential anomalies)
SELECT
    sku,
    supplier_name,
    lead_times,
    shipping_times,
    ROUND(shipping_times / NULLIF(lead_times, 0), 2) AS delay_ratio
FROM supply_chain
WHERE shipping_times > lead_times * 3
ORDER BY delay_ratio DESC
LIMIT 20;
