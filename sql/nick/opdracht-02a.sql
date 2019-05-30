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