-- Opdracht 1
USE ODISEE;
GO
DECLARE @MovieInReeks INT= 207989;
WITH children
     AS (SELECT P.*
         FROM Product P
         WHERE P.product_id = @MovieInReeks
         UNION ALL
         SELECT child.*
         FROM Product AS child
              INNER JOIN children parent ON parent.previous_product_id = child.product_id),
     parents
     AS (SELECT p.*
         FROM Product p
         WHERE p.product_id = @MovieInReeks
         UNION ALL
         SELECT super.*
         FROM Product AS super
              INNER JOIN parents parent ON parent.product_id = super.previous_product_id)
     SELECT product_id AS PRODUCT_ID, 
            title AS TITLE, 
            ROW_NUMBER() OVER(
            ORDER BY publication_year ASC) AS VOLGNUMMER
     FROM
     (
         SELECT *
         FROM children
         UNION
         SELECT *
         FROM parents
     ) AS result;
GO