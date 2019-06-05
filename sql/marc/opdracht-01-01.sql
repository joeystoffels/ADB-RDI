USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

DECLARE @MovieInReeks INT= 207989;
WITH moviereeks
     AS (SELECT product_id, 
                title, 
                previous_product_id, 
                publication_year
         FROM product
         WHERE product_id = @MovieInReeks
         UNION
         SELECT product_id, 
                title, 
                previous_product_id, 
                publication_year
         FROM product
         WHERE previous_product_id = @MovieInReeks
         UNION ALL
         SELECT P.product_id, 
                P.title, 
                P.previous_product_id, 
                P.publication_year
         FROM product P
              JOIN moviereeks M ON P.product_id = M.previous_product_id)
     SELECT product_id AS ITEM_ID, 
            title AS TITLE, 
            ROW_NUMBER() OVER(
            ORDER BY publication_year) AS Volgnummer
     FROM moviereeks
     GROUP BY product_id, 
              title, 
              publication_year;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


-- SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--     CPU time = 13 ms, elapsed time = 13 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
--
-- (3 rows affected)
-- Table 'Worktable'. Scan count 2, logical reads 29, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product'. Scan count 1, logical reads 3366, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--     CPU time = 58 ms,  elapsed time = 57 ms.
