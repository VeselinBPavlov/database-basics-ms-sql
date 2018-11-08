CREATE PROCEDURE p_Withdraw @AccountId INT, @Ammount DECIMAL(15, 2) AS
BEGIN
	DECLARE @OldBalance DECIMAL(15, 2)
	SELECT @OldBalance = Balance FROM Accounts WHERE Id = @AccountId
	IF (@OldBalance - @Ammount >= 0)
	BEGIN
		UPDATE Accounts
		SET Balance -= @Ammount
		WHERE Id = @AccountId
	END
	ELSE
	BEGIN
		RAISERROR('Insufficient funds', 10, 1)
	END	
END
GO

--Test
p_Withdraw 4, 1000
GO
p_Withdraw 4, 1500
GO