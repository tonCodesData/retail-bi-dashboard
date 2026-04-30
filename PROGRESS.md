# Retail BI Dashboard — Progress Log

## Project Overview
Junior BI Developer application project — UK online retail analytics dashboard
built with Python, SQL Server, and Power BI.

**Target role:** Junior BI Developer, Trafford, Manchester  
**Stack:** Python, SQL Server 2025, SSMS, Power BI Desktop, Git

---

## Week 1 — 16/04/2026

### Step 1 — Environment Setup ✅
- Installed SQL Server 2025 Express
- Installed SSMS 22
- Verified Python 3.13.5 (Anaconda), pandas, pyodbc, sqlalchemy

### Step 2 — Data Acquisition ✅
- Downloaded UCI Online Retail dataset (541,909 rows, UK retailer 2010–2011)

### Step 3 — Data Cleaning (Python) ✅
- Removed 1,454 rows with missing product descriptions
- Removed 9,288 cancelled transactions
- Removed 474 negative quantity rows and 589 zero price rows
- Standardised descriptions to uppercase, trimmed whitespace
- Converted InvoiceDate to datetime
- Added TotalAmount column (Quantity × UnitPrice)
- Final clean dataset: 530,104 rows, £10,666,684 total revenue, 38 countries

### Step 4 — Data Loading ✅
- Created RetailDW database in SQL Server
- Loaded clean data into dbo.retail_sales table
- Verified in SSMS — 530,104 rows confirmed

### Step 5 — SQL Views ✅
- Created vw_monthly_revenue — monthly revenue, orders and units sold
- Created vw_top_products — top 20 products by revenue
- Created vw_revenue_by_country — revenue and orders by country
- Saved all views to scripts/views.sql

### Step 6 — Power BI Dashboard ✅
- Connected Power BI to SQL Server RetailDW (Import mode)
- Created _Measures table with 5 DAX measures (Total Revenue, Total Orders, Total Units Sold, Average Order Value, Unique Customers)
- Built star schema with vw_dim_country as dimension table enabling cross-filtering
- Country slicer filters all visuals simultaneously via proper one-to-many relationships
- **Page 1 — Executive Overview:** 4 KPI cards, monthly revenue line chart, top 20 products bar chart, revenue by country bar chart
- **Page 2 — Customer Segment Analysis:** Bar chart and table showing customer spend distribution across 4 quartiles using CTE-based SQL view
- Key insight: Top 25% of customers average £6,499 spend and 10 orders vs £179 and 1 order for bottom 25%
- Screenshots saved to docs/

### Step 7 — Customer & Marketing Analytics Extension ✅
- Built cohort retention analysis using 3 chained CTEs and DATEDIFF
- Created A/B test simulation — control/treatment split by CustomerID odd/even
- Ingested semi-structured JSON from REST Countries API (36 countries)
- Joined JSON data to retail sales — Revenue per Million Population metric
- Created 4 new SQL views: vw_cohort_analysis, vw_ab_test, vw_ab_test_summary, vw_country_enriched_sales
- Added Customer & Marketing Analytics page to Power BI dashboard
- Applied to Matalan Customer Data Analyst role