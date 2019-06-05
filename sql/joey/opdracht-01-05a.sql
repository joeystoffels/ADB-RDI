USE ODISEE;
GO
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO
WITH cte
     AS (SELECT P.product_id + 1 AS 'GapStart', -- +1 to exclude the current product_id in the GapStart
                ISNULL(LEAD(P.product_id) OVER(
                ORDER BY P.product_id), 0) AS 'GapEnd', 
                ISNULL(LEAD(P.product_id) OVER(
                       ORDER BY P.product_id) - product_id, 0) AS 'Gap'
         FROM Product P
         WHERE P.product_type = 'Movie')
     SELECT TOP 1 [GapStart] - ISNULL([GapStart] - LAG([GapEnd]) OVER(
                                      ORDER BY [GapStart]), 0) AS 'Start',
                  [GapStart] AS 'End', 
                  ISNULL([GapStart] - LAG([GapEnd]) OVER(
                         ORDER BY [GapStart]), 0) AS 'NoGap'
     FROM cte
     WHERE Gap <> 1
     ORDER BY [NoGap] DESC;
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--    CPU time = 9 ms, elapsed time = 9 ms.
--
-- (1 row affected)
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product'. Scan count 5, logical reads 3350, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
--  SQL Server Execution Times:
--    CPU time = 1613 ms,  elapsed time = 1221 ms.