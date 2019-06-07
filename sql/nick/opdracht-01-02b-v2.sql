USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

DECLARE @Year INT= 2019;
WITH YearCountryTotals(Year,
                       Country,
                       ItemsPerMonth)
     AS (SELECT YEAR(P.purchase_date) AS Year,
                U.country_name AS Country,
                COUNT(*) AS ItemsPerMonth
         FROM Purchase AS P
              INNER JOIN [User] AS U ON P.email_address = U.email_address
         GROUP BY YEAR(P.purchase_date),
                  U.country_name
         HAVING YEAR(P.purchase_date) = @Year),
     YearMonthCountryTotals(Countryname,
                            Month,
                            ItemsPerMonth,
                            TotalItems)
     AS (SELECT U.country_name AS Countryname,
                MONTH(P.purchase_date) AS Month,
                COUNT(*) AS ItemsPerMonth,
         (
             SELECT SUM(ItemsPerMonth)
             FROM YearCountryTotals AS YCT
             WHERE YCT.Country = U.country_name
         ) AS TotalItems
         FROM Purchase AS P
              INNER JOIN [User] AS U ON P.email_address = U.email_address
         GROUP BY YEAR(P.purchase_date),
                  MONTH(P.purchase_date),
                  U.country_name
         HAVING YEAR(P.purchase_date) = @Year)
     SELECT Countryname,
            FORMAT(ISNULL([1], 0) / ISNULL(TotalItems, 0), 'P') AS January,
            FORMAT(ISNULL([2], 0) / ISNULL(TotalItems, 0), 'P') AS February,
            FORMAT(ISNULL([3], 0) / ISNULL(TotalItems, 0), 'P') AS March,
            FORMAT(ISNULL([4], 0) / ISNULL(TotalItems, 0), 'P') AS April,
            FORMAT(ISNULL([5], 0) / ISNULL(TotalItems, 0), 'P') AS May,
            FORMAT(ISNULL([6], 0) / ISNULL(TotalItems, 0), 'P') AS June,
            FORMAT(ISNULL([7], 0) / ISNULL(TotalItems, 0), 'P') AS July,
            FORMAT(ISNULL([8], 0) / ISNULL(TotalItems, 0), 'P') AS August,
            FORMAT(ISNULL([9], 0) / ISNULL(TotalItems, 0), 'P') AS September,
            FORMAT(ISNULL([10], 0) / ISNULL(TotalItems, 0), 'P') AS October,
            FORMAT(ISNULL([11], 0) / ISNULL(TotalItems, 0), 'P') AS November,
            FORMAT(ISNULL([12], 0) / ISNULL(TotalItems, 0), 'P') AS December,
            TotalItems
     FROM YearMonthCountryTotals PIVOT(SUM(ItemsPerMonth) FOR Month IN([1],
                                                                       [2],
                                                                       [3],
                                                                       [4],
                                                                       [5],
                                                                       [6],
                                                                       [7],
                                                                       [8],
                                                                       [9],
                                                                       [10],
                                                                       [11],
                                                                       [12])) AS P;
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 1 ms.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
--
-- (2 rows affected)
-- Table 'Worktable'. Scan count 4, logical reads 13, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'User'. Scan count 0, logical reads 99, physical reads 2, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Purchase'. Scan count 3, logical reads 6, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 11 ms.
-- SQL Server parse and compile time:
--    CPU time = 0 ms, elapsed time = 0 ms.
