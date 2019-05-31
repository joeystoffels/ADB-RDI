USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

DECLARE @Country VARCHAR(MAX)= 'The Netherlands';
DECLARE @Month INT= 4;
DECLARE @Year INT= 2019;
SELECT YEAR(P.purchase_date) AS Year,
       MONTH(P.purchase_date) AS Month, 
       COUNT(*) AS ItemsPerMonth, 
       CONCAT(CONVERT(DECIMAL(4, 2), (100 /
(
    SELECT CONVERT(DECIMAL(4, 2), COUNT(*))
    FROM Purchase P
         INNER JOIN [User] AS U ON P.email_address = U.email_address
    WHERE U.country_name = 'The Netherlands'
))) * COUNT(*), '%') AS PercentageOfTotal
FROM Purchase P
     INNER JOIN [User] AS U ON P.email_address = U.email_address
WHERE U.country_name = 'The Netherlands'
      AND ((YEAR(P.purchase_date) = @Year
                      AND MONTH(P.purchase_date) <= @Month)
                     OR (YEAR(P.purchase_date) = (@Year - 1)
                         AND MONTH(P.purchase_date) > @Month))
GROUP BY U.country_name, 
         YEAR(P.purchase_date), 
         MONTH(P.purchase_date);

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--    CPU time = 24 ms, elapsed time = 24 ms.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
--
-- (1 row affected)
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'User'. Scan count 1, logical reads 35, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Purchase'. Scan count 35, logical reads 70, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 57 ms.
