CREATE TABLE ba_sales
(
    row_id       INT PRIMARY KEY,
    order_id     VARCHAR(20),
    order_date   DATE,
    ship_date    DATE,
    ship_mode    VARCHAR(20),
    customer_id  VARCHAR(15),
    customer_name VARCHAR(30),
    segment      VARCHAR(15),
    country      VARCHAR(20),
    city         VARCHAR(30),
    state        VARCHAR(30),
    postal_code  INT,
    region       VARCHAR(10),
    product_id   VARCHAR(20),
    category     VARCHAR(20),
    sub_category VARCHAR(20),
    product_name VARCHAR(100),
    sales        FLOAT
);

---Q1. Total Revenue by Category
---Which product category generates the most revenue?

SELECT 
    category,
    COUNT(*) AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue
FROM ba_sales
GROUP BY category
ORDER BY total_revenue DESC;

---Q2. Top 10 Best Selling Products
---What are the top 10 products by total sales?

SELECT 
    product_name,
    category,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    COUNT(*) AS total_orders
FROM ba_sales
GROUP BY 1, 2
ORDER BY total_sales DESC
LIMIT 10;

---Q3. Revenue by Region
---Which region performs the best in terms of sales?

SELECT 
    region,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue
FROM ba_sales
GROUP BY 1
ORDER BY total_revenue DESC;

---Q4. Monthly Sales Trend
---How do sales grow or decline month by month?

SELECT 
    EXTRACT(YEAR FROM TO_DATE(order_date, 'DD-MM-YYYY'))  AS year,
    EXTRACT(MONTH FROM TO_DATE(order_date, 'DD-MM-YYYY')) AS month,
    ROUND(SUM(sales)::NUMERIC, 2) AS monthly_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM ba_sales
GROUP BY 1, 2
ORDER BY 1, 2;

---Q5. Top 5 Customers by Sales
---Who are the highest spending customers?
SELECT 
    customer_id,
    customer_name,
    segment,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_spent
FROM ba_sales
GROUP BY 1, 2, 3
ORDER BY total_spent DESC
LIMIT 5;

---Q6. Sales by Customer Segment
---Which customer segment — Consumer, Corporate, or Home Office — drives the most revenue?

SELECT 
    segment,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(sales)::NUMERIC, 2) AS avg_order_value
FROM ba_sales
GROUP BY 1
ORDER BY total_revenue DESC;

---Q7. Shipping Mode Analysis
---Which shipping mode is most preferred and how does it affect sales volume?

SELECT 
    ship_mode,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(sales)::NUMERIC, 2) AS avg_sale_per_order
FROM ba_sales
GROUP BY 1
ORDER BY total_orders DESC;

---Q8. Top 5 States by Revenue
---Which states generate the most sales?
SELECT 
    state,
    region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue
FROM ba_sales
GROUP BY 1, 2
ORDER BY total_revenue DESC
LIMIT 5;

---Q9. Best Selling Sub-Category per Category
---What is the top performing sub-category within each category?
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

---Q10. Year-over-Year Sales Growth
---How has total revenue grown each year?

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





