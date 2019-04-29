-- OPDRACHT 02
-- 2.	Geef het statement dat per land het maandgebruik over 12 maanden geeft met daarbij het percentage dat die maand uitmaakt van het totaal van die 12 maanden.
-- Hier zijn twee interpretaties mogelijk: per land de afgelopen 12 maanden in rijen, hier onder de uitdraai voor b.v. ‘Netherlands’ uitgevoerd in april 2019.
--
-- Year	Month	ItemsPerMonth	PercentageOfTotal
-- 2018	4	60		4.44%
-- 2018	5	60		4.44%
-- 2018	6	60		4.44%
-- 2018	7	56		4.14%
-- 2018	8	132		9.76%
-- 2018	9	155		11.46%
-- 2018	10	141		10.43%
-- 2018	11	138		10.21%
-- 2018	12	148		10.95%
-- 2019	1	137		10.13%
-- 2019	2	117		8.65%
-- 2019	3	148		10.95%

DECLARE    @Country VARCHAR(MAX) = 'The Netherlands';
DECLARE    @Month INT = 4;
DECLARE    @Year INT = 2019;

;WITH  YearMonthCountryTotals (Year, Month, Country, ItemsPerMonth) AS (
    SELECT YEAR(P.purchase_date)        AS Year,
           MONTH(P.purchase_date)       AS Month,
           U.country_name               AS Country,
           COUNT(*)                     AS ItemsPerMonth
    FROM Purchase AS P
             INNER JOIN [User] AS U ON P.email_address = U.email_address
    GROUP BY YEAR(P.purchase_date), MONTH(P.purchase_date), U.country_name
    HAVING U.country_name = @Country
       AND ((YEAR(P.purchase_date)  = @Year AND  MONTH(P.purchase_date) <= @Month) OR (YEAR(P.purchase_date)  = (@Year - 1) AND  MONTH(P.purchase_date) > @Month))
)
 SELECT
     YMT1.Year,
     YMT1.Month,
     YMT1.ItemsPerMonth,
     FORMAT(YMT1.ItemsPerMonth / SUM(YMT1.ItemsPerMonth), 'P') AS PercentageOfTotal
 FROM YearMonthCountryTotals AS YMT1
 GROUP BY YMT1.Year,YMT1.Month, YMT1.ItemsPerMonth, YMT1.Country




--
-- Een mooier alternatief is een statement dat per land de percentages en totalen geeft over een jaar in kolommen.
-- -- jouw statement hier levert b.v. onderstaand resultaat voor 2017
--
-- Countryname  January	Feburary  March    April    May    June    July    August  September  October  November  December  TotalItems
-- Chile         9.76%    8.22%   10.06%    9.07%   9.26%   8.38%   8.91%    7.75%    7.28%     7.09%     7.53%    6.68%     3638
-- Greece        9.67%    7.69%    9.06%    8.49%   8.49%   7.92%   9.06%    8.49%    8.40%     7.78%     7.78%    7.17%     2120
-- Poland        9.93%    7.94%    9.41%    8.82%   8.82%   8.24%   8.24%    7.72%    7.72%     7.72%     7.72%    7.72%     1360
-- Netherlands   8.38%    7.26%    8.94%    8.38%   8.38%   7.82%   8.94%    8.38%    8.38%     8.38%     8.38%    8.38%      716
-- …
-- …
-- Maak ook deze tweede versie als je voor een 10 in aanmerking wilt komen.



--------------------------------
--     Optie 1
--------------------------------

DECLARE    @Year INT = 2019;

