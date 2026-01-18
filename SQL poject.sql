CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
SHOW TABLES;
INSERT INTO customers VALUES
(1, 'Amit Sharma', 'Delhi', '2023-01-10'),
(2, 'Neha Verma', 'Mumbai', '2023-02-15'),
(3, 'Rahul Mehta', 'Bangalore', '2023-03-05'),
(4, 'Pooja Singh', 'Pune', '2023-04-20'),
(5, 'Arjun Patel', 'Ahmedabad', '2023-05-12');
INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 55000),
(102, 'Smartphone', 'Electronics', 30000),
(103, 'Headphones', 'Accessories', 2000),
(104, 'Office Chair', 'Furniture', 7000),
(105, 'Notebook', 'Stationery', 200);
INSERT INTO orders VALUES
(1001, 1, '2023-06-01'),
(1002, 2, '2023-06-03'),
(1003, 3, '2023-06-10'),
(1004, 1, '2023-06-15'),
(1005, 4, '2023-06-18');
INSERT INTO order_items VALUES
(1, 1001, 101, 1),
(2, 1001, 103, 2),
(3, 1002, 102, 1),
(4, 1003, 104, 1),
(5, 1003, 105, 5);

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

SELECT COUNT(*) AS total_customers
FROM customers;
SELECT COUNT(*) AS total_orders
FROM orders;
SELECT 
    SUM(oi.quantity * p.price) AS total_revenue
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id;
SELECT 
    AVG(order_total) AS avg_order_value
FROM (
    SELECT 
        o.order_id,
        SUM(oi.quantity * p.price) AS order_total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY o.order_id
) t;
SELECT 
    p.category,
    SUM(oi.quantity * p.price) AS revenue
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
GROUP BY p.category;

SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC
LIMIT 3;

SELECT 
    p.product_name,
    SUM(oi.quantity * p.price) AS revenue
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 1;
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * p.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name;

SELECT *
FROM (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
) t
WHERE total_spent > 30000;

SELECT 
    customer_name,
    total_spent,
    CASE
        WHEN total_spent > 50000 THEN 'Platinum'
        WHEN total_spent BETWEEN 20000 AND 50000 THEN 'Gold'
        ELSE 'Silver'
    END AS customer_segment
FROM (
    SELECT 
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_name
) t;
SELECT 
    customer_name,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM (
    SELECT 
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_name
) t;

SELECT 
    o.order_date,
    SUM(oi.quantity * p.price) AS daily_revenue,
    SUM(SUM(oi.quantity * p.price)) 
        OVER (ORDER BY o.order_date) AS running_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_date
ORDER BY o.order_date;

WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    customer_name,
    total_spent
FROM customer_spending
ORDER BY total_spent DESC;
WITH ranked_customers AS (
    SELECT 
        customer_name,
        SUM(oi.quantity * p.price) AS total_spent,
        NTILE(3) OVER (ORDER BY SUM(oi.quantity * p.price) DESC) AS bucket
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY customer_name
)
SELECT 
    customer_name,
    total_spent
FROM ranked_customers
WHERE bucket = 1;









