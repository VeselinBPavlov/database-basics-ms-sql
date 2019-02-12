-- Section 1. DDL (30 pts)
USE [master]
GO

CREATE DATABASE ReportService ON PRIMARY
   ( NAME = N'ReportService_Data', FILENAME = N'D:\Courses\Data\ReportService_Data.mdf' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
LOG ON
   ( NAME = N'ReportService_Log', FILENAME = N'D:\Courses\Data\ReportService_Log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE ReportService
GO

-- 01. Database Design
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY,
    Username NVARCHAR(30) UNIQUE NOT NULL,
    Password  NVARCHAR(50) NOT NULL,
    [Name]  NVARCHAR(50),
    Gender CHAR(1) CHECK (Gender = 'M' OR Gender = 'F'),
    BirthDate DATETIME,
    Age INT,
    Email  NVARCHAR(50) NOT NULL
)

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY,
    [Name]  NVARCHAR(50) NOT NULL
)

CREATE TABLE [Status] (
    Id INT PRIMARY KEY IDENTITY,
    Label  VARCHAR(30) NOT NULL
)

CREATE TABLE Employees (
    Id INT PRIMARY KEY IDENTITY,
    FirstName  NVARCHAR(25),
    LastName  NVARCHAR(25),
    Gender CHAR(1) CHECK (Gender = 'M' OR Gender = 'F'),
    BirthDate DATETIME,
    Age INT,
    DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)

