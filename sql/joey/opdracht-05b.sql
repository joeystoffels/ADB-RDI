-- Opdracht 5
USE ODISEE;
GO

-- Tel gaps tussen MovieId's
WITH cte
     AS (SELECT P.product_id AS 'Start', 
                ISNULL(LEAD(P.product_id) OVER(
                ORDER BY P.product_id), 0) AS 'End', 
                ISNULL(LEAD(P.product_id) OVER(
                       ORDER BY P.product_id ASC) - 1 - product_id, 0) AS 'Gap'
         FROM Product P
         WHERE P.product_type = 'Movie')
     SELECT TOP 1 *
     FROM cte
     ORDER BY [Gap] DESC;

-- Check query
SELECT *
FROM Product P
WHERE product_id BETWEEN 249922 AND 250371;