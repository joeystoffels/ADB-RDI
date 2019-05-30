
/*
 Opdracht 5.

 Vermoedelijk zijn niet alle Film ID’s in gebruik.
 Geef het statement dat de langste aaneengesloten reeks geeft van Film ID’s in jouw database.
 Geef ook het statement dat de langste reeks geeft die NIET in de database aanwezig is.
 Geef van beide statements het start en eind ID van de reeks.
 */

-- Geef het statement dat de langste aaneengesloten reeks geeft van Film ID’s in jouw database.
-- Geef het start en eind ID van de reeks. (lengte van reeks toegevoegd tbv. vergelijking)
WITH aaneengeslotenReeksCTE
     AS (SELECT MIN(product_id) AS startID, 
                MAX(product_id) AS eindID, 
                COUNT(*) AS maxReeksBestaand
         FROM
         (
             SELECT product_id, 
                    product_id - ROW_NUMBER() OVER(
                    ORDER BY product_id) AS resultaatVerschil
             FROM Product
             WHERE product_type = 'Movie'
         ) qry
         GROUP BY resultaatVerschil)
     SELECT startID, 
            eindID, 
            maxReeksBestaand
     FROM aaneengeslotenReeksCTE
     WHERE maxReeksBestaand =
     (
         SELECT MAX(maxReeksBestaand)
         FROM aaneengeslotenReeksCTE
     );