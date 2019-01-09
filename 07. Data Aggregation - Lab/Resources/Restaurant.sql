USE [master]
GO

CREATE DATABASE Restaurant ON PRIMARY
   ( NAME = N'Restaurant_Data', FILENAME = N'D:\Courses\Data\Restaurant_Data.mdf' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
LOG ON
   ( NAME = N'Restaurant_Log', FILENAME = N'D:\Courses\Data\Restaurant_Log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE Restaurant
GO

CREATE TABLE Departments (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL
)

CREATE TABLE Employees (
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(30) NOT NULL,
	[LastName] VARCHAR(30) NOT NULL,
	[DepartmentId] INT NOT NULL,
	[Salary] DECIMAL(15, 2) NOT NULL,
	
	CONSTRAINT Fk_Employees_Departmets
	FOREIGN KEY(DepartmentId) REFERENCES Departments(Id)
)

CREATE TABLE Categories (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Products (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[CategoryId] INT NOT NULL,
	[Price] DECIMAL(15, 2) NOT NULL,

	CONSTRAINT Fk_Products_Categories
	FOREIGN KEY(CategoryId) REFERENCES Categories(Id)
)

INSERT INTO Departments
	([Name]) 
VALUES 
	('Management'), 
	('Kitchen Staff'), 
	('Wait Staff')

INSERT INTO Employees 
	([FirstName], [LastName], [DepartmentId], [Salary]) 
VALUES 
	('Jasmine', 'Maggot', 2, 1250.00), 
	('Nancy', 'Olson', 2, 1350.00), 
	('Karen', 'Bender', 1, 2400.00), 
	('Pricilia','Parker', 2, 980.00),
	('Stephen', 'Bedford', 2, 780.00),
	('Jack', 'McGee', 1, 1700.00),
	('Clarence', 'Willis', 3, 650.00),
	('Michael', 'Boren', 3, 780.00),
	('Michael', 'Boren', 3, 780.00)

INSERT INTO Categories
	([Name]) 
VALUES
	('salads'),
	('appetizers'),
	('soups'),
	('main'),
	('desserts')

INSERT INTO Products 
	([Name], [CategoryId], [Price]) 
VALUES 
	('Lasagne', 4, 12.99),
	('Linguine Positano with Chicken', 4, 11.69),
	('Chicken Marsala', 4, 13.69),
	('Calamari', 2, 14.89),
	('Tomato Caprese with Fresh Burrata', 2, 7.99),
	('Wood-Fired Italian Wings', 2, 9.90),
	('Caesar Side Salad', 1, 8.79),
	('House Side Salad', 1, 6.79),
	('Johny Rocco Salad', 1, 6.90),
	('Minestrone', 3, 8.89),
	('Sausage & Lentil', 3, 7.90),
	('Mama Mandola’s Sicilian Chicken Soup', 3, 6.90),
	('Tiramisú', 5, 4.90),
	('John Cole', 5, 5.60),
	('Mini Cannoli', 5, 5.60)