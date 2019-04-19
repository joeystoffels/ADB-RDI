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


SELECT YEAR(P.purchase_date) AS Year,
       MONTH(P.purchase_date) AS Month,
       COUNT(*) AS ItemsPerMont
	   --,
       -- CAST(CAST(COUNT(*)*100 AS numeric(10,2)) AS varchar)+'%' AS PercentageOfTotal,
	   --(SELECT COUNT(*) FROM Purchase AS P2 GROUP BY YEAR(P2.purchase_date) / 100 * COUNT(*)) AS Test
FROM Purchase AS P
 INNER JOIN [User] AS U ON P.email_address = U.email_address
GROUP BY YEAR(P.purchase_date), MONTH(P.purchase_date), U.country_name
HAVING U.country_name = 'The Netherlands'
AND P.purchase_date > EOMONTH (DATEADD(month, -13, GETDATE()))


SELECT EOMONTH (DATEADD(month, -13, GETDATE()))



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