# Retail Sales Analysis

**829,262 sales transactions · 50 stores · PostgreSQL/SQL · Power BI/DAX**

Analysis of revenue, profit, margin, product concentration, store-level differences, seasonality, and current inventory for **Maven Toys**, a fictitious toy store chain in Mexico.

**Dataset:** [Maven Analytics – Mexico Toy Sales](https://mavenanalytics.io/data-playground/mexico-toy-sales) · Public Domain

![Sales Performance Dashboard](images/sales_dashboard.png)

## Key Findings

- **Revenue and units grew faster than profit.** From January–September 2022 to the same period in 2023, revenue increased **30.9%**, units sold **40.8%**, and profit **16.0%**. Profit margin decreased from **29.55% to 26.20%** (-3.35 percentage points).
- **The top five products accounted for 46.81% of total revenue**, corresponding to **$6.76M** of **$14.44M**.
- **The highest-revenue product was not the highest-profit product.** **Lego Bricks** generated $2.39M in revenue with a **12.5% margin**; **Colorbuds** generated the highest profit at $834.9K with a **53.4% margin**.
- **Airport stores had the highest average revenue and profit per store.** Their averages were **$429.9K** and **$126.0K**, compared with $283.4K and $77.5K for Downtown stores. The dataset contains 3 Airport stores and 29 Downtown stores.
- **April 30 was a high-revenue date in both years.** April 30, 2023 had the highest daily revenue in the dataset (**$66.8K**); April 30, 2022 generated **$47.5K** and was also among the highest-revenue days.
- **The inventory snapshot contains 29,742 units and 77 explicit zero-stock store-product records.** The stock has an estimated cost value of **$300.2K** and a retail value of **$410.2K**.

## Summary Metrics

| Metric | Value |
|---|---:|
| Sales transactions | 829,262 |
| Units sold | 1,090,565 |
| Revenue | $14.44M |
| Cost | $10.43M |
| Profit | $4.01M |
| Profit margin | 27.79% |
| Stores | 50 |
| Cities | 29 |
| Products | 35 |
| Product categories | 5 |

## Analysis Questions

The analysis addresses five questions:

1. How do revenue, profit, units sold, and profit margin change over time?
2. Which products and categories account for the largest shares of revenue and profit?
3. How do revenue and profit differ across stores and location types, including per-store averages?
4. Are there notable calendar-related sales peaks?
5. Which observed store-product records have zero stock or low estimated days of cover?

## Dataset

The **Mexico Toy Sales** dataset from Maven Analytics contains sales and current inventory data for a fictitious toy store chain in Mexico.

The sales data covers **January 2022 through September 2023**.

| Table | Role | Rows |
|---|---|---:|
| `sales.csv` | Daily sales transactions | 829,262 |
| `calendar.csv` | Calendar dates | 638 |
| `stores.csv` | Store master data | 50 |
| `products.csv` | Product, category, cost, and price data | 35 |
| `inventory.csv` | Current stock by store and product | 1,593 |

## Workflow

```text
Raw CSV files
    ↓
PostgreSQL
    ↓
Sales + Products + Stores
    ↓
Transaction-level analytical view
    ↓
Summary metrics / time / product / store analysis
    ↓
Power BI + DAX
    ↓
Sales dashboard

Inventory + final 30 days of sales
    ↓
Inventory value / zero-stock / days-of-cover calculations
```

The transaction-level sales view calculates **revenue, cost, and profit for each sales record**. The same definitions are used for SQL validation and Power BI reporting.

## SQL Analysis

The repository contains separate SQL files for the main calculations:

- [`create_sales_analysis_view.sql`](sql/create_sales_analysis_view.sql) – joins sales, store, and product tables and calculates revenue, cost, and profit at transaction level.
- [`kpi_queries.sql`](sql/kpi_queries.sql) – recalculates the summary metrics reported in the README.
- [`analysis_queries.sql`](sql/analysis_queries.sql) – contains queries for monthly trends, matched-period growth, product concentration, product and category profitability, store and location comparisons, and peak sales days.
- [`inventory_queries.sql`](sql/inventory_queries.sql) – calculates inventory value, explicit zero-stock records, inventory-table completeness, and 30-day days of cover.

## Dashboard

The Power BI dashboard shows:

- revenue, profit, and profit margin
- monthly revenue and margin
- top products by revenue
- top stores by revenue
- profit by product category

## Inventory Analysis

The inventory data is a **point-in-time snapshot**, not a historical stock series. The inventory queries calculate:

- stock on hand
- inventory value at cost and retail price
- explicit zero-stock records
- units sold over the final 30 days of the sales data
- estimated days of cover based on that 30-day sales rate

## Methodological Notes

- The dataset ends on **September 30, 2023**. Year-over-year comparisons therefore use **January–September 2022 and January–September 2023**, rather than comparing a full year with a partial year.
- Store-location comparisons include **average revenue and profit per store** because the number of stores differs substantially between location types. The dataset contains 3 Airport stores and 29 Downtown stores.
- The inventory table contains **1,593 observed store-product records** versus 1,750 theoretically possible combinations (50 × 35). The **157 absent combinations are treated as missing records, not as zero stock**.
- Inventory values are calculated from the point-in-time stock quantities and product cost and retail-price fields. They are not historical inventory valuations.
- The April 30 pattern is an observed association. External context identifies April 30 as Mexico's annual children's day, but the sales data alone cannot establish causality.

## Repository Structure

```text
sales-performance-analysis/
├── README.md
├── data/
│   └── raw/
│       ├── calendar.csv
│       ├── data_dictionary.csv
│       ├── inventory.csv
│       ├── products.csv
│       ├── sales.csv
│       └── stores.csv
├── images/
│   └── sales_dashboard.png
└── sql/
    ├── analysis_queries.sql
    ├── create_sales_analysis_view.sql
    ├── inventory_queries.sql
    └── kpi_queries.sql
```

## Sources

- [Maven Analytics – Mexico Toy Sales](https://mavenanalytics.io/data-playground/mexico-toy-sales)
- [Gobierno de México – Día de la Niña y el Niño](https://www.gob.mx/conapo/articulos/dia-de-la-nina-y-el-nino-363531?idiom=es)
