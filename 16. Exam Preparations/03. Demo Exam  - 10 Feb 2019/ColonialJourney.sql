-- Section 1. DDL (30 pts)
USE [master]
GO

CREATE DATABASE ColonialJourney ON PRIMARY
   ( NAME = N'ColonialJourney_Data', FILENAME = N'D:\Courses\Data\ColonialJourney_Data.mdf' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
LOG ON
   ( NAME = N'ColonialJourney_Log', FILENAME = N'D:\Courses\Data\ColonialJourney_Log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE ColonialJourney
GO

-- 01. Database Design
CREATE TABLE Planets (
    Id INT PRIMARY KEY IDENTITY,
    [Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceships (
    Id INT PRIMARY KEY IDENTITY,
    [Name] VARCHAR(50) NOT NULL,
    Manufacturer VARCHAR(30) NOT NULL,
    LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists (
    Id INT PRIMARY KEY IDENTITY,
    FirstName VARCHAR(20) NOT NULL,
    LastName VARCHAR(20) NOT NULL,
    Ucn VARCHAR(10) UNIQUE NOT NULL,
    BirthDate DATE NOT NULL
)

CREATE TABLE Spaceports (
    Id INT PRIMARY KEY IDENTITY,
    [Name] VARCHAR(50) NOT NULL,
    PlanetId INT NOT NULL FOREIGN KEY REFERENCES Planets(Id)   
)

CREATE TABLE Journeys (
    Id INT PRIMARY KEY IDENTITY,
    JourneyStart DATETIME NOT NULL,
    JourneyEnd DATETIME NOT NULL,
    Purpose VARCHAR(11) CHECK (Purpose IN ('Medical', 'Technical', 'Educational', 'Military')),
    DestinationSpaceportId INT NOT NULL FOREIGN KEY REFERENCES Spaceports(Id),
    SpaceshipId INT NOT NULL FOREIGN KEY REFERENCES Spaceships(Id)
)

CREATE TABLE TravelCards (
    Id INT PRIMARY KEY IDENTITY,
    CardNumber CHAR(10) NOT NULL UNIQUE,
    JobDuringJourney VARCHAR(8) CHECK (JobDuringJourney IN ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
    ColonistId INT NOT NULL FOREIGN KEY REFERENCES Colonists(Id),
    JourneyId INT NOT NULL FOREIGN KEY REFERENCES Journeys(Id)
)
GO

-- Section 2. DML (10 pts)
-- 02. Insert
INSERT INTO Planets
    ([Name])
VALUES
    ('Mars'),
    ('Earth'),
    ('Jupiter'),
    ('Saturn')

INSERT INTO Spaceships 
    ([Name], [Manufacturer], [LightSpeedRate])
VALUES
    ('Golf', 'VW', 3),
    ('WakaWaka', 'Wakanda', 4),
    ('Falcon9', 'SpaceX', 1),
    ('Bed', 'Vidolov', 6)
GO

-- 03. Update
UPDATE Spaceships
SET LightSpeedRate += 1
WHERE Id BETWEEN 8 AND 12
GO

-- 04. Delete
DELETE 
FROM TravelCards
WHERE JourneyId BETWEEN 1 AND 3

DELETE
FROM Journeys
WHERE Id BETWEEN 1 AND 3
GO

-- Section 3. Querying (40 pts)

-- 05. Select All Travel Cards
SELECT CardNumber, JobDuringJourney
FROM TravelCards
ORDER BY CardNumber ASC
GO

-- 06. Select All Colonists
SELECT Id, CONCAT(FirstName, ' ', LastName) AS FullName, Ucn
FROM Colonists
ORDER BY FirstName ASC, LastName ASC, Id ASC
GO

-- 07. Select All Military Journeys 
SELECT Id, FORMAT(JourneyStart, 'dd/MM/yyyy') AS JourneyStart, FORMAT(JourneyEnd, 'dd/MM/yyyy') AS JourneyEnd
FROM Journeys
WHERE Purpose = 'Military'
ORDER BY JourneyStart ASC
GO

-- 08. Select All Pilots
SELECT c.Id, CONCAT(FirstName, ' ', LastName) AS FullName
FROM TravelCards AS t
JOIN Colonists AS c ON c.Id = t.ColonistId
WHERE JobDuringJourney = 'Pilot'
ORDER BY c.Id ASC
GO

-- 09. Count Colonists 
SELECT COUNT(c.Id) AS [Count]
FROM Journeys AS j
JOIN TravelCards AS t ON t.JourneyId = j.Id
JOIN Colonists AS c ON c.Id = t.ColonistId
WHERE j.Purpose = 'Technical'
GO

-- 10. Select The Fastest Spaceship
SELECT TOP(1) sp.[Name] AS SpaceShipName, spp.[Name] AS SpaceportName
FROM Spaceships AS sp
JOIN Journeys AS j ON j.SpaceshipId = sp.Id
JOIN Spaceports AS spp ON spp.Id = j.DestinationSpaceportId
ORDER BY LightSpeedRate DESC
GO

-- 11. Select Spaceships With Pilots younger than 30 years
SELECT s.[Name], s.Manufacturer
FROM TravelCards AS t
JOIN Colonists AS c ON c.Id = t.ColonistId
JOIN Journeys AS j ON j.Id = t.JourneyId
JOIN Spaceships AS s ON s.Id = j.SpaceshipId
WHERE DATEDIFF(YEAR, c.BirthDate, '2019/01/01') < 30
AND t.JobDuringJourney = 'Pilot'
ORDER BY s.[Name] ASC
GO

--12.  Select all educational mission planets and spaceports
SELECT p.[Name] AS PlanetName, s.[Name] AS SpaceportName
FROM Planets AS p
JOIN Spaceports AS s ON s.PlanetId = p.Id
JOIN Journeys AS j ON j.DestinationSpaceportId = s.Id
WHERE j.Purpose = 'Educational'
ORDER BY s.[Name] DESC
GO

-- 13. Planets And Journeys
SELECT p.[Name] AS PlanetName, COUNT(j.Id) AS JourneysCount
FROM Planets AS p
JOIN Spaceports AS s ON s.PlanetId = p.Id
JOIN Journeys AS j ON j.DestinationSpaceportId = s.Id
GROUP BY p.[Name]
ORDER BY JourneysCount DESC, p.[Name] ASC
GO

-- 14. Extract The Shortest Journey 
SELECT TOP(1) j.Id, p.[Name] AS PlanetName, s.[Name] AS SpaceshipName, j.Purpose AS JourneyPurpose
FROM Journeys AS j
JOIN Spaceports AS s ON s.Id = j.DestinationSpaceportId
JOIN Planets AS p ON p.Id = s.PlanetId
ORDER BY j.JourneyEnd - j.JourneyStart ASC
GO

-- 15. Select The Less Popular Job
SELECT TOP(1) tc.JourneyId, tc.JobDuringJourney AS JobName
FROM TravelCards AS tc
WHERE tc.JourneyId = (SELECT TOP(1) j.Id FROM Journeys AS j ORDER BY DATEDIFF(MINUTE, j.JourneyStart, j.JourneyEnd) DESC)
GROUP BY tc.JobDuringJourney, tc.JourneyId
ORDER BY COUNT(tc.JobDuringJourney) ASC
GO

-- 16. Select Second Oldest Important Colonist
SELECT t.JobDuringJourney, 
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName, e.Ranks AS JobRank    
FROM (
    SELECT t.Id AS TravelId, t.JobDuringJourney, c.FirstName, c.LastName, RANK() OVER (PARTITION BY t.JobDuringJourney ORDER BY c.BirthDate ASC) AS Ranks
    FROM TravelCards AS t
    JOIN Journeys AS j ON j.Id = t.JourneyId  
    JOIN Colonists AS c ON c.Id = t.ColonistId     
) AS e
JOIN TravelCards AS t ON t.Id = e.TravelId
JOIN Journeys AS j ON j.Id = t.JourneyId
JOIN Colonists AS c ON c.Id = t.ColonistId
GROUP BY t.JobDuringJourney, e.Ranks, c.FirstName, c.LastName
HAVING e.Ranks = 2
GO

-- 17. Planets and Spaceports
SELECT p.[Name], COUNT(s.Id) AS [Count]
FROM Planets AS p
LEFT JOIN Spaceports AS s ON s.PlanetId = p.Id
GROUP BY p.[Name]
ORDER BY [Count] DESC, p.[Name] ASC
GO

-- 18. Get Colonists Count
CREATE FUNCTION dbo.udf_GetColonistsCount(@PlanetName VARCHAR (30))
RETURNS INT 
AS
BEGIN
RETURN (SELECT COUNT(*) FROM Journeys AS j
	JOIN Spaceports AS s ON s.Id = j.DestinationSpaceportId
	JOIN Planets AS p ON p.Id = s.PlanetId
	JOIN TravelCards AS tc ON tc.JourneyId = j.Id
	JOIN Colonists AS c ON c.Id = tc.ColonistId
	WHERE p.Name = @PlanetName)
END
GO


SELECT dbo.udf_GetColonistsCount('Otroyphus')
GO

-- 19. Change Journey Purpose
CREATE PROCEDURE usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11)) AS
BEGIN
    DECLARE @Journey INT = (SELECT Id FROM Journeys WHERE Id = @JourneyId);    

    IF (@Journey IS NULL)
    BEGIN
        RAISERROR('The journey does not exist!', 16, 1)
    END

    DECLARE @Purpose VARCHAR(11) = (SELECT Purpose FROM Journeys WHERE @JourneyId = Id)

    IF (@Purpose = @NewPurpose)
    BEGIN
        RAISERROR('You cannot change the purpose!', 16, 1)
    END

    UPDATE Journeys
    SET Purpose = @NewPurpose
    WHERE Id = @JourneyId
END
GO

-- 20. Deleted Journeys 
CREATE TABLE DeletedJourneys (
    Id INT PRIMARY KEY IDENTITY,
    JourneyStart DATETIME NOT NULL,
    JourneyEnd DATETIME NOT NULL,
    Purpose VARCHAR(11),
    DestinationSpaceportId INT NOT NULL FOREIGN KEY REFERENCES Spaceports(Id),
    SpaceshipId INT NOT NULL FOREIGN KEY REFERENCES Spaceships(Id)
)
GO

CREATE TRIGGER tr_DeletedJourneys ON Journeys
AFTER DELETE AS
BEGIN
	INSERT INTO DeletedJourneys
	SELECT Id, JourneyStart, JourneyEnd, Purpose, DestinationSpaceportId, SpaceshipId
	FROM deleted
END
GO