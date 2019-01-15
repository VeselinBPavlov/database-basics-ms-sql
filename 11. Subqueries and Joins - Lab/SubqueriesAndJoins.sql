USE SoftUni
GO

-- 1. Managers
SELECT TOP(5) e.EmployeeID, CONCAT(e.FirstName, ' ', LastName) AS FullName, d.DepartmentID, d.[Name] 
FROM Employees AS e
INNER JOIN Departments AS d
ON d.ManagerID = e.EmployeeID
ORDER BY e.EmployeeID ASC
GO

-- 2. Towns Addresses
SELECT t.TownID, t.[Name], a.AddressText
FROM Towns AS t
INNER JOIN Addresses AS a
ON (a.TownID = t.TownID AND t.[Name] IN ('San Francisco', 'Sofia', 'Carnation'))
ORDER BY t.TownID ASC, a.AddressID ASC
GO

-- 3. Employees Without Managers
SELECT e.EmployeeID, e.FirstName, e.LastName, e.DepartmentID, e.Salary 
FROM Employees as e
WHERE e.ManagerID IS NULL
GO

-- 4. Higher Salary
SELECT COUNT(EmployeeID) AS [Count]
FROM Employees
WHERE Salary > (
	SELECT AVG(Salary)
	FROM Employees
) 
GO