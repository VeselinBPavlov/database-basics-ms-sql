-- Section I. Functions and Procedures

-- Part 1. Queries for SoftUni Database
USE SoftUni
GO

-- 1. Employees with Salary Above 35000
CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000 AS
BEGIN
	SELECT [FirstName], [LastName]
	FROM Employees
	WHERE Salary > 35000
END
GO

-- 2. Employees with Salary Above Number
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber (@Number DECIMAL(15, 2)) AS
BEGIN
	SELECT [FirstName], [LastName]
	FROM Employees
	WHERE Salary >= @Number
END
GO

-- 3. Town Names Starting With
CREATE PROCEDURE usp_GetTownsStartingWith (@String VARCHAR(50)) AS
BEGIN
	SELECT [Name]
	FROM Towns
	WHERE [Name] LIKE @String + '%'
END
GO

-- 4. Employees from Town
CREATE PROCEDURE usp_GetEmployeesFromTown (@Town VARCHAR(50)) AS
BEGIN
	SELECT e.FirstName, e.LastName
	FROM Employees AS e
	INNER JOIN Addresses AS a
	ON a.AddressID = e.AddressID
	INNER JOIN Towns AS t
	ON t.TownID = a.TownID
	WHERE t.[Name] = @Town
END
GO

-- 5. Salary Level Function 
CREATE FUNCTION ufn_GetSalaryLevel(@Salary DECIMAL(18,4))
RETURNS VARCHAR(10)
BEGIN
	DECLARE @Result VARCHAR(10);
	IF (@Salary < 30000)
	BEGIN
		SET @Result = 'Low';
	END
	ELSE IF (@Salary >= 30000 AND @Salary <= 50000)
	BEGIN
		SET @Result = 'Average';
	END
	IF (@Salary > 50000)
	BEGIN
		SET @Result = 'High';
	END
	RETURN @Result;
END
GO

-- 6. Employees by Salary Level
CREATE PROCEDURE usp_EmployeesBySalaryLevel (@LevelOfSalary VARCHAR(10)) AS
BEGIN
	SELECT FirstName, LastName
	FROM Employees
	WHERE dbo.ufn_GetSalaryLevel(Salary) = @LevelOfSalary	
END
GO

-- 7. Define Function 
CREATE FUNCTION ufn_IsWordComprised(@SetOfLetters VARCHAR(50), @Word VARCHAR(50))
RETURNS BIT
BEGIN
	DECLARE @currentLetter CHAR;
	DECLARE @counter INT = 1;	
	WHILE (LEN(@word) >= @counter)
	BEGIN
		SET @currentLetter = SUBSTRING(@word, @counter, 1);
		DECLARE @match INT = CHARINDEX(@currentLetter, @setOfLetters);
		IF (@match = 0)
		BEGIN
			RETURN 0;
		END;
		SET @counter += 1;
	END;
	RETURN 1;
END
GO

-- 8. Delete Employees and Departments
CREATE PROC usp_DeleteEmployeesFromDepartment (@DepartmentId INT) AS
ALTER TABLE Departments
ALTER COLUMN ManagerID INT NULL

DELETE FROM EmployeesProjects
WHERE EmployeeID IN (
	SELECT EmployeeID FROM Employees
	WHERE DepartmentID = @DepartmentId
)

UPDATE Employees
SET ManagerID = NULL
WHERE ManagerID IN  (
	SELECT EmployeeID FROM Employees
	WHERE DepartmentID = @DepartmentId
)


UPDATE Departments
SET ManagerID = NULL
WHERE ManagerID IN (
	SELECT EmployeeID FROM Employees
	WHERE DepartmentID = @DepartmentId
)

DELETE FROM Employees
WHERE EmployeeID IN (
	SELECT EmployeeID FROM Employees
	WHERE DepartmentID = @DepartmentId
)

DELETE FROM Departments
WHERE DepartmentID = @DepartmentId
SELECT COUNT(*) AS [Employees Count] 
FROM Employees AS e
INNER JOIN Departments AS d
ON d.DepartmentID = e.DepartmentID
WHERE e.DepartmentID = @DepartmentId
GO

-- Part 2. Queries for Bank Database
USE Bank
GO

-- 9. Find Full Name
CREATE PROCEDURE usp_GetHoldersFullName AS
BEGIN
	SELECT CONCAT(FirstName, ' ', LastName) AS FullName 
	FROM AccountHolders
END
GO

