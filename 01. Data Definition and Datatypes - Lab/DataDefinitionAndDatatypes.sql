USE master
GO

--1. Create a Database
CREATE DATABASE Bank ON PRIMARY
   ( NAME = N'Bank_Data', FILENAME = N'D:\Courses\Data\Bank_Data.mdf' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
LOG ON
   ( NAME = N'Bank_Log', FILENAME = N'D:\Courses\Data\Bank_Log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE Bank
GO

--2. Create Tables
CREATE TABLE Clients (
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(50) NOT NULL,
	[LastName] NVARCHAR(50) NOT NULL
)

CREATE TABLE AccountTypes (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Accounts (
	[Id] INT PRIMARY KEY IDENTITY,
	[AccountTypeId] INT FOREIGN KEY REFERENCES AccountTypes(Id),
	[Balance] DECIMAL(15, 2) NOT NUll DEFAULT(0),
	[ClientId] INT FOREIGN KEY REFERENCES Clients(Id)
)
GO

--3. Insert Sample Data into Database
INSERT INTO Clients
	([FirstName], [LastName])
VALUES
	('Gosho', 'Ivanov'),
	('Pesho', 'Petrov'),
	('Ivan', 'Iliev'),
	('Merry', 'Ivanova')

INSERT INTO AccountTypes
	([Name])
VALUES
	('Checking'),
	('Savings')

INSERT INTO Accounts
	([ClientId], [AccountTypeId], [Balance])
VALUES
	(1, 1, 175),
	(2, 1, 275.56),
	(3, 1, 138.01),
	(4, 1, 40.30),
	(4, 2, 375.50) 
GO

--4. Create a Function
CREATE FUNCTION f_CalculateTotalBalance 
	(@ClientId INT)
RETURNS DECIMAL(15, 2)
BEGIN
	DECLARE @result AS DECIMAL(15, 2) = (
		SELECT SUM (Balance)
		FROM Accounts WHERE ClientId = @ClientId
	)
	RETURN @result	
END
GO

--5. Create Procedures
CREATE PROC p_AddAccount 
	@ClientId INT, @AccountTypeId INT AS
INSERT INTO Accounts 
	([ClientId], [AccountTypeId]) 
VALUES 
	(@ClientId, @AccountTypeId)
GO

	--Deposit Procedure
CREATE PROC p_Deposit 
	@AccountId INT, @Amount DECIMAL(15, 2) AS
UPDATE Accounts
SET Balance += @Amount
WHERE Id = @AccountId
GO

	--Withdraw Procedure
CREATE PROC p_Withdraw 
	@AccountId INT, @Amount DECIMAL(15, 2) AS
BEGIN
	DECLARE @OldBalance DECIMAL(15, 2)
	SELECT @OldBalance = Balance FROM Accounts WHERE Id = @AccountId
	IF (@OldBalance - @Amount >= 0)
	BEGIN
		UPDATE Accounts
		SET Balance -= @Amount
		WHERE Id = @AccountId
	END
	ELSE
	BEGIN
		RAISERROR('Insufficient funds', 10, 1)
	END
END
GO

--6. Create Transactions Table and a Trigger
CREATE TABLE Transactions (
	[Id] INT PRIMARY KEY IDENTITY,
	[AccountId] INT FOREIGN KEY REFERENCES Accounts(Id),
	[OldBalance] DECIMAL(15, 2) NOT NULL,
	[NewBalance] DECIMAL(15, 2) NOT NULL,
	[Amount] AS [NewBalance] - [OldBalance],
	[DateTime] DATETIME2
)
GO

CREATE TRIGGER tr_Transaction ON Accounts
AFTER UPDATE
AS
	INSERT INTO Transactions 
		([AccountId], [OldBalance], [NewBalance], [DateTime])
	SELECT inserted.Id, deleted.Balance, inserted.Balance,
		GETDATE() FROM inserted
	JOIN deleted ON inserted.Id = deleted.Id
GO