CREATE TABLE Categories (
    Id INT PRIMARY KEY IDENTITY,
    [Name]  NVARCHAR(50) NOT NULL,
    DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Reports (
    Id INT PRIMARY KEY IDENTITY,
    CategoryId  INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
    StatusId INT FOREIGN KEY REFERENCES [Status](Id) NOT NULL,
    OpenDate DATETIME NOT NULL,
    CloseDate DATETIME,
    [Description]  VARCHAR(200),
    UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
    EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)
GO

-- 02. Insert
INSERT INTO Employees
    ([FirstName], [LastName], [Gender], [BirthDate], DepartmentId)
VALUES
    ('Marlo', 'O’Malley', 'M', '9/21/1958',	1),
    ('Niki', 'Stanaghan', 'F',  '11/26/1969', 4),
    ('Ayrton', 'Senna',	'M', '03/21/1960',  9),
    ('Ronnie', 'Peterson', 'M', '02/14/1944', 9),
    ('Giovanna', 'Amati', 'F', '07/20/1959', 5)

INSERT INTO Reports
    ([CategoryId], [StatusId], [OpenDate], [CloseDate], [Description], [UserId], [EmployeeId])
VALUES
    (1, 1, '04/13/2017', NULL, 'Stuck Road on Str.133', 6 , 2),
    (6, 3, '09/05/2015', '12/06/2015', 'Charity trail running', 3, 5),
    (14, 2, '09/07/2015', NULL, 'Falling bricks on Str.58', 5, 2),   
    (4, 3, '07/03/2017', '07/06/2017', 'Cut off streetlight on Str.11', 1, 1)
GO

-- 03. Update 
UPDATE Reports
SET StatusId = 2
WHERE [StatusId] = 1 AND CategoryId = 4
GO

-- 04. Delete
DELETE
FROM Reports
WHERE [StatusId] = 4
GO

-- 05. Users by Age 
SELECT Username, Age
FROM Users
ORDER BY Age ASC, Username DESC
GO

-- 06. Unassigned Reports
SELECT [Description], OpenDate
FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate ASC, [Description] ASC
GO

-- 07. Employees & Reports
SELECT e.FirstName, e.LastName, r.[Description], FORMAT(r.OpenDate, 'yyyy-MM-dd', 'zh-cn') AS OpenDate
FROM Reports AS r
JOIN Employees AS e ON e.Id = r.EmployeeId
ORDER BY e.Id ASC, r.OpenDate ASC, r.Id ASC
GO

-- 08. Most Reported Category 
SELECT c.[Name] AS CategoryName, COUNT(r.CategoryId) AS ReportNumber
FROM Reports AS r
JOIN Categories AS c ON c.Id = r.CategoryId
GROUP BY c.[Name]
ORDER BY ReportNumber DESC, CategoryName ASC
GO

-- 09. Employees in Category
SELECT c.[Name] AS CategoryName, COUNT(e.DepartmentId) AS [Employees Number]
FROM Categories AS c
JOIN Departments AS d ON d.Id = c.DepartmentId
JOIN Employees AS e ON e.DepartmentId = d.Id
GROUP BY c.[Name]
ORDER BY CategoryName ASC
GO

-- 10. Users per Employee
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS [Name], COUNT(r.UserId) AS [Users Number]
FROM Employees AS e
LEFT JOIN Reports AS r ON r.EmployeeId = e.Id
GROUP BY e.FirstName, e.LastName
ORDER BY [Users Number] DESC, e.FirstName ASC
GO

-- 11. Emergency Patrol
SELECT r.OpenDate, r.[Description], u.Email AS ReporterEmail
FROM Reports AS r
JOIN Users AS u ON u.Id = r.UserId
JOIN Categories AS c ON c.Id = r.CategoryId
JOIN Departments AS d ON d.Id = c.DepartmentId
WHERE r.CloseDate IS NULL
AND LEN(r.[Description]) > 20
AND r.[Description] LIKE '%str%'
AND d.[Name] IN ('Infrastructure', 'Emergency', 'Roads Maintenance')
ORDER BY r.OpenDate ASC, u.Email ASC, r.Id ASC 
GO

-- 12. Birthday Report 
SELECT DISTINCT c.[Name] AS CategoryName
FROM Reports AS r
JOIN Users AS u ON u.Id = r.UserId
JOIN Categories AS c ON c.Id = r.CategoryId
WHERE DATEPART(DAY, u.BirthDate) = DATEPART(DAY, r.OpenDate)
AND DATEPART(MONTH, u.BirthDate) = DATEPART(MONTH, r.OpenDate)
ORDER BY c.[Name] ASC
GO

-- 13. Numbers Coincidence
SELECT DISTINCT u.Username
FROM Users AS u
JOIN Reports AS r ON r.UserId = u.Id
WHERE u.Username LIKE '[0-9]%' OR u.Username LIKE '%[0-9]'
AND LEFT(u.Username, 1) = CONVERT(VARCHAR, r.CategoryId) OR RIGHT(u.Username, 1) = CONVERT(VARCHAR, r.CategoryId)
ORDER BY u.Username ASC
GO

-- 14. Open/Closed Statistics 
SELECT h.Name, CONCAT(SUM(h.ClosedProjects), '/', SUM(h.OpenProjects)) AS ClosedOpenReports
FROM (SELECT p.Id, p.Name,
        CASE WHEN DATEPART(YEAR, p.OpenDate) = 2016 THEN 1 ELSE 0 END AS OpenProjects,
	    CASE WHEN p.CloseDate IS NULL THEN 0 ELSE 1 END AS ClosedProjects
      FROM (SELECT e.Id, CONCAT(e.FirstName,' ', e.LastName) AS [Name], r.OpenDate, r.CloseDate
            FROM Employees AS e
            RIGHT JOIN Reports AS r ON r.EmployeeId = e.Id
            WHERE ((DATEPART(YEAR, r.OpenDate) = 2016 AND r.CloseDate IS NULL) AND e.Id IS NOT NULL
            OR (DATEPART(YEAR, r.CloseDate)  = 2016 )) AND e.Id IS NOT NULL) AS p) AS h
GROUP BY h.Id,h.Name
ORDER BY h.Name, h.Id
GO

-- 15. Average Closing Time
SELECT d.[Name], 
	CASE 
	    WHEN CAST(AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate)) AS VARCHAR(20)) IS NULL THEN 'no info'
	    ELSE CAST(AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate)) AS VARCHAR(20))
	END AS [Average Duration] 
