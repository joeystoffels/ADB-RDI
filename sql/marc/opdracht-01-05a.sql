
USE ODISEE;
GO
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO
WITH aaneengeslotenReeksCTE
     AS (SELECT MIN(product_id) AS startID, 
                MAX(product_id) AS eindID, 
                (COUNT(*)-1) AS maxReeksBestaand
         FROM
         (
             SELECT product_id, 
                    product_id - ROW_NUMBER() OVER(
                    ORDER BY product_id) AS resultaatVerschil
             FROM Product
             WHERE product_type = 'Movie'
         ) qry
         GROUP BY resultaatVerschil)
     SELECT startID, 
            eindID, 
            maxReeksBestaand
     FROM aaneengeslotenReeksCTE
     WHERE maxReeksBestaand =
     (
         SELECT MAX(maxReeksBestaand)
         FROM aaneengeslotenReeksCTE
     );
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--    CPU time = 17 ms, elapsed time = 17 ms.
--
-- (1 row affected)
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product'. Scan count 10, logical reads 6700, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
--  SQL Server Execution Times:
--    CPU time = 2149 ms,  elapsed time = 1256 ms.