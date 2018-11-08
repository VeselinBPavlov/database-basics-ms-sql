CREATE PROC p_AddAccount @ClientId INT, @AccountTypeId INT AS
INSERT INTO Accounts (ClientId, AccountTypeId) 
VALUES (@ClientId, @AccountTypeId)

--Test
p_AddAccount 2, 1

