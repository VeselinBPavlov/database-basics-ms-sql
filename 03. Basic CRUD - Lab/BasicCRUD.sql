USE Hospital
Go

-- 1. Select Employee Information
SELECT Id, FirstName, LastName, JobTitle
FROM Employees
ORDER BY Id
GO

-- 2. Select Employees with Filter
SELECT Id, FirstName + ' ' + LastName AS FullName, JobTitle, Salary
FROM Employees
WHERE Salary >= 1000
ORDER BY Id
GO

-- 03. Update Employees Salary
UPDATE Employees
SET Salary *= 1.10
WHERE JobTitle = 'Therapist'

SELECT Salary
FROM Employees
WHERE JobTitle = 'Therapist'
GO

-- 04. Top Paid Employee
CREATE VIEW v_TopPaidEmployee AS
SELECT TOP(1) * 
FROM Employees
ORDER BY Salary DESC
GO

SELECT * 
FROM v_TopPaidEmployee
GO

-- 05. Select Employees by Multiple Filters
SELECT *
FROM Employees
WHERE DepartmentId = (SELECT Id
					FROM Departments
					WHERE Name = 'Other')
AND Salary >= 1600
ORDER BY Id
GO

-- 06. Delete from Table
DELETE 
FROM Employees
WHERE DepartmentId = 1 
	  OR DepartmentId = 2
GO

SELECT *
FROM Employees
GO