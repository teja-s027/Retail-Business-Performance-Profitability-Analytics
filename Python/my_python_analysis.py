"""
Retail Business Performance & Profitability Analytics — Python (Pandas) EDA
Analyst : Teja S
Tool    : Python, Pandas, Matplotlib (VS Code)
Data    : Synthetic portfolio dataset (seed 42), 2024-2025
Answers : BQ1-BQ8 — same questions as Excel and SQL; results must match both.
"""

# ============================================================
# Load the data
# ============================================================
import pandas as pd
import matplotlib.pyplot as plt
import os

orders    = pd.read_csv("raw_data/orders.csv", parse_dates=["OrderDate", "ShipDate"])
customers = pd.read_csv("raw_data/customers.csv")
products  = pd.read_csv("raw_data/products.csv")
stores    = pd.read_csv("raw_data/stores.csv")
returns   = pd.read_csv("raw_data/returns.csv")

print(orders.shape, customers.shape, products.shape, stores.shape, returns.shape)
print(orders.head())
print(orders.dtypes)

# ============================================================
# Data quality checks
# ============================================================

print("Missing values:", orders.isna().sum().sum())
print("Duplicate OrderLineID:", orders["OrderLineID"].duplicated().sum())
print("Date range:", orders["OrderDate"].min(), "to", orders["OrderDate"].max())

# ============================================================
# Merge: one analysis table (df)
# ============================================================

df = (orders.merge(products, on="ProductID") 
      .merge(stores, on="StoreID") 
      .merge(customers, on="CustomerID", suffixes=("", "_cust")))
print(df.shape)

# ============================================================
# Overall KPIs (BQ1)
# ============================================================ 

sales, profit = df["Sales"].sum(), df["Profit"].sum()
print(f"Sales: {sales:,.2f}  Profit: {profit:,.2f}  Margin: {profit/sales*100:.2f}%")
print("Distinct orders:", df["OrderID"].nunique())
print(f"AOV: {sales/df['OrderID'].nunique():,.2f}")
# FINDING: Sales Rs 11.37 Cr, profit Rs 1.99 Cr, margin 17.52% — same as Excel and SQL

# ============================================================
# Monthly trend (BQ2)
# ============================================================

df["YM"] = df["OrderDate"].dt.to_period("M")
monthly = df.groupby("YM")[["Sales", "Profit"]].sum()
monthly["MarginPct"] = monthly["Profit"] / monthly["Sales"] * 100
print(monthly.sort_values("Sales", ascending=False).head(3))
print(monthly.sort_values("MarginPct").head(3))
# FINDING: Dec-2025 is the biggest sales month, but Nov months have the worst margins — festive selling earns less per rupee.

# ============================================================
# Category profitability (BQ3)
# ============================================================

cat = df.groupby("Category")[["Sales", "Profit"]].sum()
cat["MarginPct"] = cat["Profit"] / cat["Sales"] * 100
print(cat.sort_values("Profit", ascending=False))
# FINDING: Electronics is the profit engine (profit 9,250,274.81); Sports & Fitness has the weakest margin (14.34%).

# ============================================================
# Discount impact (BQ4) - the headline analysis
# ============================================================

df["DiscountBand"] = pd.cut(df["Discount"],
    bins=[-0.001, 0, 0.05, 0.10, 0.20, 0.30, 1],
    labels=["0%", "0-5%", "5-10%", "10-20%", "20-30%", "30%+"])
band = df.groupby("DiscountBand", observed=True)[["Sales", "Profit"]].sum()
band["MarginPct"] = band["Profit"] / band["Sales"] * 100
print(band)
print("Correlation discount vs line margin:",
      round(df["Discount"].corr(df["Profit"] / df["Sales"]), 2))
loss = df[df["Profit"] < 0]
print("Loss-making lines:", len(loss), " Total loss:", round(loss["Profit"].sum(), 2))
# FINDING: Margin falls 27.92% -> -15.97% as discount rises; the 30%+ band loses money overall. Cap routine discounts at 20%.

