USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

WITH onderbrokenReeksCTE
     AS (SELECT product_id AS eindID, 
                LAG(product_id) OVER(
                ORDER BY product_id) AS startID, 
                (product_id - LAG(product_id) OVER(
                 ORDER BY product_id)) AS maxReeksLeeg
         FROM Product
         WHERE product_type = 'Movie')
     SELECT startID, 
            eindID, 
            maxReeksLeeg
     FROM onderbrokenReeksCTE
     WHERE maxReeksLeeg =
     (
         SELECT MAX(maxReeksLeeg)
         FROM onderbrokenReeksCTE
     );

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--    CPU time = 15 ms, elapsed time = 29 ms.
-- Warning: Null value is eliminated by an aggregate or other SET operation.
--
-- (1 row affected)
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product'. Scan count 10, logical reads 6700, physical reads 0, read-ahead reads 3343, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
--  SQL Server Execution Times:
--    CPU time = 1422 ms,  elapsed time = 1110 ms.
