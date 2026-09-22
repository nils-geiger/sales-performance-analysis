# Sales Performance Analysis

Retail sales analysis with an inventory extension for **Maven Toys**, a fictitious toy store chain in Mexico.

The project evaluates growth, profitability, product concentration, store performance, seasonality, and inventory risk using **PostgreSQL, SQL, Power BI, and DAX**.

**Dataset:** [Maven Analytics – Mexico Toy Sales](https://mavenanalytics.io/data-playground/mexico-toy-sales) · Public Domain

**Period:** January 2022 – September 2023

![Sales Performance Dashboard](images/sales_dashboard.png)

## Project Snapshot

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

## Key Business Insights

- **Growth came with margin pressure.** Comparing January–September on a like-for-like basis, 2023 revenue increased **30.9%** and units sold **40.8%** versus 2022, while profit increased only **16.0%**. Profit margin declined from **29.55% to 26.20%** (-3.35 percentage points).
- **Revenue is concentrated in a small group of products.** The top five products generated **46.81% of total revenue** ($6.76M of $14.44M).
- **Revenue leadership and profit leadership are not the same.** **Lego Bricks** generated the most revenue ($2.39M) but operated at a **12.5% margin**. **Colorbuds** generated the highest product profit ($834.9K) with a **53.4% margin**.
- **Airport stores had the highest average revenue and profit per store.** Their averages were **$429.9K** and **$126.0K**, compared with $283.4K and $77.5K for Downtown stores. The network contains only 3 Airport stores versus 29 Downtown stores.
- **Sales show a pronounced April 30 peak.** April 30, 2023 was the highest-revenue day in the dataset (**$66.8K**); April 30, 2022 was also among the strongest days (**$47.5K**). This coincides with Mexico's annual *Día de la Niña y el Niño* on April 30 and is treated as seasonal context rather than proof of causation.
- **The inventory snapshot contains 29,742 units and 77 explicit zero-stock store-product records.** The stock has an estimated cost value of **$300.2K** and a retail value of **$410.2K**.

## Business Questions

The analysis focuses on five questions:

1. How are revenue, profit, units, and margin developing over time?
2. Which products and categories drive revenue and profit?
3. Which stores and location types perform best, including on a per-store basis?
4. Are there recurring seasonal demand patterns?
5. Where does the inventory snapshot indicate zero-stock or low-cover risk?

## Dataset

The project uses the **Mexico Toy Sales** dataset from Maven Analytics: sales and inventory data for a fictitious toy store chain in Mexico, including product, store, daily transaction, and current inventory information.

| Table | Role | Rows |
|---|---|---:|
| `sales.csv` | Daily sales transactions | 829,262 |
| `calendar.csv` | Calendar dates | 638 |
| `stores.csv` | Store master data | 50 |
| `products.csv` | Product, category, cost, and price data | 35 |
| `inventory.csv` | Current stock by store and product | 1,593 |

The source data covers **50 stores across 29 cities**, 35 products, and 5 product categories.

## Analytical Workflow

```text
Raw CSV files
    ↓
PostgreSQL
    ↓
Sales + Products + Stores
    ↓
Transaction-level analytical view
    ↓
KPI / trend / product / store analysis
    ↓
Power BI + DAX
    ↓
Sales performance dashboard

Inventory + recent sales velocity
    ↓
Inventory value / zero-stock / days-of-cover analysis
```

The analytical sales view derives **revenue, cost, and profit at transaction level**, creating a reusable base for both SQL validation and Power BI reporting.

## SQL Analysis

The repository contains separate SQL files for the main analytical steps:

- [`create_sales_analysis_view.sql`](sql/create_sales_analysis_view.sql) – joins sales, store, and product data and derives revenue, cost, and profit.
- [`kpi_queries.sql`](sql/kpi_queries.sql) – validates the headline KPIs used in the project.
- [`analysis_queries.sql`](sql/analysis_queries.sql) – covers monthly trends, comparable-period growth, product concentration, profitability, store performance, location performance, categories, and peak sales days.
- [`inventory_queries.sql`](sql/inventory_queries.sql) – extends the project with inventory value, explicit zero-stock checks, completeness checks, and 30-day days-of-cover logic.

## Dashboard

The Power BI dashboard summarizes the core sales view through:

- revenue, profit, and profit margin KPIs
- monthly revenue and margin development
- top products by revenue
- top stores by revenue
- profit by product category

The dashboard is intentionally compact and optimized for fast scanning; the README provides the detailed analytical interpretation.

## Inventory Extension

The inventory table is a **point-in-time snapshot**, so it should not be interpreted as a historical stock series. The SQL extension therefore focuses on:

- stock on hand
- inventory value at cost and retail price
- explicit zero-stock records
- recent sales velocity
- estimated days of cover

A data-quality caveat is important: the inventory table contains **1,593 rows** versus 1,750 theoretically possible store-product combinations (50 × 35). The **157 absent combinations are not automatically classified as zero stock**.

## Analytical Notes

- The dataset ends on **September 30, 2023**. Year-over-year comparisons therefore use **January–September 2022 vs. January–September 2023**, rather than comparing a full 2022 with a partial 2023.
- The April 30 pattern is an observed association. External context supports April 30 as Mexico's annual children's day, but the dataset alone cannot establish causality.
- Inventory values are calculated from the current stock snapshot and product cost/retail price; they are not historical inventory valuations.

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

## Tools

**PostgreSQL · SQL · Power BI · DAX**

## Sources

- [Maven Analytics – Mexico Toy Sales](https://mavenanalytics.io/data-playground/mexico-toy-sales)
- [Gobierno de México – Día de la Niña y el Niño](https://www.gob.mx/conapo/articulos/dia-de-la-nina-y-el-nino-363531?idiom=es)