FROM Departments AS d
INNER JOIN Categories AS c ON c.DepartmentId = d.Id
INNER JOIN Reports AS r ON r.CategoryId = c.Id
GROUP BY d.[Name]
GO

-- 16. Favorite Categories
WITH CTE_TotalReportsByDepartment (DepartmentId, Count) AS (
	SELECT d.Id, COUNT(r.Id)
	FROM Departments AS d
	INNER JOIN Categories AS c ON d.Id = c.DepartmentId
	INNER JOIN Reports AS r ON r.CategoryId = c.Id
	GROUP BY d.Id
)

SELECT d.[Name] AS [Department Name], c.[Name] AS [Category Name],
	CAST(ROUND(CEILING(CAST(COUNT(r.Id) AS DECIMAL(7, 2)) * 100)/tr.Count, 0) AS INT) AS [Percentage]
FROM Departments AS d
INNER JOIN CTE_TotalReportsByDepartment AS tr ON d.Id = tr.DepartmentId
INNER JOIN Categories AS c ON c.DepartmentId = d.Id
INNER JOIN Reports AS r ON r.CategoryId = c.Id
GROUP BY d.[Name], c.[Name], tr.Count
GO

-- 17. Employee's Load 
CREATE FUNCTION udf_GetReportsCount (@employeeId INT, @statusId INT)
RETURNS INT
AS
BEGIN
	RETURN (SELECT COUNT(Id) FROM Reports
			WHERE EmployeeId = @employeeId 
			AND StatusId = @statusId)
END
GO

-- 18. Assign Employee 
CREATE PROCEDURE usp_AssignEmployeeToReport (@employeeId INT, @reportId INT) AS
BEGIN
	DECLARE @employeeDept INT = (SELECT DepartmentId FROM Employees WHERE Id = @employeeId)

	DECLARE @JobDept INT = (SELECT DepartmentId 
							FROM Categories AS c
						    INNER JOIN Reports AS r ON r.CategoryId = c.Id
							WHERE r.Id = @reportId)

	IF (@employeeDept = @JobDept)
	BEGIN
		UPDATE Reports
		SET EmployeeId = @employeeId
		WHERE Id = @reportId
	END
	ELSE
	BEGIN
		RAISERROR ('Employee doesn''t belong to the appropriate department!', 16, 1)
	END
END
GO

-- 19. Close Reports 
CREATE TRIGGER tr_CloseReports 	ON Reports
AFTER UPDATE AS
BEGIN
	UPDATE Reports
	SET StatusId = 3
	FROM deleted AS d
    INNER JOIN inserted AS i ON i.Id = d.Id
	WHERE i.CloseDate IS NOT NULL
END
GO

-- 20. Categories Revision 
SELECT [Category Name],
	Waitings + InProgress AS [Reports Number],
	CASE
	    WHEN Waitings > InProgress THEN 'waiting'
	    WHEN Waitings < InProgress THEN 'in progress'
	    ELSE 'equal'
	END AS [Main Status]
FROM (SELECT c.[Name] AS [Category Name], 
	 COUNT(CASE WHEN StatusId = 1 THEN 1 ELSE NULL END) AS [Waitings],
	 COUNT(CASE WHEN StatusId = 2 THEN 1 ELSE NULL END) AS [InProgress]
	 FROM Reports AS r
	 INNER JOIN Categories AS c ON c.Id = r.CategoryId
	 WHERE StatusId IN (SELECT Id 
			            FROM [Status] 
			            WHERE Label IN ('waiting', 'in progress'))
	GROUP BY r.CategoryId, c.[Name]) AS Temp
ORDER BY [Category Name], [Reports Number], [Main Status]
GO