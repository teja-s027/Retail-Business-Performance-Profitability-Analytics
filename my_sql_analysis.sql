--                            ============================================================
--                              Retail Business Performance & Profitability Analytics
--                                    --------------------------------------
-- Analyst  : Teja S
-- Tool     : MySQL 8.0 (Workbench)
-- Database : retail_analytics
-- Data     : Synthetic portfolio dataset (seed 42), 2024-2025

# -- CHECK: Row counts after import
USE retail_analytics;
SELECT (SELECT COUNT(*) FROM orders)    AS orders_rows,
       (SELECT COUNT(*) FROM customers) AS customers_rows,
       (SELECT COUNT(*) FROM products)  AS products_rows,
       (SELECT COUNT(*) FROM stores)    AS stores_rows,
       (SELECT COUNT(*) FROM returns)   AS returns_rows; 


# ----------- Analysis 1 — Overall KPIs + year-wise growth ---------------

-- Q1: What are the overall KPIs?
SELECT
    ROUND(SUM(Sales), 2)  AS TotalSales,
    ROUND(SUM(Profit), 2) AS TotalProfit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS ProfitMarginPct,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    ROUND(SUM(Sales) / COUNT(DISTINCT OrderID), 2) AS AvgOrderValue
FROM orders;

-- Q1b: Is the business growing year by year?
SELECT YEAR(OrderDate) AS Year,
       ROUND(SUM(Sales), 2) AS Sales,
       ROUND(SUM(Profit), 2) AS Profit,
       ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS MarginPct
FROM orders GROUP BY YEAR(OrderDate) ORDER BY Year;

 -- Finding: Sales grew ~2.9% and profit ~3.9% in 2025.

#  -----------------    Analysis 2 — Monthly trend ---------------------

-- Q2: How do sales and profit trend month by month?
SELECT DATE_FORMAT(OrderDate,'%Y-%m') AS YearMonth,
       ROUND(SUM(Sales),2) AS Sales, 
       ROUND(SUM(Profit),2) AS Profit,
       ROUND(SUM(Profit)/SUM(Sales)*100,2) AS MarginPct,
       COUNT(*) AS OrderLines FROM orders GROUP BY YearMonth ORDER BY YearMonth;
   
-- Finding: Festive months (Oct–Nov) sell a lot but earn the least margin.
   
# ---------------   Analysis 3 — Category profitability --------------

-- Q3: Which categories make the money?
SELECT p.Category, ROUND(SUM(o.Sales),2) AS Sales, ROUND(SUM(o.Profit),2) AS Profit,
       ROUND(SUM(o.Profit)/SUM(o.Sales)*100,2) AS MarginPct, SUM(o.Quantity) AS UnitsSold
FROM orders o JOIN products p ON p.ProductID = o.ProductID
GROUP BY p.Category ORDER BY Profit DESC;

-- Q3b: Top 10 products by profit
SELECT p.ProductName, p.Category, ROUND(SUM(o.Sales),2) AS Sales,
       ROUND(SUM(o.Profit),2) AS Profit,
       ROUND(SUM(o.Profit)/SUM(o.Sales)*100,2) AS MarginPct
FROM orders o JOIN products p ON p.ProductID = o.ProductID
GROUP BY p.ProductName, p.Category ORDER BY Profit DESC LIMIT 10;

-- Finding: Electronics is the engine; Sports & Fitness pricing is the weakest.

# ----------        Analysis 4 — Discount bands     -----------

-- Q4: How does discount level affect margin?
SELECT CASE
         WHEN Discount = 0 THEN '0%'
         WHEN Discount <= 0.05 THEN '0-5%'
         WHEN Discount <= 0.10 THEN '5-10%'
         WHEN Discount <= 0.20 THEN '10-20%'
         WHEN Discount <= 0.30 THEN '20-30%'
         ELSE '30%+'
       END AS DiscountBand,
       COUNT(*) AS Line_Count,
       ROUND(SUM(Sales), 2) AS Sales,
       ROUND(SUM(Profit), 2) AS Profit,
       ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS MarginPct
FROM orders GROUP BY DiscountBand ORDER BY MIN(Discount);

-- Finding: Margin falls with every discount band and turns negative at 30%+ (-15.97%, total loss -770503.22). Cap routine discounts at 20%.

