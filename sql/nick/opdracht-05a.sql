-- 5.	Vermoedelijk zijn niet alle Film ID’s in gebruik.
-- Geef het statement dat de langste aaneengesloten reeks geeft van Film ID’s in jouw database.
-- Geef ook het statement dat de langste reeks geeft die NIET in de database aanwezig is. Geef van beide statements het start en eind ID van de reeks.
-- https://www.red-gate.com/simple-talk/sql/t-sql-programming/the-sql-of-gaps-and-islands-in-sequences/
------------------------------------------
-- Langste aaneengesloten reeks
------------------------------------------
WITH DetectIslands
     AS (SELECT ROW_NUMBER() OVER(
                ORDER BY product_id) AS rn, 
                product_id, 
                product_id - ROW_NUMBER() OVER(
                ORDER BY product_id) AS diff
         FROM Product),
     Islands
     AS (SELECT MIN(product_id) AS [startID], 
                MAX(product_id) AS [endID], 
                MAX(product_id) - MIN(product_id) AS length
         FROM DetectIslands
         GROUP BY diff)
     SELECT startID, 
            endID, 
            length
     FROM Islands
     WHERE length =
     (
         SELECT MAX(length)
         FROM Islands
     );
