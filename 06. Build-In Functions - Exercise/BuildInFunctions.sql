-- Part I – Queries for SoftUni Database
USE SoftUni
GO

-- 1. Find Names of All Employees by First Name
SELECT FirstName, LastName
FROM Employees
WHERE SUBSTRING(FirstName, 1, 2) = 'SA'
GO

-- 2. Find Names of All Employees by Last Name
SELECT FirstName, LastName
FROM Employees
WHERE LastName LIKE '%ei%'
GO

-- 3. Find First Names of All Employess
SELECT FirstName
FROM Employees
WHERE DepartmentID IN (3 ,10)
AND HireDate BETWEEN '1995-01-01' AND '2005-12-31'
GO

-- 4. Find All Employees Except Engineers 
SELECT FirstName, LastName
FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'
GO

-- 5. Find Towns with Name Length
SELECT [Name] 
FROM Towns
WHERE LEN([Name]) IN (5, 6)
ORDER BY [Name] ASC
GO

-- 6. Find Towns Starting With
SELECT TownID, [Name]
FROM Towns
WHERE [Name] LIKE '[MKBE]%'
ORDER BY [Name] ASC
GO

-- 7. Find Towns Not Starting With
SELECT TownID, [Name]
FROM Towns
WHERE [Name] NOT LIKE '[RDB]%'
ORDER BY [Name] ASC
GO

-- 8. Create View Employees Hired After
CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName
FROM Employees
WHERE DATEPART(YEAR, HireDate) > 2000
GO

-- 9. Length of Last Name
SELECT FirstName, LastName
FROM Employees
WHERE LEN(LastName) = 5
GO

-- Part II – Queries for Geography Database 
USE [Geography]
GO

-- 10. Countries Holding 'A' 3 or More Times
SELECT CountryName, IsoCode
FROM Countries
WHERE CountryName LIKE '%a%a%a%'
ORDER BY IsoCode
GO

-- 11. Mix of Peak and River Names
SELECT PeakName, RiverName,
LOWER(PeakName + SUBSTRING(RiverName, 2, LEN(RiverName) - 1)) AS [Mix]
FROM Peaks, Rivers
WHERE RIGHT(PeakName, 1) = LEFT(RiverName, 1)
ORDER BY [Mix]
GO

-- Part III – Queries for Diablo Database
USE Diablo
GO

-- 12. Games From 2011 and 2012 Year 
SELECT TOP(50) [Name], 
FORMAT([Start], 'yyyy-MM-dd') AS [Start]
FROM Games
WHERE [Start] BETWEEN '2011-01-01' AND '2012-12-31'
ORDER BY [Start], [Name]
GO

-- 13. User Email Providers 
SELECT Username,
SUBSTRING(Email, CHARINDEX('@', Email, 1) + 1, LEN(Email)) AS [Email Provider]
FROM Users
ORDER BY [Email Provider], Username
GO

-- 14. Get Users with IPAddress Like Pattern 
SELECT Username, IpAddress
FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username
GO

-- 15. Show All Games with Duration
SELECT [Name] AS [Game],
CASE
	WHEN DATEPART(HOUR, [Start]) BETWEEN 0 AND 11 THEN 'Morning'
	WHEN DATEPART(HOUR, [Start]) BETWEEN 12 AND 17 THEN 'Afternoon'
	WHEN DATEPART(HOUR, [Start]) BETWEEN 18 AND 24 THEN 'Evening'
END AS [Part of the Day],
CASE
	WHEN Duration <= 3 THEN 'Extra Short'
	WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
	WHEN Duration > 6 THEN 'Long'
	WHEN Duration IS NULL THEN 'Extra Long'
END AS [Duration]
FROM Games
ORDER BY Game, Duration, [Part of the Day]
GO

-- Part IV – Date Functions Queries (From Orders Database)
USE Orders
GO

-- 16. Orders Table 
SELECT ProductName, OrderDate,
DATEADD(DAY, 3, OrderDate) AS [Pay Due],
DATEADD(MONTH, 1, OrderDate) AS [Deliver Due]
FROM Orders
GO

-- 17.  People Table
CREATE TABLE People
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(50),
	Birthdate DATE
)

INSERT INTO People VALUES
('Pesho', '1932-01-02'),
('Gosho', '1935-02-03'),
('Sasho', '1938-03-04'),
('Tosho', '1943-05-06')

SELECT [Name],
DATEDIFF(YEAR, Birthdate, GETDATE()) AS [Age in Years],
DATEDIFF(MONTH, Birthdate, GETDATE()) AS [Age in Months],
DATEDIFF(DAY, Birthdate, GETDATE()) AS [Age in Days],
DATEDIFF(MINUTE, Birthdate, GETDATE()) AS [Age in Minutes]
FROM People
GO