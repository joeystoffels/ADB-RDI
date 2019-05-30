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

------------------------------------------
-- Langste aaneengesloten reeks die NIET aanwezig is
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
                MAX(product_id) AS [endID]
         --      MAX(product_id) - MIN(product_id) AS length
         FROM DetectIslands
         GROUP BY diff)
     SELECT *
     FROM Islands AS I;

--     ;WITH DetectIslands AS (
--         SELECT
--     --         ROW_NUMBER() OVER (ORDER BY product_id) AS rn,
--             product_id,
--             product_id - ROW_NUMBER() OVER (ORDER BY product_id) AS rn
--         FROM Product
--     ), Islands AS (
--         SELECT
--     --            ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY MIN(rn)) AS grp,
--                MIN(product_id) AS [startID],
--                MAX(product_id) AS [endID]
--         FROM DetectIslands
--         GROUP BY product_id, rn
--     )
--     SELECT *
--         FROM Islands AS I
--     CROSS APPLY (
--         VALUES (I.rn, I.endID + 1),(I.rn - 1, I.startID - 1)
--     ) AS f(Seq, Num)
--
-- WITH cteSource(ID, Seq, Num)
--          AS (
--         SELECT d.ID, f.Seq, f.Num
--         FROM (
--                  SELECT ID,
--                         ROW_NUMBER() OVER (PARTITION BY ID ORDER BY MIN(SeqNo)) AS Grp,
--                         MIN(SeqNo) AS StartSeqNo,
--                         MAX(SeqNo) AS EndSeqNo
--                  FROM (
--                           SELECT ID, SeqNo,
--                                  SeqNo - ROW_NUMBER() OVER (PARTITION BY ID ORDER BY SeqNo) AS rn
--                           FROM dbo.GapsIslands
--                       ) AS a
--                  GROUP BY ID,rn
--              ) d
--                  CROSS APPLY (
--             VALUES (d.Grp, d.EndSeqNo + 1),(d.Grp - 1, d.StartSeqNo - 1)
--         ) AS f(Seq, Num)
--     )
-- SELECT ID, MIN(Num) AS StartSeqNo, MAX(Num) AS EndSeqNo
-- FROM cteSource
-- GROUP BY ID, Seq
-- HAVING COUNT(*) = 2;