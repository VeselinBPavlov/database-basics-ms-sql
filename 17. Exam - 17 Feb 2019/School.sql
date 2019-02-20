-- Section 1. DDL (30 pts)
USE [master]
GO

CREATE DATABASE School
GO

USE School
GO

-- 01. Database Design
CREATE TABLE Students (
    Id INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(30) NOT NULL,
    MiddleName NVARCHAR(30),
    LastName NVARCHAR(30) NOT NULL,
    Age INT CHECK (Age >= 5 AND Age <= 100),
    [Address] NVARCHAR(50),
    Phone CHAR(10)
)

CREATE TABLE Subjects (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(20) NOT NULL,
    Lessons INT CHECK (Lessons > 0) NOT NULL
)

CREATE TABLE StudentsSubjects (
    Id INT PRIMARY KEY IDENTITY,
    StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
    SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
    Grade DECIMAL(15, 2) CHECK (Grade >= 2 AND GRADE <= 6) NOT NULL
)

CREATE TABLE Teachers (
    Id INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(20) NOT NULL,
    LastName NVARCHAR(20) NOT NULL,
    [Address] NVARCHAR(20) NOT NULL,
    Phone CHAR(10),
    SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsTeachers (
    StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
    TeacherId INT FOREIGN KEY REFERENCES Teachers(Id) NOT NULL,

    CONSTRAINT PK_StudentsTeachers 
    PRIMARY KEY  (StudentId, TeacherId)
)

CREATE TABLE Exams (
    Id INT PRIMARY KEY IDENTITY,
    [Date] DATETIME,
    SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsExams (
    StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
    ExamId INT FOREIGN KEY REFERENCES Exams(Id) NOT NULL,
    Grade DECIMAL(15, 2) CHECK (Grade >= 2 AND GRADE <= 6) NOT NULL,

    
    CONSTRAINT PK_StudentsExams
    PRIMARY KEY  (StudentId, ExamId)
)
GO

--Section 2. DML (10 pts)
-- 02. Insert 
INSERT INTO Teachers 
    ([FirstName], [LastName], [Address], [Phone], [SubjectId])
VALUES
    ('Ruthanne', 'Bamb', '84948 Mesta Junction', '3105500146', 6),
    ('Gerrard',	'Lowin', '370 Talisman Plaza', '3324874824', 2),
    ('Merrile',	'Lambdin', '81 Dahle Plaza', '4373065154', 5),
    ('Bert', 'Ivie', '2 Gateway Circle', '4409584510', 4)

INSERT INTO Subjects 
    ([Name], [Lessons])
VALUES
    ('Geometry',	12),
    ('Health',	10),
    ('Drama',	7),
    ('Sports',	9)
GO

-- 03. Update 
UPDATE StudentsSubjects
SET Grade = 6.00
WHERE SubjectId IN (1, 2)
AND GRADE >= 5.50
GO

-- 04. Delete
DELETE FROM StudentsTeachers
FROM StudentsTeachers AS s
INNER JOIN Teachers AS t ON s.TeacherId = t.Id
WHERE Phone LIKE ('%72%')

DELETE
FROM Teachers
WHERE Phone LIKE ('%72%')
GO

-- Section 3. Querying (40 pts)
-- 05. Teen Students 
SELECT FirstName, LastName, Age
FROM Students
WHERE AGE >= 12
ORDER BY FirstName ASC, LastName ASC
GO

-- 06. Cool Addresses
SELECT CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS FullName, [Address]
FROM Students
WHERE [Address] LIKE ('%road%')
ORDER BY FirstName ASC, LastName ASC, [Address] ASC
GO

-- 07. 42 Phones
SELECT FirstName, [Address], Phone
FROM Students
WHERE MiddleName IS NOT NULL
AND Phone LIKE ('42%')
ORDER BY FirstName ASC
GO

-- 08. Students Teachers 
SELECT s.FirstName, s.LastName, COUNT(TeacherId) AS Teachers
FROM Students AS s
LEFT JOIN StudentsTeachers AS st ON st.StudentId = s.Id
GROUP BY s.FirstName, s.LastName
GO

-- 09. Subjects with Students
SELECT CONCAT(t.FirstName, ' ', t.LastName) AS FullName, 
    CONCAT(su.[Name], '-', su.Lessons) AS Subjects, 
    COUNT(st.StudentId) AS Students
FROM Teachers AS t
JOIN Subjects AS su ON su.Id = t.SubjectId
JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
GROUP BY t.FirstName, t.LastName, su.[Name], su.Lessons
ORDER BY Students DESC
GO

-- 10. Students to Go
SELECT CONCAT(s.FirstName, ' ', s.LastName) AS FullName
FROM Students AS s
LEFT JOIN StudentsExams AS se ON se.StudentId = s.Id
WHERE se.ExamId IS NULL
ORDER BY FullName ASC
GO

-- 11. Busiest Teachers 
SELECT TOP(10) t.FirstName, t.LastName,
    COUNT(st.StudentId) AS Students
FROM Teachers AS t
JOIN Subjects AS su ON su.Id = t.SubjectId
JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
GROUP BY t.FirstName, t.LastName
ORDER BY Students DESC, t.FirstName ASC, t.LastName ASC
GO

-- 12. Top Students
SELECT TOP(10) s.FirstName, s.LastName, CAST(AVG(se.Grade) AS DECIMAL(15, 2)) AS Grade
FROM Students AS s
JOIN StudentsExams AS se ON se.StudentId = s.Id
GROUP BY s.FirstName, s.LastName
ORDER BY Grade DESC, s.FirstName ASC, s.LastName ASC
GO

-- 13. Second Highest Grade
SELECT h.FirstName, h.LastName, h.Grade
FROM (SELECT s.FirstName, s.LastName, ss.Grade,
        ROW_NUMBER() OVER (PARTITION BY s.Id ORDER BY ss.Grade DESC) AS Ranks
      FROM Students AS s
      JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id) AS h
WHERE Ranks = 2
ORDER BY h.FirstName ASC, h.LastName ASC
GO

-- 14. Not So In The Studying 
SELECT CONCAT(s.FirstName, ' ' + s.MiddleName, ' ', s.LastName) AS FullName
FROM Students AS s
LEFT JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id
WHERE SubjectId IS NULL
ORDER BY FullName ASC
GO

-- 15. Top Student per Teacher
SELECT
    d.TeacherFullName,
    d.SubjectName,
    d.StudentFullName,
    CAST(d.AverageGrade AS decimal(18,2)) AS Grade
FROM(SELECT
         t.FirstName + ' ' + t.LastName AS TeacherFullName,
         sub.[Name] AS SubjectName,
         s.FirstName + ' ' + s.LastName AS StudentFullName,
         RANK() OVER (PARTITION BY t.FirstName ORDER BY AVG(ss.Grade) DESC) AS GradeRank,
         AVG(ss.Grade) AS AverageGrade
     FROM Teachers AS t
     JOIN Subjects AS sub ON sub.Id = t.SubjectId
     JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
     JOIN Students AS s ON s.Id = st.StudentId
     JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id AND ss.SubjectId = sub.Id
     GROUP BY t.FirstName, t.LastName, sub.[Name], s.FirstName, s.LastName) AS d
WHERE d.GradeRank = 1   
ORDER BY d.SubjectName, d.TeacherFullName, d.AverageGrade DESC

-- 16. Average Grade per Subject 
SELECT t.FirstName, su.Name, stu.FirstName, AVG(ss.Grade)
FROM Teachers AS t
JOIN Subjects AS su ON su.Id = t.SubjectId
JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
JOIN StudentsSubjects AS ss ON ss.StudentId = st.StudentId
JOIN Students AS stu ON stu.Id = ss.StudentId
GROUP BY t.FirstName, su.Name, stu.FirstName
ORDER BY su.Name,  AVG(ss.Grade) DESC
GO

-- 17. Exams Information 
SELECT DISTINCT
    CASE
        WHEN e.[Date] IS NULL THEN 'TBA'
        WHEN DATEPART(QUARTER, e.[Date]) = 1 THEN 'Q1'
        WHEN DATEPART(QUARTER, e.[Date]) = 2 THEN 'Q2'
        WHEN DATEPART(QUARTER, e.[Date]) = 3 THEN 'Q3'
        WHEN DATEPART(QUARTER, e.[Date]) = 4 THEN 'Q4'
    END AS Quarter,
    sub.[Name] AS SubjectName,
    COUNT(e.Id) AS StudentsCount
FROM Subjects AS sub
JOIN Exams AS e ON e.SubjectId = sub.Id
JOIN StudentsExams AS se ON se.ExamId = e.Id
WHERE se.Grade >= 4.00
GROUP BY e.[Date], sub.[Name], COUNT(e.Id) AS StudentsCount
ORDER BY Quarter ASC
GO

-- Section 4. Programmability (20 pts)
-- 18. Exam Grades 
CREATE FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(15, 2))
RETURNS NVARCHAR(MAX)
BEGIN
    IF (@grade > 6.00)
    BEGIN
        RETURN 'Grade cannot be above 6.00!'
    END

    DECLARE @Student INT = (SELECT Id FROM Students WHERE Id = @studentId);

    IF (@Student IS NULL)
    BEGIN
        RETURN 'The student with provided id does not exist in the school!';
    END 

    DECLARE @StudentName NVARCHAR(30) = (SELECT FirstName FROM Students WHERE Id = @studentId)
    DECLARE @GradesCount NVARCHAR(10) = (SELECT COUNT(*) AS CountGrade
                            FROM StudentsExams AS se
                            JOIN Exams AS e ON e.Id = se.ExamId
                            JOIN Students AS s ON s.Id = se.StudentId
                            WHERE s.Id = @Student AND se.Grade >= @grade AND se.Grade <= @grade + 0.50
                            GROUP BY s.FirstName)


    RETURN 'You have to update ' + @GradesCount + ' grades for the student ' + @StudentName;
END
GO

SELECT dbo.udf_ExamGradesToUpdate(12, 5.50)
GO 
-- 19. Exclude from school
CREATE PROCEDURE usp_ExcludeFromSchool(@StudentId INT) AS
BEGIN
    DECLARE @Student INT = (SELECT Id FROM Students WHERE Id = @StudentId)

    IF (@Student IS NULL)
    BEGIN 
        RAISERROR('This school has no student with the provided id!', 16, 2);
    END

    DELETE 
    FROM StudentsTeachers
    WHERE StudentId = @Student

    DELETE 
    FROM StudentsSubjects
    WHERE StudentId = @Student

    DELETE 
    FROM StudentsExams
    WHERE StudentId = @Student

    DELETE 
    FROM Students
    WHERE Id = @Student
END

-- 20. Deleted Student
CREATE TABLE ExcludedStudents (
    StudentId INT PRIMARY KEY IDENTITY,
    StudentName NVARCHAR(100) NOT NULL
)
GO

CREATE TRIGGER tr_ExcludedStudents ON Students
AFTER DELETE AS
BEGIN
	INSERT INTO ExcludedStudents
	SELECT Id, CONCAT(FirstName, ' ', LastName)
	FROM deleted
END
GO