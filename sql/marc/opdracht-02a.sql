
/* 
    Opdracht 2.
    Geef het statement dat per land het maandgebruik over 12 maanden geeft 
    met daarbij het percentage dat die maand uitmaakt van het totaal van die 12 maanden.
*/
/*
 VERSIE 1
 Per land de afgelopen 12 maanden in rijen
 */

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
      AND P.purchase_date BETWEEN '20180501' AND '20190501'
GROUP BY U.country_name, 
         YEAR(P.purchase_date), 
         MONTH(P.purchase_date);