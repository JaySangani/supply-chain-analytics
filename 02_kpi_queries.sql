-- ============================================================
-- Supply Chain Operations Analytics — KPI Queries
-- Author: Jay Sangani
-- Project: Supply Chain Operations Analytics Dashboard
-- Dataset: Supply Chain Analysis (Kaggle)
-- Compatible: PostgreSQL / MySQL
-- ============================================================


-- ── 1. DATA EXPLORATION ─────────────────────────────────────────────

-- Row count and basic overview
SELECT COUNT(*) AS total_records
FROM supply_chain;

-- Distinct product types
SELECT
    product_type,
    COUNT(*) AS record_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM supply_chain
GROUP BY product_type
ORDER BY record_count DESC;

-- Distinct suppliers
SELECT
    supplier_name,
    COUNT(*) AS shipments,
    ROUND(AVG(defect_rates), 2) AS avg_defect_rate,
    ROUND(AVG(lead_times), 1)   AS avg_lead_time_days
FROM supply_chain
GROUP BY supplier_name
ORDER BY shipments DESC;


-- ── 2. ON-TIME DELIVERY KPI ─────────────────────────────────────────

-- Overall on-time delivery rate
SELECT
    COUNT(*) AS total_shipments,
    SUM(CASE WHEN shipping_times <= lead_times THEN 1 ELSE 0 END) AS on_time,
    ROUND(
        SUM(CASE WHEN shipping_times <= lead_times THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS on_time_delivery_rate_pct
FROM supply_chain;

-- On-time delivery rate by product type
SELECT
    product_type,
    COUNT(*) AS total_shipments,
    ROUND(
        SUM(CASE WHEN shipping_times <= lead_times THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS on_time_rate_pct
FROM supply_chain
GROUP BY product_type
ORDER BY on_time_rate_pct ASC;

-- On-time delivery by supplier
SELECT
    supplier_name,
    COUNT(*) AS total_shipments,
    ROUND(
        SUM(CASE WHEN shipping_times <= lead_times THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS on_time_rate_pct,
    ROUND(AVG(shipping_times - lead_times), 1) AS avg_delay_days
FROM supply_chain
GROUP BY supplier_name
ORDER BY on_time_rate_pct ASC;


-- ── 3. COST ANALYSIS KPI ────────────────────────────────────────────

-- Average cost per shipment by transportation mode
SELECT
    transportation_modes,
    COUNT(*) AS shipments,
    ROUND(AVG(shipping_costs), 2)       AS avg_shipping_cost,
    ROUND(AVG(manufacturing_costs), 2)  AS avg_manufacturing_cost,
    ROUND(AVG(shipping_costs + manufacturing_costs), 2) AS avg_total_cost
FROM supply_chain
GROUP BY transportation_modes
ORDER BY avg_total_cost DESC;

-- Cost per unit revenue (cost efficiency) by product type
SELECT
    product_type,
    ROUND(SUM(manufacturing_costs), 2) AS total_manufacturing_cost,
    ROUND(SUM(revenue_generated), 2)   AS total_revenue,
    ROUND(
        SUM(manufacturing_costs) / NULLIF(SUM(revenue_generated), 0),
        4
    ) AS cost_per_revenue_dollar
FROM supply_chain
GROUP BY product_type
ORDER BY cost_per_revenue_dollar DESC;

-- Top 10 most expensive routes
SELECT
    routes,
    transportation_modes,
    COUNT(*) AS shipments,
    ROUND(AVG(shipping_costs), 2) AS avg_shipping_cost
FROM supply_chain
GROUP BY routes, transportation_modes
ORDER BY avg_shipping_cost DESC
LIMIT 10;


-- ── 4. SUPPLIER PERFORMANCE KPI ─────────────────────────────────────

-- Supplier scorecard
SELECT
    supplier_name,
    COUNT(*) AS total_shipments,
    ROUND(AVG(defect_rates), 2) AS avg_defect_rate_pct,
    ROUND(AVG(lead_times), 1)   AS avg_lead_time_days,
    ROUND(AVG(shipping_costs), 2) AS avg_shipping_cost,
    ROUND(
        SUM(CASE WHEN shipping_times <= lead_times THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS on_time_rate_pct
FROM supply_chain
GROUP BY supplier_name
ORDER BY avg_defect_rate_pct DESC;


-- ── 5. STOCK AND AVAILABILITY KPI ───────────────────────────────────

-- Stock availability by product type
SELECT
    product_type,
    ROUND(AVG(stock_levels), 0)         AS avg_stock_level,
    ROUND(AVG(order_quantities), 0)     AS avg_order_qty,
    ROUND(
        AVG(stock_levels) / NULLIF(AVG(order_quantities), 0) * 100,
        2
    ) AS fill_rate_pct
FROM supply_chain
GROUP BY product_type
ORDER BY fill_rate_pct ASC;

-- Products with critically low stock (below 20% fill rate)
SELECT
    sku,
    product_type,
    stock_levels,
    order_quantities,
    ROUND(stock_levels * 100.0 / NULLIF(order_quantities, 0), 2) AS fill_rate_pct
FROM supply_chain
WHERE (stock_levels * 100.0 / NULLIF(order_quantities, 0)) < 20
ORDER BY fill_rate_pct ASC;


-- ── 6. DEFECT AND QUALITY KPI ───────────────────────────────────────

-- Defect rate by product category and supplier
SELECT
    product_type,
    supplier_name,
    ROUND(AVG(defect_rates), 2) AS avg_defect_rate_pct,
    COUNT(*) AS sample_size
FROM supply_chain
GROUP BY product_type, supplier_name
HAVING COUNT(*) > 5
ORDER BY avg_defect_rate_pct DESC
LIMIT 20;

-- Revenue lost to defects (estimated)
SELECT
    product_type,
    ROUND(SUM(revenue_generated), 2) AS total_revenue,
    ROUND(AVG(defect_rates), 4)      AS avg_defect_rate,
    ROUND(
        SUM(revenue_generated) * AVG(defect_rates) / 100,
        2
    ) AS estimated_revenue_at_risk
FROM supply_chain
GROUP BY product_type
ORDER BY estimated_revenue_at_risk DESC;


-- ── 7. EXECUTIVE SUMMARY VIEW ───────────────────────────────────────

-- Single-row KPI summary for dashboard headline cards
SELECT
    COUNT(*)                                                      AS total_shipments,
    ROUND(AVG(revenue_generated), 2)                             AS avg_revenue_per_shipment,
    ROUND(SUM(revenue_generated), 2)                             AS total_revenue,
    ROUND(AVG(shipping_costs), 2)                                AS avg_shipping_cost,
    ROUND(AVG(defect_rates), 2)                                  AS avg_defect_rate_pct,
    ROUND(
        SUM(CASE WHEN shipping_times <= lead_times THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    )                                                            AS on_time_delivery_rate_pct,
    ROUND(AVG(lead_times), 1)                                    AS avg_lead_time_days
FROM supply_chain;