# ----------------   Analysis 5 — Store ranking     ---------------------------

-- Q5: Which stores perform best on sales AND margin together?

SELECT s.StoreName, s.City, s.State, ROUND(SUM(o.Sales),2) AS Sales,
       ROUND(SUM(o.Profit),2) AS Profit,
       ROUND(SUM(o.Profit)/SUM(o.Sales)*100,2) AS MarginPct,
       RANK() OVER (ORDER BY SUM(o.Sales) DESC) AS SalesRank
FROM orders o JOIN stores s ON s.StoreID = o.StoreID
GROUP BY s.StoreName, s.City, s.State ORDER BY Sales DESC;

 -- Finding: Judge stores on sales AND margin together — Ahmedabad sells big but keeps little.

# ---------------  Analysis 6 — Customer segments + repeat customers  --------------------

-- Q6: Which customer segment is most valuable?

SELECT c.CustomerSegment, COUNT(DISTINCT o.OrderID) AS Orders,
       ROUND(SUM(o.Sales),2) AS Sales, ROUND(SUM(o.Profit),2) AS Profit,
       ROUND(SUM(o.Profit)/SUM(o.Sales)*100,2) AS MarginPct
FROM orders o JOIN customers c ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerSegment ORDER BY Sales DESC;

-- Q6b: How many customers buy more than once? 
SELECT COUNT(*) AS CustomersWhoOrdered,
       SUM(CASE WHEN OrderCount >= 2 THEN 1 ELSE 0 END) AS RepeatCustomers,
       ROUND(SUM(CASE WHEN OrderCount >= 2 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS RepeatPct
FROM (SELECT CustomerID, COUNT(DISTINCT OrderID) AS OrderCount
      FROM orders GROUP BY CustomerID) t;

-- Finding: Regular customers carry the business; VIPs are few but most profitable per rupee.

# ------------------  Analysis 7 — Order status & payments --------------------

-- Q7a: Where does order value get stuck or lost?
SELECT OrderStatus, COUNT(*) AS Line_Count, ROUND(SUM(Sales),2) AS SalesValue,
       ROUND(SUM(Sales)/(SELECT SUM(Sales) FROM orders)*100,2) AS SharePct
FROM orders GROUP BY OrderStatus ORDER BY SalesValue DESC;

-- Q7b: How do customers pay?
SELECT PaymentMethod, COUNT(*) AS Line_Count, ROUND(SUM(Sales),2) AS Sales,
       ROUND(SUM(Sales)/(SELECT SUM(Sales) FROM orders)*100,2) AS SharePct
FROM orders GROUP BY PaymentMethod ORDER BY Sales DESC;

-- Finding: 16 paise of every sales rupee is stuck in cancelled/returned orders.

#  -------------------   Analysis 8 — Returns   ----------------------------

-- Q8a: Why do customers return products?
SELECT ReturnReason, COUNT(*) AS Returns,
       ROUND(COUNT(*)/(SELECT COUNT(*) FROM returns)*100,2) AS SharePct
FROM returns GROUP BY ReturnReason ORDER BY Returns DESC;

-- Q8b: Which category gets returned most, relative to its order lines?

SELECT p.Category, COUNT(r.ReturnID) AS Returns,
       (SELECT COUNT(*) FROM orders o2 JOIN products p2 ON p2.ProductID = o2.ProductID
        WHERE p2.Category = p.Category) AS OrderLines,
       ROUND(COUNT(r.ReturnID) /
         (SELECT COUNT(*) FROM orders o2 JOIN products p2 ON p2.ProductID = o2.ProductID
          WHERE p2.Category = p.Category) * 100, 2) AS ReturnRatePct
FROM returns r JOIN products p ON p.ProductID = r.ProductID
GROUP BY p.Category ORDER BY ReturnRatePct DESC;

 -- Finding: Fix packaging, picking accuracy and duplicate-order checks first — they cause 2 of every 5 returns.

-- BONUS: loss-making lines

SELECT COUNT(*) AS LossMakingLines,
       ROUND(COUNT(*)/(SELECT COUNT(*) FROM orders)*100,2) AS PctOfLines,
       ROUND(SUM(Profit),2) AS TotalLoss
FROM orders WHERE Profit < 0;

-- Finding: 1483 lines (14.83%) are loss-making, total loss -1319953.17 - deep discounting is the main driver.