--  --------------------------------------------------------
--  Constraint 1 - Triggers 
--  --------------------------------------------------------
-- Een film of spel hoort altijd bij minimaal één genre.
USE odisee
go

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'FK_PRODUCT__PRODUCT_G_PRODUCT' AND [type] = 'F')
BEGIN
	ALTER TABLE Product_Genre
	DROP CONSTRAINT FK_PRODUCT__PRODUCT_G_PRODUCT
END;
IF NOT EXISTS (SELECT * FROM Genre WHERE genre_name = 'No genre allocated') 
	BEGIN
	INSERT INTO Genre VALUES ('No genre allocated')
END;
go

--  --------------------------------------------------------
--  Trigger
--  --------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'ProductGenre_AI' AND [type] = 'TR')
BEGIN
	DROP TRIGGER [dbo].[ProductGenre_AI];
END;
go

CREATE TRIGGER ProductGenre_AI
ON Product_Genre
AFTER INSERT
AS
BEGIN
	
	SET NOCOUNT ON;

	-- Controleer of er een product met dit product_id bestaat
	IF NOT EXISTS (SELECT * 
			FROM inserted AS i 
				JOIN Product AS p 
					ON i.product_id = p.product_id)

	THROW 50001, 'Given product does not exist.', 1;

	-- Verwijder standaard genre wanneer andere genre word toegevoegd
	IF EXISTS (SELECT * 
		FROM inserted AS i 
			JOIN Product_Genre AS pg ON i.product_id = pg.product_id
		WHERE pg.genre_name IN (
								SELECT genre_name 
								FROM Product_Genre AS pg2 
								WHERE pg.product_id = pg2.product_id 
									AND pg.genre_name != 'No genre allocated')
								)

	DELETE FROM Product_Genre 
	WHERE product_id IN (
							SELECT product_id 
							FROM inserted
						) 
						AND genre_name = 'No genre allocated'

;END
go

--  --------------------------------------------------------
--  Trigger
--  --------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'ProductGenre_AD' AND [type] = 'TR')
BEGIN
	DROP TRIGGER [dbo].[ProductGenre_AD];
END;
go

CREATE TRIGGER ProductGenre_AD
ON Product_Genre
AFTER DELETE
AS
BEGIN

	SET NOCOUNT ON;

	-- Controleer of er een product met dit product_id bestaat
	IF EXISTS (SELECT * 
		FROM deleted AS d 
			JOIN Product_Genre AS pg ON d.product_id = pg.product_id 
		HAVING COUNT(pg.genre_name) = 0)

	THROW 50001, 'At least one genre required. Deleting this genre(s) would result in a total of 0 genres.', 1;

;END
go

--  --------------------------------------------------------
--  Trigger
--  --------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'Product_AI' AND [type] = 'TR')
BEGIN
	DROP TRIGGER [dbo].[Product_AI];
END;
go

CREATE TRIGGER Product_AI
ON Product
AFTER INSERT
AS
BEGIN

	SET NOCOUNT ON;

	-- Voeg standaard genre toe wanneer er een product zonder genre wordt toegevoegd
	IF NOT EXISTS (SELECT * 
			FROM inserted AS i 
				JOIN Product_Genre AS pg
					ON i.product_id = pg.product_id)

	INSERT INTO Product_Genre 
		SELECT product_id, 'No genre allocated' FROM inserted

;END
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [01] Film toevoegen zonder genre
-- [02] Spel toevoegen zonder genre
-- [03] Film en spel toevoegen zonder genre
-- [04] Film toevoegen met één genre
-- [05] Film toevoegen met twee genres
-- [06] Spel toevoegen met één genre
-- [07] Spel toevoegen met twee genres
-- [08] Film en spel toevoegen met één genre
-- [09] Film en spel toevoegen met twee genres
-- [10] Alle genres van film of spel verwijderen
-- [11] Eén genre van film of spel verwijderen
-- [12] Genre toevoegen aan niet bestaande film of spel

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 01] : Film toevoegen zonder genre
-- Result: Success (standard genre added)

BEGIN TRANSACTION;

INSERT INTO Product (product_id, product_type, title, movie_default_price, publication_year) 
VALUES ((SELECT MAX(product_id)+1 FROM Product), 'Movie', 'Scenario 01 - Test', 2.50, 2019)

