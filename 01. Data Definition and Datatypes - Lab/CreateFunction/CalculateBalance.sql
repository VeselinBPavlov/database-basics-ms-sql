CREATE FUNCTION f_CalculateTotalBalance(@ClientId INT)
RETURNS DECIMAL (15, 2)
BEGIN
	DECLARE @result AS DECIMAL (15, 2) = (
		SELECT SUM(Balance)
		FROM Accounts 
		WHERE ClientId = @ClientId
	)
	RETURN @result
END
GO

--Test
SELECT [dbo].f_CalculateTotalBalance(1) AS Balance
GO