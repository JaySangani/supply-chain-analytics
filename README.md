# Supply Chain Operations Analytics Dashboard

A business analysis and reporting project built to demonstrate end-to-end BA practice — from requirements documentation through to stakeholder-facing Power BI dashboards.

---

## Business problem

Operations teams managing multi-product supply chains often lack consolidated visibility into delivery performance, cost efficiency, and stock availability. Without a unified reporting layer, decisions are reactive rather than data-driven.

This project simulates a BA engagement where I was tasked with defining reporting requirements, documenting the current state process, and delivering a dashboard that gives operations stakeholders real-time KPI visibility.

---

## What I delivered

| Artefact | Location | Description |
|---|---|---|
| Business Requirements Document | `/docs/BRD_Supply_Chain.pdf` | Stakeholder objectives, functional requirements, scope |
| AS-IS Process Map | `/docs/AS-IS_Process_Map.png` | Current state reporting workflow with 3 identified gaps |
| Power BI Dashboard | `/dashboard/` | 5-page stakeholder-facing dashboard |
| SQL KPI Queries | `/sql/` | Data extraction and aggregation queries |
| Python Data Cleaning | `/analysis/data_cleaning.ipynb` | Cleaning and preparation of raw dataset |

---

## Dashboard pages

1. **Executive summary** — KPI cards for on-time delivery, cost per shipment, defect rate, stock availability
2. **Delivery performance** — On-time rate by carrier, route, and product line over time
3. **Cost analysis** — Cost per shipment trends and variance by supplier
4. **Supplier breakdown** — Lead time and defect rate by supplier
5. **Stock and availability** — Inventory levels and fill rate by product category

---

## Key findings

- Three bottlenecks identified in the AS-IS fulfilment process contributing to a 12% on-time delivery gap
- Supplier lead time variance accounts for 68% of delivery delays across the top 5 product lines
- Two product categories consistently below 80% stock availability threshold

---

## Dataset

**Source:** [Supply Chain Analysis — Kaggle](https://www.kaggle.com/datasets/harshsingh2209/supply-chain-analysis)
**Size:** ~24,000 records across product lines, suppliers, and shipping routes
**Format:** CSV

---

## Tools used

- **SQL** — Data exploration and KPI extraction (PostgreSQL syntax)
- **Python** — pandas for data cleaning and preparation
- **Power BI** — Dashboard development and publishing
- **draw.io** — AS-IS process mapping

---

## Folder structure

```
supply-chain-analytics/
├── README.md
├── data/
│   ├── raw_supply_chain.csv
│   └── cleaned_supply_chain.csv
├── sql/
│   ├── 01_data_exploration.sql
│   └── 02_kpi_queries.sql
├── docs/
│   ├── BRD_Supply_Chain.pdf
│   └── AS-IS_Process_Map.png
├── analysis/
│   └── data_cleaning.ipynb
└── dashboard/
    ├── supply_chain_dashboard.pbix
    └── dashboard_screenshot.png
```

---

## How to run the analysis

1. Download the dataset from the Kaggle link above and place in `/data/raw_supply_chain.csv`
2. Run `/analysis/data_cleaning.ipynb` to produce the cleaned CSV
3. Run the SQL queries in `/sql/` against the cleaned dataset
4. Open the Power BI file in Power BI Desktop and refresh the data source

---

*Part of my BA portfolio — see also: [customer-segmentation-ba](https://github.com/JaySangani/customer-segmentation-ba)*