-- Toon testdata
SELECT * 
FROM Product 
WHERE title = 'Scenario 01 - Test'
-- Toon testdata
SELECT * 
FROM Product_Genre 
WHERE product_id = (
					SELECT product_id 
					FROM Product 
					WHERE title = 'Scenario 01 - Test'
					)

ROLLBACK TRANSACTION
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 02] : Spel toevoegen zonder genre
-- Result: Success (standard genre added)

BEGIN TRANSACTION;

INSERT INTO Product (product_id, product_type, title, movie_default_price, publication_year) 
VALUES ((SELECT MAX(product_id)+1 FROM Product), 'Game', 'Scenario 02 - Test', 3.00, 2018)

-- Toon testdata
SELECT * 
FROM Product 
WHERE title = 'Scenario 02 - Test'
-- Toon testdata
SELECT * 
FROM Product_Genre 
WHERE product_id = (
					SELECT product_id 
					FROM Product 
					WHERE title = 'Scenario 02 - Test'
					)

ROLLBACK TRANSACTION
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 03] : Film en spel toevoegen zonder genre
-- Result: Success (standard genre added)

BEGIN TRANSACTION;

INSERT INTO Product (product_id, product_type, title, movie_default_price, publication_year) 
VALUES ((SELECT MAX(product_id)+1 FROM Product), 'Movie', 'Scenario 03 - Test film', 2.50, 2019),
	   ((SELECT MAX(product_id)+2 FROM Product), 'Game', 'Scenario 03 - Test spel', 3.00, 2018)

-- Toon testdata
SELECT * 
FROM Product 
WHERE title = 'Scenario 03 - Test film' 
	OR title = 'Scenario 03 - Test spel'
-- Toon testdata
SELECT * 
FROM Product_Genre AS pg
	JOIN Product AS p ON pg.product_id = p.product_id
WHERE title = 'Scenario 03 - Test film'
	OR title = 'Scenario 03 - Test spel'

ROLLBACK TRANSACTION
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 04] : Film toevoegen met één genre
-- Result: Success

BEGIN TRANSACTION;

INSERT INTO Product (product_id, product_type, title, movie_default_price, publication_year) 
VALUES ((SELECT MAX(product_id)+1 FROM Product), 'Movie', 'Scenario 04 - Test', 2.50, 2019)

-- Toon testdata
SELECT * 
FROM Product 
WHERE title = 'Scenario 04 - Test'

-- Genre toevoegen
INSERT INTO Product_Genre 
VALUES ((SELECT product_id 
			FROM Product 
			WHERE title = 'Scenario 04 - Test')
		, 'Action')

-- Toon testdata
SELECT * 
FROM Product_Genre 
WHERE product_id = (
					SELECT product_id 
					FROM Product 
					WHERE title = 'Scenario 04 - Test'
					)

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 05] : Film toevoegen met twee genres
-- Result: Success

BEGIN TRANSACTION;

INSERT INTO Product (product_id, product_type, title, movie_default_price, publication_year) 
VALUES ((SELECT MAX(product_id)+1 FROM Product), 'Movie', 'Scenario 05 - Test', 2.50, 2019)

-- Toon testdata
SELECT * 
FROM Product 
WHERE title = 'Scenario 05 - Test'

-- Twee genres toevoegen
INSERT INTO Product_Genre 
VALUES ((SELECT product_id 
			FROM Product 
			WHERE title = 'Scenario 05 - Test')
		, 'Action'),
		((SELECT product_id 
			FROM Product 
			WHERE title = 'Scenario 05 - Test')
		, 'Horror')

-- Toon testdata
SELECT * 
FROM Product_Genre 
WHERE product_id = (
					SELECT product_id 
					FROM Product 
					WHERE title = 'Scenario 05 - Test'
					)

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 06] : Spel toevoegen met één genre
-- Result: Success

BEGIN TRANSACTION;

INSERT INTO Product (product_id, product_type, title, movie_default_price, publication_year) 
VALUES ((SELECT MAX(product_id)+1 FROM Product), 'Game', 'Scenario 06 - Test', 3.00, 2018)

-- Toon testdata
SELECT * 
FROM Product 
WHERE title = 'Scenario 06 - Test'

-- Twee genres toevoegen
INSERT INTO Product_Genre 
VALUES ((SELECT product_id 
			FROM Product 
			WHERE title = 'Scenario 06 - Test')
		, 'Action')

