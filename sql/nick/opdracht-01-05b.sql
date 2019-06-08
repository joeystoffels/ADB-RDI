USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

WITH DetectIslands
     AS (SELECT ROW_NUMBER() OVER(
                ORDER BY product_id) AS rn, 
                product_id, 
                product_id - ROW_NUMBER() OVER(
                ORDER BY product_id) AS diff
         FROM Product),
     Islands
     AS (SELECT MIN(product_id) AS [startID], 
                MAX(product_id) AS [endID]
         FROM DetectIslands
         GROUP BY diff)
     SELECT *
     FROM Islands AS I;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--    CPU time = 15 ms, elapsed time = 30 ms.
--
-- (14710 rows affected)
-- Table 'Product'. Scan count 1, logical reads 870, physical reads 2, read-ahead reads 856, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
--  SQL Server Execution Times:
--    CPU time = 563 ms,  elapsed time = 397 ms.
