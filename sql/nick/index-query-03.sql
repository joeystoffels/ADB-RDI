USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

SELECT TOP 10
     Y.product_id,
      P.title,
      Y.MedianCont
FROM
(
   SELECT product_id,
          score,
          PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY 
          product_id) AS MedianCont
   FROM Review_Category R
) AS Y
JOIN Product P ON Y.product_id = P.product_id
WHERE P.product_type = 'Movie'
GROUP BY Y.product_id,
        P.title,
        Y.MedianCont
ORDER BY Y.MedianCont DESC;
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


-- SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--    CPU time = 0 ms, elapsed time = 0 ms.
--
-- (10 rows affected)
-- Table 'Product'. Scan count 0, logical reads 38, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Worktable'. Scan count 6, logical reads 322, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Review_Category'. Scan count 1, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--    CPU time = 5 ms,  elapsed time = 5 ms.
-- SQL Server parse and compile time:
--    CPU time = 0 ms, elapsed time = 0 ms.



--  --------------------------------------------------------
--  Create index
--  --------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_ReviewCategory_productId_score ON Review_Category(product_id,score);

--  --------------------------------------------------------
--  Remove index
--  --------------------------------------------------------
DROP INDEX IX_ReviewCategory_productId_score ON Review_Category;