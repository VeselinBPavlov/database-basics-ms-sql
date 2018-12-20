USE master
GO

--1. Create Database
CREATE DATABASE Minions
GO

USE Minions
GO

--2. Create Tables
CREATE TABLE Minions (
	Id INT PRIMARY KEY,
	[Name] NVARCHAR(50) NOT NULL,
	Age INT
)

CREATE TABLE Towns (
	Id INT PRIMARY KEY,
	[Name] NVARCHAR(50) NOT NULL
)
GO

--3. Alter Minions Table
ALTER TABLE Minions
ADD TownId INT FOREIGN KEY REFERENCES Towns(Id);
GO

--4. Insert Records in Both Tables
INSERT INTO Towns
	([Id], [Name])
VALUES
	(1, 'Sofia'),
	(2, 'Plovdiv'),
	(3, 'Varna')

INSERT INTO Minions
	([Id], [Name], [Age], [TownId])
VALUES
	(1, 'Kevin', 22, 1),
	(2, 'Bob', 15, 3),
	(3, 'Steward', NULL, 2)
GO

--5. Truncate Table Minions
TRUNCATE TABLE Minions
GO 

--6. Drop All Tables
DROP TABLE Minions
DROP TABLE Towns
GO

--7. Create Table People
CREATE TABLE People (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX),
	Height DECIMAL(5,2),
	[Weight] DECIMAL(5,2),
	Gender char(1) NOT NULL CHECK(Gender='m' OR Gender='f'),
	Birthdate DATE NOT NULL,
	Biography NVARCHAR(MAX)
)

INSERT INTO People
	([Name], [Picture], [Height], [Weight] , [Gender], [Birthdate], [Biography]) 
VALUES
	('Pesho',Null,1.65,44.55,'f','2000-09-22',Null),
	('Gosho',Null,2.15,95.55,'m','1989-11-02',Null),
	('Tosho',Null,1.55,33.00,'m','2010-04-11',Null),
	('Sasho',Null,2.15,55.55,'f','2001-11-11',Null),
	('Misho',Null,1.85,90.00,'m','1983-07-22',Null)
GO

--8. Create Table Users
CREATE TABLE Users (
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) UNIQUE NOT NULL,
	[Password] BINARY(26) NOT NULL,
	ProfilePicture VARBINARY(MAX),
	LastLoginTime DATETIME2,
	IsDeleted BIT
)

INSERT INTO Users
	([Username], [Password], [ProfilePicture], [LastLoginTime], [IsDeleted])
VALUES
	('Pesho', HASHBYTES('SHA1', '123'), NULL, CONVERT(DATETIME, '01-01-2018', 103), 0),
	('Gosho',  HASHBYTES('SHA1', '123'), NULL, CONVERT(DATETIME, '01-02-2018', 103), 0),
	('Tosho',  HASHBYTES('SHA1', '123'), NULL, CONVERT(DATETIME, '01-03-2018', 103), 0),
	('Sasho',  HASHBYTES('SHA1', '123'), NULL, CONVERT(DATETIME, '01-04-2018', 103), 0),
	('Misho',  HASHBYTES('SHA1', '123'), NULL, CONVERT(DATETIME, '01-05-2018', 103), 0)

ALTER TABLE Users
ADD CONSTRAINT CHK_ProfilePicture 
CHECK (DATALENGTH(ProfilePicture) <= 900 * 1024)
GO

--9. Change Primary Key
ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC07BC68F74B

ALTER TABLE Users
ADD CONSTRAINT PK_Users PRIMARY KEY (Id, Username)
GO

--10. Add Check Constraint
ALTER TABLE Users
ADD CONSTRAINT CHK_Password
CHECK (LEN([Password]) < 5)
GO

--11. Set Default Value of a Field
ALTER TABLE Users
ADD DEFAULT GETDATE() FOR LastLoginTime
GO

--12. Set Unique Field
ALTER TABLE Users
DROP CONSTRAINT PK_Users

ALTER TABLE Users
ADD CONSTRAINT CHK_Username
CHECK (LEN(Username) >= 3)
GO

--13. Movies Database
CREATE DATABASE Movies
GO

USE Movies
GO

