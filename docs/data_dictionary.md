# Data Dictionary — Retail BI Dashboard

**Dataset:** UCI Online Retail  
**Database:** RetailDW (SQL Server 2025 Express)  
**Last updated:** May 2026  
**Owner:** Mohammad Mamunor Rashid Tonmoy  

---

## Core Table: dbo.retail_sales

This is the primary fact table containing all cleaned transactional data. 530,104 rows after quality processing.

| Field | Data Type | Description | Example | Notes |
|-------|-----------|-------------|---------|-------|
| InvoiceNo | VARCHAR | Unique identifier for each transaction. Invoices starting with 'C' denote cancellations and have been excluded from this dataset. | 536365 | 6-digit integer as string |
| StockCode | VARCHAR | Unique product identifier assigned by the retailer. | 85123A | Alphanumeric |
| Description | VARCHAR | Product name. Standardised to uppercase during cleaning. | WHITE HANGING HEART T-LIGHT HOLDER | Rows with missing descriptions excluded |
| Quantity | INT | Number of units purchased per line item. Negative values excluded during cleaning. | 6 | Always positive in clean dataset |
| InvoiceDate | DATETIME | Date and time of the transaction. | 2010-12-01 08:26:00 | Range: Dec 2010 – Dec 2011 |
| UnitPrice | DECIMAL | Price per unit in GBP (£). Zero and negative prices excluded during cleaning. | 2.55 | Always positive in clean dataset |
| CustomerID | VARCHAR | Unique customer identifier. Nullable — approximately 25% of transactions have no CustomerID (guest/anonymous purchases). | 17850 | NULL values retained in fact table; excluded from customer-level analysis |
| Country | VARCHAR | Country where the customer is based. | United Kingdom | 38 distinct countries |
| TotalAmount | DECIMAL | Derived field: Quantity × UnitPrice. Calculated during Python cleaning pipeline. | 15.30 | Always positive |

---

## Enrichment Table: dbo.country_enriched

Country-level metadata ingested from the REST Countries public API (restcountries.com). 36 countries matched to retail dataset.

| Field | Data Type | Description | Example | Notes |
|-------|-----------|-------------|---------|-------|
| Country | VARCHAR | Country name — matches Country field in dbo.retail_sales for JOIN. | United Kingdom | ISO alpha-2 mapping used during API ingestion |
| Population | BIGINT | Total population of the country at time of API call (2026). | 67886011 | Source: REST Countries API |
| Region | VARCHAR | World region classification. | Europe | e.g. Europe, Asia, Americas, Oceania |
| Subregion | VARCHAR | More granular regional classification. | Northern Europe | e.g. Northern Europe, Western Asia |
| Area_km2 | DECIMAL | Total land area in square kilometres. | 242900.0 | Source: REST Countries API |

---

## Integration Table: dbo.xml_orders

Sample order data parsed from XML format — demonstrates XML data ingestion capability.

| Field | Data Type | Description | Example | Notes |
|-------|-----------|-------------|---------|-------|
| invoice_no | VARCHAR | Invoice reference number. | 536365 | Matches InvoiceNo in retail_sales |
| customer_id | VARCHAR | Customer reference. | 17850 | Matches CustomerID in retail_sales |
| country | VARCHAR | Country of purchase. | United Kingdom | Free text from XML source |
| description | VARCHAR | Product description. | WHITE HANGING HEART T-LIGHT HOLDER | As provided in XML |
| quantity | INT | Units purchased. | 6 | Typed as integer during parsing |
| unit_price | DECIMAL | Price per unit. | 2.55 | Typed as float during parsing |
| total_amount | DECIMAL | Total line value. | 15.30 | Typed as float during parsing |
| invoice_date | VARCHAR | Date of invoice. | 2010-12-01 | Stored as string from XML |

---

## SQL Views

| View Name | Source Tables | Description |
|-----------|--------------|-------------|
| vw_monthly_revenue | retail_sales | Monthly revenue, orders, and units sold grouped by country and month |
| vw_top_products | retail_sales | Top 20 products by total revenue with unit and order counts |
| vw_revenue_by_country | retail_sales | Total revenue, orders, and unique customers per country |
| vw_dim_country | retail_sales | Distinct country list — dimension table for Power BI star schema cross-filtering |
| vw_customer_segments | retail_sales | Customer spend quartiles using NTILE(4) window function — 4 segments |
| vw_cohort_analysis | retail_sales | Customer retention by acquisition cohort month — 3 chained CTEs, DATEDIFF |
| vw_ab_test | retail_sales | A/B test simulation — control/treatment split by CustomerID odd/even |
| vw_ab_test_summary | vw_ab_test | Group-level summary of A/B test — avg revenue, AOV, orders per group |
| vw_country_enriched_sales | retail_sales, country_enriched | Retail sales joined to API country data — includes RevenuePerMillion metric |

---

## Derived Metrics & Calculated Fields

| Metric | Definition | Used In |
|--------|-----------|---------|
| TotalAmount | Quantity × UnitPrice | retail_sales, all views |
| RevenuePerMillion | SUM(TotalAmount) / Population × 1,000,000 | vw_country_enriched_sales |
| CohortMonth | DATEFROMPARTS(YEAR(MIN(InvoiceDate)), MONTH(MIN(InvoiceDate)), 1) — first purchase month rounded to 1st | vw_cohort_analysis |
| MonthNumber | DATEDIFF(MONTH, CohortMonth, ActivityMonth) — months since first purchase | vw_cohort_analysis |
| SpendQuartile | NTILE(4) OVER (ORDER BY TotalSpend DESC) — 1=highest, 4=lowest | vw_customer_segments |
| TestGroup | CASE WHEN CAST(CustomerID AS INT) % 2 = 0 THEN 'Control' ELSE 'Treatment' END | vw_ab_test |

---

## Data Quality Rules Applied During Cleaning

| Rule | Records Removed | Reason |
|------|----------------|--------|
| Missing Description | 1,454 | Cannot identify product — unusable for product analysis |
| Cancelled Transactions | 9,288 | InvoiceNo starts with 'C' — not actual sales |
| Negative Quantity | 474 | Invalid transaction data |
| Zero or Negative UnitPrice | 589 | Invalid pricing data |
| **Total removed** | **11,805** | **From 541,909 to 530,104 clean rows** |

---

## Data Lineage

```
UCI Online Retail (Excel/CSV)
        │
        ▼ Python — clean_data_steps.ipynb
data/online_retail_clean.csv
        │
        ▼ Python — sqlalchemy engine
dbo.retail_sales (SQL Server — RetailDW)
        │
        ├──▶ REST Countries API (JSON) ──▶ dbo.country_enriched
        │
        ├──▶ XML sample data ──▶ dbo.xml_orders
        │
        ▼ SSMS — views.sql
8 SQL Views
        │
        ▼ Power BI — Import mode
retail_dashboard.pbix (3 pages)
```

---

*Data dictionary maintained as part of project documentation standards. All field definitions reflect the state of the RetailDW database as of May 2026.*
