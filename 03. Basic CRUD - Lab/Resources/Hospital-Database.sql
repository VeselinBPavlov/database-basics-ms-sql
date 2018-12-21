USE master
GO

CREATE DATABASE Hospital ON PRIMARY
   ( NAME = N'Hospital_Data', FILENAME = N'D:\Courses\Data\Hospital_Data.mdf' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
LOG ON
   ( NAME = N'Hospital_Log', FILENAME = N'D:\Courses\Data\Hospital_Log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE Hospital
GO

CREATE TABLE Departments (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50)
);

INSERT INTO Departments
	([Name]) 
VALUES
	('Therapy'), 
	('Support'), 
	('Management'), 
	('Other');

CREATE TABLE Employees (
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(50) NOT NULL,
	[LastName] VARCHAR(50) NOT NULL,
	[JobTitle] VARCHAR(50) NOT NULL,
	[DepartmentId] INT NOT NULL,
	[Salary] DECIMAL(15, 2) NOT NULL,
	CONSTRAINT fk_DepartmentId FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

INSERT INTO Employees 
	([FirstName], [LastName], [JobTitle], [DepartmentId], [Salary]) 
VALUES
	('John', 'Smith', 'Therapist',1, 900.00),
	('John', 'Johnson', 'Acupuncturist',1, 880.00),
	('Smith', 'Johnson', 'Technician',2, 1100.00),
	('Peter', 'Petrov', 'Supervisor',3, 1100.00),
	('Peter', 'Ivanov', 'Dentist',4, 1500.23),
	('Ivan' ,'Petrov', 'Therapist',1, 990.00),
	('Jack', 'Jackson', 'Epidemiologist',4, 1800.00),
	('Pedro', 'Petrov', 'Medical Director',3, 2100.00),
	('Nikolay', 'Ivanov', 'Nutrition Technician',4, 1600.00);
	
CREATE TABLE Rooms (
	[Id] INT PRIMARY KEY IDENTITY,
	[Occupation] VARCHAR(30)
);

INSERT INTO Rooms
	([Occupation]) 
VALUES
	('Free'), 
	('Occupied'),
	('Free'),
	('Free'),
	('Occupied');

CREATE TABLE Patients (
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(50),
	[LastName] VARCHAR(50),
	[RoomId] INT NOT NULL
);

INSERT INTO Patients
	([FirstName], [LastName], [RoomId]) 
VALUES
	('Pesho','Petrov',1),
	('Gosho','Georgiev',3),
	('Mariya','Marieva', 2), 
	('Katya','Katerinova', 2), 
	('Nikolay','Nikolaev',3);