CREATE TABLE Directors (
	Id INT PRIMARY KEY IDENTITY,
	DirectorName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Genres (
	Id INT PRIMARY KEY IDENTITY,
	GenreName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Movies (
	Id INT PRIMARY KEY IDENTITY,
	Title NVARCHAR(50) NOT NULL,
	DirectorId INT,
	CopyrightYear SMALLINT,
	[Length] INT,
	GenreId INT,
	CategoryId INT,
	Rating INT,
	Notes NVARCHAR(MAX)
)

INSERT INTO Directors
	([DirectorName], [Notes])
VALUES
	('Peter Jackson', NULL),
	('Michael Bay', NULL),
	('Quentin Tarantino', NULL),
	('James Cameron', NULL),
	('Steven Spielberg', NULL)

INSERT INTO Genres 
	([GenreName], [Notes])
VALUES
	('Action', NULL),
	('Comedy', NULL),
	('Crime', NULL),
	('Drama', NULL),
	('Fantasy', NULL)

INSERT INTO Categories
	([CategoryName], Notes)
VALUES
	('Best Movie', NULL),
	('Best Actor', NULL),
	('Best Actess', NULL),
	('Best Video', NULL),
	('Best Music', NULL)

INSERT INTO Movies
	([Title], [DirectorId], [CopyrightYear], [Length], [GenreId], [CategoryId], [Rating], [Notes])
VALUES
	('Avatar', 4, 2009, 3, 5, 1, 9, NULL),
	('The Hobbit', 1, 2012, 3, 5, 4, 8, NULL),
	('Transformers', 2, 2007, 2, 1, 2, 7, NULL),
	('Catch Me If You Can', 5, 2002, 2, 2, 2, 8, NULL),
	('Django Unchained', 4, 2012, 2, 3, 2, 8, NULL)
GO

--14. Car Rental Database
CREATE DATABASE CarRental
GO

USE CarRental
GO
 
CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	DailyRate DECIMAL(5, 2),
	WeeklyRate DECIMAL(5, 2),
	MonthlyRate DECIMAL(5, 2),
	WeekendRate DECIMAL(5, 2)
)

CREATE TABLE Cars (
	Id INT PRIMARY KEY IDENTITY,
	PlateNumber SMALLINT UNIQUE NOT NULL,
	Manufacturer NVARCHAR(50),
	Model NVARCHAR(50) NOT NULL,
	CarYear SMALLINT,
	CategoryId INT,
	Doors SMALLINT,
	Picture VARBINARY(MAX),
	Condition NVARCHAR(250),
	Available BIT NOT NULL
)

CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50),
	Title NVARCHAR(50),
	Notes NVARCHAR(MAX)
)

CREATE TABLE Customers (
	Id INT PRIMARY KEY IDENTITY,
	DriverLicenceNumber BIGINT NOT NULL,
	FullName NVARCHAR(50) NOT NULL,
	[Address] NVARCHAR(50),
	City NVARCHAR(50),
	ZIPCode NVARCHAR(50),
	Notes NVARCHAR(MAX)
)

CREATE TABLE RentalOrders (
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT UNIQUE NOT NULL,
	CustomerId INT UNIQUE NOT NULL,
	CarID INT UNIQUE NOT NULL,
	TankLevel INT,
	KilometrageStart BIGINT,
	KilometrageEnd BIGINT,
	TotalKilometrage BIGINT,
	StartDate DATETIME2,
	EndDate DATETIME2,
	TotalDays INT,
	RateApplied DECIMAL(5, 2),
	TaxRate DECIMAL(5, 2),
	OrderStatus NVARCHAR(50),
	Notes NVARCHAR(MAX)
)

INSERT INTO Categories
	([CategoryName], [DailyRate], [WeekendRate], [MonthlyRate], [WeeklyRate])
VALUES
	('Day Rent', 10.00, 7.25, 4.50, 5.30),
	('Week Rent', 5.00, 8.40, 6.50, 10.00),
	('Month Rent', 4.50, 7.25, 10.00, 9.30)

INSERT INTO Cars
	([PlateNumber], [Manufacturer], [Model], [CarYear], [CategoryId], [Doors], [Picture], [Condition], [Available])
VALUES
	(1122, 'Mercedes', 'S320', 2016, 1, 4, NULL, 'New', 0),
	(4455, 'Audi', 'Q7', 2018, 2, 4, NULL, 'New', 0),
	(7788, 'BMW', '5', 2003, 3, 4, NULL, 'New', 0)

INSERT INTO Employees
	([FirstName], [LastName], [Title], [Notes])
VALUES 
	('Pesho', 'Peshov', 'DK', NULL),
	('Gosho', 'Goshov', 'RK', NULL),
	('Sasho', 'Sashov', 'SK', NULL)

INSERT INTO Customers
	([DriverLicenceNumber], [FullName], [Address], [City], [ZIPCode], [Notes])
VALUES
	(123456789, 'Misho Mishov', 'Iskar', 'Sofia', 'A1', NULL),
	(987654321, 'Tosho Toshov', 'Dunav', 'Plovdiv', 'B2', NULL),
	(456123789, 'Tisho Tishov', 'Osam', 'Varna', 'C3', NULL)

