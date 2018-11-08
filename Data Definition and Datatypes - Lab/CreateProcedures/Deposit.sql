CREATE PROCEDURE p_Deposit @AccountId INT, @Ammount DECIMAL(15, 2) AS
UPDATE Accounts
SET Balance += @Ammount
WHERE Id = @AccountId
GO
--Test
p_Deposit 4, 5000
GO