# Retail BI Dashboard

An end-to-end Business Intelligence project built to demonstrate data analyst 
skills using the Microsoft BI stack.

## Overview
Analysis of 530,000+ UK retail transactions (2010–2011) covering £10.6M in revenue 
across 38 countries. Built a multi-page Power BI dashboard surfacing key business 
metrics including revenue trends, top products, and geographic performance.

## Tech Stack
- **Python** — data cleaning and loading (pandas, sqlalchemy)
- **SQL Server 2025** — data storage and transformation
- **Power BI Desktop** — dashboard and visualisation
- **Git/GitHub** — version control

## Project Structure

```
retail-bi-dashboard/
├── data/               # Raw and clean data (excluded from Git)
├── scripts/            # Python cleaning and loading scripts
├── docs/               # Dashboard screenshots
├── PROGRESS.md         # Step by step build log
└── README.md
```

## Dashboard Pages

![Dashboard Screenshot](docs/dashboard_screenshot.png)

### Executive Overview
Single-page dashboard featuring:
- KPI cards — Total Revenue (£10.67M), Total Orders (20K), Total Units Sold (6M), Average Order Value (£534)
- Monthly Revenue Trend line chart — clear Q4 seasonality visible
- Revenue by Country bar chart — UK dominates, Netherlands and EIRE are top international markets
- Top 20 Products by Revenue bar chart
- Country slicer — filters all visuals simultaneously

## Key Findings
- Total revenue of £10.67M across 530,000+ transactions (Dec 2010 – Dec 2011)
- Strong Q4 seasonality — November 2011 was peak month at £1.5M
- United Kingdom accounts for the vast majority of revenue
- Top product: Regency Cakestand 3 Tier at £150K+ revenue
- 38 countries represented, with Netherlands and EIRE as strongest international markets