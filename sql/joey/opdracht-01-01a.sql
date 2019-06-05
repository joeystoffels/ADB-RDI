USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

DECLARE @MovieInReeks INT= 207989;
WITH children
     AS (SELECT P.product_id, P.previous_product_id, P.publication_year, P.title
         FROM Product P
         WHERE P.product_id = @MovieInReeks
         UNION ALL
         SELECT child.product_id, child.previous_product_id, child.publication_year, child.title
         FROM Product AS child
              INNER JOIN children parent ON parent.previous_product_id = child.product_id),
     parents
     AS (SELECT p.product_id, p.previous_product_id, p.publication_year, p.title
         FROM Product p
         WHERE p.product_id = @MovieInReeks
         UNION ALL
         SELECT super.product_id, super.previous_product_id ,super.publication_year, super.title
         FROM Product AS super
              INNER JOIN parents parent ON parent.product_id = super.previous_product_id)
     SELECT product_id AS PRODUCT_ID, 
            title AS TITLE, 
            ROW_NUMBER() OVER(
            ORDER BY publication_year ASC) AS Volgnummer
     FROM
     (
         SELECT *
         FROM children
         UNION
         SELECT *
         FROM parents
     ) AS result;
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
--
-- (3 rows affected)
-- Table 'Product'. Scan count 1, logical reads 6712, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Worktable'. Scan count 4, logical reads 26, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--    CPU time = 124 ms,  elapsed time = 126 ms.
-- SQL Server parse and compile time:
--    CPU time = 0 ms, elapsed time = 0 ms.