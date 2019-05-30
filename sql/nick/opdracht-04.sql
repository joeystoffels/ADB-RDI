-- 4.	In de oorspronkelijke data van IMDB staat in Imported_Director_Genre een veld Prob.
-- Dit geeft de kans dat een film in deze database van dat genre is.
-- Onderstaande query geeft de resultaten voor Sergio Leone.
-- SELECT *
-- FROM myimdb.dbo.Imported_Director_Genre
-- WHERE did = 46046
-- ORDER BY Prob
--
-- Staan deze gegevens in de juiste volgorde? Maak een query die deze gegevens produceert vanuit jouw eigen database op volgorde van kans, met de grootste kans bovenaan.

SELECT P2.first_name, 
       P2.last_name
FROM Movie_Director
     INNER JOIN Product P ON Movie_Director.product_id = P.product_id
     INNER JOIN Person P2 ON Movie_Director.person_id = P2.person_id;
SELECT *
FROM Person
WHERE EXISTS
(
    SELECT person_id
    FROM Movie_Director
);
WITH GenreMoviesPerDirectory
     AS (SELECT P2.person_id, 
                P2.first_name, 
                P2.last_name, 
                PG.genre_name, 
                COUNT(PG.genre_name) AS TotalGenre, 
                SUM()
         FROM Movie_Director
              INNER JOIN Product P ON Movie_Director.product_id = P.product_id
              INNER JOIN Person P2 ON Movie_Director.person_id = P2.person_id
              INNER JOIN Product_Genre PG ON P.product_id = PG.product_id
         GROUP BY P2.person_id, 
                  P2.first_name, 
                  P2.last_name, 
                  PG.genre_name)
     SELECT person_id, 
            first_name, 
            last_name, 
            genre_name, 
            MAX(Total), 
            SUM(Total)
     FROM GenreMoviesPerDirectory
     GROUP BY person_id, 
              first_name, 
              last_name, 
              genre_name
     HAVING Total = MAX(Total);