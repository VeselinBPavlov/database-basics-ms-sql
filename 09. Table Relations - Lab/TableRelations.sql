USE Camp
GO

-- 1. Mountains and Peaks
CREATE TABLE Mountains (
	[Id] INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,

	CONSTRAINT Pk_MountainId
	PRIMARY KEY (Id)
)

CREATE TABLE Peaks (
	[Id] INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	[MountainId] INT NOT NULL,

	CONSTRAINT Pk_PeakId
	PRIMARY KEY (Id),

	CONSTRAINT Fk_Peaks_Mountains
	FOREIGN KEY (MountainId) REFERENCES Mountains(Id)
)

-- 2. Trip Organization
SELECT DriverId, VehicleType, CONCAT(FirstName, ' ', LastName) AS DriverName
FROM Vehicles AS v
JOIN Campers AS c
ON v.DriverId = c.Id

-- 3. SoftUni Hiking
SELECT [StartingPoint], [EndPoint], [LeaderId], CONCAT(FirstName, ' ', LastName) AS LeaderName
FROM [Routes] AS r
JOIN [Campers] AS c
ON r.LeaderId = c.Id

-- 4. Project Management DB
USE [master]
GO

CREATE DATABASE ProjectDBManagement ON PRIMARY
   ( NAME = N'ProjectDBManagement_Data', FILENAME = N'D:\Courses\Data\ProjectDBManagement_Data.mdf' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
LOG ON
   ( NAME = N'ProjectDBManagement_Log', FILENAME = N'D:\Courses\Data\ProjectDBManagement_Log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE ProjectDBManagement
GO

CREATE TABLE Projects (
	[Id] INT NOT NULL,
	[ClientId] INT NOT NULL,
	[ProjectLeadId] INT NOT NULL

	CONSTRAINT Pk_ProjectId
	PRIMARY KEY (Id) IDENTITY
)

CREATE TABLE Employees (
	[Id] INT NOT NULL,
	[FirstName] VARCHAR(30) NOT NULL,
	[LastName] VARCHAR(30) NOT NULL,
	[ProjectId] INT NOT NULL

	CONSTRAINT Pk_EmployeeId
	PRIMARY KEY (Id) IDENTITY
)

ALTER TABLE Projects
ADD CONSTRAINT Fk_Projects_Employees
FOREIGN KEY (ProjectLeadId) REFERENCES Employees(Id)

ALTER TABLE Employees
ADD CONSTRAINT Fk_Employees_Projects
FOREIGN KEY (ProjectId) REFERENCES Projects(Id)

CREATE TABLE Clients (
	[Id] INT NOT NULL,
	[ClinetName] VARCHAR(100) NOT NULL,
	[ProjectId] INT NOT NULL,

	CONSTRAINT Pk_ClientId
	PRIMARY KEY (Id) ,

	CONSTRAINT Fk_Clients_Projects
	FOREIGN KEY (ProjectId) REFERENCES Projects(Id)
)

ALTER TABLE Projects
ADD CONSTRAINT Fk_Projects_Clients
FOREIGN KEY (ClientId) REFERENCES Clients(Id)