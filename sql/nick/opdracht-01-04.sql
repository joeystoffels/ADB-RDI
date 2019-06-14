-- 4.	In de oorspronkelijke data van IMDB staat in Imported_Director_Genre een veld Prob.
-- Dit geeft de kans dat een film in deze database van dat genre is.
-- Onderstaande query geeft de resultaten voor Sergio Leone.
-- SELECT *
-- FROM myimdb.dbo.Imported_Director_Genre
-- WHERE did = 46046
-- ORDER BY Prob
--
-- Staan deze gegevens in de juiste volgorde? Maak een query die deze gegevens produceert vanuit jouw eigen database op volgorde van kans, met de grootste kans bovenaan.

USE ODISEE;
GO
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
DECLARE @director INT= 65358;
WITH GenreMoviesPerDirector
     AS (SELECT P2.person_id,
                PG.genre_name, 
                COUNT(PG.genre_name) AS totalPerGenre
         FROM Movie_Director
              INNER JOIN Product P ON Movie_Director.product_id = P.product_id
              INNER JOIN Person P2 ON Movie_Director.person_id = P2.person_id
              INNER JOIN Product_Genre PG ON P.product_id = PG.product_id
         GROUP BY P2.person_id,
                  PG.genre_name
         HAVING P2.person_id = 65358),
     DirectorGenreProb
     AS (SELECT person_id, 
                first_name, 
                last_name, 
                genre_name, 
                CAST((totalPerGenre * 100.0 /
         (
             SELECT SUM(totalPerGenre)
             FROM GenreMoviesPerDirector
             GROUP BY person_id
         )) AS DECIMAL(4, 2)) AS Prob
         FROM GenreMoviesPerDirector)
     SELECT *
     FROM DirectorGenreProb
     ORDER BY Prob DESC;
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
--
-- (6 rows affected)
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product_Genre'. Scan count 34, logical reads 102, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Movie_Director'. Scan count 2, logical reads 4, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Person'. Scan count 0, logical reads 7, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
--  SQL Server Execution Times:
--    CPU time = 1 ms,  elapsed time = 1 ms.