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

### Step 6 — Power BI Dashboard ⬜ Pending
### Step 7 — Documentation and Portfolio Polish ⬜ Pending