-- Part I – Queries for Diablo Database
USE Diablo
GO

-- 1. Number of Users for Email Provider
SELECT SUBSTRING(Email, CHARINDEX('@', Email, 1) + 1 , LEN(Email)) AS [Email Provider],
	COUNT(Email) AS [Number Of Users]
FROM Users
GROUP BY SUBSTRING(Email, CHARINDEX('@', Email, 1) + 1 , LEN(Email))
ORDER BY [Number Of Users] DESC, [Email Provider] ASC
GO

-- 2. All User in Games
SELECT g.[Name] AS Game, gt.[Name] AS GameType, u.Username, ug.[Level], ug.Cash, c.[Name] AS [Character]
FROM Games AS g
INNER JOIN GameTypes AS gt
ON gt.Id = g.GameTypeId
INNER JOIN UsersGames AS ug
ON ug.GameId = g.Id
INNER JOIN Users AS u
ON u.Id = ug.UserId
INNER JOIN Characters AS c
ON c.Id = ug.CharacterId
ORDER BY ug.[Level] DESC, u.Username ASC, g.[Name]
GO

-- 3. Users in Games with Their Items
SELECT u.Username, g.[Name], COUNT(i.Id) AS ItemsCount, SUM(i.Price) AS ItemsPrice
FROM UsersGames AS ug
INNER JOIN Users AS u
ON u.Id = ug.UserId
INNER JOIN Games AS g
ON g.Id = ug.GameId
INNER JOIN UserGameItems AS ugi
ON ugi.UserGameId = ug.Id
INNER JOIN Items AS i
ON i.Id = ugi.ItemId
GROUP BY u.Username, g.[Name]
HAVING COUNT(i.Id) >= 10
ORDER BY ItemsCount DESC, ItemsPrice DESC, u.[Username] ASC
GO

-- 4. User in Games with Their Statistics
SELECT u.Username,
	g.Name AS [Game],
	MAX(ch.Name) AS Character,
	MAX(statch.Strength) + MAX(statgt.Strength) + SUM(stati.Strength) AS Strength, 
	MAX(statch.Defence) + MAX(statgt.Defence) + SUM(stati.Defence) AS Defence, 
	MAX(statch.Speed) + MAX(statgt.Speed) + SUM(stati.Speed) AS Speed, 
	MAX(statch.Mind) + MAX(statgt.Mind) + SUM(stati.Mind) AS Mind, 
	MAX(statch.Luck) + MAX(statgt.Luck) + SUM(stati.Luck) AS Luck
FROM Users AS u
INNER JOIN UsersGames AS ug
ON ug.UserId = u.Id
INNER JOIN Games AS g
ON g.Id = ug.GameId
INNER JOIN Characters AS ch
ON ch.Id = ug.CharacterId
INNER JOIN [Statistics] AS statch
ON statch.Id = ch.StatisticId
INNER JOIN GameTypes AS gt
ON gt.Id = g.GameTypeId
INNER JOIN [Statistics] AS statgt
ON statgt.Id = gt.BonusStatsId
INNER JOIN UserGameItems AS ugi
ON ugi.UserGameId = ug.Id
INNER JOIN Items AS i
ON i.Id = ugi.ItemId
INNER JOIN [Statistics] AS stati
ON stati.Id = i.StatisticId
GROUP BY u.Username, g.Name
ORDER BY Strength DESC, Defence DESC, Speed DESC, Mind DESC, Luck DESC

-- 5. All Items with Greater than Average Statistics
SELECT i.[Name], i.Price, i.MinLevel, s.Strength, s.Defence, s.Speed, s.Luck, s.Mind
FROM Items AS i
INNER JOIN [Statistics] AS s
ON s.Id = i.StatisticId
WHERE s.Mind > (SELECT AVG(Mind) FROM [Statistics])
AND s.Luck > (SELECT AVG(Luck) FROM [Statistics])
AND s.Speed > (SELECT AVG(Speed) FROM [Statistics])
ORDER BY i.[Name]
GO
-- 6. Display All Items with Information about Forbidden Game Type
SELECT i.[Name] AS Item, i.Price, i.MinLevel, gt.[Name] AS [Forbidden Game Type]
FROM Items AS i
LEFT JOIN GameTypeForbiddenItems AS gtfi
ON gtfi.ItemId = i.Id
LEFT JOIN GameTypes AS gt
ON gt.Id = gtfi.GameTypeId
ORDER BY gt.[Name] DESC, i.[Name] ASC
GO

