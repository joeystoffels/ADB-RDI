DECLARE @MovieInReeks INT= 207989;
WITH moviereeks
     AS (SELECT product_id, 
                title, 
                previous_product_id, 
                publication_year
         FROM product
         WHERE product_id = @MovieInReeks
         UNION
         SELECT product_id, 
                title, 
                previous_product_id, 
                publication_year
         FROM product
         WHERE previous_product_id = @MovieInReeks
         UNION ALL
         SELECT P.product_id, 
                P.title, 
                P.previous_product_id, 
                P.publication_year
         FROM product P
              JOIN moviereeks M ON P.product_id = M.previous_product_id)
     SELECT product_id AS ITEM_ID, 
            title AS TITLE, 
            ROW_NUMBER() OVER(
            ORDER BY publication_year ASC) AS Volgnummer
     FROM moviereeks
     GROUP BY product_id, 
              title, 
              publication_year;