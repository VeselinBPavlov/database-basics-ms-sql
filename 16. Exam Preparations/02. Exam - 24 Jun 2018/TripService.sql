-- Section 1. DDL (30 pts)
USE [master]
GO

CREATE DATABASE TripService ON PRIMARY
   ( NAME = N'TripService_Data', FILENAME = N'D:\Courses\Data\TripService_Data.mdf' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
LOG ON
   ( NAME = N'TripService_Log', FILENAME = N'D:\Courses\Data\TripService_Log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE TripService
GO

-- 01. Database Design
CREATE TABLE Cities (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(20) NOT NULL,
    CountryCode CHAR(2) NOT NULL 
)

CREATE TABLE Hotels (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(30) NOT NULL,
    CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
    EmployeeCount INT NOT NULL,
    BaseRate DECIMAL(15, 2)
)

CREATE TABLE Rooms (
    Id INT PRIMARY KEY IDENTITY,
    Price DECIMAL(15, 2) NOT NULL,
    [Type] NVARCHAR(20) NOT NULL,
    Beds INT NOT NULL,
    HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
)

CREATE TABLE Trips (
     Id INT PRIMARY KEY IDENTITY,
     RoomId INT FOREIGN KEY REFERENCES Rooms(Id),
     BookDate DATE NOT NULL,
     ArrivalDate DATE NOT NULL,
     ReturnDate DATE NOT NULL,
     CancelDate DATE,

     CONSTRAINT CHK_BookDate
     CHECK (BookDate < ArrivalDate),

     CONSTRAINT CHK_ArrivalDate
     CHECK (ArrivalDate < ReturnDate)
)

CREATE TABLE Accounts (
    Id INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(20),
    LastName NVARCHAR(50) NOT NULL,
    CityId INT FOREIGN KEY REFERENCES Cities(Id),
    BirthDate DATE NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE AccountsTrips (
    AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
    TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
    Luggage INT NOT NULL,

    CONSTRAINT PK_AccountsTrips    
    PRIMARY KEY (AccountId, TripId),

    CONSTRAINT CHK_Luggage
    CHECK (Luggage >= 0)
)
GO

-- Section 2. DML (10 pts)

-- 02. Insert
INSERT INTO Accounts
    ([FirstName], [MiddleName], [LastName], [CityId], [BirthDate], [Email])
VALUES
('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips
    ([RoomId], [BookDate], [ArrivalDate], [ReturnDate], [CancelDate])
VALUES
(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)
GO

-- 03. Update
UPDATE Rooms
SET Price *= 1.14
WHERE HotelId IN (5, 7, 9)
GO

-- 04. Delete
DELETE
FROM AccountsTrips
WHERE AccountId = 47

--Section 3. Querying (40 pts)
-- 05. Bulgarian Cities 
SELECT Id, [Name]
FROM Cities
WHERE CountryCode = 'BG'
ORDER BY [Name] ASC
GO

-- 06. People Born After 1991 
SELECT CONCAT(FirstName, ' ' + MiddleName, ' ', LastName) AS [Full Name], DATEPART(YEAR, BirthDate) AS [BirthYear]
FROM Accounts
WHERE DATEPART(YEAR, BirthDate) > 1991
ORDER BY BirthYear DESC, FirstName ASC
GO

-- 07. EEE-Mails
SELECT a.FirstName, a.LastName, FORMAT(a.BirthDate, 'MM-dd-yyyy') AS BirthDate, c.[Name] AS Hometown, a.Email
FROM Accounts AS a
INNER JOIN Cities AS c ON c.Id = a.CityId
WHERE a.Email LIKE 'e%'
ORDER BY c.[Name] DESC
GO

-- 08. City Statistics
SELECT c.[Name] AS City, COUNT(h.Id) AS Hotels
FROM Cities AS c
LEFT JOIN Hotels AS h ON h.CityId = c.Id
GROUP BY c.[Name]
ORDER BY Hotels DESC, City ASC
GO

--09. Expensive First Class Rooms
SELECT r.Id, r.Price, h.[Name] AS Hotel, c.[Name] AS City
FROM Rooms AS r
INNER JOIN Hotels AS h ON h.Id = r.HotelId
INNER JOIN Cities AS c ON c.Id = h.CityId
WHERE [Type] = 'First Class'
ORDER BY r.Price DESC, r.Id ASC
GO

-- 10. Longest and Shortest Trips
SELECT ac.AccountId, 
    CONCAT(a.FirstName, ' ', a.LastName) AS FullName, 
    MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS LongestTrip,
    MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS ShortestTrip
FROM Trips AS t
INNER JOIN AccountsTrips AS ac ON ac.TripId = t.Id
INNER JOIN Accounts AS a ON a.Id = ac.AccountId
WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
GROUP BY ac.AccountId, a.FirstName, a.LastName
ORDER BY LongestTrip DESC, ac.AccountId ASC
GO

-- 11. Metropolis
SELECT TOP(5) c.Id, c.[Name] AS City, c.CountryCode AS Country, COUNT(a.Id) AS Accounts
FROM Cities AS c
INNER JOIN Accounts AS a ON a.CityId = c.Id
GROUP BY c.Id, c.[Name], c.CountryCode
ORDER BY Accounts DESC
GO

-- 12. Romantic Getaways
SELECT a.Id, a.Email, c.[Name] AS City, COUNT(*) AS Trips
FROM Accounts AS a
INNER JOIN AccountsTrips AS atr ON atr.AccountId = a.Id
INNER JOIN Trips AS t ON t.Id = atr.TripId
INNER JOIN Rooms AS r ON r.Id = t.RoomId
INNER JOIN Hotels AS h ON h.Id = r.HotelId
INNER JOIN Cities AS c ON c.Id = h.CityId
WHERE a.CityId = h.CityId
GROUP BY a.Id, a.Email, c.[Name]
ORDER BY Trips DESC, a.Id ASC
GO

-- 13. Lucrative Destinations 
SELECT TOP(10) c.Id, c.[Name], SUM(h.BaseRate + r.Price) AS [Total Revenue], COUNT(t.Id) AS Trips
FROM Cities AS c
INNER JOIN Hotels AS h ON h.CityId = c.Id
INNER JOIN Rooms AS r ON r.HotelId = h.Id
INNER JOIN Trips AS t ON t.RoomId = r.Id
WHERE DATEPART(YEAR, t.BookDate) = 2016
GROUP BY c.Id, c.[Name]
ORDER BY [Total Revenue] DESC, Trips DESC
GO

-- 14. Trip Revenues 
SELECT t.Id, h.[Name] AS HotelName, r.[Type] AS RoomType,
    CASE 
        WHEN t.CancelDate IS NULL THEN SUM(h.BaseRate + r.Price)
        ELSE 0
    END AS Revenue
FROM Trips AS t
INNER JOIN Rooms AS r ON r.Id = t.RoomId
INNER JOIN Hotels AS h ON h.Id = r.HotelId
INNER JOIN AccountsTrips AS atr ON atr.TripId = t.Id
GROUP BY t.Id, h.[Name], r.[Type], t.CancelDate
ORDER BY r.[Type], t.Id
GO

-- 15. Top Travelers
SELECT AccountId, Email, CountryCode, Trips
FROM (SELECT A.Id AS AccountId, A.Email, C.CountryCode, COUNT(*) AS Trips,
        DENSE_RANK() OVER ( PARTITION BY C.CountryCode ORDER BY COUNT(*) DESC, A.Id ) AS Rank
      FROM Accounts AS a
      INNER  JOIN AccountsTrips atr ON a.Id = atr.AccountId
      INNER  JOIN Trips t ON atr.TripId = t.Id
      INNER  JOIN Rooms r ON t.RoomId = r.Id
      INNER  JOIN Hotels h ON r.HotelId = h.Id
      INNER  JOIN Cities c ON h.CityId = c.Id
      GROUP BY c.CountryCode, a.Email, a.Id) AS RanksPerCountry
WHERE Rank = 1
ORDER BY Trips DESC, AccountId
GO

-- 16. Luggage Fees 
SELECT TripId, SUM(Luggage) AS Luggage,
    CASE
        WHEN SUM(Luggage) > 5 THEN CONCAT('$', SUM(Luggage * 5))
        ELSE CONCAT('$', 0)
    END AS Fee
FROM AccountsTrips
WHERE Luggage > 0
GROUP BY TripId
ORDER BY SUM(Luggage) DESC
GO

-- 17. GDPR Violation
SELECT 
    t.Id, 
    CONCAT(FirstName, ' ' + MiddleName, ' ' ,LastName) AS [Full Name],
    c.[Name] AS [From],
    ci.Name AS [To],
    CASE
        WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
        ELSE CONCAT(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' ','days') 
    END AS [Duration]   
FROM Trips AS t
INNER JOIN AccountsTrips AS atr ON atr.TripId = t.Id
INNER JOIN Accounts AS a ON a.Id = atr.AccountId
INNER JOIN Cities AS c ON c.Id = a.CityId
INNER JOIN Rooms AS r ON r.Id = t.RoomId
INNER JOIN Hotels AS h ON h.Id = r.HotelId
INNER JOIN Cities AS ci ON ci.Id = h.CityId
ORDER BY [Full Name] ASC, t.Id ASC
GO

--18. Available Room 
CREATE FUNCTION udf_GetAvailableRoom (@HotelId INT, @Date DATE, @People INT)
RETURNS VARCHAR(MAX)
BEGIN
    DECLARE @BookedRooms TABLE(Id INT)
    INSERT INTO @BookedRooms
    SELECT DISTINCT r.Id
    FROM Rooms AS r
    LEFT JOIN Trips t ON r.Id = t.RoomId
    WHERE r.HotelId = @HotelId AND @Date BETWEEN t.ArrivalDate AND t.ReturnDate AND t.CancelDate IS NULL

    DECLARE @Rooms TABLE(Id INT, Price DECIMAL(15, 2), Type VARCHAR(20), Beds INT, TotalPrice DECIMAL(15, 2))
    INSERT INTO @Rooms
    SELECT TOP 1 r.Id, r.Price, r.Type, r.Beds, @People * (H.BaseRate + R.Price) AS TotalPrice
    FROM Rooms AS r
    LEFT JOIN Hotels h on r.HotelId = h.Id
    WHERE r.HotelId = @HotelId 
    AND r.Beds >= @People 
    AND r.Id NOT IN (SELECT Id
                     FROM @BookedRooms)
    ORDER BY TotalPrice DESC

    DECLARE @RoomCount INT = (SELECT COUNT(*)
                              FROM @Rooms)
    IF (@RoomCount < 1)
      BEGIN
        RETURN 'No rooms available'
      END

    DECLARE @Result VARCHAR(MAX) = (SELECT CONCAT('Room ', Id, ': ', Type, ' (', Beds, ' beds) - ', '$', TotalPrice)
                                    FROM @Rooms)

    RETURN @Result
END
GO

--19. Switch Room
CREATE PROCEDURE usp_SwitchRoom(@TripId INT, @TargetRoomId INT) AS
BEGIN

    DECLARE @TripHotelId INT = (SELECT h.Id
                                FROM Hotels AS h
                                INNER JOIN Rooms r on h.Id = r.HotelId
                                INNER JOIN Trips t on r.Id = t.RoomId
                                WHERE t.Id = @TripId)

    DECLARE @TargetHotelId INT = (SELECT h.Id
                                  FROM Hotels h
                                  INNER JOIN Rooms r on h.Id = r.HotelId
                                  WHERE r.Id = @TargetRoomId)

    IF (@TripHotelId <> @TargetHotelId)
    BEGIN
        RAISERROR('Target room is in another hotel!', 16, 1)
    END

    DECLARE @PeopleCount INT = (SELECT COUNT(*) 
                                FROM AccountsTrips 
                                WHERE TripId = @TripId)
    
    DECLARE @BedsCount INT = (SELECT Beds
                              FROM Rooms
                              WHERE Id = @TargetRoomId)

    IF (@PeopleCount > @BedsCount)
    BEGIN
        RAISERROR('Not enough beds in target room!', 16, 1)
    END                         
    
    UPDATE Trips
    SET RoomId = @TargetRoomId
    WHERE Id = @TripId
END
GO

-- 20. Cancel Trip
CREATE TRIGGER T_CancelTrip ON Trips
INSTEAD OF DELETE AS
BEGIN
    UPDATE Trips
    SET CancelDate = GETDATE()
    WHERE Id IN (SELECT Id
                 FROM deleted
                 WHERE CancelDate IS NULL)
END