INSERT INTO RentalOrders
	([EmployeeId], [CustomerId], [CarID], [TankLevel], [KilometrageStart], 
	[KilometrageEnd], [TotalKilometrage], [StartDate], [EndDate], 
	[TotalDays], [RateApplied], [TaxRate], [OrderStatus], [Notes])
VALUES
	(1, 2, 3, 50, 120000, 140000, 20000, CONVERT(DATETIME, '01-01-2018', 103), CONVERT(DATETIME, '01-02-2018', 103), 30, 8.00, 3.00,'In Progress', NULL),
	(2, 3, 1, 40, 200000, 250000, 50000, CONVERT(DATETIME, '01-02-2018', 103), CONVERT(DATETIME, '01-03-2018', 103), 30, 9.00, 4.00,'In Progress', NULL),
	(3, 1, 2, 45, 300000, 360000, 60000, CONVERT(DATETIME, '01-03-2018', 103), CONVERT(DATETIME, '01-04-2018', 103), 30, 7.00, 5.00,'In Progress', NULL)
GO

--15. Hotel Database
CREATE DATABASE Hotel
GO

USE Hotel
GO

CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50),
	Title NVARCHAR(50),
	Notes NVARCHAR(MAX)
)

CREATE TABLE Customers (
	AccountNumber INT PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50),
	PhoneNumber INT,
	EmergencyName NVARCHAR(50),
	EmergencyNumber NVARCHAR(50),
	Notes NVARCHAR(MAX)
)

CREATE TABLE RoomStatus (
	RoomStatus NVARCHAR(50),
	Notes NVARCHAR(MAX)
)

CREATE TABLE RoomTypes (
	RoomType NVARCHAR(50),
	Notes NVARCHAR(MAX)
)

CREATE TABLE BedTypes (
	BedType NVARCHAR(50),
	Notes NVARCHAR(MAX)
)

