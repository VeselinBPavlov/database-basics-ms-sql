-- Section 1. DDL (30 pts)
USE [master]
GO

CREATE DATABASE Supermarket ON PRIMARY
   ( NAME = N'Supermarket_Data', FILENAME = N'D:\Courses\Data\Supermarket_Data.mdf' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
LOG ON
   ( NAME = N'Supermarket_Log', FILENAME = N'D:\Courses\Data\Supermarket_Log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE Supermarket
GO

-- 01. Database Design
CREATE TABLE Employees (
    Id INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Phone CHAR(12) NOT NULL,
    Salary DECIMAL(15, 2) NOT NULL
)

CREATE TABLE Shifts (
    Id INT IDENTITY NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
	CheckIn DATETIME NOT NULL,
	CheckOut DATETIME NOT NULL,
	
	CONSTRAINT PK_Shifts 
    PRIMARY KEY (Id, EmployeeId),

    CONSTRAINT CHK_CheckOut 
    CHECK (CheckOut > CheckIn)
)

CREATE TABLE Orders (
    Id INT PRIMARY KEY IDENTITY,
    [DateTime] DATETIME2 NOT NULL,
    EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL
)

CREATE TABLE Categories (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE Items (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(30) NOT NULL,
    Price DECIMAL(15, 2) NOT NULL,
    CategoryId INT FOREIGN KEY REFERENCES Categories(Id)  NOT NULL
)

CREATE TABLE OrderItems (
    OrderId INT FOREIGN KEY REFERENCES Orders(Id) NOT NULL,
    ItemId INT FOREIGN KEY REFERENCES Items(Id) NOT NULL,
    Quantity INT NOT NULL,

    CONSTRAINT PK_OrderItems
    PRIMARY KEY (OrderId, ItemId),

    CONSTRAINT CHK_Quantity
    CHECK (Quantity > 0)
)
GO

-- Section 2. DML (10 pts)
-- 02. Insert
INSERT INTO Employees
    ([FirstName], [LastName], [Phone], [Salary])
VALUES
    ('Stoyan', 'Petrov', '888-785-8573', 500.25),
    ('Stamat', 'Nikolov', '789-613-1122', 999995.25),
    ('Evgeni', 'Petkov', '645-369-9517', 1234.51),
    ('Krasimir', 'Vidolov', '321-471-9982', 50.25)

INSERT INTO Items 
    ([Name], [Price], [CategoryId])
VALUES
    ('Tesla battery', 154.25, 8),
    ('Chess', 30.25, 8),
    ('Juice', 5.32, 1),
    ('Glasses', 10, 8),
    ('Bottle of water', 1, 1)
GO

-- 03. Update
UPDATE Items
SET Price *= 1.27
WHERE CategoryId IN (1, 2, 3)
GO

-- 04. Delete
DELETE 
FROM OrderItems
WHERE OrderId = 48 
GO

-- Section 3. Querying (40 pts)
-- 05. Richest People
SELECT Id, FirstName
FROM Employees
WHERE Salary > 6500
ORDER BY FirstName ASC, Id ASC 
GO

-- 06. Cool Phone Numbers 
SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name], Phone
FROM Employees
WHERE Phone LIKE '3%'
ORDER BY FirstName ASC, Phone ASC
GO

-- 07. Employee Statistics
SELECT e.FirstName, e.LastName, COUNT(o.EmployeeId) AS [Count]
FROM Employees AS e
INNER JOIN Orders AS o
ON o.EmployeeId = e.Id
GROUP BY e.FirstName, e.LastName
ORDER BY [Count] DESC, e.FirstName ASC
GO

-- 08. Hard Workers Club 
SELECT e.FirstName, e.LastName, AVG(DATEDIFF(HOUR, s.CheckIn, s.CheckOut)) AS [Work hours]
FROM Employees AS e
INNER JOIN Shifts AS s
ON s.EmployeeId = e.Id
GROUP BY e.FirstName, e.LastName, e.Id
HAVING AVG(DATEDIFF(HOUR, s.CheckIn, s.CheckOut)) > 7
ORDER BY [Work hours] DESC, e.Id ASC
GO

-- 09. The Most Expensive Order
SELECT TOP(1) o.Id, SUM(oi.Quantity * i.Price) AS TotalPrice
FROM Orders AS o
INNER JOIN OrderItems AS oi
ON oi.OrderId = o.Id
INNER JOIN Items AS i
ON i.Id = oi.ItemId
GROUP BY o.Id
ORDER BY TotalPrice DESC
GO

-- 10. Rich Item, Poor Item
SELECT TOP(10) o.Id, MAX(i.Price) AS [ExpensivePrice], MIN(i.Price) AS [CheapPrice]
FROM Orders AS o
INNER JOIN OrderItems AS oi
ON oi.OrderId = o.Id
INNER JOIN Items AS i
ON i.Id = oi.ItemId
GROUP BY o.Id
ORDER BY [ExpensivePrice] DESC, o.Id ASC
GO

-- 11. Cashiers
SELECT DISTINCT e.Id, e.FirstName, e.LastName
FROM Employees AS e
INNER JOIN Orders AS o
ON o.EmployeeId = e.Id
ORDER BY e.Id ASC
GO

-- 12. Lazy Employees
SELECT DISTINCT e.Id, CONCAT(e.FirstName, ' ', e.LastName) AS [Full Name]
FROM Employees AS e
INNER JOIN Shifts AS s
ON s.EmployeeId = e.Id
WHERE DATEDIFF(HOUR, s.CheckIn, s.CheckOut) < 4
ORDER BY e.Id ASC
GO

-- 13. Sellers
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS [Full Name],
    SUM(i.Price * oi.Quantity) AS [TotalPrice],
    SUM(oi.Quantity) AS [Items]
FROM Employees AS e
INNER JOIN Orders AS o
ON o.EmployeeId = e.Id
INNER JOIN OrderItems AS oi
ON oi.OrderId = o.Id
INNER JOIN Items AS i
ON i.Id = oi.ItemId
WHERE o.[DateTime] < '2018-06-15'
GROUP BY e.FirstName, e.LastName
ORDER BY TotalPrice DESC, Items DESC
GO

-- 14. Tough Days
SELECT
  CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
  CASE
    WHEN DATEPART(WEEKDAY, s.CheckIn) = 2 THEN 'Monday'
    WHEN DATEPART(WEEKDAY, s.CheckIn) = 3 THEN 'Tuesday'
    WHEN DATEPART(WEEKDAY, s.CheckIn) = 4 THEN 'Wednesday'
    WHEN DATEPART(WEEKDAY, s.CheckIn) = 5 THEN 'Thursday'
    WHEN DATEPART(WEEKDAY, s.CheckIn) = 6 THEN 'Friday'
    WHEN DATEPART(WEEKDAY, s.CheckIn) = 7 THEN 'Saturday'
    WHEN DATEPART(WEEKDAY, s.CheckIn) = 1 THEN 'Sunday'
  END AS DayOfWeek
FROM Employees AS e
LEFT JOIN Orders AS o ON o.EmployeeId = e.Id
INNER JOIN Shifts AS s ON s.EmployeeId = e.Id
WHERE o.Id IS NULL AND DATEDIFF(HOUR, s.CheckIn, s.CheckOut) > 12
ORDER BY e.Id

-- 15. Top Order per Employee
SELECT emp.FirstName + ' ' + emp.LastName AS FullName, 
    DATEDIFF(HOUR, s.CheckIn, s.CheckOut) AS WorkHours, 
    e.TotalPrice AS TotalPrice FROM  (
        SELECT o.EmployeeId, SUM(oi.Quantity * i.Price) AS TotalPrice, o.DateTime,
	    ROW_NUMBER() OVER (PARTITION BY o.EmployeeId ORDER BY o.EmployeeId, SUM(i.Price * oi.Quantity) DESC ) AS Rank
        FROM Orders AS o
        INNER JOIN OrderItems AS oi ON oi.OrderId = o.Id
        INNER JOIN Items AS i ON i.Id = oi.ItemId
        GROUP BY o.EmployeeId, o.Id, o.DateTime
        ) AS e 
INNER JOIN Employees AS emp ON emp.Id = e.EmployeeId
INNER JOIN Shifts AS s ON s.EmployeeId = e.EmployeeId
WHERE e.Rank = 1 AND e.DateTime BETWEEN s.CheckIn AND s.CheckOut
ORDER BY FullName, WorkHours DESC, TotalPrice DESC
GO

-- 16. Average Profit per Day
SELECT DATEPART(DAY, o.[DateTime]) AS [Day], CAST(AVG(i.Price * oi.Quantity) AS DECIMAL(15, 2)) AS [Total Profit]
FROM Orders AS o
INNER JOIN OrderItems AS oi
ON oi.OrderId = o.Id
INNER JOIN Items AS i
ON i.Id = oi.ItemId
GROUP BY DATEPART(DAY, o.[DateTime])
ORDER BY [Day] ASC
GO

-- 17. Top Products
SELECT i.Name AS Item, 
    c.Name AS Category, 
    SUM(oi.Quantity) AS [Count],
    SUM(oi.Quantity * i.Price) AS TotalPrice
FROM Orders AS o
INNER JOIN OrderItems AS oi
ON oi.ItemId = o.Id
RIGHT JOIN Items AS i
ON i.Id = oi.ItemId
INNER JOIN Categories AS c
ON c.Id = i.CategoryId
GROUP BY i.Name, c.Name
ORDER BY TotalPrice DESC, [Count] DESC
GO

-- Section 4. Programmability (20 pts)
-- 18. Promotion days
CREATE FUNCTION udf_GetPromotedProducts 
    (@CurrentDate DATETIME, @StartDate DATETIME, @EndDate DATETIME, @Discount INT, @FirstItemId INT, @SecondItemId INT, @ThirdItemId INT)
RETURNS VARCHAR(100)
BEGIN 
	DECLARE @FirstItemPrice DECIMAL(15,2) = (SELECT Price FROM Items WHERE Id = @FirstItemId)
	DECLARE @SecondItemPrice DECIMAL(15,2) = (SELECT Price FROM Items WHERE Id = @SecondItemId)
	DECLARE @ThirdItemPrice DECIMAL(15,2) = (SELECT Price FROM Items WHERE Id = @ThirdItemId)

	IF (@FirstItemPrice IS NULL OR @SecondItemPrice IS NULL OR @ThirdItemPrice IS NULL)
	BEGIN
	 RETURN 'One of the items does not exists!'
	END

	IF (@CurrentDate <= @StartDate OR @CurrentDate >= @EndDate)
	BEGIN
	 RETURN 'The current date is not within the promotion dates!'
	END

	DECLARE @NewFirstItemPrice DECIMAL(15,2) = @FirstItemPrice - (@FirstItemPrice * @Discount / 100)
	DECLARE @NewSecondItemPrice DECIMAL(15,2) = @SecondItemPrice - (@SecondItemPrice * @Discount / 100)
	DECLARE @NewThirdItemPrice DECIMAL(15,2) = @ThirdItemPrice - (@ThirdItemPrice * @Discount / 100)

	DECLARE @FirstItemName VARCHAR(50) = (SELECT [Name] FROM Items WHERE Id = @FirstItemId)
	DECLARE @SecondItemName VARCHAR(50) = (SELECT [Name] FROM Items WHERE Id = @SecondItemId)
	DECLARE @ThirdItemName VARCHAR(50) = (SELECT [Name] FROM Items WHERE Id = @ThirdItemId)

	RETURN @FirstItemName + ' price: ' + CAST(ROUND(@NewFirstItemPrice,2) AS VARCHAR) + ' <-> ' +
		   @SecondItemName + ' price: ' + CAST(ROUND(@NewSecondItemPrice,2) AS VARCHAR)+ ' <-> ' +
		   @ThirdItemName + ' price: ' + CAST(ROUND(@NewThirdItemPrice,2) AS VARCHAR)
END
GO

-- 19. Cancel Order
CREATE PROCEDURE  usp_CancelOrder(@OrderId INT, @CancelDate DATETIME) AS
BEGIN
    DECLARE @Order INT = (SELECT Id FROM Orders WHERE Id = @OrderId);

    IF (@Order IS NULL)
    BEGIN
        RAISERROR('The order does not exist!', 16, 1);
    END

    DECLARE @IssueDate DATETIME = (SELECT [DateTime] FROM Orders WHERE Id = @OrderId);
    DECLARE @DateDiff INT = (SELECT DATEDIFF(DAY, @IssueDate, @CancelDate))

    IF (@DateDiff > 3)
    BEGIN
        RAISERROR('You cannot cancel the order!', 16, 1)
    END

	DELETE FROM OrderItems
	WHERE OrderId = @OrderId

    DELETE
    FROM Orders
    WHERE Id = @OrderId

END
GO

-- 20. Deleted Orders
CREATE TABLE DeletedOrders (
    OrderId INT,
    ItemId INT,
    ItemQuantity INT
)
GO 

CREATE TRIGGER tr_DeletedOrders ON OrderItems
AFTER DELETE AS
BEGIN
	INSERT INTO DeletedOrders
	SELECT OrderId, ItemId, Quantity
	FROM deleted
END
GO