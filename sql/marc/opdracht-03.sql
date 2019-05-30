-- 3.	Geef de 10 films met de hoogste mediaan van hun reviews. Wat zegt dit getal over een film?

/*
 In deze versie een distinct gebruikt. Krijg namelijk meerdere rijen terug doordat scores per film over meerdere
 rijen zijn verdeeld.
 */

WITH MediaanCTE
     AS (SELECT DISTINCT 
                P.title AS FilmTitel, 
                AVG(CAST(RC.score AS DECIMAL(3, 1))) OVER(PARTITION BY RC.product_id) AS Mediaan
         FROM Review_Category RC
              INNER JOIN Product P ON P.product_id = RC.product_id),
     RankCTE
     AS (SELECT FilmTitel, 
                DENSE_RANK() OVER(
                ORDER BY Mediaan DESC, 
                         FilmTitel) AS Rank
         FROM MediaanCTE)
     SELECT c.FilmTitel, 
            c.Mediaan, 
            DENSE_RANK() OVER(
            ORDER BY c.Mediaan DESC, 
                     C.FilmTitel) AS Rank
     FROM MediaanCTE c
          INNER JOIN RankCTE r ON c.FilmTitel = r.FilmTitel
     WHERE Rank <= 10
     ORDER BY Mediaan DESC;