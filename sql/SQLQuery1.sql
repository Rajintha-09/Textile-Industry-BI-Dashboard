-- ============================================================
-- STEP 1: CREATE DATABASE
-- ============================================================
CREATE DATABASE MAS_Dashboard;
GO
USE MAS_Dashboard;
GO

-- ============================================================
-- STEP 2: DATA CLEANING - GARMENT TABLE
-- ============================================================
 
-- Fix NULL values in wip column
UPDATE garment_productivity
SET wip = 0
WHERE wip IS NULL;
 
-- Fix department typos
UPDATE garment_productivity
SET department = 'sewing'
WHERE department = 'sweing';
 
UPDATE garment_productivity
SET department = 'finishing'
WHERE department = 'finishing ';
 
-- Fix invalid Quarter5
UPDATE garment_productivity
SET quarter = 'Quarter4'
WHERE quarter = 'Quarter5';
 
-- Cap actual_productivity at 1.0 (cannot exceed 100%)
UPDATE garment_productivity
SET actual_productivity = 1.0
WHERE actual_productivity > 1.0;


-- ============================================================
-- STEP 3: DATA CLEANING - ADIDAS TABLE
-- ============================================================
 
-- Add clean numeric columns
ALTER TABLE adidas_sales ADD Price_Clean FLOAT;
ALTER TABLE adidas_sales ADD Units_Clean INT;
ALTER TABLE adidas_sales ADD Sales_Clean FLOAT;
ALTER TABLE adidas_sales ADD Profit_Clean FLOAT;
ALTER TABLE adidas_sales ADD Margin_Clean FLOAT;
GO
 
-- Remove $ signs and commas - convert to proper numbers
UPDATE adidas_sales
SET Price_Clean = CAST(REPLACE(REPLACE(REPLACE(Price_Per_Unit, '$', ''), ',', ''), ' ', '') AS FLOAT);
 
UPDATE adidas_sales
SET Units_Clean = CAST(REPLACE(REPLACE(Units_Sold, ',', ''), ' ', '') AS INT);
 
UPDATE adidas_sales
SET Sales_Clean = CAST(REPLACE(REPLACE(REPLACE(Total_Sales, '$', ''), ',', ''), ' ', '') AS FLOAT);
 
UPDATE adidas_sales
SET Profit_Clean = CAST(REPLACE(REPLACE(REPLACE(Operating_Profit, '$', ''), ',', ''), ' ', '') AS FLOAT);
 
UPDATE adidas_sales
SET Margin_Clean = CAST(REPLACE(REPLACE(Operating_Margin, '%', ''), ' ', '') AS FLOAT);



-- ============================================================
-- STEP 4: CREATE VIEWS FOR POWER BI
-- ============================================================
 
-- View 1: Team Productivity Summary
CREATE OR ALTER VIEW vw_team_productivity AS
SELECT
    department,
    team,
    quarter,
    day,
    AVG(targeted_productivity)  AS avg_target,
    AVG(actual_productivity)    AS avg_actual,
    SUM(over_time)              AS total_overtime,
    SUM(incentive)              AS total_incentive,
    SUM(idle_time)              AS total_idle_time,
    SUM(no_of_workers)          AS total_workers,
    COUNT(*)                    AS total_records
FROM garment_productivity
GROUP BY department, team, quarter, day;
GO
 
-- View 2: Productivity vs Target
CREATE OR ALTER VIEW vw_productivity_vs_target AS
SELECT
    date,
    department,
    team,
    targeted_productivity,
    actual_productivity,
    actual_productivity - targeted_productivity AS productivity_gap,
    CASE 
        WHEN actual_productivity >= targeted_productivity 
        THEN 'Met Target'
        ELSE 'Below Target'
    END AS target_status,
    over_time,
    incentive,
    idle_time,
    no_of_workers
FROM garment_productivity;
GO
 
