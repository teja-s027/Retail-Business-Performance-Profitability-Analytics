Retail Business Performance & Profitability Analytics
 
Complete Project Documentation
 
Analyst: Teja S — Aspiring Data Analyst, Bengaluru Tools: Microsoft Excel · MySQL · Python (Pandas, Matplotlib) · Power BI (DAX) Company scenario: RetailHub — a multi-city Indian retail chain (20 stores + online, 8 product categories) Period analysed: 1 Jan 2024 – 31 Dec 2025
Dataset: Synthetic retail dataset generated in Python (seed = 42) — 10,000 transactions for a retail chain scenario, "RetailHub", covering Jan 2024 – Dec 2025. All figures in this document are calculated from this dataset and were cross-verified in Excel, SQL, Python and Power BI.
Table of Contents
 
1.	Project Overview
2.	Business Problem & Objectives
3.	Business Questions (BQ1–BQ8)
4.	Dataset Description
5.	Project Workflow
6.	Stage 1 — Excel
7.	Stage 2 — SQL (MySQL)
8.	Stage 3 — Python
9.	Stage 4 — Power BI
10.	Key Findings
11.	Recommendations
12.	Dashboard User Guide
13.	Skills Demonstrated
14.	Limitations
15.	Conclusion
 
1.	Project Overview
 
RetailHub's sales are growing slowly, but profitability is not keeping pace. This project analyses
10,000 transactions from 2024–2025 to find where profit is actually made, where it leaks, and which levers — discount, category, store, returns — managers should pull first.
The project was built end-to-end in four tools, following the same business questions in each: Excel → SQL → Python → Power BI, ending in an interactive dashboard and data-driven recommendations.
Headline results:
KPI	Value
Total Sales	₹11,36,69,811.14 (₹11.37 Cr)
Total Profit	₹1,99,20,018.64 (₹1.99 Cr)
Profit Margin %	17.52%
Distinct Orders	5,905
Average Order Value	₹19,249.76
Loss-Making Lines	1,483 (14.83%), total loss −₹13,19,953.17
 
2.	Business Problem & Objectives
 
Problem statement: RetailHub's sales grew only modestly from 2024 to 2025 (₹5.60 Cr → ₹5.77 Cr, +2.9%), while profit is being eroded by deep discounting, uneven category and store performance, and preventable returns. The business does not know where profit is created and where it is lost, so decisions stay guess-based: more discounts to chase sales, equal attention to all stores, and no action on preventable returns.
Objectives:
1.	Find the true drivers of profit and loss (profit/margin by category, product, store, segment, month)
2.	Stop discount-led profit leakage (margin by discount band; a defensible discount ceiling)
3.	Fix festive-season profitability (Oct–Dec sales vs margin)
4.	Improve underperforming stores & categories (rank on sales and margin, not sales alone)
5.	Reduce preventable returns (return rate by category and reason)
6.	Know the best customers (segment sales, margin, repeat behaviour)
7.	Give managers a repeatable view (Excel workbook + Power BI dashboard, refreshable monthly)
 
3.	Business Questions (BQ1–BQ8)
BQ1. What are total Sales, Profit and Profit Margin — overall, by year and by month? BQ2. Which categories and products are most and least profitable? Which products are lossmaking?
 	BQ3. Does a higher discount justify its margin loss? At what discount level does a sale stop being profitable?
BQ4. Where is seasonality strongest, and why is festive-season margin lower?
BQ5. Which stores perform best on Sales and Margin? Which high-sales stores are quietly low-margin?
 	BQ6. How do Regular / Premium / VIP / New customer segments differ in sales and margin? How strong is repeat purchasing?
 	BQ7. What is the split of Order Status and Payment Method, and what sales value is stuck in Cancelled / Returned orders?
 
4.	Dataset Description
 
