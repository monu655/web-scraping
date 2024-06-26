-- Create the database
CREATE DATABASE EcommerceDB;
USE EcommerceDB;

-- Create Categories table
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

-- Create Products table
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL,
    CategoryID INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create Customers table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE
);

-- Create Orders table
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create OrderDetails table
CREATE TABLE OrderDetails (
    DetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Create Reviews table
CREATE TABLE Reviews (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    CustomerID INT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comment TEXT,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create Shipping table
CREATE TABLE Shipping (
    ShippingID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ShipDate DATETIME,
    DeliveryDate DATETIME,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Create Discounts table
CREATE TABLE Discounts (
    DiscountID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    DiscountAmount DECIMAL(5, 2) NOT NULL,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Add sample data to Categories table
INSERT INTO Categories (CategoryName) VALUES 
('Electronics'),
('Clothing'), 
('Books'),
('Furniture'),
('Toys');

-- Add sample data to Products table
INSERT INTO Products (Name, Price, StockQuantity, CategoryID) 
VALUES 
  ('Laptop', 999.99, 50, 1), 
  ('T-Shirt', 19.99, 200, 2), 
  ('Novel', 9.99, 100, 3),
  ('Desk', 199.99, 25, 4),
  ('Jeans', 29.99, 150, 2);

-- Add sample data to Customers table
INSERT INTO Customers (Name, Email) 
VALUES 
  ('Ravi Kumar', 'ravi@example.com'),
  ('Priya Patel', 'priya@example.com'),
  ('Amit Sharma', 'amit@example.com'),
  ('Neha Gupta', 'neha@example.com'),
  ('Suresh Singh', 'suresh@example.com');

-- Add sample data to Orders table
INSERT INTO Orders (CustomerID, OrderDate) 
VALUES 
  (1, '2023-01-01 10:00:00'),
  (2, '2023-01-02 12:00:00'),
  (3, '2023-01-03 14:00:00'),
  (4, '2023-01-04 16:00:00'),
  (5, '2023-01-05 18:00:00');

-- Add sample data to OrderDetails table
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) 
VALUES 
  (1, 1, 1),
  (1, 3, 2),
  (2, 2, 3),
  (2, 1, 1),
  (3, 3, 2),
  (4, 4, 1),
  (5, 5, 4);

-- Add sample data to Reviews table
INSERT INTO Reviews (ProductID, CustomerID, Rating, Comment) 
VALUES 
  (1, 1, 5, 'Great product!'),
  (2, 2, 4, 'Nice quality.'),
  (3, 3, 3, 'Good value for money.'),
  (1, 4, 5, 'Excellent service!'),
  (2, 5, 4, 'Fast shipping.');

-- Add sample data to Discounts table
INSERT INTO Discounts (ProductID, DiscountAmount) 
VALUES 
  (1, 50.00),
  (2, 5.00),
  (3, 10.00),
  (4, 15.00),
  (5, 20.00);

-- Add sample data to Shipping table
INSERT INTO Shipping (OrderID, ShipDate, DeliveryDate) 
VALUES
    (1, '2023-01-02 08:00:00', '2023-01-05 15:00:00'), 
    (2, '2023-01-03 09:00:00', '2023-01-06 18:00:00'),
    (3, '2023-01-04 10:00:00', '2023-01-07 14:00:00'),
    (4, '2023-01-05 11:00:00', '2023-01-08 12:00:00'),
    (5, '2023-01-06 12:00:00', '2023-01-09 16:00:00');
    
    
    
    
    
    SELECT * FROM ecommercedb.orders;
-- Req 1 Finding Month Which Brought Highest Number Of Sales

SELECT 
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    COUNT(OrderID) AS NumberOfSales
FROM 
    Orders
GROUP BY 
    YEAR(OrderDate), 
    MONTH(OrderDate)
ORDER BY 
    NumberOfSales DESC
LIMIT 1;


-- Req 2 Finding Year wise Sales

SELECT 
    YEAR(O.OrderDate) AS OrderYear,
    SUM(OD.Quantity * P.Price) AS TotalRevenue
FROM 
    Orders O
JOIN 
    OrderDetails OD ON O.OrderID = OD.OrderID
JOIN 
    Products P ON OD.ProductID = P.ProductID
GROUP BY 
    YEAR(O.OrderDate)
ORDER BY 
    OrderYear;
    
    
    -- Req 3 Finding the customers which orders the most
SELECT 
    C.CustomerID,
    C.Name,
    C.Email,
    COUNT(O.OrderID) AS NumberOfOrders
FROM 
    Customers C
JOIN 
    Orders O ON C.CustomerID = O.CustomerID
GROUP BY 
    C.CustomerID, C.Name, C.Email
ORDER BY 
    NumberOfOrders DESC
LIMIT 10;


-- Req 4 Finding produts which were sold the most
SELECT 
    P.ProductID,
    P.Name,
    SUM(OD.Quantity) AS TotalQuantitySold
FROM 
    Products P
JOIN 
    OrderDetails OD ON P.ProductID = OD.ProductID
GROUP BY 
    P.ProductID,
    P.Name
ORDER BY 
    TotalQuantitySold DESC;


-- Req 5 Finding which category brings most customers to the website
-- Select the EcommerceDB database
USE EcommerceDB;

SELECT 
    c.CategoryName,
    COUNT(DISTINCT o.CustomerID) AS NumberOfCustomers
FROM 
    Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY 
    c.CategoryName
ORDER BY 
    NumberOfCustomers DESC
LIMIT 0, 1000;


-- Req 6 Finding which proudct brought the highest sale in a particular month

SELECT 
    p.Name AS ProductName,
    SUM(od.Quantity * p.Price) AS TotalSales
FROM 
    Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
WHERE 
    DATE_FORMAT(o.OrderDate, '%Y-%m') = '2023-01'
GROUP BY 
    p.Name
ORDER BY 
    TotalSales DESC
LIMIT 1;


--  Req 7 Finding which proudct category the highest sale in a particular month

SELECT 
    c.CategoryName,
    SUM(od.Quantity * p.Price) AS TotalSales
FROM 
    Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE 
    DATE_FORMAT(o.OrderDate, '%Y-%m') = '2023-01'
GROUP BY 
    c.CategoryName
ORDER BY 
    TotalSales DESC
LIMIT 1;


-- Req 8 Finding total quantity of each products sold through the website

SELECT 
    p.Name AS ProductName,
    SUM(od.Quantity) AS TotalQuantitySold
FROM 
    OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
GROUP BY 
    p.Name
ORDER BY 
    TotalQuantitySold DESC;
    
    
   -- Req 9 Finding Products whose sales were very low i.e. <120
   
    SELECT 
    p.Name AS ProductName,
    SUM(od.Quantity) AS TotalQuantitySold
FROM 
    OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
GROUP BY 
    p.Name
HAVING 
    SUM(od.Quantity) < 120
ORDER BY 
    TotalQuantitySold;
    
    
   -- 10 Products which are there in inventory
   
SELECT 
    ProductID,
    Name AS ProductName,
    Price,
    StockQuantity
FROM 
    Products
WHERE 
    StockQuantity > 0;
   
   
    -- Req 11 Products which are outofstock  
    
    SELECT 
    ProductID,
    Name AS ProductName,
    Price,
    StockQuantity
FROM 
    Products
WHERE 
    StockQuantity = 0;
    
    
    -- Req 12 Orders which were not delivered yet 
    
SELECT 
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    s.ShippingID,
    s.ShipDate,
    s.DeliveryDate
FROM 
    Orders o
    JOIN Shipping s ON o.OrderID = s.OrderID
WHERE 
    s.DeliveryDate IS NULL OR s.DeliveryDate > NOW();
    
    
       -- Req 13 Orders whose shping has not yet started
       
    SELECT 
    o.OrderID,
    o.CustomerID,
    o.OrderDate
FROM 
    Orders o
    LEFT JOIN Shipping s ON o.OrderID = s.OrderID
WHERE 
    s.ShipDate IS NULL;
    
    
   -- Req 14 Finding average deliver time of each products

    SELECT 
    p.Name AS ProductName,
    AVG(DATEDIFF(s.DeliveryDate, s.ShipDate)) AS AverageDeliveryTime
FROM 
    OrderDetails od
    JOIN Orders o ON od.OrderID = o.OrderID
    JOIN Shipping s ON o.OrderID = s.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
GROUP BY 
    p.Name;

-- Req 15 which product brought the maximum revenue


SELECT 
    p.Name AS ProductName,
    SUM(od.Quantity * p.Price) AS TotalRevenue
FROM 
    OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
GROUP BY 
    p.Name
ORDER BY 
    TotalRevenue DESC
LIMIT 1;


-- Req 16 which category brought the maximum revenue

SELECT 
    c.CategoryName,
    SUM(od.Quantity * p.Price) AS TotalRevenue
FROM 
    OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
    JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY 
    c.CategoryName
ORDER BY 
    TotalRevenue DESC
LIMIT 1;


-- Req 17 finding which product in each category brought the highest revenue

SELECT 
    categories.CategoryID,
    categories.CategoryName, products.productID,
    products.Name,
    SUM(orderdetails.Quantity * products.Price) AS TotalRevenue
FROM categories
JOIN 
    products ON categories.CategoryID = products.CategoryID
JOIN 
    orderdetails ON products.productID = orderdetails.productID
GROUP BY categories.CategoryID,categories.CategoryName, products.productID,products.Name
ORDER BY TotalRevenue DESC
LIMIT 1;


-- Req 18 Findin selling price of each product

SELECT
    ProductID,
    Name AS ProductName,
    Price AS SellingPrice
FROM
    Products;
    
    
-- Req 19 Finding products which gets more reviews
   
   SELECT
    p.ProductID,
    p.Name AS ProductName,
    COUNT(r.ReviewID) AS ReviewCount
FROM
    Products p
    LEFT JOIN Reviews r ON p.ProductID = r.ProductID
GROUP BY
    p.ProductID, p.Name
ORDER BY
    ReviewCount DESC;
    
    
-- R20 Query to fetch those customer whose discount amount is 200.

SELECT
    DISTINCT c.CustomerID,
    c.Name AS CustomerName,
    c.Email
FROM
    Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    JOIN Discounts d ON p.ProductID = d.ProductID
WHERE
    d.DiscountAmount = 200;
    
    
   -- R21 Query to fetch the maximum price of the product.
   
   SELECT
    MAX(Price) AS MaxPrice
FROM
    Products;
    
    
    
-- R22 Query to fetch those products whose review is good

SELECT
    p.ProductID,
    p.Name AS ProductName,
    AVG(r.Rating) AS AverageRating
FROM
    Products p
    JOIN Reviews r ON p.ProductID = r.ProductID
GROUP BY
    p.ProductID, p.Name
HAVING
    AVG(r.Rating) >= 4;
    
    
    -- R23 Query to fetch maximum stock quantity of product.
    
    SELECT
    MAX(StockQuantity) AS MaxStockQuantity
FROM
    Products;


-- R24 Query to fetch order delivered on specified date.

  SELECT
    o.OrderID,
    o.OrderDate,
    s.ShipDate,
    s.DeliveryDate
FROM
    Orders o
    JOIN Shipping s ON o.OrderID = s.OrderID
WHERE
    DATE(s.DeliveryDate) = '2023-01-05';
   

-- R25 Query to list those customers who have placed the most orders

SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    c.Email,
    COUNT(o.OrderID) AS OrderCount
FROM
    Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID, c.Name, c.Email
ORDER BY
    OrderCount DESC
LIMIT 1;
 
 
 -- R26 Query to fetch top selling product.

 
 SELECT
    p.ProductID,
    p.Name AS ProductName,
    SUM(od.Quantity) AS TotalQuantitySold
FROM
    Products p
    JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY
    p.ProductID, p.Name
ORDER BY
    TotalQuantitySold DESC
LIMIT 1;


-- R27 Query to find out those customers who have not placed any order.

SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    c.Email
FROM
    Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE
    o.OrderID IS NULL;


    -- R28 Query to fetch products and their discounts.
    
    SELECT
    p.ProductID,
    p.Name AS ProductName,
    p.Price,
    COALESCE(d.DiscountAmount, 0) AS DiscountAmount
FROM
    Products p
    LEFT JOIN Discounts d ON p.ProductID = d.ProductID;

-- R29 Query to fetch customers discount amount on their product.

SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    p.ProductID,
    p.Name AS ProductName,
    COALESCE(d.DiscountAmount, 0) AS DiscountAmount
FROM
    Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    LEFT JOIN Discounts d ON p.ProductID = d.ProductID
ORDER BY
    c.CustomerID, p.ProductID;

-- R30 Query to fetch product delivered between 25 January to 20 February. 

SELECT
    p.ProductID,
    p.Name AS ProductName,
    o.OrderID,
    s.ShipDate,
    s.DeliveryDate
FROM
    Products p
    JOIN OrderDetails od ON p.ProductID = od.ProductID
    JOIN Orders o ON od.OrderID = o.OrderID
    JOIN Shipping s ON o.OrderID = s.OrderID
WHERE
    s.DeliveryDate BETWEEN '2023-01-25' AND '2023-02-20';
    
    
   -- R31 Query to fetch product details along with their category
   
   SELECT 
    products.productID,
    products.Name AS ProductName,
    products.Price,
    products.StockQuantity,
    categories.CategoryID,
    categories.CategoryName
FROM products
JOIN 
    categories ON products.CategoryID = categories.CategoryID;
    
    
    
    
