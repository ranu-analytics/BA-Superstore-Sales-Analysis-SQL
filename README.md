#  BA Sales Analysis — SQL Project

![SQL](https://img.shields.io/badge/Tool-SQL-blue) ![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-336791) ![Status](https://img.shields.io/badge/Status-Completed-brightgreen) ![Records](https://img.shields.io/badge/Records-9800-orange) ![Years](https://img.shields.io/badge/Years-2015--2018-yellow)

##  Project Overview

This project performs an end-to-end sales analysis on a **US-based retail superstore dataset** using **SQL (PostgreSQL)**. The dataset contains **9,800 transactions** across **4 years (2015–2018)** covering product categories, customer segments, shipping modes, and regional performance across **49 US states**.

---

##  Objective

To analyze business sales data and extract meaningful insights such as:
- Which product categories and sub-categories drive the most revenue?
- Which regions and states perform best?
- How has revenue grown year-over-year?
- Which customer segments and shipping modes are most valuable?
- Who are the top spending customers?

---

##  Dataset Details

| Property | Value |
|---|---|
| Total Records | 9,800 transactions |
| Time Period | 2015 – 2018 |
| Country | United States |
| States Covered | 49 |
| Regions | South, West, Central, East |
| Categories | Furniture, Office Supplies, Technology |
| Sub-Categories | 17 |
| Customer Segments | Consumer, Corporate, Home Office |
| Ship Modes | Standard Class, Second Class, First Class, Same Day |

---

##  Database Schema

### Table: `ba_sales`

| Column | Data Type | Description |
|---|---|---|
| `row_id` | INT (PK) | Unique row identifier |
| `order_id` | VARCHAR(20) | Unique order identifier |
| `order_date` | DATE | Date the order was placed |
| `ship_date` | DATE | Date the order was shipped |
| `ship_mode` | VARCHAR(20) | Shipping mode used |
| `customer_id` | VARCHAR(15) | Unique customer identifier |
| `customer_name` | VARCHAR(30) | Customer full name |
| `segment` | VARCHAR(15) | Customer segment |
| `country` | VARCHAR(20) | Country of sale |
| `city` | VARCHAR(30) | City of sale |
| `state` | VARCHAR(30) | State of sale |
| `postal_code` | INT | Postal code |
| `region` | VARCHAR(10) | Region (South/West/Central/East) |
| `product_id` | VARCHAR(20) | Unique product identifier |
| `category` | VARCHAR(20) | Product category |
| `sub_category` | VARCHAR(20) | Product sub-category |
| `product_name` | VARCHAR(100) | Full product name |
| `sales` | FLOAT | Total sale amount |

### Schema Setup

```sql
CREATE TABLE ba_sales
(
    row_id        INT PRIMARY KEY,
    order_id      VARCHAR(20),
    order_date    DATE,
    ship_date     DATE,
    ship_mode     VARCHAR(20),
    customer_id   VARCHAR(15),
    customer_name VARCHAR(30),
    segment       VARCHAR(15),
    country       VARCHAR(20),
    city          VARCHAR(30),
    state         VARCHAR(30),
    postal_code   INT,
    region        VARCHAR(10),
    product_id    VARCHAR(20),
    category      VARCHAR(20),
    sub_category  VARCHAR(20),
    product_name  VARCHAR(100),
    sales         FLOAT
);
```

---

##  Business Questions & SQL Queries

---

### Q1. Total Revenue by Category
**Which product category generates the most revenue?**

```sql
SELECT 
    category,
    COUNT(*) AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue
FROM ba_sales
GROUP BY category
ORDER BY total_revenue DESC;
```

---

### Q2. Top 10 Best Selling Products
**What are the top 10 products by total sales?**

```sql
SELECT 
    product_name,
    category,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    COUNT(*) AS total_orders
FROM ba_sales
GROUP BY 1, 2
ORDER BY total_sales DESC
LIMIT 10;
```

---

### Q3. Revenue by Region
**Which region performs the best in terms of sales?**

```sql
SELECT 
    region,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT order_id)    AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue
FROM ba_sales
GROUP BY 1
ORDER BY total_revenue DESC;
```

---

### Q4. Monthly Sales Trend
**How do sales grow or decline month by month?**

```sql
SELECT 
    EXTRACT(YEAR FROM TO_DATE(order_date, 'DD-MM-YYYY'))  AS year,
    EXTRACT(MONTH FROM TO_DATE(order_date, 'DD-MM-YYYY')) AS month,
    ROUND(SUM(sales)::NUMERIC, 2) AS monthly_revenue,
    COUNT(DISTINCT order_id)      AS total_orders
FROM ba_sales
GROUP BY 1, 2
ORDER BY 1, 2;
```

---

### Q5. Top 5 Customers by Sales
**Who are the highest spending customers?**

```sql
SELECT 
    customer_id,
    customer_name,
    segment,
    COUNT(DISTINCT order_id)      AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_spent
FROM ba_sales
GROUP BY 1, 2, 3
ORDER BY total_spent DESC
LIMIT 5;
```

---

### Q6. Sales by Customer Segment
**Which customer segment — Consumer, Corporate, or Home Office — drives the most revenue?**

```sql
SELECT 
    segment,
    COUNT(DISTINCT customer_id)   AS unique_customers,
    COUNT(DISTINCT order_id)      AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(sales)::NUMERIC, 2) AS avg_order_value
FROM ba_sales
GROUP BY 1
ORDER BY total_revenue DESC;
```

---

### Q7. Shipping Mode Analysis
**Which shipping mode is most preferred and how does it affect sales volume?**

```sql
SELECT 
    ship_mode,
    COUNT(DISTINCT order_id)      AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(sales)::NUMERIC, 2) AS avg_sale_per_order
FROM ba_sales
GROUP BY 1
ORDER BY total_orders DESC;
```

---

### Q8. Top 5 States by Revenue
**Which states generate the most sales?**

```sql
SELECT 
    state,
    region,
    COUNT(DISTINCT order_id)      AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue
FROM ba_sales
GROUP BY 1, 2
ORDER BY total_revenue DESC
LIMIT 5;
```

---

### Q9. Best Selling Sub-Category per Category
**What is the top performing sub-category within each category?**

```sql
SELECT * FROM (
    SELECT 
        category,
        sub_category,
        ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue,
        DENSE_RANK() OVER(
            PARTITION BY category 
            ORDER BY SUM(sales) DESC
        ) AS rank
    FROM ba_sales
    GROUP BY 1, 2
) AS t1
WHERE rank = 1;
```

---

### Q10. Year-over-Year Sales Growth
**How has total revenue grown each year?**

```sql
WITH yearly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM TO_DATE(order_date, 'DD-MM-YYYY')) AS year,
        ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue
    FROM ba_sales
    GROUP BY 1
)
SELECT 
    year,
    total_revenue,
    LAG(total_revenue) OVER(ORDER BY year) AS prev_year_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER(ORDER BY year)) /
        LAG(total_revenue) OVER(ORDER BY year) * 100
    , 2) AS yoy_growth_pct
FROM yearly_sales
ORDER BY year;
```

---

## 🔍 Key SQL Concepts Used

- Aggregate functions: `SUM()`, `COUNT()`, `AVG()`, `ROUND()`
- `GROUP BY` for category, segment, region, and state-level analysis
- `COUNT(DISTINCT ...)` for unique customers and orders
- `EXTRACT()` and `TO_DATE()` for year and month extraction
- Window functions: `DENSE_RANK()`, `LAG()` with `PARTITION BY`
- Common Table Expressions (CTEs) — `WITH` clause
- `LIMIT` for top-N queries
- PostgreSQL type casting with `::NUMERIC`
- Subqueries and derived tables

---

## 💡 Key Findings

- Dataset contains **9,800 transactions** across **3 categories** and **49 US states**
- Sales data spans **4 years**: 2015 to 2018
- **3 customer segments**: Consumer, Corporate, and Home Office
- **17 sub-categories** analysed for best performers within each category
- **Year-over-Year growth** tracked using `LAG()` window function
- **4 shipping modes** compared by order volume and revenue
- **Top 5 states and customers** identified for business targeting

---

## 📁 Project Structure

```
ba-sales-analysis-sql/
│
├── ba_sales.sql              # All SQL queries
├── BA_Sales_Dataset.csv      # Raw sales dataset
└── README.md                 # Project documentation
```

---

## Tools Used

- **PostgreSQL** — Database & query execution
- **SQL** — Data analysis and reporting

---

## How to Run

1. Set up a PostgreSQL database
2. Run the `CREATE TABLE` statement from `ba_sales.sql`
3. Import `BA_Sales_Dataset.csv` into the `ba_sales` table
4. Note: Date format in CSV is `DD-MM-YYYY` — use `TO_DATE(order_date, 'DD-MM-YYYY')` when needed
5. Execute the analysis queries one by one

---

##  Author

**Ranu  Choudhary**  
Data Analyst Trainee  
📧 choudharyranu54@gmail.com  | 🔗 [[LinkedIn](https://www.linkedin.com/in/ranu-choudhary-36aa6a325?utm_source=share_via&utm_content=profile&utm_medium=member_android)] | 💻 [https://github.com/ranu-analytics/Data-Analyst-Portfolio]

---

> *This project was built to strengthen SQL skills through real-world US retail business sales data analysis.*
