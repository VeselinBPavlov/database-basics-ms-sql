USE BookLibrary
GO

-- 01. Find Book Titles
SELECT Title
FROM Books
WHERE SUBSTRING(Title, 1, 3) = 'The'
ORDER BY Id ASC

-- 02. Replace Titles
SELECT REPLACE(Title, 'The', '***') AS [ReplacedTitles]
FROM Books
WHERE SUBSTRING(Title, 1, 3) = 'The'
ORDER BY Id ASC

-- 03. Sum Cost Of All Books
SELECT ROUND(SUM(Cost), 2) AS [Sum]
FROM Books

-- 04. Days Lived
SELECT CONCAT(FirstName, ' ', LastName) AS [FullName], DATEDIFF(DAY, Born, Died) AS [DaysLived]
FROM Authors

-- 05. Harry Potter Books
SELECT Title 
FROM Books
WHERE Title LIKE CONCAT('Harry Potter','%')