;WITH YearMonthCountryTotals (Countryname, Month, ItemsPerMonth) AS (
    SELECT
        U.country_name               AS Countryname,
        MONTH(P.purchase_date)       AS Month,
        COUNT(*)                     AS ItemsPerMonth
    FROM Purchase AS P
             INNER JOIN [User] AS U ON P.email_address = U.email_address
    GROUP BY YEAR(P.purchase_date), MONTH(P.purchase_date), U.country_name
    HAVING YEAR(P.purchase_date) = @Year
)
SELECT
       A.Countryname,
       FORMAT( ISNULL(SUM(A.January), 0) / ISNULL(SUM(ItemsPerMonth),0), 'P') AS January,
       FORMAT( ISNULL(SUM(A.February), 0) / ISNULL(SUM(ItemsPerMonth),0), 'P') AS February,
       FORMAT( ISNULL(SUM(A.March), 0) / ISNULL(SUM(ItemsPerMonth),0), 'P') AS March,
       FORMAT( ISNULL(SUM(A.April), 0) / ISNULL(SUM(ItemsPerMonth),0), 'P') AS April,
       FORMAT( ISNULL(SUM(A.May), 0) / ISNULL(SUM(ItemsPerMonth),0), 'P') AS May,
       FORMAT( ISNULL(SUM(A.June), 0) / ISNULL(SUM(ItemsPerMonth),0), 'P') AS June,
       FORMAT( ISNULL(SUM(A.July), 0) / ISNULL(SUM(ItemsPerMonth),0), 'P') AS July,
       FORMAT( ISNULL(SUM(A.August), 0) / ISNULL(SUM(ItemsPerMonth),0), 'P') AS August,
       FORMAT( ISNULL(SUM(A.September), 0) / ISNULL(SUM(ItemsPerMonth),0), 'P') AS September,
       FORMAT( ISNULL(SUM(A.October), 0) / ISNULL(SUM(ItemsPerMonth),0), 'P') AS October,
       FORMAT( ISNULL(SUM(A.November), 0) / ISNULL(SUM(ItemsPerMonth),0), 'P') AS November,
       FORMAT( ISNULL(SUM(A.December), 0) / ISNULL(SUM(ItemsPerMonth),0), 'P') AS December,
       SUM(ItemsPerMonth) AS TotalItems
    FROM (
             SELECT Countryname,
                    CASE
                        WHEN Month=1 THEN ItemsPerMonth
                        END AS January,
                    CASE
                        WHEN Month=2 THEN ItemsPerMonth
                        END AS February,
                    CASE
                        WHEN Month=3 THEN ItemsPerMonth
                        END AS March,
                    CASE
                        WHEN Month=4 THEN ItemsPerMonth
                        END AS April,
                    CASE
                        WHEN Month=5 THEN ItemsPerMonth
                        END AS May,
                    CASE
                        WHEN Month=6 THEN ItemsPerMonth
                        END AS June,
                    CASE
                        WHEN Month=7 THEN ItemsPerMonth
                        END AS July,
                    CASE
                        WHEN Month=8 THEN ItemsPerMonth
                        END AS August,
                    CASE
                        WHEN Month=9 THEN ItemsPerMonth
                        END AS September,
                    CASE
                        WHEN Month=10 THEN ItemsPerMonth
                        END AS October,
                    CASE
                        WHEN Month=11 THEN ItemsPerMonth
                        END AS November,
                    CASE
                        WHEN Month=12 THEN ItemsPerMonth
                        END AS December,
                    ItemsPerMonth
             FROM YearMonthCountryTotals
         ) AS A
GROUP BY  A.Countryname


--------------------------------
--     Optie 2
--------------------------------
DECLARE    @Year INT = 2019;

;WITH YearCountryTotals (Year, Country, ItemsPerMonth) AS (
    SELECT YEAR(P.purchase_date)  AS Year,
           U.country_name         AS Country,
           COUNT(*)               AS ItemsPerMonth
    FROM Purchase AS P
             INNER JOIN [User] AS U ON P.email_address = U.email_address
    GROUP BY YEAR(P.purchase_date), U.country_name
    HAVING YEAR(P.purchase_date) = @Year
),
      YearMonthCountryTotals (Countryname, Month, ItemsPerMonth, TotalItems) AS (
          SELECT
              U.country_name               AS Countryname,
              MONTH(P.purchase_date)       AS Month,
              COUNT(*)                     AS ItemsPerMonth,
              ( SELECT SUM(ItemsPerMonth)
                FROM YearCountryTotals AS YCT
                WHERE YCT.Country = U.country_name
              )  AS TotalItems
          FROM Purchase AS P
                   INNER JOIN [User] AS U ON P.email_address = U.email_address
          GROUP BY YEAR(P.purchase_date), MONTH(P.purchase_date), U.country_name
          HAVING YEAR(P.purchase_date) = @Year
      )

SELECT
       Countryname,
       FORMAT( ISNULL([1], 0) / ISNULL(TotalItems, 0), 'P') AS January,
       FORMAT( ISNULL([2], 0) / ISNULL(TotalItems, 0), 'P') AS February,
       FORMAT( ISNULL([3], 0) / ISNULL(TotalItems, 0), 'P') AS March,
       FORMAT( ISNULL([4], 0) / ISNULL(TotalItems, 0), 'P') AS April,
       FORMAT( ISNULL([5], 0) / ISNULL(TotalItems, 0), 'P') AS May,
       FORMAT( ISNULL([6], 0) / ISNULL(TotalItems, 0), 'P') AS June,
       FORMAT( ISNULL([7], 0) / ISNULL(TotalItems, 0), 'P') AS July,
       FORMAT( ISNULL([8], 0) / ISNULL(TotalItems, 0), 'P') AS August,
       FORMAT( ISNULL([9], 0) / ISNULL(TotalItems, 0), 'P') AS September,
       FORMAT( ISNULL([10], 0) / ISNULL(TotalItems, 0), 'P') AS October,
       FORMAT( ISNULL([11], 0) / ISNULL(TotalItems, 0), 'P') AS November,
       FORMAT( ISNULL([12], 0) / ISNULL(TotalItems, 0), 'P') AS December,
       TotalItems
FROM YearMonthCountryTotals
PIVOT (
        SUM(ItemsPerMonth)
        FOR Month IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
    ) AS P