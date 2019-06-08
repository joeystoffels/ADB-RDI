USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

WITH cte
     AS (SELECT P.product_id AS 'Start', 
                ISNULL(LEAD(P.product_id) OVER(
                ORDER BY P.product_id), 0) AS 'End', 
                ISNULL(LEAD(P.product_id) OVER(
                       ORDER BY P.product_id ASC) - product_id, 0) AS 'Gap'
         FROM Product P
         WHERE P.product_type = 'Movie')
     SELECT TOP 1 *
     FROM cte
     ORDER BY [Gap] DESC;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--    CPU time = 8 ms, elapsed time = 8 ms.
--
-- (1 row affected)
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product'. Scan count 5, logical reads 3350, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
--  SQL Server Execution Times:
--    CPU time = 1013 ms,  elapsed time = 650 ms.
-- SQL Server parse and compile time:
--    CPU time = 0 ms, elapsed time = 0 ms.
--
-- (4 rows affected)
-- Table 'Product'. Scan count 1, logical reads 7, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
