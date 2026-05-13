# Retail BI Dashboard — Progress Log

## Project Overview
Junior BI Developer application project — UK online retail analytics dashboard
built with Python, SQL Server, and Power BI.

Built as a portfolio project to demonstrate end-to-end data analytics skills. 
**Stack:** Python, SQL Server 2025, SSMS, Power BI Desktop, Git

---

### Step 1 — Environment Setup ✅
- Installed SQL Server 2025 Express
- Installed SSMS 22
- Verified Python 3.13.5 (Anaconda), pandas, pyodbc, sqlalchemy

I chose SQL Server Express over alternatives like PostgreSQL or SQLite because the target role stack specified Microsoft technologies. Using the same ecosystem end-to-end (SQL Server, SSMS, Power BI) reflects a real enterprise BI environment and demonstrates familiarity with the Microsoft data platform.

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

I chose to remove cancelled transactions (InvoiceNo starting with 'C') entirely rather than netting them off against originals, because the analysis goal was revenue performance rather than returns reconciliation. Standardising descriptions to uppercase ensured consistent grouping in product-level aggregations — without this, the same product could appear as multiple entries due to mixed casing.

### Step 4 — Data Loading ✅
- Created RetailDW database in SQL Server
- Loaded clean data into dbo.retail_sales table
- Verified in SSMS — 530,104 rows confirmed

I loaded data via sqlalchemy rather than SSMS bulk import to keep the pipeline reproducible and version-controlled. Anyone cloning the repo can re-run the notebook to rebuild the database from the clean CSV without manual intervention.

### Step 5 — SQL Views ✅
- Created vw_monthly_revenue — monthly revenue, orders and units sold
- Created vw_top_products — top 20 products by revenue
- Created vw_revenue_by_country — revenue and orders by country
- Saved all views to scripts/views.sql

I pre-aggregated data into views rather than loading raw tables into Power BI directly. This keeps transformation logic in SQL where it is easier to test and version control, and reduces the volume of data Power BI needs to import. I used NTILE(4) for customer segmentation rather than manual quartile bins because it distributes customers evenly regardless of spend distribution skew.

### Step 6 — Power BI Dashboard ✅
- Connected Power BI to SQL Server RetailDW (Import mode)
- Created _Measures table with 5 DAX measures (Total Revenue, Total Orders, Total Units Sold, Average Order Value, Unique Customers)
- Built star schema with vw_dim_country as dimension table enabling cross-filtering
- Country slicer filters all visuals simultaneously via proper one-to-many relationships
- **Page 1 — Executive Overview:** 4 KPI cards, monthly revenue line chart, top 20 products bar chart, revenue by country bar chart
- **Page 2 — Customer Segment Analysis:** Bar chart and table showing customer spend distribution across 4 quartiles using CTE-based SQL view
- Key insight: Top 25% of customers average £6,499 spend and 10 orders vs £179 and 1 order for bottom 25%
- Screenshots saved to docs/

I chose Import mode over DirectQuery because the dataset is static and Import mode delivers significantly faster query performance for dashboard interactions. I built the star schema with vw_dim_country as the single dimension table because country was the only shared dimension across all three report pages — adding unnecessary dimension tables would have complicated the model without adding value.

### Step 7 — Customer & Marketing Analytics Extension ✅
- Built cohort retention analysis using 3 chained CTEs and DATEDIFF
- Created A/B test simulation — control/treatment split by CustomerID odd/even
- Ingested semi-structured JSON from REST Countries API (36 countries)
- Joined JSON data to retail sales — Revenue per Million Population metric
- Created 4 new SQL views: vw_cohort_analysis, vw_ab_test, vw_ab_test_summary, vw_country_enriched_sales
- Added Customer & Marketing Analytics page to Power BI dashboard

I used a REST API rather than a static lookup table for population data to demonstrate JSON ingestion and semi-structured data handling as a transferable skill. The odd/even CustomerID split for the A/B test is a proxy for randomisation — in a real scenario this would use a proper experiment design, but it serves to demonstrate the analytical approach and SQL implementation.