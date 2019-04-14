USE odisee

DECLARE @MovieInReeks INT = 313477;

WITH result AS (
	SELECT p.*
	FROM Product p
	WHERE product_id = @MovieInReeks
	UNION ALL
	SELECT child.*
	FROM Product as child
		JOIN result parent ON parent.previous_product_id = child.product_id

)

SELECT *
FROM parent;

-- TODO add volgnummers