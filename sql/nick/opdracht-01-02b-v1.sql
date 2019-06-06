USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

DECLARE @Year INT= 2019;
WITH YearMonthCountryTotals(Countryname, 
                            Month, 
                            ItemsPerMonth)
     AS (SELECT U.country_name AS Countryname, 
                MONTH(P.purchase_date) AS Month, 
                COUNT(*) AS ItemsPerMonth
         FROM Purchase AS P
              INNER JOIN [User] AS U ON P.email_address = U.email_address
         GROUP BY YEAR(P.purchase_date), 
                  MONTH(P.purchase_date), 
                  U.country_name
         HAVING YEAR(P.purchase_date) = @Year)
     SELECT A.Countryname, 
            FORMAT(ISNULL(SUM(A.January), 0) / ISNULL(SUM(ItemsPerMonth), 0), 'P') AS January, 
            FORMAT(ISNULL(SUM(A.February), 0) / ISNULL(SUM(ItemsPerMonth), 0), 'P') AS February, 
            FORMAT(ISNULL(SUM(A.March), 0) / ISNULL(SUM(ItemsPerMonth), 0), 'P') AS March, 
            FORMAT(ISNULL(SUM(A.April), 0) / ISNULL(SUM(ItemsPerMonth), 0), 'P') AS April, 
            FORMAT(ISNULL(SUM(A.May), 0) / ISNULL(SUM(ItemsPerMonth), 0), 'P') AS May, 
            FORMAT(ISNULL(SUM(A.June), 0) / ISNULL(SUM(ItemsPerMonth), 0), 'P') AS June, 
            FORMAT(ISNULL(SUM(A.July), 0) / ISNULL(SUM(ItemsPerMonth), 0), 'P') AS July, 
            FORMAT(ISNULL(SUM(A.August), 0) / ISNULL(SUM(ItemsPerMonth), 0), 'P') AS August, 
            FORMAT(ISNULL(SUM(A.September), 0) / ISNULL(SUM(ItemsPerMonth), 0), 'P') AS September, 
            FORMAT(ISNULL(SUM(A.October), 0) / ISNULL(SUM(ItemsPerMonth), 0), 'P') AS October, 
            FORMAT(ISNULL(SUM(A.November), 0) / ISNULL(SUM(ItemsPerMonth), 0), 'P') AS November, 
            FORMAT(ISNULL(SUM(A.December), 0) / ISNULL(SUM(ItemsPerMonth), 0), 'P') AS December, 
            SUM(ItemsPerMonth) AS TotalItems
     FROM
     (
         SELECT Countryname,
                CASE
                    WHEN Month = 1
                    THEN ItemsPerMonth
                END AS January,
                CASE
                    WHEN Month = 2
                    THEN ItemsPerMonth
                END AS February,
                CASE
                    WHEN Month = 3
                    THEN ItemsPerMonth
                END AS March,
                CASE
                    WHEN Month = 4
                    THEN ItemsPerMonth
                END AS April,
                CASE
                    WHEN Month = 5
                    THEN ItemsPerMonth
                END AS May,
                CASE
                    WHEN Month = 6
                    THEN ItemsPerMonth
                END AS June,
                CASE
                    WHEN Month = 7
                    THEN ItemsPerMonth
                END AS July,
                CASE
                    WHEN Month = 8
                    THEN ItemsPerMonth
                END AS August,
                CASE
                    WHEN Month = 9
                    THEN ItemsPerMonth
                END AS September,
                CASE
                    WHEN Month = 10
                    THEN ItemsPerMonth
                END AS October,
                CASE
                    WHEN Month = 11
                    THEN ItemsPerMonth
                END AS November,
                CASE
                    WHEN Month = 12
                    THEN ItemsPerMonth
                END AS December, 
                ItemsPerMonth
         FROM YearMonthCountryTotals
     ) AS A
     GROUP BY A.Countryname;
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO