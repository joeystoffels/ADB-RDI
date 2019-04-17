/* 
    Opdracht 2.
    Geef het statement dat per land het maandgebruik over 12 maanden geeft 
    met daarbij het percentage dat die maand uitmaakt van het totaal van die 12 maanden.
*/

-- VERSIE 1
SELECT Year(P.purchase_date)                          AS Year,
       Month(P.purchase_date)                         AS Month,
       Count(*)                                       AS ItemsPerMonth,
       CONCAT(CONVERT(DECIMAL(4, 2),
           ( 100 / (SELECT CONVERT(DECIMAL(4, 2),
                           Count(*))
                    FROM   Purchase P
                           JOIN [User] AS U
                             ON P.email_address =
                                U.email_address
                    WHERE  U.country_name =
                           'The Netherlands'
                   ) )) * Count(*), '%')              AS PercentageOfTotal
FROM   Purchase P
       JOIN [User] AS U
         ON P.email_address = U.email_address
WHERE  U.country_name = 'The Netherlands'
       AND P.purchase_date BETWEEN '20180501' AND '20190501'
GROUP  BY U.country_name,
          Year(P.purchase_date),
          Month(P.purchase_date)


-- VERSIE 2
-- SELECT country_name, '' AS January, '' AS February, '' AS March, '' AS April, '' AS May, '' AS June, '' AS July, '' AS August, '' AS September, '' AS October, '' AS November, '' AS December, '' AS TotalItems
-- FROM Country

