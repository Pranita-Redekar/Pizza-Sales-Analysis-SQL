DROP TABLE IF EXISTS Pizza_types;

CREATE TABLE IF NOT EXISTS Pizza_types(
	pizza_type_id VARCHAR(50) PRIMARY KEY ,
	name VARCHAR(50) ,
	category VARCHAR(50) ,
	ingredients TEXT
);

DROP TABLE IF EXISTS Pizzas;

CREATE TABLE IF NOT EXISTS Pizzas(
	pizza_id VARCHAR(50) PRIMARY KEY,
	pizza_type_id VARCHAR(50) REFERENCES Pizza_types(pizza_type_id),
	size VARCHAR(10) ,
	price DECIMAL(10,2) 
);

DROP TABLE IF EXISTS Orders;

CREATE TABLE IF NOT EXISTS Orders(
	Order_id INT PRIMARY KEY,
	date DATE,
	time TIME
);


DROP TABLE IF EXISTS Order_Details;

CREATE TABLE IF NOT EXISTS Order_Details(
	Order_details_id INT PRIMARY KEY,
	Order_id INT REFERENCES Orders(Order_id) ,
	Pizza_id VARCHAR(50) REFERENCES Pizzas(Pizza_id),
	Quantity INT
);

SELECT * FROM Pizza_types;
SELECT * FROM Pizzas;
SELECT * FROM Orders;
SELECT * FROM Order_Details;


-- Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS Total_Orders 
FROM Orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
ROUND(SUM(od.quantity * p.price),2) AS total_sales
FROM order_details od
JOIN pizzas p ON p.pizza_id=od.pizza_id

-- Identify the highest-priced pizza.
SELECT pt.name,p.price 
FROM Pizza_types pt
JOIN pizzas p ON pt.pizza_type_id=p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT p.size ,SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON p.pizza_id=od.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name,SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN Pizzas p ON pt.pizza_type_id=p.pizza_type_id
JOIN Order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category,SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN Pizzas p ON pt.pizza_type_id=p.pizza_type_id
JOIN Order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY total_quantity DESC

-- Determine the distribution of orders by hour of the day.
SELECT EXTRACT(HOUR FROM time) AS hours , COUNT(order_id) AS Order_Count
FROM orders
GROUP BY hours;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category ,COUNT(name)
FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(total_quantity) ,0) AS avg_pizza_ordered_per_day
FROM (SELECT o.date , SUM(od.quantity) AS total_quantity
FROM orders o
JOIN order_details od ON o.order_id=od.order_id
GROUP BY o.date);

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name, 
	SUM(od.quantity * p.price) AS revenue
FROM pizza_types pt
JOIN pizzas p ON p.pizza_type_id=pt.pizza_type_id
JOIN order_details od ON od.pizza_id=p.pizza_id
GROUP BY pt.name 
ORDER BY revenue DESC 
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.category,
	ROUND((SUM(od.quantity * p.price))/(SELECT 
ROUND(SUM(od.quantity * p.price),2) AS total_sales
FROM order_details od
JOIN pizzas p ON p.pizza_id=od.pizza_id)*100,2) AS revenue
	
FROM pizza_types pt
JOIN pizzas p ON p.pizza_type_id=pt.pizza_type_id 
JOIN order_details od ON od.pizza_id=p.pizza_id
GROUP BY pt.category 
ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time.
SELECT date,
SUM(revenue) OVER (ORDER BY date) AS cum_revenue
FROM (SELECT o.date,
		SUM(od.quantity * p.price) AS revenue
	FROM order_details od 
	JOIN pizzas p ON od.pizza_id=p.pizza_id
	JOIN orders o ON od.order_id=o.order_id
	GROUP BY o.date ) AS Sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name,revenue
FROM 
(SELECT category , name,revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) as rn
FROM
	(SELECT pt.category,pt.name,
		SUM((od.quantity)* p.price )AS revenue
	FROM pizza_types pt
	JOIN pizzas p ON pt.pizza_type_id=p.pizza_type_id
	JOIN order_details od ON od.pizza_id=p.pizza_id
	GROUP BY pt.category,pt.name) AS a) AS b
WHERE rn<=3;


