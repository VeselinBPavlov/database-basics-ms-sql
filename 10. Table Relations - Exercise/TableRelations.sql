USE [master]
GO

CREATE DATABASE TableRelations ON PRIMARY
   ( NAME = N'TableRelations_Data', FILENAME = N'D:\Courses\Data\TableRelations_Data.mdf' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
LOG ON
   ( NAME = N'TableRelations_Log', FILENAME = N'D:\Courses\Data\TableRelations_Log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE TableRelations
GO

-- 1. One-To-One Relationship 
CREATE TABLE Passports (
	PassportID INT IDENTITY(101, 1) NOT NULL,
	PassportNumber NVARCHAR(50)

	CONSTRAINT PK_PassportID
	PRIMARY KEY (PassportID)
)

CREATE TABLE Persons (
	PersonID INT IDENTITY NOT NULL,
	FirstName VARCHAR(50) NOT NULL,
	Salary DECIMAL(15, 2),
	PassportID INT,

	CONSTRAINT FK_Persons_Passports
	FOREIGN KEY (PassportID) 
	REFERENCES Passports(PassportID)
)

ALTER TABLE Persons 
ADD PRIMARY KEY(PersonID)

INSERT INTO Passports
	([PassportNumber])
VALUES
	('N34FG21B'), 
	('K65LO4R7'), 
	('ZE657QP2')

INSERT INTO Persons 
	([FirstName], [Salary], [PassportId])
VALUES
	('Roberto', 43300.00, 102),
	('Tom', 56100.00, 103),
	('Yana', 60200.00, 101)
GO

-- 2. One-To-Many Relationship 
CREATE TABLE Manufacturers (
	[ManufacturerID] INT IDENTITY NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	[EstablishedOn] DATE,

	CONSTRAINT PK_ManufacturerID
	PRIMARY KEY (ManufacturerID)
)

CREATE TABLE Models (
	[ModelID] INT IDENTITY NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	[ManufacturerID] INT,

	CONSTRAINT PK_ModelID
	PRIMARY KEY (ModelID),

	CONSTRAINT FK_Models_Manufacturers
	FOREIGN KEY (ManufacturerID)
	REFERENCES Manufacturers(ManufacturerID)
)

INSERT INTO Manufacturers 
	([Name], [EstablishedOn])
VALUES
	('BMW', '1916-03-07'),
	('Tesla', '2003-01-01'),
	('Lada', '1966-05-01')

INSERT INTO Models 
	([Name], [ManufacturerID])
VALUES
	('X1', '1'),
	('i6', '1'),
	('Model S', '2'),
	('Model X', '2'),
	('Model 3', '2'),
	('Nova', '3')
GO

-- 3. Many-To-Many Relationship
CREATE TABLE Students (
	[StudentID] INT IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_StudentID
	PRIMARY KEY (StudentID)
)

CREATE TABLE Exams (
	[ExamID] INT IDENTITY(101, 1) NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_ExamID
	PRIMARY KEY (ExamID)
)

CREATE TABLE StudentsExams (
	[StudentID] INT NOT NULL,
	[ExamID] INT NOT NULL,

	CONSTRAINT PK_Students_Exams
	PRIMARY KEY (StudentID, ExamID),

	CONSTRAINT FK_StudentsExams_Students
	FOREIGN KEY (StudentID)
	REFERENCES Students(StudentID),

	CONSTRAINT FK_StudentsExams_Exams
	FOREIGN KEY (ExamID)
	REFERENCES Exams(ExamID)
)

INSERT INTO Students 
	([Name])
VALUES
	('Mila'), 
	('Toni'), 
	('Ron')

INSERT INTO Exams 
	([Name])
VALUES
	('SpringMVC'), 
	('Neo4j'), 
	('Oracle 11g')

INSERT INTO StudentsExams 
	([StudentID], [ExamID])
VALUES
	(1, 101),
	(1, 102),
	(2, 101),
	(3, 103),
	(2, 102),
	(2, 103)
GO

-- 4. Self-Referencing
CREATE TABLE Teachers (
	[TeacherID] INT IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	[ManagerID] INT,

	CONSTRAINT PK_TeacherId
	PRIMARY KEY (TeacherId),

	CONSTRAINT FK_TeacharID_ManagerID
	FOREIGN KEY (ManagerID)
	REFERENCES Teachers (TeacherID)
)
GO

-- 5. Online Store Database
CREATE TABLE Cities (
	[CityID] INT IDENTITY NOT NULL,
	[Name] VARCHAR(50),

	CONSTRAINT PK_CityID
	PRIMARY KEY (CityID)
)

CREATE TABLE Customers (
	[CustomerID] INT IDENTITY NOT NULL,
	[Name] VARCHAR(50),
	[Birthday] DATE,
	[CityID] INT,

	CONSTRAINT PK_CustomerID
	PRIMARY KEY (CustomerID),

	CONSTRAINT FK_Customers_Cities
	FOREIGN KEY (CityID)
	REFERENCES Cities(CityID)
)

CREATE TABLE Orders (
	[OrderID] INT IDENTITY NOT NULL,
	[CustomerID] INT,

	CONSTRAINT PK_OrderID
	PRIMARY KEY (OrderID),

	CONSTRAINT FK_Orders_Customers
	FOREIGN KEY (CustomerID)
	REFERENCES Customers(CustomerID)
)

CREATE TABLE ItemTypes (
	[ItemTypeID] INT IDENTITY NOT NULL,
	[Name] VARCHAR(50)

	CONSTRAINT PK_ItemTypeID
	PRIMARY KEY (ItemTypeID)
)

CREATE TABLE Items (
	[ItemID] INT IDENTITY NOT NULL,
	[Name] VARCHAR(50),
	[ItemTypeID] INT,

	CONSTRAINT PK_ItemID
	PRIMARY KEY (ItemID),

	CONSTRAINT FK_Items_ItemTypes
	FOREIGN KEY (ItemTypeID)
	REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE OrderItems (
	[OrderID] INT NOT NULL,
	[ItemID] INT NOT NULL,

	CONSTRAINT PK_OrderID_ItemID
	PRIMARY KEY (OrderID, ItemID),

	CONSTRAINT FK_OrderItems_Orders
	FOREIGN KEY (OrderID)
	REFERENCES Orders(OrderID),

	CONSTRAINT FK_OrderItems_Items
	FOREIGN KEY (ItemID)
	REFERENCES Items(ItemID)
)
GO

-- 6. University Database
CREATE TABLE Majors (
	[MajorID] INT IDENTITY NOT NULL,
	[Name] VARCHAR(50)

	CONSTRAINT PK_MajorID
	PRIMARY KEY (MajorID)
)

CREATE TABLE Students (
	[StudentID] INT IDENTITY NOT NULL,
	[StudentNumber] VARCHAR(50),
	[StudentName] VARCHAR(50),
	[MajorID] INT,

	CONSTRAINT PK_StudentID
	PRIMARY KEY (StudentID),

	CONSTRAINT FK_Students_Majors
	FOREIGN KEY (MajorID)
	REFERENCES Majors(MajorID)
)

CREATE TABLE Payments (
	[PaymentID] INT IDENTITY NOT NULL,
	[PaymentDate] DATE,
	[PaymentAmount] DECIMAL(15, 2),
	[StudentID] INT

	CONSTRAINT PK_PaymentID
	PRIMARY KEY (PaymentID),

	CONSTRAINT FK_Payments_Students
	FOREIGN KEY (StudentID)
	REFERENCES Students(StudentID)
)

CREATE TABLE Subjects (
	[SubjectID] INT IDENTITY NOT NULL,
	[SubjectName] VARCHAR(50),

	CONSTRAINT PK_SubjectID
	PRIMARY KEY (SubjectID)
)

CREATE TABLE Agenda (
	[StudentID] INT NOT NULL,
	[SubjectID] INT NOT NULL,

	CONSTRAINT PK_StudentID_SubjectID
	PRIMARY KEY (StudentID, SubjectID),

	CONSTRAINT FK_Agenda_Students
	FOREIGN KEY (StudentID)
	REFERENCES Students(StudentID),

	CONSTRAINT FK_Agenda_Subjects
	FOREIGN KEY (SubjectID)
	REFERENCES Subjects(SubjectID)
)


-- 7. SoftUni Design
-- Create an E/R Diagram of the SoftUni Database.

-- 8. Geography Design
--Create an E/R Diagram of the Geography Database.

-- 9. Peaks in Rila
USE [Geography]
GO

SELECT MountainRange, PeakName, Elevation
FROM Peaks AS p
JOIN Mountains AS m
ON m.Id = p.MountainId
WHERE m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC