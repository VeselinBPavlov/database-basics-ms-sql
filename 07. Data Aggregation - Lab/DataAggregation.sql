USE Restaurant
GO

-- 1. Departments Info
SELECT DepartmentId, COUNT(DepartmentId) AS [Number Of Employees] 
FROM Employees
GROUP BY DepartmentId
ORDER BY [Number Of Employees]

-- 2. Average Salary
SELECT DepartmentId, CONVERT(FLOAT, ROUND(AVG(Salary), 2)) AS [Average Salary] 
FROM Employees
GROUP BY DepartmentId
ORDER BY DepartmentId

-- 3. Minimum Salary
SELECT DepartmentId, CONVERT(FLOAT, ROUND(MIN(Salary), 2)) AS [Average Salary] 
FROM Employees
GROUP BY DepartmentId
HAVING MIN(Salary) > 800
ORDER BY DepartmentId

-- 4. Appetizers Count
SELECT COUNT(Id) + 1 AS [Count]
FROM Products
WHERE Id = 2 AND Price > 8
GROUP BY Id

-- 5. Menu Prices
SELECT CategoryId, 
CONVERT(FLOAT, ROUND(AVG(Price), 2)) AS [Price], 
MIN(Price) AS [Cheapest Product], 
MAX(Price) AS [Most Expensive Product]
FROM Products
GROUP BY CategoryId
ORDER BY CategoryId