Synthetic dataset (Python-generated, seed 42), 5 tables:
Table	Rows	Contents
orders	10,000	One row per order line: OrderLineID, OrderID, OrderDate, ShipDate,
CustomerID, StoreID, ProductID, Quantity, UnitPrice, Discount,
Sales, Cost, Profit, PaymentMethod, OrderStatus
customers	1,000	CustomerID, name, CustomerSegment (Regular / Premium / VIP / New), City, State, signup details
products	200	ProductID, ProductName, Category (8), SubCategory, Brand, UnitCost, SellingPrice
stores	20	StoreID, StoreName (e.g. RetailHub Visakhapatnam West), City, State
returns	620	ReturnID, OrderID, ProductID, ReturnDate, ReturnReason, ReturnQuantity
Formulas: Sales = Quantity × UnitPrice × (1 − Discount) · Cost = Quantity × UnitCost ·
Profit = Sales − Cost
Validation (all passed): 0 missing values · 0 duplicate OrderLineIDs · 0 foreign-key errors · formula check Sales = Qty × Price × (1 − Discount) within ₹0.01–0.02 rounding tolerance on all rows · date range 2024-01-01 to 2025-12-31.
KPI definitions: Profit Margin % = Total Profit ÷ Total Sales · AOV = Total Sales ÷ Distinct Orders · Loss-Making Lines % = lines with Profit < 0 ÷ total lines · Return Rate = returns ÷ order lines · Repeat Customer Rate = customers with ≥ 2 distinct orders ÷ customers who ordered.
 
5.	Project Workflow
 
 
Every stage was verified against the same expected answers, so the four tools agree on every figure in this document.
 
6.	Stage 1 — Excel
File: Retail_Analysis.xlsx · Built with Power Query (4 data tables loaded as connections) and an Orders analysis sheet with helper columns (rebuilt Sales check, Is_First_Order flag, loss-making flag — ~100,000 live formulas).
 	KPI_Dashboard sheet: 8 KPIs as live formulas (SUM, COUNTA, COUNTIF, ratios) — Total
Sales ₹11,36,69,811.14, Total Profit ₹1,99,20,018.64, Margin 17.52%, Order Lines 10,000,
Distinct Orders 5,905, AOV ₹19,249.76, Loss-Making Lines 1,483 (14.83%)
 	5 PivotTables built manually: Monthly, Category, Store, Discount Band, Customer Segment
— each with Sales, Profit and a Margin % calculated field; every Grand Total = 17.52% margin  	Conditional formatting: negative profit/margin highlighted light-red (the 30%+ discount band: −₹7,70,503.22, −15.97%); colour scales on Margin % columns
 	Dashboard (Step 8): monthly Line-with-Markers PivotChart, category Clustered Bar
PivotChart (sorted by profit), title "RetailHub — Sales are growing, discounting is eating the profit", and 3 slicers (Category, StoreName, CustomerSegment) connected via Report
Connections to all 5 PivotTables
 	All pivot outputs were cross-checked against the SQL and Python results — every value matches
7.	Stage 2 — SQL (MySQL)
 
Database: retail_analytics (MySQL 8, Workbench) · File: my_sql_analysis.sql
 	Schema with primary/foreign keys, CHECK constraints (Discount 0–1, ShipDate ≥ OrderDate) and indexes; 5 CSVs imported in FK order
 	Verification checks: row counts 10,000 / 1,000 / 200 / 20 / 620; KPI grid 113669811.14 · 19920018.64 · 17.52 · 5905 · 19249.76
 	Analyses (typed queries, one per business question): Q1 overall KPIs + year split (2024 margin 17.45%, 2025 17.60%) · Q2 monthly trend (24 rows) · Q3 categories · Q3b Top-10 products · Q4 discount bands · Q5 all 20 stores with RANK() window function · Q6 segments + repeat customers (938 of 985 = 95.23% placed ≥ 2 orders) · Q7a order status, Q7b payments
· Q8a return reasons, Q8b return rates by category · Bonus: loss-making lines 1,483 / 14.83% / −₹13,19,953.17
 	Every query carries a written # FINDING comment, and the file opens with a header (analyst, tool, database, dataset note)
8.	Stage 3 — Python
File: my_python_analysis.py (Pandas + Matplotlib, run in VS Code) · Organised in 11 headed sections: Load → Quality checks → Merge → BQ1–BQ8 → Charts
 	Load & quality: shapes (10000, 15) / (1000, 9) / (200, 7) / (20, 5) / (620, 6); dates parsed to datetime; Missing values: 0 · Duplicate OrderLineID: 0