CREATE TABLE Rooms (
	RoomNumber INT PRIMARY KEY NOT NULL,
	RoomType INT,
	BedType INT,
	Rate DECIMAL(5, 2),
	RoomStatus INT,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Payments (
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT NOT NULL,
	PaymentDate DATETIME2 NOT NULL,
	AccountNumber INT NOT NULL,
	FirstDateOccupied DATETIME2,
	LastDateOccupied DATETIME2,
	TotalDays INT,
	AmountCharged DECIMAL(15, 2),
	TaxRate DECIMAL(5, 2),
	TaxAmount DECIMAL(15, 2),
	PaymentTotal DECIMAL(15, 2) NOT NULL,
	Notes NVARCHAR(MAX)
)
    
CREATE TABLE Occupancies (
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT NOT NULL,	
	DateOccupied DATETIME2 NOT NULL,
	AccountNumber INT,
	RoomNumber INT,
	RateApplied DECIMAL(5, 2),
	PhoneCharge DECIMAL(15, 2),
	Notes NVARCHAR(MAX)
)

INSERT INTO Employees
	([FirstName], [LastName], [Title], [Notes])
VALUES 
	('Pesho', 'Peshov', 'DK', NULL),
	('Gosho', 'Goshov', 'RK', NULL),
	('Sasho', 'Sashov', 'SK', NULL)

INSERT INTO Customers
	([AccountNumber], [FirstName], [LastName], [PhoneNumber], [EmergencyName], [EmergencyNumber], [Notes])
VALUES
	(111, 'Pesho', 'Peshov', 123456789, 'Bai Pesho', 999, NULL),
	(222, 'Gosho', 'Goshov', 465646564, 'Bai Gosho', 888, NULL),
	(333, 'Tosho', 'Toshov', 132313231, 'Bai Tosho', 777, NULL)

INSERT INTO RoomStatus
	([RoomStatus], [Notes])
VALUES
	('For Checking', NULL),
	('Checking', NULL),
	('Checked', NULL)

INSERT INTO RoomTypes
	([RoomType], [Notes])
VALUES 
	('One bedroom', NULL),
	('Two bedrooms', NULL),
	('Apartment', NULL)
  
INSERT INTO BedTypes
	([BedType], [Notes])
VALUES 
	('One person', NULL),
	('Person and a half', NULL),
	('Two person', NULL)

INSERT INTO Rooms 
	([RoomNumber], [RoomType], [BedType], [Rate], [RoomStatus], [Notes])
VALUES
	(1, 1, 1, 5.30, 1, NULL),
	(2, 2, 2, 6.30, 2, NULL),
	(3, 3, 3, 7.30, 3, NULL)

INSERT INTO Payments
	([EmployeeId], [PaymentDate], [AccountNumber], [FirstDateOccupied], [LastDateOccupied], 
	[TotalDays], [AmountCharged], [TaxRate], [TaxAmount], [PaymentTotal], [Notes])
VALUES
	(1, CONVERT(DATETIME, '01-01-2018', 103), 1, CONVERT(DATETIME, '01-02-2018', 103), CONVERT(DATETIME, '01-03-2018', 103), 30, 5.25, 20.00, 30.00, 120.00, NULL),
	(2, CONVERT(DATETIME, '01-02-2018', 103), 1, CONVERT(DATETIME, '01-03-2018', 103), CONVERT(DATETIME, '01-04-2018', 103), 30, 5.25, 20.00, 30.00, 120.00, NULL),
	(3, CONVERT(DATETIME, '01-03-2018', 103), 1, CONVERT(DATETIME, '01-04-2018', 103), CONVERT(DATETIME, '01-05-2018', 103), 30, 5.25, 20.00, 30.00, 120.00, NULL)

INSERT INTO Occupancies
	([EmployeeId], [DateOccupied], [AccountNumber], [RoomNumber], [RateApplied], [PhoneCharge], [Notes])
VALUES
	(1, CONVERT(DATETIME, '01-01-2018', 103), 1, 1, 5.50, 5.50, NULL),
	(2, CONVERT(DATETIME, '01-02-2018', 103), 2, 2, 5.50, 5.50, NULL),
	(3, CONVERT(DATETIME, '01-03-2018', 103), 3, 3, 5.50, 5.50, NULL)
GO

--16. Create SoftUni Database
CREATE DATABASE SoftUni
GO

USE SoftUni
GO

CREATE TABLE Towns (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Addresses (
	Id INT PRIMARY KEY IDENTITY,
	AddressText NVARCHAR(50) NOT NULL,
	TownId INT CONSTRAINT FK_Addresses_Town FOREIGN KEY REFERENCES Towns(Id) NOT NULL
)

CREATE TABLE Departments (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	JobTitle NVARCHAR(50)NOT NULL,
	DepartmentId INT CONSTRAINT FK_Employees_Departments FOREIGN KEY REFERENCES Departments(Id) NOT NULL,
	HireDate DATE NOT NULL,
	Salary DECIMAL(15, 2) NOT NULL,
	AddressId INT CONSTRAINT FK_Employees_Addresses FOREIGN KEY REFERENCES Addresses(Id)
)
GO

--17. Backup Database
BACKUP DATABASE [SoftUni] 
TO  DISK = N'C:\Users\veselinp\SoftUni.bak' WITH NOFORMAT, 
NOINIT, 
NAME = N'SoftUni-Full Database Backup', 
SKIP, 
NOREWIND, 
NOUNLOAD,  
STATS = 10
GO

--18. Basic Insert
INSERT INTO Towns
	([Name])
VALUES
	('Sofia'),
	('Plovdiv'),
	('Varna'),
	('Burgas')

INSERT INTO Departments
	([Name])
VALUES
	('Engineering'),
	('Sales'),
	('Marketing'),
	('Software Development'),
	('Quality Assurance')


INSERT INTO Employees
	([FirstName], [MiddleName], [LastName], [JobTitle], [DepartmentId], [HireDate], [Salary], [AddressId])
VALUES
	('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, CONVERT(DATETIME, '01/02/2013', 103), 3500.00, NULL),
	('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, CONVERT(DATETIME, '02/03/2004', 103), 4000.00, NULL),
	('Maria', 'Petrova', 'Ivanova', 'Intern', 5, CONVERT(DATETIME, '28/08/2016', 103), 525.25, NULL),
	('Georgi', 'Terziev', 'Ivanov', 'CEO', 2, CONVERT(DATETIME, '09/12/2007', 103), 3000.00, NULL),
	('Peter', 'Pan', 'Pan', 'Intern', 3, CONVERT(DATETIME, '28/08/2016', 103), 599.88, NULL)
GO

--19. Basic Select All Fields
SELECT * FROM Towns
SELECT * FROM Departments
SELECT * FROM Employees
GO

--20. Basic Select All Fields and Order Them
SELECT * FROM Towns
ORDER BY [Name] ASC

SELECT * FROM Departments
ORDER BY [Name] ASC

SELECT * FROM Employees
ORDER BY [Salary] DESC
GO

--21. Basic Select Some Fields
SELECT [Name] FROM Towns
ORDER BY [Name] ASC

SELECT [Name] FROM Departments
ORDER BY [Name] ASC

SELECT [FirstName], [LastName], [JobTitle], [Salary] FROM Employees
ORDER BY [Salary] DESC
GO

--22. Increase Employees Salary
UPDATE Employees
SET Salary *= 1.1

SELECT [Salary] FROM Employees

--23. Decrease Tax Rate
USE Hotel
GO

UPDATE Payments
SET TaxRate *= 0.97

SELECT [TaxRate] FROM Payments
GO

--24. Delete All Records
TRUNCATE TABLE Occupancies
GO