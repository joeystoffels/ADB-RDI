-- Opdracht 4:
-- Isolation level  + overwegingen bij SP's in casus weergeven
USE ODISEE;
GO
DECLARE @DIRECTOR_ID INT= 65358;
WITH cte
     AS (SELECT MD.person_id,
                PG.genre_name,
                COUNT(PG.genre_name) AS 'Total'
         FROM Movie_Director MD
              INNER JOIN Product_Genre PG ON MD.product_id = PG.product_id
         WHERE MD.person_id = @DIRECTOR_ID
         GROUP BY MD.person_id,
                  PG.genre_name)
     SELECT person_id, 
            genre_name, 
            CONVERT(DECIMAL(5, 2), Total * 100.0 / SUM(SUM(Total)) OVER(PARTITION BY person_id)) AS 'Percentage'
     FROM cte
     GROUP BY person_id, 
              genre_name, 
              Total
     ORDER BY person_id, 
              Percentage DESC;
GO