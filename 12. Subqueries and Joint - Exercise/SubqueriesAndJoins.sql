-- Part I – Queries for SoftUni Database
USE SoftUni
GO

-- 1. Employee Address
SELECT TOP(5) e.EmployeeID, e.JobTitle, e.AddressId, a.AddressText
FROM Employees AS e
INNER JOIN Addresses AS a
ON a.AddressID = e.AddressID
ORDER BY AddressID ASC
GO

-- 2. Addresses with Towns
SELECT TOP(50) e.FirstName, e.LastName, t.[Name], a.AddressText
FROM Employees AS e
INNER JOIN Addresses AS a
ON a.AddressID = e.AddressID
INNER JOIN Towns AS t
ON t.TownID = a.TownID
ORDER BY e.FirstName ASC, e.LastName ASC
GO

-- 3. Sales Employee
SELECT e.EmployeeID, e.FirstName, e.LastName, d.[Name] AS DepartmentName
FROM Employees AS e
INNER JOIN Departments AS d
ON d.DepartmentID = e.DepartmentID
WHERE d.[Name] = 'Sales'
ORDER BY e.EmployeeID ASC
GO

-- 4. Employee Departments
SELECT TOP(5) e.EmployeeID, e.FirstName, e.Salary, d.[Name]
FROM Employees AS e
INNER JOIN Departments AS d
ON d.DepartmentID = e.DepartmentID
WHERE e.Salary > 15000
ORDER BY d.DepartmentID ASC
GO

-- 5. Employees Without Projects
SELECT TOP(3) e.EmployeeID, e.FirstName
FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep
ON ep.EmployeeID = e.EmployeeID
WHERE ep.EmployeeID IS NULL
ORDER BY e.EmployeeID ASC
GO

-- 6. Employees Hired After
SELECT e.FirstName, e.LastName, e.HireDate, d.[Name]
FROM Employees AS e
INNER JOIN Departments AS d
ON d.DepartmentID = e.DepartmentID
WHERE d.[Name] IN ('Sales', 'Finance')
AND DATEPART(YEAR, e.HireDate) > 1998
ORDER BY e.HireDate ASC
GO

-- 7. Employees with Project
SELECT TOP(5) e.EmployeeID, e.FirstName, p.[Name]
FROM Employees AS e
INNER JOIN EmployeesProjects AS ep
ON ep.EmployeeID = e.EmployeeID
INNER JOIN Projects AS p
ON p.ProjectID = ep.ProjectID
WHERE p.StartDate > '2002-08-13'
AND p.EndDate IS NULL
ORDER BY e.EmployeeID ASC
GO

-- 8. Employee 24
SELECT e.EmployeeID, e.FirstName,
	CASE
		WHEN p.StartDate > '2004' THEN NULL
		ELSE p.[Name]
	END AS ProjectName		
FROM Employees AS e
INNER JOIN EmployeesProjects AS ep
ON ep.EmployeeID = e.EmployeeID
INNER JOIN Projects AS p
ON p.ProjectID = ep.ProjectID
WHERE e.EmployeeID = 24
GO

-- 9. Employee Manager
SELECT e1.EmployeeID, e1.FirstName, e1.ManagerID, e2.FirstName AS ManagerName
FROM Employees AS e1
INNER JOIN Employees AS e2
ON e2.EmployeeID = e1.ManagerID
WHERE e1.ManagerID IN (3, 7)
ORDER BY e1.EmployeeID ASC
GO

-- 10. Employee Summary
SELECT TOP(50) e1.EmployeeID,
	CONCAT(e1.FirstName, ' ', e1.LastName) AS EmployeeName,
	CONCAT(e2.FirstName, ' ', e2.LastName) AS ManagerName,
	d.[Name]
FROM Employees AS e1
INNER JOIN Employees AS e2
ON e2.EmployeeID = e1.ManagerID
INNER JOIN Departments AS d
ON d.DepartmentID = e1.DepartmentID
ORDER BY e1.EmployeeID ASC
GO

