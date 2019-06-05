USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

DECLARE @Country VARCHAR(MAX)= 'The Netherlands';
DECLARE @Month INT= 4;
DECLARE @Year INT= 2019;
WITH YearMonthCountryTotals(Year, 
                            Month, 
                            Country, 
                            ItemsPerMonth)
     AS (SELECT YEAR(P.purchase_date) AS Year, 
                MONTH(P.purchase_date) AS Month, 
                U.country_name AS Country, 
                COUNT(*) AS ItemsPerMonth
         FROM Purchase AS P
              INNER JOIN [User] AS U ON P.email_address = U.email_address
         GROUP BY YEAR(P.purchase_date), 
                  MONTH(P.purchase_date), 
                  U.country_name
         HAVING U.country_name = @Country
                AND ((YEAR(P.purchase_date) = @Year
                      AND MONTH(P.purchase_date) <= @Month)
                     OR (YEAR(P.purchase_date) = (@Year - 1)
                         AND MONTH(P.purchase_date) > @Month)))
     SELECT YMT1.Year, 
            YMT1.Month, 
            YMT1.ItemsPerMonth, 
            FORMAT(YMT1.ItemsPerMonth / SUM(YMT1.ItemsPerMonth), 'P') AS PercentageOfTotal
     FROM YearMonthCountryTotals AS YMT1
     GROUP BY YMT1.Year, 
              YMT1.Month, 
              YMT1.ItemsPerMonth, 
              YMT1.Country;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 2 ms.
-- SQL Server parse and compile time:
--    CPU time = 15 ms, elapsed time = 15 ms.
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
-- Table 'User'. Scan count 0, logical reads 33, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Purchase'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 79 ms.