-- Toon testdata
SELECT * 
FROM Product_Genre 
WHERE product_id = (
					SELECT product_id 
					FROM Product 
					WHERE title = 'Scenario 06 - Test'
					)

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 07] : Spel toevoegen met twee genres
-- Result: Success

BEGIN TRANSACTION;

INSERT INTO Product (product_id, product_type, title, movie_default_price, publication_year) 
VALUES ((SELECT MAX(product_id)+1 FROM Product), 'Game', 'Scenario 07 - Test', 3.00, 2018)

-- Toon testdata
SELECT * 
FROM Product 
WHERE title = 'Scenario 07 - Test'

-- Twee genres toevoegen
INSERT INTO Product_Genre 
VALUES ((SELECT product_id 
			FROM Product 
			WHERE title = 'Scenario 07 - Test')
		, 'Action'),
		((SELECT product_id 
			FROM Product 
			WHERE title = 'Scenario 07 - Test')
		, 'Horror')

-- Toon testdata
SELECT * 
FROM Product_Genre 
WHERE product_id = (
					SELECT product_id 
					FROM Product 
					WHERE title = 'Scenario 07 - Test'
					)

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 08] : Film en spel toevoegen met één genre
-- Result: Success

BEGIN TRANSACTION;

INSERT INTO Product (product_id, product_type, title, movie_default_price, publication_year) 
VALUES ((SELECT MAX(product_id)+1 FROM Product), 'Movie', 'Scenario 08 - Test film', 2.50, 2019),
	   ((SELECT MAX(product_id)+2 FROM Product), 'Game', 'Scenario 08 - Test spel', 3.00, 2018)

-- Toon testdata
SELECT * 
FROM Product 
WHERE title = 'Scenario 08 - Test film' 
	OR title = 'Scenario 08 - Test spel'

-- Twee genres toevoegen
INSERT INTO Product_Genre 
VALUES ((SELECT product_id 
			FROM Product 
			WHERE title = 'Scenario 08 - Test film')
		, 'Action'),
		((SELECT product_id 
			FROM Product 
			WHERE title = 'Scenario 08 - Test spel')
		, 'Horror')

-- Toon testdata
SELECT * 
FROM Product_Genre AS pg
	JOIN Product AS p ON pg.product_id = p.product_id
WHERE title = 'Scenario 08 - Test film'
	OR title = 'Scenario 08 - Test spel'

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 09] : Film en spel toevoegen met twee genres
-- Result: Success

BEGIN TRANSACTION;

INSERT INTO Product (product_id, product_type, title, movie_default_price, publication_year) 
VALUES ((SELECT MAX(product_id)+1 FROM Product), 'Movie', 'Scenario 09 - Test film', 2.50, 2019),
	   ((SELECT MAX(product_id)+2 FROM Product), 'Game', 'Scenario 09 - Test spel', 3.00, 2018)

-- Toon testdata
SELECT * 
FROM Product 
WHERE title = 'Scenario 09 - Test film' 
	OR title = 'Scenario 09 - Test spel'

-- Twee genres toevoegen
INSERT INTO Product_Genre 
VALUES ((SELECT product_id 
			FROM Product 
			WHERE title = 'Scenario 09 - Test film')
		, 'Action'),
		((SELECT product_id 
			FROM Product 
			WHERE title = 'Scenario 09 - Test spel')
		, 'Horror'),
		((SELECT product_id 
			FROM Product 
			WHERE title = 'Scenario 09 - Test spel')
		, 'Fantasy'),
		((SELECT product_id 
			FROM Product 
			WHERE title = 'Scenario 09 - Test film')
		, 'Documentary')

-- Toon testdata
SELECT * 
FROM Product_Genre AS pg
	JOIN Product AS p ON pg.product_id = p.product_id
WHERE title = 'Scenario 09 - Test film'
	OR title = 'Scenario 09 - Test spel'

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 10] : Alle genres van film of spel verwijderen
-- Result: Throw Error

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

DELETE FROM Product_Genre
WHERE product_id = 2

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 11] : Eén genre van film of spel verwijderen
-- Result: Success

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

DELETE FROM Product_Genre
WHERE product_id = 2 AND genre_name = 'Comedy'

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 12] : Genre toevoegen aan niet bestaande film of spel
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES ((SELECT MAX(product_id)+1 FROM Product), 'Action')

ROLLBACK TRANSACTION;
go