-- 11. Min Average Salary 
SELECT TOP(1) (AVG(Salary)) AS MinAverageSalary
FROM Employees
GROUP BY DepartmentID
ORDER BY MinAverageSalary ASC
GO

-- Part II – Queries for Geography Database
USE [Geography]
GO

--12. Highest Peaks in Bulgaria
SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation
FROM Countries AS c
INNER JOIN MountainsCountries AS mc
ON mc.CountryCode = c.CountryCode
INNER JOIN Mountains AS m
ON m.Id = mc.MountainId
INNER JOIN Peaks AS p
ON p.MountainId = m.Id
WHERE c.CountryCode = 'BG'
AND p.Elevation > 2835
ORDER BY p.Elevation DESC
GO

-- 13. Count Mountain Ranges
SELECT c.CountryCode, COUNT(m.MountainRange) AS MountainRanges
FROM Countries AS c
INNER JOIN MountainsCountries AS mc
ON mc.CountryCode = c.CountryCode
INNER JOIN Mountains AS m
ON m.Id = mc.MountainId
WHERE c.CountryCode IN ('BG', 'US', 'RU')
GROUP BY c.CountryCode
GO

--14. Countries With Rivers
SELECT TOP(5) c.CountryName, r.RiverName
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr
ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r
ON r.Id = cr.RiverId
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName
GO

-- 15. Continents and Currencies
SELECT c.ContinentCode, c.CurrencyCode, c.CurrencyUsage 
FROM  (
	SELECT ContinentCode, CurrencyCode, COUNT(*) AS CurrencyUsage,
		   DENSE_RANK() OVER (
		   	PARTITION BY ContinentCode
		   	ORDER BY COUNT(*) DESC
		   ) AS RANK
    FROM Countries
	GROUP BY CurrencyCode, ContinentCode
    HAVING COUNT(*) > 1
) AS c
WHERE c.RANK = 1
GO

-- 16. Countries without any Mountains
SELECT COUNT(c.CountryCode) AS CountryCode
FROM Countries AS c
LEFT JOIN MountainsCountries as mc
ON mc.CountryCode = c.CountryCode
WHERE MountainId IS NULL
GO

-- 17. Highest Peak and Longest River by Country
SELECT TOP(5) c.CountryName,
	MAX(p.Elevation) AS HighestPeakElevation,
	MAX(r.[Length]) AS LongestRiverLength
FROM Countries AS c
INNER JOIN MountainsCountries AS mc
ON mc.CountryCode = c.CountryCode
INNER JOIN Mountains AS m
ON m.Id = mc.MountainId
INNER JOIN Peaks AS p
ON p.MountainId = m.Id 
INNER JOIN CountriesRivers AS cr
ON cr.CountryCode = c.CountryCode
INNER JOIN Rivers AS r
ON r.Id = cr.RiverId
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, c.CountryName ASC
GO

-- 18. Highest Peak Name and Elevation by Country
SELECT TOP(5) c.CountryName AS Country,
	CASE
		WHEN p.PeakName IS NULL THEN '(no highest peak)'
		ELSE p.PeakName
	END AS HighestPeakName,
    CASE
        WHEN p.Elevation IS NULL THEN 0
        ELSE MAX(p.Elevation)
    END AS HighestPeakElevation,
    CASE
		WHEN m.MountainRange IS NULL THEN '(no mountain)'
		ELSE m.MountainRange
	END AS Mountain FROM Countries AS c
LEFT JOIN MountainsCountries AS mc 
ON mc.CountryCode = c.CountryCode
LEFT JOIN Mountains AS m 
ON m.Id = mc.MountainId
LEFT JOIN Peaks AS p 
ON m.Id = p.MountainId
GROUP BY c.CountryName, p.PeakName, p.Elevation, m.MountainRange
ORDER BY c.CountryName, p.PeakName
GO