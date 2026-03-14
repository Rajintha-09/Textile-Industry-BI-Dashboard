# Textile & Apparel Industry — Business Intelligence Dashboard

A professional 4-page **Power BI Dashboard** built for the Textile & Apparel Industry, integrating **garment factory productivity data** with **global brand sales data**. This project demonstrates end-to-end data engineering and business intelligence skills using **SQL Server** and **Power BI**.

---
## Dashboard Pages

| Page | Title | Description |
|---|---|---|
| 1 | Factory Operations | Team productivity, overtime, idle time analysis |
| 2 | Sales Performance | Revenue, profit, product & retailer analysis |
| 3 | Geographic Analysis | US map, regional & city level sales breakdown |
| 4 | Executive Summary | One-page CEO-level KPI overview |

---

## Datasets Used

### 1. Garment Worker Productivity
- **Source:** Kaggle
- **Rows:** 1,197 | **Columns:** 15
- **Description:** Real garment factory data showing team productivity, overtime, idle time and worker counts
- **File:** `dataset/garments_worker_productivity.csv`
- **Link:** https://www.kaggle.com/datasets/ishadss/productivity-prediction-of-garment-employees

### 2. Adidas US Sales Dataset
- **Source:** Kaggle
- **Rows:** 9,648 | **Columns:** 13
- **Description:** Adidas retail sales data across US regions, retailers and product categories (2020-2021)
- **File:** `dataset/Adidas US Sales Datasets.csv`
- **Link:** https://www.kaggle.com/datasets/heemalichaudhari/adidas-sales-dataset

---

## Tools & Technologies

| Tool | Purpose |
|---|---|
| **SQL Server (SSMS)** | Database management & data storage |
| **SQL** | Data cleaning, transformation & view creation |
| **Power BI Desktop** | Dashboard development & visualization |
| **DAX** | Custom KPI measures & calculations |
| **Power BI Service** | Publishing & sharing dashboard |

---

## Data Cleaning Performed

### Garment Dataset
- Fixed 506 NULL values in `wip` column
- Corrected department typo: `'sweing'` → `'sewing'`
- Removed trailing spaces: `'finishing '` → `'finishing'`
- Fixed invalid quarter: `'Quarter5'` → `'Quarter4'`
- Capped `actual_productivity` values exceeding 1.0

### Adidas Dataset
- Removed `$` signs and `,` from `Price_Per_Unit`, `Total_Sales`, `Operating_Profit`
- Removed `%` sign from `Operating_Margin`
- Removed `,` from `Units_Sold`
- Converted all text-formatted numbers to proper numeric data types

---

## SQL Views Created

| View | Description |
|---|---|
| `vw_team_productivity` | Team-level productivity aggregation |
| `vw_productivity_vs_target` | Actual vs target comparison with status |
| `vw_department_summary` | Sewing vs finishing department KPIs |
| `vw_monthly_sales` | Monthly revenue and profit trends |
| `vw_region_sales` | Revenue by US region, state and city |
| `vw_product_sales` | Revenue by product category and retailer |
| `vw_kpi_summary` | Overall KPI totals for card visuals |
| `vw_retailer_sales` | Performance breakdown by retailer |

---

## DAX Measures

```
Total Revenue = SUM(vw_kpi_summary[total_revenue])
Total Profit = SUM(vw_kpi_summary[total_profit])
Profit Margin % = DIVIDE([Total Profit], [Total Revenue], 0) * 100
Avg Productivity = AVERAGE(vw_department_summary[avg_productivity])
Productivity Gap = AVERAGE(vw_productivity_vs_target[actual_productivity]) - AVERAGE(vw_productivity_vs_target[targeted_productivity])
Total Units Sold = SUM(vw_kpi_summary[total_units_sold])
```

---

## Key Insights

- **Total Revenue:** $899.79M across all regions
- **Total Profit:** $331.50M with 36.84% profit margin
- **Top Region:** West region leads with $270M revenue
- **Top Retailer:** West Gear highest revenue at $242.93M (27%)
- **Factory Performance:** 73.1% of teams met productivity targets
- **Best Sales Method:** In-store leads at 39.64% of total revenue

---

## How to Run This Project

1. Download both datasets from `dataset/` folder
2. Import into SQL Server using SSMS (Import Flat File)
3. Run `sql/SQLQuery1.sql` to clean data and create views
4. Open `powerbi/Textile_Industry_Dashboard.pbix` in Power BI Desktop
5. Update SQL Server connection to your server name
6. Refresh data and explore the dashboard!

---

## Repository Structure

```
Textile-Industry-BI-Dashboard/
├── README.md
├── dataset/
│   ├── garments_worker_productivity.csv
│   └── Adidas US Sales Datasets.csv
├── powerbi/
│   ├── Textile_Industry_Dashboard.pbix
│   ├── Factory Operations.png
│   ├── Sales Performance.png
│   ├── Geographic Analysis.png
│   └── Executive Summary.png
└── sql/
    └── SQLQuery1.sql
```
## Project Outcome

This dashboard was built as a portfolio project to demonstrate
real-world Business Intelligence skills applicable to the
Textile & Apparel Industry. It simulates the kind of data
analytics work done at leading apparel manufacturers like
MAS Holdings, covering both factory floor operations and
global brand sales performance.
