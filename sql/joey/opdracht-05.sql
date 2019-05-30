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

-- Tel aaneengesloten MovieId's
WITH cte
     AS (SELECT P.product_id + 1 AS 'GapStart', -- +1 to exclude the current product_id in the GapStart
                ISNULL(LEAD(P.product_id) OVER(
                ORDER BY P.product_id), 0) AS 'GapEnd', 
                ISNULL(LEAD(P.product_id) OVER(
                       ORDER BY P.product_id ASC) - product_id, 0) AS 'Gap'
         FROM Product P
         WHERE P.product_type = 'Movie')
     SELECT TOP 1 [GapStart] - ISNULL([GapStart] - LAG([GapEnd]) OVER(
                                      ORDER BY [GapStart] ASC), 0) AS 'Start', 
                  [GapStart] AS 'End', 
                  ISNULL([GapStart] - LAG([GapEnd]) OVER(
                         ORDER BY [GapStart] ASC), 0) AS 'NoGap'
     FROM cte
     WHERE Gap <> 1
     ORDER BY [NoGap] DESC;

-- Check query
SELECT *
FROM PRODUCT P
WHERE product_id BETWEEN 381682 AND 382236;