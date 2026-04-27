-- =============================================
-- Retail BI Dashboard — SQL Views
-- Database: RetailDW
-- =============================================

-- View 1: Monthly Revenue
CREATE VIEW vw_monthly_revenue AS
SELECT 
    YEAR(InvoiceDate) AS Year,
    MONTH(InvoiceDate) AS Month,
    DATENAME(MONTH, InvoiceDate) AS MonthName,
    ROUND(SUM(TotalAmount), 2) AS MonthlyRevenue,
    COUNT(DISTINCT InvoiceNo) AS NumberOfOrders,
    SUM(Quantity) AS TotalUnitsSold
FROM dbo.retail_sales
GROUP BY 
    YEAR(InvoiceDate), 
    MONTH(InvoiceDate),
    DATENAME(MONTH, InvoiceDate)

-- View 2: Top 20 Products by Revenue
CREATE VIEW vw_top_products AS
SELECT TOP 20
    StockCode,
    Description,
    ROUND(SUM(TotalAmount), 2) AS TotalRevenue,
    SUM(Quantity) AS TotalUnitsSold,
    COUNT(DISTINCT InvoiceNo) AS NumberOfOrders,
    ROUND(AVG(UnitPrice), 2) AS AvgUnitPrice
FROM dbo.retail_sales
GROUP BY StockCode, Description
ORDER BY TotalRevenue DESC

-- View 3: Revenue by Country
CREATE VIEW vw_revenue_by_country AS
SELECT 
    Country,
    ROUND(SUM(TotalAmount), 2) AS TotalRevenue,
    COUNT(DISTINCT InvoiceNo) AS NumberOfOrders,
    SUM(Quantity) AS TotalUnitsSold,
    COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM dbo.retail_sales
GROUP BY Country

-- View 4: Customer Segments (CTE example)
-- Uses two CTEs to segment customers into spend quartiles
-- CTE 1 (customer_spend): aggregates total spend, orders, and dates per customer
-- CTE 2 (customer_segments): applies NTILE(4) to rank customers into quartiles
CREATE VIEW vw_customer_segments AS
WITH customer_spend AS (
    SELECT 
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS TotalOrders,
        ROUND(SUM(TotalAmount), 2) AS TotalSpend,
        ROUND(AVG(TotalAmount), 2) AS AvgOrderValue,
        MIN(InvoiceDate) AS FirstPurchase,
        MAX(InvoiceDate) AS LastPurchase
    FROM dbo.retail_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
customer_segments AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY TotalSpend DESC) AS SpendQuartile
    FROM customer_spend
)
SELECT 
    SpendQuartile,
    COUNT(*) AS NumberOfCustomers,
    ROUND(AVG(TotalSpend), 2) AS AvgSpend,
    ROUND(MIN(TotalSpend), 2) AS MinSpend,
    ROUND(MAX(TotalSpend), 2) AS MaxSpend,
    ROUND(AVG(TotalOrders), 2) AS AvgOrders
FROM customer_segments
GROUP BY SpendQuartile

-- View 5: Cohort Analysis
-- Three CTEs tracking customer retention by acquisition month
CREATE VIEW vw_cohort_analysis AS
WITH tbl_acquisition AS (
    SELECT CustomerID,
        DATEFROMPARTS(YEAR(MIN(InvoiceDate)), MONTH(MIN(InvoiceDate)), 1) AS CohortMonth
    FROM retail_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
tbl_activity AS (
    SELECT r.CustomerID,
        DATEFROMPARTS(YEAR(r.InvoiceDate), MONTH(r.InvoiceDate), 1) AS ActivityMonth,
        a.CohortMonth
    FROM retail_sales AS r
    JOIN tbl_acquisition AS a ON r.CustomerID = a.CustomerID
),
tbl_cohort AS (
    SELECT CohortMonth, ActivityMonth,
        DATEDIFF(MONTH, CohortMonth, ActivityMonth) AS MonthNumber,
        COUNT(DISTINCT CustomerID) AS ActiveCustomers
    FROM tbl_activity
    GROUP BY CohortMonth, ActivityMonth, DATEDIFF(MONTH, CohortMonth, ActivityMonth)
)
SELECT CohortMonth, MonthNumber, ActiveCustomers FROM tbl_cohort

-- View 6: A/B Test — customer level
CREATE VIEW vw_ab_test AS
SELECT CustomerID,
    CASE WHEN CAST(CustomerID AS INT) % 2 = 0 THEN 'Control' ELSE 'Treatment' END AS TestGroup,
    COUNT(DISTINCT InvoiceNo) AS TotalOrders,
    ROUND(SUM(TotalAmount), 2) AS TotalRevenue,
    ROUND(AVG(TotalAmount), 2) AS AvgOrderValue
FROM retail_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID

-- View 7: A/B Test Summary
CREATE VIEW vw_ab_test_summary AS
SELECT TestGroup,
    COUNT(CustomerID) AS NumberOfCustomers,
    ROUND(AVG(TotalRevenue), 2) AS AvgCustomerRevenue,
    ROUND(AVG(AvgOrderValue), 2) AS AvgOrderValue,
    ROUND(AVG(TotalOrders), 2) AS AvgOrders
FROM vw_ab_test
GROUP BY TestGroup

-- View 8: Country Enriched Sales (JSON data joined to retail transactions)
CREATE VIEW vw_country_enriched_sales AS
SELECT r.Country, ce.Region, ce.Subregion, ce.Population, ce.Area_km2,
    ROUND(SUM(r.TotalAmount), 2) AS TotalRevenue,
    COUNT(DISTINCT r.InvoiceNo) AS TotalOrders,
    COUNT(DISTINCT r.CustomerID) AS UniqueCustomers,
    ROUND(SUM(r.TotalAmount) / ce.Population * 1000000, 2) AS RevenuePerMillion
FROM retail_sales r
JOIN country_enriched ce ON r.Country = ce.Country
GROUP BY r.Country, ce.Region, ce.Subregion, ce.Population, ce.Area_km2