-- Retail Business Performance & Profitability Analytics
-- - MySQL 8.0 Schema
-- Synthetic portfolio dataset. Create database first: CREATE DATABASE retail_analytics;

CREATE DATABASE IF NOT EXISTS retail_analytics;
USE retail_analytics;

CREATE TABLE customers (
  CustomerID VARCHAR(8) PRIMARY KEY,
  CustomerName VARCHAR(100) NOT NULL,
  Gender VARCHAR(10),
  Age INT,
  City VARCHAR(50),
  State VARCHAR(50),
  Country VARCHAR(50),
  SignupDate DATE,
  CustomerSegment VARCHAR(15)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE products (
  ProductID VARCHAR(8) PRIMARY KEY,
  ProductName VARCHAR(150) NOT NULL,
  Category VARCHAR(50),
  SubCategory VARCHAR(50),
  UnitCost DECIMAL(10,2) NOT NULL,
  SellingPrice DECIMAL(10,2) NOT NULL,
  Brand VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE stores (
  StoreID VARCHAR(7) PRIMARY KEY,
  StoreName VARCHAR(100) NOT NULL,
  City VARCHAR(50),
  State VARCHAR(50),
  StoreType VARCHAR(15)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders (
  OrderLineID VARCHAR(10) PRIMARY KEY,
  OrderID VARCHAR(10) NOT NULL,
  OrderDate DATE NOT NULL,
  ShipDate DATE,
  CustomerID VARCHAR(8) NOT NULL,
  StoreID VARCHAR(7) NOT NULL,
  ProductID VARCHAR(8) NOT NULL,
  Quantity INT NOT NULL,
  UnitPrice DECIMAL(10,2) NOT NULL,
  Discount DECIMAL(5,2) NOT NULL DEFAULT 0,
  Sales DECIMAL(12,2) NOT NULL,
  Cost DECIMAL(12,2) NOT NULL,
  Profit DECIMAL(12,2) NOT NULL,
  PaymentMethod VARCHAR(20),
  OrderStatus VARCHAR(15),
  CONSTRAINT fk_orders_customer FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
  CONSTRAINT fk_orders_store FOREIGN KEY (StoreID) REFERENCES stores(StoreID),
  CONSTRAINT fk_orders_product FOREIGN KEY (ProductID) REFERENCES products(ProductID),
  CONSTRAINT chk_discount CHECK (Discount >= 0 AND Discount <= 1),
  CONSTRAINT chk_shipdate CHECK (ShipDate >= OrderDate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE returns (
  ReturnID VARCHAR(8) PRIMARY KEY,
  OrderID VARCHAR(10) NOT NULL,
  ProductID VARCHAR(8) NOT NULL,
  ReturnDate DATE,
  ReturnQuantity INT NOT NULL,
  ReturnReason VARCHAR(50),
  CONSTRAINT fk_returns_product FOREIGN KEY (ProductID) REFERENCES products(ProductID)
  -- Note: OrderID references orders(OrderID) which is not unique per line,
  -- so validate OrderID existence in application / load checks (see validation_report.txt).
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_orders_date ON orders(OrderDate);
CREATE INDEX idx_orders_orderid ON orders(OrderID);
CREATE INDEX idx_returns_orderid ON returns(OrderID);
