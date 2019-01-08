USE master
GO

CREATE DATABASE BookLibrary ON PRIMARY
   ( NAME = N'BookLibrary_Data', FILENAME = N'D:\Courses\Data\BookLibrary_Data.mdf' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
LOG ON
   ( NAME = N'BookLibrary_Log', FILENAME = N'D:\Courses\Data\BookLibrary_Log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE BookLibrary
GO

CREATE TABLE Authors (
	[Id] INT NOT NULL,
	[FirstName] VARCHAR(50) NOT NULL,
	[MiddleName] VARCHAR(50),
	[LastName] VARCHAR(50) NOT NULL,
	[Born] DATE NOT NULL,
	[Died] DATE

	CONSTRAINT Pk_Id
	PRIMARY KEY (Id)
)

INSERT INTO Authors
	([Id], [FirstName], [MiddleName], [LastName], [Born], [Died]) 
VALUES
	(1,'Agatha', 'Mary Clarissa','Christie', '1890-09-15', '1976-01-12'),
	(2,'William', NULL,'Shakespeare', '1564-04-26', '1616-04-23'),
	(3,'Danielle', 'Fernandes Dominique', 'Schuelein-Steel', '1947-07-14', NULL),
	(4,'Joanne', NULL,'Rowling' , '1965-07-31', NULL),
	(5,'Lev', 'Nikolayevich', 'Tolstoy', '1828-09-09', '1910-11-20'),
	(6,'Paulo', 'Coelho de', 'Souza', '1947-08-24', NULL),
	(7,'Stephen', 'Edwin', 'King', '1947-09-21', NULL),
	(8,'John', 'Ronald Reuel', 'Tolkien', '1892-01-03', '1973-09-02'),
	(9,'Erika', NULL, 'Mitchell', '1963-03-07', NULL);
GO

CREATE TABLE Books (
	[Id] INT PRIMARY KEY IDENTITY,
	[Title] VARCHAR(100) NOT NULL,
	[AuthorId] INT NOT NULL,
	[YearOfRelease] INT,
	[Cost] DECIMAL(15, 2) NOT NULL,

	CONSTRAINT Fk_Author_Authors
	FOREIGN KEY (AuthorId) 
	REFERENCES Authors(Id)
)

INSERT INTO Books
	([AuthorId], [Title], [YearOfRelease], [Cost]) 
VALUES
	(1,'Unfinished Portrait', 1930, 15.99),
	(1,'The Mysterious Affair at Styles', 1920, 17.99),
	(1,'The Big Four', 1927, 14.99),
	(1,'The Murder at the Vicarage', 1930, 13.99),
	(1,'The Mystery of the Blue Train', 1928, 12.99),
	(2,'Julius Caesar', 1599, 11.99),
	(2,'Timon of Athens', 1607, 13.99),
	(2,'As You Like It', 1600, 18.99),
	(2,'A Midsummer Night''s Dream', 1595, 15.99),
	(3,'Going Home', 1973, 15.99),
	(3,'The Ring', 1980, 14.99),
	(3,'Secrets', 1985, 15.99),
	(3,'Message From Nam', 1990, 13.99),
	(4,'Career of Evil', 2015, 15.99),
	(4, 'Harry Potter and the Philosopher''s Stone', 1997, 19.99),
	(4,'Harry Potter and the Chamber of Secrets', 1998, 19.99),
	(4,'Harry Potter and the Prisoner of Azkaban',1999, 19.99),
	(4,'Harry Potter and the Goblet of Fire',2000, 19.99),
	(4,'Harry Potter and the Order of the Phoenix',2003, 19.99),
	(4,'Harry Potter and the Half-Blood Prince', 2005, 19.99),
	(4,'Harry Potter and the Deathly Hallows', 2007, 19.99),
	(4,'Harry Potter and the Deathly Hallows', 2007, 15.99),
	(5,'Anna Karenina', 1877, 15.99),
	(5,'War And Peace', 1869, 30),
	(5,'Boyhood', 1854, 15.99),
	(6,'By the River Piedra I Sat Down and Wept', 1994, 15.99),
	(6,'The Alchemist', 1988, 15.99),
	(6,'The Fifth Mountain', 1996, 15.99),
	(6,'The Zahir', 2005, 15.99),
	(7,'Rage', 1977, 13.99),
	(7,'The Dead Zone', 1979, 13.99),
	(7,'It', 1986, 13.99),
	(7,'It', 1986, 13.99),	
	(8,'The Hobbit', 1937, 20.99),	
	(8,'The Adventures of Tom Bombadil', 1962, 13.99),	
	(9,'Fifty Shades of Grey', 2011, 13.99),	
	(9,'Fifty Shades Darker', 2012, 13.99),	
	(9,'Fifty Shades Freed', 2012, 13.99)

