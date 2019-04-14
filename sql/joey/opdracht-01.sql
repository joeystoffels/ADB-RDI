USE odisee

DECLARE @MovieInReeks INT = 207989;

WITH children AS (
    SELECT p.*
    FROM Product p
    WHERE p.product_id = @MovieInReeks

    UNION ALL

    SELECT child.*
    FROM Product as child
      INNER JOIN children parent ON parent.previous_product_id = child.product_id
)
, parents AS (
    SELECT p.*
    FROM Product p
    WHERE p.product_id = @MovieInReeks

    UNION ALL

    SELECT super.*
    FROM Product as super
      INNER JOIN parents parent on parent.product_id = super.previous_product_id
)
SELECT product_id as PRODUCT_ID,
	     title as TITLE,
	     ROW_NUMBER() OVER (ORDER BY publication_year ASC) AS VOLGNUMMER
FROM (
    SELECT *
    FROM children
    UNION
    SELECT *
    FROM parents) as result;