-- 10. People with Balance Higher Than
CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan (@InputBalance DECIMAL(15, 2)) AS
BEGIN
	SELECT ah.FirstName, ah.LastName
	FROM AccountHolders AS ah
	INNER JOIN Accounts AS a
	ON a.AccountHolderId = ah.Id
	GROUP BY ah.FirstName, ah.LastName
	HAVING SUM(a.Balance) > @InputBalance
END
GO

-- 11. Future Value Function
CREATE FUNCTION ufn_CalculateFutureValue (@Sum MONEY, @YIRate FLOAT, @Years INT)
RETURNS DECIMAL(24, 4) AS
BEGIN
	DECLARE @Result DECIMAL(24, 4)
	SET @Result = @Sum * (POWER((1 + @YIRate), @Years))
	RETURN @Result
END
GO

-- 12. Calculating Interest
CREATE PROCEDURE usp_CalculateFutureValueForAccount (@AccountID INT, @InterestRate FLOAT) AS
BEGIN
	SELECT a.Id, ah.FirstName, ah.LastName, a.Balance, 
		dbo.ufn_CalculateFutureValue(a.Balance, @InterestRate, 5) AS [Balance in 5 years]
	FROM Accounts AS a
	INNER JOIN AccountHolders AS ah
	ON ah.Id = a.AccountHolderId
	WHERE a.Id = @AccountID
END
GO

-- Part 3. Queries for Diablo Database
USE Diablo
GO

-- 13. Cash in User Games Odd Rows 
CREATE FUNCTION ufn_CashInUsersGames (@GameName VARCHAR(50))
RETURNS TABLE AS
RETURN (
	SELECT SUM(e.Cash) AS SumCash
	FROM ( 
		SELECT g.Id, ug.Cash, ROW_NUMBER() OVER(ORDER BY ug.Cash DESC) AS [RowNumber]
		FROM Games AS g
		INNER JOIN UsersGames AS ug
		ON ug.GameId = g.Id
		WHERE g.[Name] = @GameName
	) AS e
	WHERE e.RowNumber % 2 = 1 
)
GO

-- Section II. Triggers and Transactions

-- Part 1. Queries for Bank Database
USE Bank
GO

-- 14. Create Table Logs
CREATE TABLE Logs (
	LogId INT PRIMARY KEY IDENTITY,
	AccountId INT NOT NULL,
	OldSum DECIMAL (15, 2),
	NewSum DECIMAL (15, 2)
)
GO

CREATE TRIGGER tr_LogsUpdate ON Accounts 
AFTER UPDATE AS
BEGIN
	DECLARE @Account INT = (SELECT Id FROM deleted)
	DECLARE @OldSum DECIMAL (15, 2) = (SELECT Balance FROM deleted)
	DECLARE @NewSum DECIMAL (15, 2) = (SELECT Balance FROM inserted)
	INSERT INTO Logs VALUES
		(@Account, @OldSum, @NewSum)
END
GO

-- 15. Create Table Emails
CREATE TRIGGER tr_MailCreator ON Logs 
AFTER INSERT AS
BEGIN
  DECLARE @Recipient int = (SELECT AccountId FROM inserted);
  DECLARE @OldBalance money = (SELECT OldSum FROM inserted);
  DECLARE @NewBalance money = (SELECT NewSum FROM inserted);
  DECLARE @Subject varchar(200) = CONCAT('Balance change for account: ', @recipient);
  DECLARE @Body varchar(200) = CONCAT('On ', GETDATE(), ' your balance was changed from ', @oldBalance, ' to ', @newBalance, '.');  

  INSERT INTO NotificationEmails 
  VALUES 
	(@Recipient, @Subject, @Body)
END
GO

-- 16. Deposit Money
CREATE PROCEDURE usp_DepositMoney (@AccountId INT, @MoneyAmount DECIMAL(15, 4))
AS
BEGIN
	UPDATE Accounts
	SET Balance += @MoneyAmount
	WHERE Id = @AccountId
END
GO

-- 17. Withdraw Money Procedure 
CREATE PROCEDURE usp_WithdrawMoney (@AccountId INT, @MoneyAmount DECIMAL(15, 4)) AS
BEGIN
	UPDATE Accounts
	SET Balance -= @MoneyAmount
	WHERE Id = @AccountId
END
GO

-- 18. Money Transfer
CREATE PROCEDURE usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(15, 4))AS
BEGIN
	BEGIN TRANSACTION
	EXEC dbo.usp_WithdrawMoney @SenderId, @Amount
	EXEC dbo.usp_DepositMoney @ReceiverId, @Amount
	IF	(
		SELECT Balance 
		FROM Accounts
		WHERE Accounts.Id = @SenderId
	) < 0
		BEGIN
			ROLLBACK
		END
		ELSE
		BEGIN
		COMMIT
	END
