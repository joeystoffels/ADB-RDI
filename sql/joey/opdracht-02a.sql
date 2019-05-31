USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

DECLARE @DATE DATE= GETDATE();
DECLARE @COUNTRY VARCHAR(255)= 'Netherlands';
WITH months
     AS (SELECT YEAR(@DATE) AS [Year], 
                MONTH(@DATE) AS [Month], 
                @DATE AS [Date]
         UNION ALL
         SELECT YEAR(DATEADD(MONTH, -1, M.[Date])) AS [Year], 
                MONTH(DATEADD(MONTH, -1, M.[Date])) AS [Month], 
                DATEADD(MONTH, -1, M.[Date]) AS [Date]
         FROM Months M
         WHERE DATEADD(MONTH, -1, M.[Date]) > DATEADD(YEAR, -1, @DATE)),
     cte2
     AS (SELECT YEAR(P.purchase_date) AS 'Year', 
                MONTH(P.purchase_date) AS 'Month'
         FROM Purchase P
              JOIN [User] U ON P.email_address = U.email_address
         WHERE U.country_name LIKE '%' + @COUNTRY + '%'
               AND P.purchase_date > DATEADD(YEAR, -1, @DATE)
         GROUP BY YEAR(purchase_date), 
                  MONTH(purchase_date)
         UNION
         SELECT [Year], 
                [Month]
         FROM months),
     cte3
     AS (SELECT YEAR(P.purchase_date) AS [Year], 
                MONTH(P.purchase_date) AS [Month], 
                COUNT(*) AS [ItemsPerMonth]
         FROM Purchase P
              JOIN [User] U ON P.email_address = U.email_address
         WHERE U.country_name LIKE '%' + @Country + '%'
               AND P.purchase_date > DATEADD(YEAR, -1, GETDATE())
         GROUP BY YEAR(purchase_date), 
                  MONTH(purchase_date))
     SELECT cte2.[Year], 
            cte2.[Month], 
            ISNULL(M.[ItemsPerMonth], 0) AS [ItemsPerMonth], 
            CONVERT(VARCHAR, CONVERT(DECIMAL(5, 2), ISNULL(M.[ItemsPerMonth], 0) * 100.0 / SUM(SUM(M.[ItemsPerMonth])) OVER())) + '%' AS [PercentageOfTotal]
     FROM cte2
          LEFT JOIN cte3 M ON M.[Year] = cte2.[Year]
                              AND M.[Month] = cte2.[Month]
     GROUP BY cte2.[Year], 
              cte2.[Month], 
              M.[ItemsPerMonth];

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


-- SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--     CPU time = 43 ms, elapsed time = 43 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 0 ms.
-- Warning: Null value is eliminated by an aggregate or other SET operation.
--
--     (12 rows affected)
--     Table 'Worktable'. Scan count 5, logical reads 102, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--     Table 'User'. Scan count 0, logical reads 66, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--     Table 'Purchase'. Scan count 13, logical reads 26, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
--     SQL Server Execution Times:
--     CPU time = 0 ms,  elapsed time = 10 ms.
