USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

DECLARE @DIRECTOR_ID INT= 65358;
WITH cte
    AS (SELECT MD.person_id,
               PG.genre_name,
               COUNT(PG.genre_name) AS 'Total'
        FROM Movie_Director MD
             INNER JOIN Product_Genre PG ON MD.product_id = PG.product_id
        WHERE MD.person_id = @DIRECTOR_ID
        GROUP BY MD.person_id,
                 PG.genre_name)
    SELECT person_id,
           genre_name,
           CONVERT(DECIMAL(5, 2), Total * 100.0 / SUM(SUM(Total)) OVER(PARTITION BY 
           person_id)) AS 'Percentage'
    FROM cte
    GROUP BY person_id,
             genre_name,
             Total
    ORDER BY person_id,
             Percentage DESC;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
--
-- (6 rows affected)
-- Table 'Worktable'. Scan count 3, logical reads 17, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product_Genre'. Scan count 17, logical reads 51, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Movie_Director'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--     CPU time = 4 ms,  elapsed time = 3 ms.


--  --------------------------------------------------------
--  Create index
--  --------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_ReviewCategory_productId_score ON Review_Category(product_id,score);

--  --------------------------------------------------------
--  Remove index
--  --------------------------------------------------------
DROP INDEX IX_ReviewCategory_productId_score ON Review_Category;