# ============================================================
# Stores & customer segments (BQ5, BQ6)
# ============================================================

store = df.groupby(["StoreName", "City"])[["Sales", "Profit"]].sum()
store["MarginPct"] = store["Profit"] / store["Sales"] * 100
print(store.sort_values("Sales", ascending=False).head(5))
print(store.sort_values("MarginPct").head(3))
seg = df.groupby("CustomerSegment")[["Sales", "Profit"]].sum()
seg["MarginPct"] = seg["Profit"] / seg["Sales"] * 100
print(seg.sort_values("Sales", ascending=False))
# FINDING: Visakhapatnam West sells the most; Ahmedabad North is 2nd on sales but has the lowest margin (15.49%). Regular customers bring the most sales; VIP has the highest margin (18.81%).

# ============================================================
# Order status & payments (BQ7)
# ============================================================

status = df.groupby("OrderStatus")[["Sales"]].sum()
status["SharePct"] = status["Sales"] / status["Sales"].sum() * 100
print(status.sort_values("Sales", ascending=False))
pay = df.groupby("PaymentMethod")[["Sales"]].sum()
pay["SharePct"] = pay["Sales"] / pay["Sales"].sum() * 100
print(pay.sort_values("Sales", ascending=False))
# FINDING: Cancelled + Returned orders hold 16% of sales value (Rs 1.82 Cr at risk). UPI is the top payment method (35.52% of sales).

# ============================================================
# Returns (BQ8)
# ============================================================

ret = returns.merge(products, on="ProductID")
rate = ret.groupby("Category").size() / df.groupby("Category").size() * 100
print(rate.sort_values(ascending=False))
print(returns["ReturnReason"].value_counts())
# FINDING: Accessories has the highest return rate (7.62%). Damaged Product is the top reason (90) — fix packaging, picking accuracy and duplicate-order checks first (41.5% of returns are preventable).

# ============================================================
# Save the 5 charts
# ============================================================


os.makedirs("outputs/charts", exist_ok=True)

monthly.index = monthly.index.to_timestamp()
plt.figure(figsize=(10, 4)); plt.plot(monthly.index, monthly["Sales"] / 1e6, marker="o")
plt.title("Monthly Sales — festive Oct-Dec peak"); plt.ylabel("Sales (Rs million)")
plt.tight_layout(); plt.savefig("outputs/charts/01_monthly_sales_trend.png", dpi=150); plt.close()

plt.figure(figsize=(9, 4)); band["MarginPct"].plot(kind="bar", color="#c0392b")
plt.title("Profit Margin % by Discount Band — above 20% discount, profit disappears"); plt.ylabel("Margin %")
plt.tight_layout(); plt.savefig("outputs/charts/02_discount_vs_margin.png", dpi=150); plt.close()

c = cat.sort_values("Profit")
plt.figure(figsize=(9, 5)); plt.barh(c.index, c["Profit"] / 1e6, color="#2471a3")
plt.title("Profit by Category (Rs million)"); plt.xlabel("Profit (Rs m)")
plt.tight_layout(); plt.savefig("outputs/charts/03_profit_by_category.png", dpi=150); plt.close()

s = store.sort_values("Sales")
plt.figure(figsize=(9, 6)); plt.barh(s.index.get_level_values(1), s["Sales"] / 1e6, color="#1e8449")
plt.title("Sales by Store City (Rs million)"); plt.xlabel("Sales (Rs m)")
plt.tight_layout(); plt.savefig("outputs/charts/04_sales_by_store.png", dpi=150); plt.close()

plt.figure(figsize=(9, 4)); rate.plot(kind="bar", color="#7d3c98")
plt.title("Return Rate % by Category"); plt.ylabel("Return rate %")
plt.tight_layout(); plt.savefig("outputs/charts/05_return_rate_by_category.png", dpi=150); plt.close()

print("Charts saved: check outputs/charts folder")
