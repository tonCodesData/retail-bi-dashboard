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