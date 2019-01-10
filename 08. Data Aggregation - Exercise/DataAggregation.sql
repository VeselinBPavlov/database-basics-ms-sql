-- Part I – Queries for Gringotts Database
USE Gringotts
GO

-- 1. Records’ Count
SELECT COUNT(Id) AS [Count]
FROM WizzardDeposits
GO

-- 2. Longest Magic Wand 
SELECT MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GO

-- 3. Longest Magic Wand per Deposit Groups
SELECT DepositGroup, MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GROUP BY DepositGroup
GO

-- 4. Smallest Deposit Group per Magic Wand Size
SELECT TOP(2) DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)
GO

-- 5. Deposits Sum
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup
GO

-- 6. Deposits Sum for Ollivander Family
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
GO

-- 7. Deposits Filter
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY SUM(DepositAmount) DESC
GO

-- 8. Deposit Charge
SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS MinDepositCharge
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup ASC
GO

-- 9. Age Groups
SELECT
 CASE
  WHEN Age < 10 THEN '[0-10]'
  WHEN Age < 21 THEN '[11-20]'
  WHEN Age < 31 THEN '[21-30]'
  WHEN Age < 41 THEN '[31-40]'
  WHEN Age < 51 THEN '[41-50]'
  WHEN Age < 61 THEN '[51-60]'
 ELSE '[61+]'
END AS [AgeGroup],
COUNT(*) AS WizardCount
FROM WizzardDeposits
GROUP BY
 CASE
  WHEN Age < 10 THEN '[0-10]'
  WHEN Age < 21 THEN '[11-20]'
  WHEN Age < 31 THEN '[21-30]'
  WHEN Age < 41 THEN '[31-40]'
  WHEN Age < 51 THEN '[41-50]'
  WHEN Age < 61 THEN '[51-60]'
 ELSE '[61+]'
END
GO

-- 10. First Letter
SELECT LEFT(FirstName, 1) AS FirstLetter
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName, 1)
ORDER BY FirstLetter ASC
GO

-- 11. Average Interest
SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS AverageInterest
FROM WizzardDeposits
WHERE DepositStartDate >  '1985-01-01'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired ASC
GO

-- 12. Rich Wizard, Poor Wizard
SELECT SUM(DepositAmount - NextDeposit) AS [SumDifference]
FROM (SELECT DepositAmount, 
	  LEAD (DepositAmount) OVER (ORDER BY Id) AS [NextDeposit]
	  FROM WizzardDeposits) AS WizzartDeposits
GO

-- Part II – Queries for SoftUni Database
USE SoftUni
GO

-- 13. Departments Total Salaries
SELECT DepartmentID, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID ASC
GO

-- 14. Employees Minimum Salaries
SELECT DepartmentID, MIN(Salary) AS MinimumSalary
FROM Employees
WHERE DepartmentID IN (2, 5, 7)
AND DATEPART(YEAR, HireDate) > 1999
GROUP BY DepartmentID
ORDER BY DepartmentID ASC
GO

-- 15. Employees Average Salaries
SELECT * INTO TempTable 
FROM Employees
WHERE Salary > 30000

DELETE 
FROM TempTable
WHERE ManagerID = 42

UPDATE TempTable
SET Salary += 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary) AS [AverageSalary]
FROM TempTable
GROUP BY DepartmentID
GO

-- 16. Employees Maximum Salaries 
SELECT DepartmentID, MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY DepartmentID
HAVING  MAX(Salary) NOT BETWEEN 30000 AND 70000
GO

-- 17. Employees Count Salaries
SELECT COUNT(Salary) AS [Count]
FROM Employees
GROUP BY ManagerID
HAVING ManagerID IS NULL
GO

-- 18. 3rd Highest Salary 
SELECT DepartmentID, ThirdHighestSalary 
FROM
	(
		SELECT DepartmentID,
		MAX(Salary) AS ThirdHighestSalary,
		DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY Salary DESC) AS Rank
		FROM Employees
		GROUP BY DepartmentID, Salary
	)
AS ThirdPart
WHERE Rank = 3

-- 19. Salary Challenge
SELECT TOP 10 e1.FirstName, e1.LastName, e1.DepartmentID 
FROM Employees AS e1
WHERE Salary >
	(
		SELECT AVG(Salary)
		FROM Employees AS e2
		WHERE e2.DepartmentID = e1.DepartmentID
		GROUP BY DepartmentID
	)