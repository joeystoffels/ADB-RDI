-- Opdracht 3:
-- Mediaan: https://docs.microsoft.com/en-us/sql/t-sql/functions/percentile-disc-transact-sql?view=sql-server-2017
-- PERCENTILE_CONT(0.5): geeft gemiddelde, eventueel berekende, waarde van set
-- PERCENTILE_DISC(0.5): geeft middelste bestaande waarde van set

USE ODISEE;
GO
SELECT TOP 10
	   Y.product_id, 
       P.title, 
       Y.MedianDisc, 
       Y.MedianCont
FROM
(
    SELECT product_id, 
           score, 
           PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY product_id) AS MedianDisc, 
           PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY product_id) AS MedianCont
    FROM Review_Category R
) AS Y
JOIN Product P ON Y.product_id = P.product_id
WHERE P.product_type = 'Movie'
GROUP BY Y.product_id, 
         P.title, 
         Y.MedianDisc, 
         Y.MedianCont
ORDER BY Y.MedianDisc DESC;
GO