Merge: orders + products + stores + customers → one analysis table (10000, 33) Analyses mirror the SQL exactly, plus the one thing pivots can't do: discount vs linemargin correlation = −0.87 (computed with groupby , pd.cut discount bands, .corr() )   5 charts saved to outputs/charts/ : monthly sales trend, discount band margin, category profit, top stores, return rate by category
  The script runs end-to-end without errors and reproduces the same KPI values as Excel and SQL
9.	Stage 4 — Power BI
File: Retail_Profitability_Dashboard.pbix · Dark-themed 3-page dashboard (navy background, panel visuals, cyan/orange accents, data labels on all charts)
Data model (star schema, 4 active relationships): orders → customers (CustomerID) · orders → products (ProductID) · orders → stores (StoreID) · returns → products (ProductID)
12 DAX measures: Total Sales SUM(orders[Sales]) · Total Profit · Total Cost · Profit Margin %
DIVIDE([Total Profit],[Total Sales]) · Total Orders DISTINCTCOUNT(orders[OrderID]) · Total Order Lines · Average Order Value · Loss-Making Lines CALCULATE(COUNTROWS(orders), orders[Profit] < 0) · Loss-Making Lines % · Total Returns · Return Rate % · High-Discount Sales
CALCULATE([Total Sales], orders[Discount] > 0.20)
Calculated columns: Discount Band ( SWITCH(TRUE(), …) ladder: 0% / 0–5% / 5–10% / 10–20% / 20–30% / 30%+) + Discount Band Order for correct sorting.
KPI check (before building visuals): 113.67M · 19.92M · 17.52% · 5905 · 19.25K · 14.83% — Power BI agrees with Excel, SQL and Python.
Pages:
  Page 1 — Executive Overview: 6 KPI cards, Monthly Trend line (Sales + Profit, festive peak Dec-2025), Profit by Category bar, 4 slicers (Year, Category, StoreName, CustomerSegment)
 	Page 2 — Profitability & Discount: discount-band margin column chart (27.92% → −15.97%, 30%+ bar below zero) with finding callout "cap routine discounts at 20%", Top 10 / Bottom 10 product tables (negative values highlighted red via conditional formatting), product scatter
(Average Discount vs Total Profit)
 	Page 3 — Stores, Customers & Returns: Sales by Store bar, segment donut, Return Rate % by Category bar, Sales by Payment Method column chart, Returns by Reason table
 
10.	Key Findings
 
1.	Discounting is the #1 profit leak (BQ3). Margin falls in a straight line as discount rises — correlation −0.87: 0% → 27.92%, 0–5% → 23.75%, 5–10% → 20.15%, 10–20% → 12.21%, 20– 30% → 0.64%, 30%+ → −15.97% (a ₹7.71 lakh loss on that band alone). Lines above 20% discount are 22.4% of all lines and net −₹6.67 lakh combined.
2.	Growth is slow and margin is fragile (BQ1). 2025 sales +2.9%, profit +3.9%; margin 17.45% → 17.60%.
3.	Electronics carries the business (BQ2). ₹5.05 Cr sales (44.5%), ₹92.5 lakh profit, 18.30% margin. Home & Kitchen has the best large-category margin (18.57%). Sports & Fitness is the problem category: ₹1.18 Cr sales, lowest margin 14.34%. Top product: Dell Signature Laptop 22 (₹16.66 lakh profit, 26.31%). Only one product loses money overall: Woodland Lite Sandal 7 (−₹923.72).
4.	Festive paradox (BQ4). Oct–Dec is peak season (Dec 2025 highest month, ₹72.25 lakh sales) but festive margins collapse — Nov 2025 12.78%, Nov 2024 13.03%, Oct 2024 14.45% vs 21.21% in Mar 2025. We sell the most when we earn the least per rupee.
5.	Stores must be judged on margin too (BQ5). Visakhapatnam West #1 on sales (₹70.74 lakh, 17.87%). Ahmedabad North is #2 on sales (₹62.57 lakh) but has the lowest margin of all 20 stores (15.49%) — a sales-only ranking would call it a star. Thiruvananthapuram Central has the lowest sales (₹47.07 lakh) but a healthy 18.11% margin. Indore South is weak on both (15.68%).
6.	Customers (BQ6). Regular = 53.27% of sales (margin 17.21%); VIP is smallest (8.33%) but most profitable (18.81%). Repeat rate is very high: 95.23% of ordering customers placed ≥ 2 orders.
7.	Operations leakage (BQ7). Only 61.23% of sales value is Delivered; Cancelled + Returned = ₹1.82 Cr (16.0%) of sales value that never completes cleanly. UPI is the top payment method (35.52% of sales), then Credit Card (23.59%).
8.	Returns are largely preventable (BQ8). 620 returns. Highest return rate: Accessories
7.62%; lowest: Sports & Fitness 4.92%. Top reasons — Damaged Product (90), Wrong Item Delivered (84), Duplicate Order (83) — are operational and preventable: 41.5% of all returns.
11.	Recommendations (priority order)
 
