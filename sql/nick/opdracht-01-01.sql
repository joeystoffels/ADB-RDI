USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

CREATE TABLE #MovieSeries
(ITEM_ID    INT NOT NULL, 
 TITLE      VARCHAR(255), 
 Volgnummer INT,
);
DECLARE @MovieInReeks INT= 207989;
DECLARE @previous_movie INT= @MovieInReeks;
DECLARE @next_movie INT= @MovieInReeks;
DECLARE @count INT= 0;
INSERT INTO #MovieSeries
(ITEM_ID, 
 TITLE, 
 Volgnummer
)
       SELECT product_id, 
              title, 
              @count
       FROM Product
       WHERE product_id = @MovieInReeks;
WHILE @previous_movie IS NOT NULL
    BEGIN
        PRINT @previous_movie;
        SET @previous_movie =
        (
            SELECT Parent.product_id
            FROM Product AS Parent
                 FULL JOIN Product AS Child ON Child.previous_product_id = Parent.product_id
            WHERE Child.product_id = @previous_movie
        );
        IF @previous_movie IS NOT NULL
            SET @count = @count - 1;
        INSERT INTO #MovieSeries
        (ITEM_ID, 
         TITLE, 
         Volgnummer
        )
               SELECT product_id, 
                      title, 
                      @count
               FROM Product
               WHERE product_id = @previous_movie;
    END;
SET @count = 0;
WHILE @next_movie IS NOT NULL
    BEGIN
        SET @next_movie =
        (
            SELECT product_id
            FROM Product
            WHERE previous_product_id = @next_movie
        );
        IF @next_movie IS NOT NULL
            SET @count = @count + 1;
        INSERT INTO #MovieSeries
        (ITEM_ID, 
         TITLE, 
         Volgnummer
        )
               SELECT product_id, 
                      title, 
                      @count
               FROM Product
               WHERE product_id = @next_movie;
    END;
SELECT ITEM_ID, 
       TITLE, 
       ROW_NUMBER() OVER(
       ORDER BY Volgnummer ASC) AS Volgnummer
FROM #MovieSeries
ORDER BY Volgnummer;
DROP TABLE #MovieSeries;
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--     CPU time = 1 ms,  elapsed time = 1 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--     CPU time = 2 ms, elapsed time = 2 ms.
-- Table '#MovieSeries________________________________________________________________________________________________________000000000006'. Scan count 0, logical reads 1, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product'. Scan count 0, logical reads 4, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--     CPU time = 2 ms,  elapsed time = 1 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- 207989
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- Table 'Product'. Scan count 0, logical reads 7, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--     CPU time = 2 ms,  elapsed time = 2 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--     CPU time = 1 ms, elapsed time = 1 ms.
-- Table '#MovieSeries________________________________________________________________________________________________________000000000006'. Scan count 0, logical reads 1, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product'. Scan count 0, logical reads 4, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--     CPU time = 2 ms,  elapsed time = 1 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- 207992
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- Table 'Product'. Scan count 0, logical reads 4, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--     CPU time = 8 ms,  elapsed time = 7 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- Table '#MovieSeries________________________________________________________________________________________________________000000000006'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (0 rows affected)
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--     CPU time = 2 ms,  elapsed time = 2 ms.
--
--  SQL Server Execution Times:
--     CPU time = 1 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- Table 'Product'. Scan count 1, logical reads 3350, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--     CPU time = 53 ms,  elapsed time = 52 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--     CPU time = 1 ms, elapsed time = 1 ms.
-- Table '#MovieSeries________________________________________________________________________________________________________000000000006'. Scan count 0, logical reads 1, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product'. Scan count 0, logical reads 4, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--     CPU time = 2 ms,  elapsed time = 1 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- Table 'Product'. Scan count 1, logical reads 3350, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--     CPU time = 48 ms,  elapsed time = 48 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- Table '#MovieSeries________________________________________________________________________________________________________000000000006'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (0 rows affected)
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--     CPU time = 1 ms,  elapsed time = 1 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--     CPU time = 1 ms, elapsed time = 1 ms.
--
-- (3 rows affected)
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table '#MovieSeries________________________________________________________________________________________________________000000000006'. Scan count 1, logical reads 1, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--     CPU time = 2 ms,  elapsed time = 1 ms.
--
--  SQL Server Execution Times:
--     CPU time = 1 ms,  elapsed time = 1 ms.
-- SQL Server parse and compile time:
--     CPU time = 0 ms, elapsed time = 0 ms.

