
/*
 4.	In de oorspronkelijke data van IMDB staat in Imported_Director_Genre een veld Prob.
 Dit geeft de kans dat een film in deze database van dat genre is.
 Onderstaande query geeft de resultaten voor Sergio Leone.

 SELECT *
 FROM myimdb.dbo.Imported_Director_Genre
 WHERE did = 46046
 ORDER BY Prob

 Staan deze gegevens in de juiste volgorde?
 Maak een query die deze gegevens produceert vanuit jouw eigen database op volgorde van kans, met de grootste kans bovenaan.
 */

DECLARE @director INT= 65358;
WITH GenresForDirectorCTE
     AS (SELECT MD.person_id, 
                MD.product_id, 
                PG.genre_name
         FROM Movie_Director MD
              INNER JOIN Product_Genre PG ON PG.product_id = MD.product_id
         WHERE person_id = @director)
     SELECT person_id, 
            genre_name, 
            CAST(100 /
     (
         SELECT CAST(COUNT(*) AS DECIMAL(4, 2))
         FROM GenresForDirectorCTE
     ) * (COUNT(*)) AS DECIMAL(4, 2)) AS Prob
     FROM GenresForDirectorCTE
     GROUP BY person_id, 
              genre_name
     ORDER BY Prob DESC;