-- Queries for SoftUni Database
USE SoftUni
GO

-- 1. Count Employees by Town
CREATE OR ALTER FUNCTION ufn_CountEmployeesByTown(@TownName VARCHAR)
RETURNS INT
BEGIN
	DECLARE @Count INT;
	SET @Count = (SELECT COUNT(e.EmployeeID)
				FROM Employees AS e
				INNER JOIN Addresses AS a
				ON a.AddressID = e.AddressID
				INNER JOIN Towns AS t
				ON t.TownID = a.TownID
				WHERE t.Name = @TownName)
	RETURN @Count
END
GO

-- 2. Employees Promotion
CREATE OR ALTER PROCEDURE usp_RaiseSalaries(@DepartmentName VARCHAR) AS
BEGIN
UPDATE Employees
SET Salary *= 1.05 
WHERE DepartmentID = (SELECT DepartmentID
					FROM Departments
					WHERE [Name] = @DepartmentName)
END
GO

-- 3. Employees Promotion By ID
CREATE OR ALTER PROCEDURE usp_RaiseSalaryById(@Id INT) AS
BEGIN
DECLARE @EmployeeId INT = (SELECT EmployeeID
							FROM Employees
							WHERE EmployeeID = @Id)
	IF (@EmployeeId IS NOT NULL)
	BEGIN
		UPDATE Employees
		SET Salary *= 1.05 
		WHERE EmployeeID = @EmployeeId
	END
END
GO

-- 4. Triggered
CREATE TABLE DeletedEmployees (
	[EmployeeId] INT PRIMARY KEY,
	[FirstName] NVARCHAR(50),
	[LastName] NVARCHAR(50),
	[MiddleName] NVARCHAR(50),
	[JobTitle] NVARCHAR(50),
	[DepartmentId] INT,
	[Salary] DECIMAL(15, 2)
)
GO 

CREATE TRIGGER t_DeletedEmployees ON Employees AFTER DELETE AS
INSERT INTO DeletedEmployees
	([EmployeeId], [FirstName], [LastName], [MiddleName], [JobTitle], [DepartmentId], [Salary])
SELECT [EmployeeId], [FirstName], [LastName], [MiddleName], [JobTitle], [DepartmentId], [Salary]
FROM deleted
GO


