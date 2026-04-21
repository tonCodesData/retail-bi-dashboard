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