END
GO

-- Part 4. Queries for Diablo Database
USE Diablo
GO

-- 19. Trigger
CREATE TRIGGER tr_RestrictHigherLevelItems
ON UserGameItems AFTER INSERT
AS
BEGIN
	DECLARE @ItemMinLevel INT = 
	(
		SELECT i.MinLevel FROM inserted AS ins
		INNER JOIN Items AS i ON i.Id = ins.ItemId
	)
	DECLARE @UserLevel INT = 
	(
		SELECT ug.[Level] FROM inserted AS ins
		INNER JOIN UsersGames AS ug ON ug.Id = ins.UserGameId
	)

	IF (@UserLevel < @ItemMinLevel)
	BEGIN
		RAISERROR('Your level is too low to aquire that item!', 16, 1)
		ROLLBACK
		RETURN
	END
END
GO

UPDATE UsersGames
SET Cash += 50000
WHERE GameId = (SELECT Id FROM Games WHERE [Name] = 'Bali') 
AND UserId IN (SELECT Id FROM Users WHERE Username IN 
('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos'))
GO

INSERT INTO UserGameItems (UserGameId, ItemId)
SELECT  UsersGames.Id, i.Id 
FROM UsersGames, Items i
WHERE UserId in (
	SELECT Id 
	FROM Users 
	WHERE Username IN ('loosenoise', 'baleremuda', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
) AND GameId = (SELECT Id FROM Games WHERE Name = 'Bali' ) AND ((i.Id > 250 AND i.Id < 300) OR (i.Id > 500 AND i.Id < 540))

SELECT u.Username, g.[Name], ug.Cash, i.[Name]
FROM Users AS u
INNER JOIN UsersGames AS ug ON ug.UserId = u.Id
INNER JOIN Games AS g ON g.Id = ug.GameId
INNER JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
INNER JOIN Items AS i ON i.Id = ugi.ItemId
WHERE g.[Name] = 'Bali'
ORDER BY u.Username, g.[Name]
GO

-- 20. Massive Shopping
BEGIN TRANSACTION
DECLARE @sum1 MONEY = (SELECT SUM(i.Price)
						FROM Items i
						WHERE MinLevel BETWEEN 11 AND 12)

IF (SELECT Cash FROM UsersGames WHERE Id = 110) < @sum1
ROLLBACK
ELSE BEGIN
		UPDATE UsersGames
		SET Cash -= @sum1
		WHERE Id = 110

		INSERT INTO UserGameItems (UserGameId, ItemId)
		SELECT 110, Id 
		FROM Items 
		WHERE MinLevel BETWEEN 11 AND 12
		COMMIT
	END

BEGIN TRANSACTION
DECLARE @sum2 MONEY = (SELECT SUM(i.Price)
						FROM Items i
						WHERE MinLevel BETWEEN 19 AND 21)

IF (SELECT Cash FROM UsersGames WHERE Id = 110) < @sum2
ROLLBACK
ELSE BEGIN
		UPDATE UsersGames
		SET Cash -= @sum2
		WHERE Id = 110

		INSERT INTO UserGameItems (UserGameId, ItemId)
			SELECT 110, Id 
			FROM Items 
			WHERE MinLevel BETWEEN 19 AND 21
		COMMIT
	END

SELECT i.[Name] AS 'Item Name' 
FROM UserGameItems ugi
INNER JOIN Items AS i
ON ugi.ItemId = i.Id
WHERE ugi.UserGameId = 110
GO

-- Part 5. Queries for SoftUni Database
USE SoftUni
GO

-- 21. Employees with Three Projects
CREATE PROCEDURE usp_AssignProject (@employeeId INT, @projectID INT) AS
BEGIN
	BEGIN TRANSACTION
	INSERT INTO EmployeesProjects VALUES (@employeeId, @projectID)
	IF (
	SELECT COUNT(ProjectID)
	FROM EmployeesProjects
	WHERE EmployeeID = @employeeId
	) > 3
	BEGIN
		RAISERROR('The employee has too many projects!', 16, 1)
		ROLLBACK
		RETURN
	END
	COMMIT
END
GO

-- 22. Delete Employees
CREATE TABLE Deleted_Employees (
	EmployeeId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	MiddleName VARCHAR(50),
	JobTitle VARCHAR(50),
	DepartmentId INT,
	Salary DECIMAL (15, 2)
)
GO

CREATE TRIGGER tr_DeleteEmployee ON Employees
AFTER DELETE AS
BEGIN
	INSERT INTO Deleted_Employees
	SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentID, Salary 
	FROM deleted
END
GO