-- Section 1. DDL (30 pts)
USE [master]
GO

CREATE DATABASE RentACar ON PRIMARY
   ( NAME = N'RentACar_Data', FILENAME = N'D:\Courses\Data\RentACar_Data.mdf' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
LOG ON
   ( NAME = N'RentACar_Log', FILENAME = N'D:\Courses\Data\RentACar_Log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE RentACar
GO

-- 01. Database Design
CREATE TABLE Clients (
    Id INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(30) NOT NULL,
    LastName NVARCHAR(30) NOT NULL,
    Gender CHAR(1) CHECK (Gender = 'M' OR Gender = 'F'),
    BirthDate DATETIME,
    CreditCard NVARCHAR(30) NOT NULL,
    CardValidity DATETIME,
    Email NVARCHAR(50) NOT NULL    
)

CREATE TABLE Towns (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Models (
    Id INT PRIMARY KEY IDENTITY,
    Manufacturer NVARCHAR(50) NOT NULL,
    Model NVARCHAR(50) NOT NULL,
    ProductionYear DATETIME,
    Seats INT,
    Class NVARCHAR(10) NOT NULL,
    Consumption DECIMAL(14, 2)
)

CREATE TABLE Offices (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(40),
    ParkingPlaces INT,
    TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL
)

CREATE TABLE Vehicles (
    Id INT PRIMARY KEY IDENTITY,
    ModelId INT FOREIGN KEY REFERENCES Models(Id) NOT NULL,
    OfficeId INT FOREIGN KEY REFERENCES Offices(Id) NOT NULL, 
    Mileage INT
)

CREATE TABLE Orders (
    Id INT PRIMARY KEY IDENTITY,
    ClientId INT FOREIGN KEY REFERENCES Clients(Id) NOT NULL,
    TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL,
    VehicleId INT FOREIGN KEY REFERENCES Vehicles(Id) NOT NULL,
    CollectionDate DATETIME NOT NULL,
    CollectionOfficeId INT FOREIGN KEY REFERENCES Offices(Id) NOT NULL,
    ReturnDate DATETIME,
    ReturnOfficeId INT FOREIGN KEY REFERENCES Offices(Id),
    Bill DECIMAL(14, 2),
    TotalMileage INT
)
GO

--Section 2. DML (10 pts)
-- 02. Insert

INSERT INTO Models
    ([Manufacturer], [Model], [ProductionYear], [Seats], [Class], [Consumption])
VALUES
 ('Chevrolet', 'Astro', '2005-07-27 00:00:00.000', 4, 'Economy', 12.60),
 ('Toyota', 'Solara', '2009-10-15 00:00:00.000', 7, 'Family', 13.80),
 ('Volvo', 'S40', '2010-10-12 00:00:00.000', 3, 'Average', 11.30),
 ('Suzuki', 'Swift', '2000-02-03 00:00:00.000', 7, 'Economy', 16.20)

INSERT INTO Orders
    ([ClientId], [TownId], [VehicleId], [CollectionDate], [CollectionOfficeId], [ReturnDate], [ReturnOfficeId], [Bill], [TotalMileage])
VALUES
(17, 2, 52, '2017-08-08', 30, '2017-09-04', 42, 2360.00, 7434),
(78, 17, 50, '2017-04-22', 10, '2017-05-09', 12, 2326.00, 7326),
(27, 13, 28, '2017-04-25', 21, '2017-05-09', 34, 597.00, 1880)
GO

-- 03. Update
UPDATE Models
SET Class = 'Luxury'
WHERE Consumption > 20
GO

-- 04. Delete
DELETE
FROM Orders
WHERE ReturnDate IS NULL
GO

-- Section 3. Querying (40 pts)
-- 05. Showroom
SELECT Manufacturer, Model
FROM Models
ORDER BY Manufacturer ASC, Id DESC
GO

-- 06. Y Generation
SELECT FirstName, LastName
FROM Clients
WHERE DATEPART(Year, BirthDate) >= 1977 AND DATEPART(Year, BirthDate) <= 1994
ORDER BY FirstName ASC, LastName ASC, Id ASC
GO

-- 07. Spacious Office 
SELECT t.[Name] AS TownName, o.[Name] AS OfficeName, o.ParkingPlaces
FROM Offices AS o
INNER JOIN Towns AS t ON t.Id = o.TownId
WHERE o.ParkingPlaces > 25
ORDER BY t.[Name] ASC, o.Id ASC
GO

-- 08. Available Vehicles
SELECT m.Model, m.Seats, v.Mileage 
FROM Models AS m
INNER JOIN Vehicles AS v ON v.ModelId = m.Id
WHERE v.Id NOT IN (SELECT o.VehicleId
                      FROM Orders AS o
                      WHERE o.ReturnDate IS NULL)
ORDER BY v.Mileage ASC, m.Seats DESC, m.Id ASC
GO

-- 09. Offices per Town 
SELECT t.[Name] AS TownName, COUNT(o.Id) AS OfficesNumber
FROM Towns AS t
INNER JOIN Offices AS o ON o.TownId = t.Id
GROUP BY t.[Name]
ORDER BY OfficesNumber DESC, TownName ASC
GO

-- 10. Buyers Best Choice
SELECT m.Manufacturer, m.Model, COUNT(o.VehicleId) AS TimesOrdered
FROM Models AS m
INNER JOIN Vehicles AS v ON v.ModelId = m.Id
LEFT JOIN Orders AS o ON o.VehicleId = v.Id
GROUP BY m.Manufacturer, m.Model
ORDER BY TimesOrdered DESC, m.Manufacturer DESC, m.Model ASC
GO

-- 11. Kinda Person
SELECT Names, Class
FROM (SELECT CONCAT(c.FirstName, ' ', c.LastName) AS Names, m.Class,
            RANK() OVER (PARTITION BY CONCAT(c.FirstName, ' ', c.LastName) ORDER BY COUNT(m.Class)  DESC) AS [Rank]  
      FROM Orders AS o
      INNER JOIN Clients AS c ON o.ClientId = c.Id
      INNER JOIN Vehicles AS v ON v.Id = o.VehicleId
      INNER JOIN Models AS m ON m.Id = v.ModelId 
      GROUP BY CONCAT(c.FirstName, ' ', c.LastName), m.Class) AS r
WHERE Rank = 1
ORDER BY Names ASC, Class ASC
GO

-- 12. Age Groups Revenue 
SELECT AgeGroup, SUM(Revenue) AS Revenue, AVG(AverageMileage) AS AverageMileage
FROM (SELECT 
        CASE
            WHEN DATEPART(Year, BirthDate) >= 1970 AND DATEPART(Year, BirthDate) <= 1979 THEN '70''s'
            WHEN DATEPART(Year, BirthDate) >= 1980 AND DATEPART(Year, BirthDate) <= 1989 THEN '80''s'
            WHEN DATEPART(Year, BirthDate) >= 1990 AND DATEPART(Year, BirthDate) <= 1999 THEN '90''s'
            ELSE 'Others'
        END AS AgeGroup,    
        o.Bill AS Revenue, 
        o.TotalMileage AS AverageMileage
      FROM Clients AS c
      INNER JOIN Orders AS o ON o.ClientId = c.Id
      GROUP BY c.BirthDate, o.Bill, o.TotalMileage) AS a
GROUP BY a.AgeGroup
ORDER BY a.AgeGroup
GO

-- 13. Consumption in Mind
SELECT TOP(3) m.Manufacturer, AVG(m.Consumption) AS AverageConsupmtion
FROM Orders AS o
JOIN Vehicles AS v ON v.Id = o.VehicleId
JOIN Models AS m ON m.Id = v.ModelId
GROUP BY m.Manufacturer, m.Model
HAVING AVG(m.Consumption) BETWEEN 5 AND 15
ORDER BY  COUNT(m.Model) DESC, m.Manufacturer ASC, AverageConsupmtion ASC
GO

-- 14. Debt Hunter
SELECT Names, Email, Bill, TownName
FROM (SELECT
		c.Id AS ClientId,
		c.FirstName + ' ' + c.LastName AS Names, 
		c.Email, 
		o.Bill, 
		t.[Name] AS TownName,
		DENSE_RANK() OVER (PARTITION BY t.[Name] ORDER BY o.Bill DESC) AS Ranks
	FROM CLIENTS AS c
	JOIN Orders AS o
	ON o.ClientId = c.Id
	JOIN Towns AS t
	ON t.Id = o.TownId
	WHERE c.CardValidity < o.CollectionDate AND o.Bill IS NOT NULL) AS h
WHERE Ranks IN (1, 2)
ORDER BY h.TownName ASC, h.Bill ASC, h.ClientId ASC
GO

-- 15. Town Statistics 
SELECT TownName,
       Males * 100 / (ISNULL(Males, 0) + ISNULL(Females, 0)) AS MalePercent,
       Females * 100 / (ISNULL(Males, 0) + ISNULL(Females, 0)) AS FemalePercent
FROM (SELECT t.[Name] AS TownName, t.Id AS TownId,
        SUM(CASE c.Gender WHEN 'M' THEN 1 ELSE NULL END) AS Males,
        SUM(CASE c.Gender WHEN 'F' THEN 1 ELSE NULL END) AS Females,
        COUNT(c.Gender) AS CountGender
      FROM Towns AS t
      JOIN Orders AS o ON o.TownId = t.Id
      JOIN Clients AS c ON c.Id = o.ClientId
      GROUP BY t.[Name], t.Id ) AS h
ORDER BY TownName ASC, TownId ASC

-- 16. Home Sweet Home 
SELECT h.Manufacturer + ' - ' + h.Model AS Vehicle,
        CASE
            WHEN (SELECT COUNT(*) FROM Orders AS o WHERE o.VehicleId = h.Id) = 0 THEN 'home' 
            WHEN (h.ReturnOfficeId IS NULL) THEN 'on a rent'
            WHEN h.OfficeId != h.ReturnOfficeId THEN (SELECT t.[Name] + ' ' + '-' + ' ' + o.[Name] FROM Towns AS t JOIN Offices AS o ON o.TownId = t.Id WHERE o.Id = h.ReturnOfficeId)
        END AS [Location]
FROM (SELECT r.ReturnOfficeId, r.OfficeId, r.Id, r.Manufacturer, r.Model
      FROM (SELECT DENSE_RANK() OVER (PARTITION BY v.Id ORDER By o.CollectionDate DESC) AS RentCarsRank, o.ReturnOfficeId, v.OfficeId, m.Manufacturer, m.Model, v.Id 
          FROM Vehicles AS v
          LEFT JOIN Orders AS o ON o.VehicleId = v.Id
          JOIN Models AS m ON m.Id = v.ModelId) AS r
      WHERE RentCarsRank = 1) AS h
ORDER BY Vehicle, h.Id
GO

-- 17. Find My Ride 
CREATE FUNCTION udf_CheckForVehicle(@townName NVARCHAR(50), @seatsNumber INT)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX) = 
	(SELECT TOP(1) o.[Name] + ' - ' + m.Model
     FROM Towns AS t
     JOIN Offices AS o ON o.TownId = t.Id
     JOIN Vehicles AS v ON v.OfficeId = o.Id
     JOIN Models AS m ON m.Id = v.ModelId
     WHERE t.[Name] = @townName AND m.Seats = @seatsNumber
     ORDER BY o.[Name] ASC)

	RETURN ISNULL(@result, 'NO SUCH VEHICLE FOUND'); 
END
GO

-- 18. Move a Vehicle 
CREATE PROCEDURE usp_MoveVehicle(@vehicleId INT, @officeId INT) AS
BEGIN
DECLARE @usedPlaces INT =  
	(SELECT TOP 1 
	 	COUNT(*) OVER (PARTITION BY v.OFFICEID)
	 FROM Vehicles AS v
	 JOIN Offices AS o
	 	ON o.Id = v.OfficeId
	 WHERE v.OfficeId = @officeId)

	DECLARE @parkingPlaces INT = 
	(SELECT ofi.ParkingPlaces 
	 FROM Offices AS ofi
	 WHERE ofi.Id = @officeId)

	BEGIN TRANSACTION 
	IF(@parkingPlaces <= @usedPlaces)
	BEGIN 
		ROLLBACK; 
		RAISERROR('Not enough room in this office!', 16, 2); 
		RETURN;
	END

	UPDATE Vehicles
	SET OfficeId = @officeId 
	WHERE Id = @vehicleId

	COMMIT
END
GO

-- 19. Move the Tally
CREATE TRIGGER tr_UpdateMileage 
ON Orders 
AFTER UPDATE 
AS
BEGIN 
	BEGIN TRANSACTION 

	DECLARE @vehicleID INT = (SELECT inserted.VehicleId FROM inserted);
	DECLARE @insertedMileage INT = (SELECT inserted.TotalMileage FROM inserted);
	DECLARE @deletedMileage INT = (SELECT deleted.TotalMileage FROM deleted);

	IF(@deletedMileage IS NOT NULL)
	BEGIN 
		ROLLBACK; 
		RETURN; 
	END

	UPDATE Vehicles
	SET Mileage += @insertedMileage
	WHERE Id = @vehicleID

	COMMIT
END
GO