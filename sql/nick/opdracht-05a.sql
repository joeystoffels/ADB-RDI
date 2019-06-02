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
                MAX(product_id) AS [endID], 
                MAX(product_id) - MIN(product_id) AS length
         FROM DetectIslands
         GROUP BY diff)
     SELECT startID, 
            endID, 
            length
     FROM Islands
     WHERE length =
     (
         SELECT MAX(length)
         FROM Islands
     );
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


-- SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--    CPU time = 7 ms, elapsed time = 7 ms.
--
-- (1 row affected)
-- Table 'Product'. Scan count 2, logical reads 1740, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
--  SQL Server Execution Times:
--    CPU time = 1358 ms,  elapsed time = 795 ms.