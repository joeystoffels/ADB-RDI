USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

DECLARE @Year INT= 2019;
SELECT country_name AS CountryName, 
       ISNULL([january], '0.00%') AS January, 
       ISNULL([february], '0.00%') AS February, 
       ISNULL([march], '0.00%') AS March, 
       ISNULL([april], '0.00%') AS April, 
       ISNULL([may], '0.00%') AS May, 
       ISNULL([june], '0.00%') AS June, 
       ISNULL([july], '0.00%') AS July, 
       ISNULL([august], '0.00%') AS August, 
       ISNULL([september], '0.00%') AS September, 
       ISNULL([october], '0.00%') AS October, 
       ISNULL([november], '0.00%') AS November, 
       ISNULL([december], '0.00%') AS December, 
(
    SELECT COUNT(purchase_date)
    FROM purchase
         INNER JOIN [user] u ON purchase.email_address = u.email_address
    WHERE pivotresult.country_name = u.country_name
) AS TotalItems
FROM
(
    SELECT u1.country_name, 
           Datename(month, p1.purchase_date) AS month, 
           CONCAT(CONVERT(DECIMAL(5, 2), (100 /
    (
        SELECT CONVERT(DECIMAL(5, 2), COUNT(*))
        FROM purchase p3
             INNER JOIN [user] u3 ON p3.email_address = u3.email_address
        WHERE u1.country_name = u3.country_name
        GROUP BY u3.country_name
    ) *
    (
        SELECT COUNT(*)
        FROM purchase p2
             INNER JOIN [user] u2 ON p2.email_address = u2.email_address
        WHERE u2.country_name = u1.country_name
    ))), '%') AS percentage
    FROM purchase p1
         INNER JOIN [user] u1 ON p1.email_address = u1.email_address
    WHERE YEAR(p1.purchase_date) = @Year
    GROUP BY u1.country_name, 
             Datename(month, p1.purchase_date)
) AS PivotData PIVOT(MAX(percentage) FOR pivotdata.month IN([January], 
                                                            [February], 
                                                            [March], 
                                                            [April], 
                                                            [May], 
                                                            [June], 
                                                            [July], 
                                                            [August], 
                                                            [September], 
                                                            [October], 
                                                            [November], 
                                                            [December])) AS PivotResult;
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
-- (2 rows affected)
-- Table 'Purchase'. Scan count 66, logical reads 132, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'User'. Scan count 2, logical reads 169, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Worktable'. Scan count 8, logical reads 26, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 1 ms.
-- SQL Server parse and compile time:
--    CPU time = 0 ms, elapsed time = 0 ms.