-- 7. Buy Items for User in Game
DECLARE @AlexCash MONEY;
DECLARE @AlexEdinburghID INT;
DECLARE @ItemsTotalPrice MONEY;

SET @AlexEdinburghID = (SELECT Id 
						FROM UsersGames 
						WHERE UserId = (SELECT Id FROM Users WHERE Username = 'Alex')
						AND GameId = (SELECT Id FROM Games WHERE Name = 'Edinburgh'));

SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items 
						WHERE Name IN 
						('Blackguard',
						'Bottomless Potion of Amplification',
						'Eye of Etlich (Diablo III)',
						'Gem of Efficacious Toxin',
						'Golden Gorget of Leoric',
						'Hellfire Amulet'))

UPDATE UsersGames
SET Cash -= @ItemsTotalPrice WHERE Id = @AlexEdinburghID

INSERT INTO UserGameItems VALUES
	((SELECT Id FROM Items WHERE Name = 'Blackguard'), @AlexEdinburghID),
	((SELECT Id FROM Items WHERE Name = 'Bottomless Potion of Amplification'), @AlexEdinburghID),
	((SELECT Id FROM Items WHERE Name = 'Eye of Etlich (Diablo III)'), @AlexEdinburghID),
	((SELECT Id FROM Items WHERE Name = 'Gem of Efficacious Toxin'), @AlexEdinburghID),
	((SELECT Id FROM Items WHERE Name = 'Golden Gorget of Leoric'), @AlexEdinburghID),
	((SELECT Id FROM Items WHERE Name = 'Hellfire Amulet'), @AlexEdinburghID)

SELECT u.Username, g.[Name], ug.Cash, i.[Name]
FROM Users AS u
INNER JOIN UsersGames AS ug
ON ug.UserId = u.Id
INNER JOIN Games AS g
ON g.Id = ug.GameId
INNER JOIN UserGameItems AS ugi
ON ugi.UserGameId = ug.Id
INNER JOIN Items AS i
ON i.Id = ugi.ItemId
WHERE g.Name = 'Edinburgh'
ORDER BY g.[Name]
GO

-- Part II – Queries for Geography Database
USE [Geography]
GO

-- 8. Peaks and Mountains
SELECT p.PeakName, m.MountainRange AS Mountain, p.Elevation
FROM Peaks AS p
INNER JOIN Mountains AS m
ON m.Id = p.MountainId
ORDER BY p.Elevation DESC, p.PeakName ASC
GO

-- 9. Peaks with Their Mountain, Country and Continent
SELECT p.PeakName, m.MountainRange, cou.CountryName, con.ContinentName
FROM Peaks AS p
INNER JOIN Mountains AS m
ON m.Id = p.MountainId
INNER JOIN MountainsCountries AS mc
ON mc.MountainId = m.Id
INNER JOIN Countries AS cou
ON cou.CountryCode = mc.CountryCode
INNER JOIN Continents AS con
ON con.ContinentCode = cou.ContinentCode
ORDER BY p.PeakName ASC, cou.CountryName ASC
GO

-- 10. Rivers by Country
SELECT cou.CountryName, con.ContinentName, 
	COUNT(r.RiverName) AS RiversCount, 
	CASE
		WHEN COUNT(r.RiverName) <> 0 THEN SUM(r.Length)
		ELSE 0
	END AS TotalLength 
