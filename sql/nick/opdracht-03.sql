-- 3.	Geef de 10 films met de hoogste mediaan van hun reviews.
-- Wat zegt dit getal over een film?
-- https://sqlperformance.com/2012/08/t-sql-queries/median

WITH ReviewScoreCalculate
     AS (SELECT DISTINCT 
				P.product_id,
                P.title, 
                PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY RC.product_id) AS median_score
         FROM Review_Category AS RC
              INNER JOIN Product AS P ON P.product_id = RC.product_id
         WHERE P.product_type = 'Movie'),
     ReviewScore
     AS (SELECT ROW_NUMBER() OVER(
                ORDER BY median_score DESC) AS nr, 
                title, 
                DENSE_RANK() OVER(
                ORDER BY median_score DESC) AS rank, 
                median_score,
				product_id
         FROM ReviewScoreCalculate)
     SELECT product_id,
            title, 
            median_score,
			nr
     FROM ReviewScore
     WHERE nr <= 10
     ORDER BY rank;