-- View 3: Department Summary
CREATE OR ALTER VIEW vw_department_summary AS
SELECT
    department,
    COUNT(*)                    AS total_records,
    AVG(actual_productivity)    AS avg_productivity,
    AVG(targeted_productivity)  AS avg_target,
    SUM(over_time)              AS total_overtime,
    SUM(incentive)              AS total_incentive,
    SUM(idle_time)              AS total_idle_time,
    AVG(no_of_workers)          AS avg_workers
FROM garment_productivity
GROUP BY department;
GO
 
-- View 4: Monthly Sales Trend
CREATE OR ALTER VIEW vw_monthly_sales AS
SELECT
    FORMAT(Invoice_Date, 'yyyy-MM')     AS sales_month,
    YEAR(Invoice_Date)                  AS sales_year,
    MONTH(Invoice_Date)                 AS month_num,
    DATENAME(MONTH, Invoice_Date)       AS month_name,
    SUM(Sales_Clean)                    AS total_revenue,
    SUM(Profit_Clean)                   AS total_profit,
    SUM(Units_Clean)                    AS total_units,
    COUNT(*)                            AS total_orders,
    AVG(Sales_Clean)                    AS avg_order_value
FROM adidas_sales
GROUP BY FORMAT(Invoice_Date, 'yyyy-MM'),
         YEAR(Invoice_Date),
         MONTH(Invoice_Date),
         DATENAME(MONTH, Invoice_Date);
GO
 
-- View 5: Sales by Region & State
CREATE OR ALTER VIEW vw_region_sales AS
SELECT
    Region,
    State,
    City,
    SUM(Sales_Clean)        AS total_revenue,
    SUM(Profit_Clean)       AS total_profit,
    SUM(Units_Clean)        AS total_units,
    COUNT(*)                AS total_orders,
    AVG(Margin_Clean)       AS avg_margin
FROM adidas_sales
GROUP BY Region, State, City;
GO
 
-- View 6: Sales by Product & Retailer
CREATE OR ALTER VIEW vw_product_sales AS
SELECT
    Product,
    Retailer,
    Sales_Method,
    SUM(Sales_Clean)        AS total_revenue,
    SUM(Profit_Clean)       AS total_profit,
    SUM(Units_Clean)        AS total_units,
    AVG(Price_Clean)        AS avg_price,
    AVG(Margin_Clean)       AS avg_margin
FROM adidas_sales
GROUP BY Product, Retailer, Sales_Method;
GO
 
-- View 7: KPI Summary
CREATE OR ALTER VIEW vw_kpi_summary AS
SELECT
    SUM(Sales_Clean)                                AS total_revenue,
    SUM(Profit_Clean)                               AS total_profit,
    SUM(Units_Clean)                                AS total_units_sold,
    COUNT(*)                                        AS total_transactions,
    AVG(Sales_Clean)                                AS avg_order_value,
    CAST(SUM(Profit_Clean) * 100.0 / 
        NULLIF(SUM(Sales_Clean), 0) AS DECIMAL(5,2)) AS profit_margin_pct
FROM adidas_sales;
GO
 
-- View 8: Sales by Retailer
CREATE OR ALTER VIEW vw_retailer_sales AS
SELECT
    Retailer,
    SUM(Sales_Clean)        AS total_revenue,
    SUM(Profit_Clean)       AS total_profit,
    SUM(Units_Clean)        AS total_units,
    COUNT(*)                AS total_orders,
    AVG(Margin_Clean)       AS avg_margin
FROM adidas_sales
GROUP BY Retailer;
GO


-- ============================================================
-- STEP 5: VERIFY EVERYTHING
-- ============================================================
 
-- Check tables
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_CATALOG = 'MAS_Dashboard' AND TABLE_TYPE = 'BASE TABLE';
 
-- Check views
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_CATALOG = 'MAS_Dashboard';
 
-- Check data
SELECT COUNT(*) AS garment_rows FROM garment_productivity;
SELECT COUNT(*) AS adidas_rows FROM adidas_sales;
 
-- Check KPIs
SELECT * FROM vw_kpi_summary;
SELECT TOP 5 * FROM vw_monthly_sales ORDER BY sales_month;
SELECT * FROM vw_department_summary;