FROM Countries AS cou
LEFT JOIN Continents AS con
ON con.ContinentCode = cou.ContinentCode
LEFT JOIN CountriesRivers AS cr
ON cr.CountryCode = cou.CountryCode
LEFT JOIN Rivers AS r
ON r.Id = cr.RiverId
GROUP BY cou.CountryName, con.ContinentName
ORDER BY RiversCount DESC, TotalLength DESC, cou.CountryName ASC
GO

-- 11. Count of Countries by Currency
SELECT cu.CurrencyCode, cu.[Description], COUNT(co.CountryName) AS NumberOfCountries
FROM Currencies AS cu
LEFT JOIN Countries AS co
ON co.CurrencyCode = cu.CurrencyCode
GROUP BY cu.CurrencyCode, cu.[Description]
ORDER BY NumberOfCountries DESC, cu.[Description] ASC
GO

-- 12. Population and Area by Continent
SELECT con.ContinentName, 
	SUM(CAST(cou.AreaInSqKm AS bigint)) AS CountriesArea,
	SUM(CAST(cou.[Population] AS bigint)) AS CountriesPopulation
FROM Continents AS con
INNER JOIN Countries AS cou
ON cou.ContinentCode = con.ContinentCode
GROUP BY con.ContinentName
ORDER BY CountriesPopulation DESC
GO

-- 13. Monasteries by Country
CREATE TABLE Monasteries (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(177),
	CountryCode CHAR(2) FOREIGN KEY REFERENCES Countries(CountryCode)
)

INSERT INTO Monasteries
	([Name], [CountryCode]) 
VALUES
	('Rila Monastery “St. Ivan of Rila”', 'BG'), 
	('Bachkovo Monastery “Virgin Mary”', 'BG'),
	('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
	('Kopan Monastery', 'NP'),
	('Thrangu Tashi Yangtse Monastery', 'NP'),
	('Shechen Tennyi Dargyeling Monastery', 'NP'),
	('Benchen Monastery', 'NP'),
	('Southern Shaolin Monastery', 'CN'),
	('Dabei Monastery', 'CN'),
	('Wa Sau Toi', 'CN'),
	('Lhunshigyia Monastery', 'CN'),
	('Rakya Monastery', 'CN'),
	('Monasteries of Meteora', 'GR'),
	('The Holy Monastery of Stavronikita', 'GR'),
	('Taung Kalat Monastery', 'MM'),
	('Pa-Auk Forest Monastery', 'MM'),
	('Taktsang Palphug Monastery', 'BT'),
	('Sümela Monastery', 'TR')

ALTER TABLE Countries 
ADD IsDeleted BIT NOT NULL DEFAULT 0

UPDATE Countries
   SET IsDeleted = 1
  FROM Countries
 WHERE CountryCode IN (SELECT cr.CountryCode 
		  				FROM CountriesRivers cr 
		  				JOIN Rivers r 
						ON r.Id = cr.RiverId
						GROUP BY cr.CountryCode
						HAVING COUNT(r.Id) > 3)

SELECT m.[Name], c.CountryName
FROM Monasteries AS m
INNER JOIN Countries AS c
ON c.CountryCode = m.CountryCode
WHERE c.IsDeleted <> 1
ORDER BY m.[Name]
GO

-- 14. Monasteries by Continents and Countries
UPDATE Countries
SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'

INSERT INTO Monasteries 
VALUES
	('Hanga Abbey', (SELECT CountryCode 
					FROM Countries 
					WHERE CountryName = 'Tanzania'))

INSERT INTO Monasteries 
VALUES
	('Myin-Tin-Daik', (SELECT CountryCode 
					  FROM Countries 
					  WHERE CountryName = 'Myanmar'))


SELECT c.ContinentName, cs.CountryName, COUNT(m.Id) AS [MonasteriesCount]
FROM Continents AS c
INNER JOIN Countries AS cs
ON cs.ContinentCode = c.ContinentCode
LEFT OUTER JOIN Monasteries AS m
ON m.CountryCode = cs.CountryCode
WHERE cs.IsDeleted = 0
GROUP BY c.ContinentName, cs.CountryName
ORDER BY [MonasteriesCount] DESC, cs.CountryName
GO