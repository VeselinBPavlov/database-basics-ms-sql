USE [master]
GO

CREATE DATABASE Camp ON PRIMARY
   ( NAME = N'Camp_Data', FILENAME = N'D:\Courses\Data\Camp_Data.mdf' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
LOG ON
   ( NAME = N'Camp_Log', FILENAME = N'D:\Courses\Data\Camp_Log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE Camp
GO

CREATE TABLE Rooms (
	[Id] INT PRIMARY KEY,
	[Occupation] VARCHAR(20) NOT NULL,
	[BedsCount] INT NOT NULL
)

CREATE TABLE Vehicles (
	[Id] INT PRIMARY KEY IDENTITY NOT NULL,
	[DriverId] INT NOT NULL,
	[VehicleType] VARCHAR(30) NOT NULL,
	[Passengers] INT NOT NULL
)

CREATE TABLE Campers (
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(20) NOT NULL,
	[LastName] VARCHAR(20) NOT NULL,
	[Age] INT NOT NULL,
	[Room] INT,
	[VehicleId] INT,

	CONSTRAINT Fk_Campers_Rooms
	FOREIGN KEY(Room) REFERENCES Rooms(Id),

  	CONSTRAINT Fk_Campers_Vehicles
	FOREIGN KEY(VehicleId) REFERENCES Vehicles(Id) ON DELETE CASCADE
)

CREATE TABLE [Routes] (
	[Id] INT PRIMARY KEY IDENTITY,
	[StartingPoint] VARCHAR(30) NOT NULL,
	[EndPoint] VARCHAR(30) NOT NULL,
	[LeaderId] INT NOT NULL,
	[RouteTime] TIME NOT NULL,	

	CONSTRAINT Fk_Routes_Campers
	FOREIGN KEY(LeaderId) REFERENCES Campers(Id)
)

INSERT INTO Rooms
	([Id], [Occupation],[BedsCount]) 
VALUES
	(101,'occupied',3),
	(102,'free',3),
	(103,'free',3),
	(104,'free',2),
	(105,'free',2),
	(201,'free',3),
	(202,'free',3),
	(203,'free',2),
	(204,'free',3),
	(205,'free',3),
	(301,'free',2),
	(302,'free',2),
	(303,'free',2),
	(304,'free',3),
	(305,'free',3)

INSERT INTO Campers
	([FirstName], [LastName], [Age], [Room]) 
VALUES
	('Simo', 'Sheytanov', 20,101),
	('Roli', 'Dimitrova', 27,102),
	('RoYaL', 'Yonkov', 25,301),
	('Ivan', 'Ivanov', 28,301),
	('Alisa', 'Terzieva', 25,102),
	('Asya', 'Ivanova', 26,102),
	('Dimitar', 'Verbov', 21,301),
	('Iskren', 'Ivanov', 28,302),
	('Bojo', 'Gevechanov', 28,302)

INSERT INTO vehicles
	([DriverId], [VehicleType], [Passengers]) 
VALUES
	(1,'bus',20),
	(2,'van',10),
	(1,'van',10),
	(4,'car',5),
	(5,'car',5),
	(6,'car',4),
	(7,'car',3),
	(8,'bus',3)

INSERT INTO [Routes]
	([StartingPoint], [EndPoint], [LeaderId], [RouteTime]) 
VALUES
	('Hotel Malyovitsa', 'Malyovitsa Peak', 3, '02:00:00'),
	('Hotel Malyovitsa', 'Malyovitsa Hut', 3, '00:40:00'),
	('Ribni Ezera Hut', 'Rila Monastery', 3, '06:00:00'),
	('Borovets', 'Musala Peak', 4, '03:30:00')