1.	Cap routine discounts at 20%; manager approval above it. Moving just the 30%+ band to a 20% cap would have avoided most of its ₹7.71 lakh loss.
2.	Change the festive playbook: bundles, gift packs and category offers in Oct–Dec instead of flat deep discounts — festive demand doesn't need the deepest cuts.
3.	Review Sports & Fitness pricing/discounting: +2 margin points there ≈ +₹2.35 lakh profit at the same sales.
4.	Rank stores on Sales and Margin together in the monthly review; coach Ahmedabad North and Indore South on margin.
5.	Fix preventable returns first: packaging/handling (Damaged 90), picking accuracy (Wrong Item 84), order-confirmation checks (Duplicates 83). Halving those three ≈ 128 fewer returns.
6.	Grow VIP & Premium deliberately (highest margins, ~37% of sales combined) with experience/early-access perks — not price cuts.
7.	Track Order Status weekly by store to reduce the ₹1.82 Cr Cancelled + Returned leakage.
12.	Dashboard User Guide
Page 1 — Executive Overview: start here for the headline KPIs. Use the Year, Category, StoreName and CustomerSegment slicers to filter every visual on the page together (e.g. Category = Electronics → cards show ≈50.54M sales / ≈9.25M profit). Click a selected slicer item again to clear it.
 	Page 2 — Profitability & Discount: the discount story. Read the band chart left to right; the callout states the recommendation. Tables rank products by profit; red cells = negative profit/margin.
 	Page 3 — Stores, Customers & Returns: store ranking (read the Ahmedabad note), segment mix, payment mix, return rates and return reasons.
 	Refresh: replace the CSVs in raw_data/ with a new month's files of the same names and press Refresh — model, measures and visuals update automatically.
13.	Skills Demonstrated
Excel: Power Query, PivotTables & calculated fields, live KPI formulas, PivotCharts, slicers with Report Connections, conditional formatting
 	SQL: schema design with FKs & constraints, joins, aggregations, CTE-style structured analysis, window functions ( RANK() ), documented queries with findings
 	Python: Pandas (merge, groupby, pd.cut , correlation), data-quality checks, Matplotlib charting, clean sectioned code
 	Power BI: star-schema modelling, DAX measures & calculated columns, Sort by Column, TopN filters, button/list slicers, conditional formatting, theme design
 	Business analysis: problem framing, KPI definition, insight writing, quantified recommendations
14.	Limitations
The analysis is based on the synthetic dataset described in Section 4.
Profit = Sales − product Cost only; operating expenses such as rent, salaries and delivery costs are not included.
 	Marketing-spend, inventory and staffing data were not part of the dataset, so CAC and stockout analysis are out of scope.
15.	Conclusion
 
Four tools, one dataset, one set of answers — verified identical everywhere. The analysis proves RetailHub's growth problem is not a sales problem but a margin problem driven by discounting: capping routine discounts at 20%, protecting festive margin, fixing two low-margin stores and three preventable return causes would recover lakhs in profit without selling a single extra unit.
 
Project by Teja S · Files: Excel workbook, my_sql_analysis.sql, my_python_analysis.py,
Retail_Profitability_Dashboard.pbix (+ PDF export), raw_data CSVs · Dataset: synthetic (seed 42), 2024– 2025

