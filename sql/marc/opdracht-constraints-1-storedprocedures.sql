/*
 Constraint 1. Een film of spel hoort altijd bij minimaal één genre.

 Uitwerking Stored Procedures
*/

DROP TRIGGER IF EXISTS trgProductInsert
GO

DROP TRIGGER IF EXISTS trgProductDelete
GO

DROP TRIGGER IF EXISTS trgProductGenreDelete
GO

DROP TRIGGER IF EXISTS trgProductGenreInsert
GO

-- Droppen van Foreign Key constraint welke in de weg zit.
ALTER TABLE Product_Genre
DROP CONSTRAINT IF EXISTS FK_PRODUCT__PRODUCT_G_PRODUCT
GO

-- Extra genre toegevoegd welke wordt toegekend aan een nieuw Product
IF NOT EXISTS (SELECT * 
			   FROM Genre 
			   WHERE genre_name = 'No genre allocated')
BEGIN
	INSERT INTO Genre
	VALUES ('No genre allocated')
;END
GO

-- Bij het toevoegen van een product, worden de genres als Table Valued Parameter meegegeven 
DROP PROCEDURE IF EXISTS spProductInsert
GO
DROP PROCEDURE IF EXISTS spProductGenreInsert
GO
DROP PROCEDURE IF EXISTS spProductGenreDelete
GO
DROP TYPE IF EXISTS GenreTableType
GO
CREATE TYPE GenreTableType AS TABLE (genre_name GENRE PRIMARY KEY)
GO

-- Stored procedure om product toe te kunnen voegen, bevat t.b.v. demo alleen verplichte velden (geen, één en twee genres)
CREATE PROCEDURE spProductInsert (@product_type TYPE, @title TITLE, @price PRICE, @genres GenreTableType READONLY)
AS
BEGIN
	
	DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

	IF((SELECT COUNT(*) FROM @genres) = 0)
	BEGIN
		INSERT INTO Product_Genre VALUES (@PRID, 'No genre allocated');
	END

	-- Eerst product toevoegen
	INSERT INTO Product (product_id, product_type, title, movie_default_price)
	VALUES (@PRID, @product_type, @title, @price)

	-- Nu ook genres toevoegen
	INSERT INTO Product_Genre
	SELECT @PRID, genre_name
	FROM @genres

;END
GO

-- Stored procedure om genre toe te voegen aan bestaand product (één, twee), foutmelding bij onbestaand product
CREATE PROCEDURE spProductGenreInsert (@product_id ID, @genres GenreTableType READONLY)
AS
BEGIN

	-- Controleren of er minimaal één genre is opgegeven
	IF((SELECT COUNT(*) FROM @genres) = 0)
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 60000,'Geen genres opgegeven!',1;
		RETURN;
	END

	-- Controleren of product wel bestaat
	IF NOT EXISTS (SELECT * FROM Product WHERE product_id = @product_id)
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 60000,'Product bestaat niet!',1;
		RETURN;
	END;

	INSERT INTO Product_Genre
	SELECT @product_id, genre_name
	FROM @genres

	-- Oude genre verwijderen wanneer eerder de default genre was toegevoegd
	IF EXISTS (SELECT * FROM Product_Genre WHERE product_id = @product_id AND genre_name = 'No genre allocated')
	BEGIN
		DELETE FROM Product_Genre
		WHERE product_id = @product_id AND genre_name = 'No genre allocated';
	END;

;END
GO

-- Stored procedure om genre te verwijderen
CREATE PROCEDURE spProductGenreDelete (@product_id ID, @genres GenreTableType READONLY)
AS
BEGIN

	-- Controleren of er minimaal één genre is opgegeven
	IF((SELECT COUNT(*) FROM @genres) = 0)
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 60000,'Geen genres opgegeven!',1;
		RETURN;
	END

	-- Controleren of product wel bestaat
	IF NOT EXISTS (SELECT * FROM Product_Genre WHERE product_id = @product_id)
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 60000,'Verwijderen van genre niet mogelijk voor product zonder genre!',1;
		RETURN;
	END;

	DELETE FROM Product_Genre
	WHERE product_id = @product_id AND genre_name IN (SELECT genre_name FROM @genres)

	-- Standaard genre toevoegen wanneer alle andere genres worden verwijderd
	IF NOT EXISTS (SELECT * FROM Product_Genre WHERE product_id = @product_id)
	BEGIN
		INSERT INTO Product_Genre
		VALUES (@product_id, 'No genre allocated');
	END;

;END


/*

	Testscenario's:

	|X| Insert product zonder genre (spProductInsert)
	|X| Insert product met één genre (spProductInsert)
	|X| Insert product met twee genres (spProductInsert)
	|X| Insert genre met verwijzing naar bestaand product (spProductGenreInsert)
	|X| Insert twee genres met verwijzing naar bestaand product (spProductGenreInsert)
	|X| Insert genre met verwijzing naar niet-bestaand product (spProductGenreInsert)
	|X| Insert twee producten zonder genre (spProductInsert)
	|X| Insert twee producten met één genre (spProductInsert)
	|X| Insert twee producten met twee genres (spProductInsert)
	|X| Verwijder genre van product (standaard genre 'No genre allocated' terugplaatsen) (spProductGenreDelete)
	|X| Verwijder meerdere genres van product (standaard genre 'No genre allocated' terugplaatsen) (spProductGenreDelete)

*/


-- Insert product zonder genre
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @ProductTitle TITLE = 'Product zonder genres'

EXEC spProductInsert 'Movie', @ProductTitle, 3.00, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = (SELECT MAX(product_id) FROM Product)

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product_Genre 
WHERE product_id IN (SELECT product_id 
					 FROM product 
					 WHERE title = 'Product zonder genres')
GO

DELETE FROM Product
WHERE title = 'Product zonder genres'
GO


-- Insert product met één genre
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @ProductTitle TITLE = 'Product met één genre'

INSERT INTO @GenreTableType
VALUES ('Action')

EXEC spProductInsert 'Movie', @ProductTitle, 3.00, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = (SELECT MAX(product_id) FROM Product)

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product_Genre 
WHERE product_id IN (SELECT product_id 
					 FROM product 
					 WHERE title = 'Product met één genre')
GO

DELETE FROM Product
WHERE title = 'Product met één genre'
GO


-- Insert product met twee genres
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @ProductTitle TITLE = 'Product met twee genres'

INSERT INTO @GenreTableType
VALUES ('Action'), ('Documentary')

EXEC spProductInsert 'Movie', @ProductTitle, 4.50, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = (SELECT MAX(product_id) FROM Product)

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product_Genre 
WHERE product_id IN (SELECT product_id 
					 FROM product 
					 WHERE title = 'Product met twee genres')
GO

DELETE FROM Product
WHERE title = 'Product met twee genres'
GO


-- Insert genre met verwijzing naar bestaand product
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @PRID ID = (SELECT product_id FROM Product_Genre WHERE product_id = (SELECT MAX(product_id) FROM Product_Genre));

INSERT INTO @GenreTableType
VALUES ('Action')

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = @PRID

EXEC spProductGenreInsert @PRID, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = @PRID

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product_Genre 
WHERE product_id IN (SELECT product_id FROM Product_Genre WHERE product_id = (SELECT MAX(product_id) FROM Product_Genre))
	AND genre_name = 'Action'
GO


-- Insert twee genres met verwijzing naar bestaand product
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @PRID ID = (SELECT product_id FROM Product_Genre WHERE product_id = (SELECT MAX(product_id) FROM Product_Genre));

INSERT INTO @GenreTableType
VALUES ('Action'), ('Documentary')

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = @PRID

EXEC spProductGenreInsert @PRID, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = @PRID

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product_Genre 
WHERE product_id IN (SELECT product_id FROM Product_Genre WHERE product_id = (SELECT MAX(product_id) FROM Product_Genre))
	AND (genre_name = 'Action' OR genre_name = 'Documentary')
GO


-- Insert genre met verwijzing naar niet-bestaand product
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO @GenreTableType
VALUES ('Action')

PRINT 'Hier verwachten we een foutmelding.';
EXEC spProductGenreInsert @PRID, @GenreTableType

COMMIT TRANSACTION
GO


-- Insert twee producten zonder genre
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @ProductTitle TITLE = 'Producten zonder genres (1/2)'

EXEC spProductInsert 'Movie', @ProductTitle, 3.00, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = (SELECT MAX(product_id) FROM Product)

SET @ProductTitle = 'Producten zonder genres (2/2)'

EXEC spProductInsert 'Movie', @ProductTitle, 3.00, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = (SELECT MAX(product_id) FROM Product)

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product_Genre 
WHERE product_id IN (SELECT product_id 
					 FROM product 
					 WHERE title = 'Producten zonder genres (1/2)' 
						OR title = 'Producten zonder genres (2/2)')
GO

DELETE FROM Product
WHERE title = 'Producten zonder genres (1/2)' 
	OR title = 'Producten zonder genres (2/2)'
GO


-- Insert twee producten met één genre
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @ProductTitle TITLE = 'Producten met één genre (1/2)'

INSERT INTO @GenreTableType
VALUES ('Action')

EXEC spProductInsert 'Movie', @ProductTitle, 3.00, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = (SELECT MAX(product_id) FROM Product)

SET @ProductTitle = 'Producten met één genre (2/2)'

EXEC spProductInsert 'Movie', @ProductTitle, 3.00, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = (SELECT MAX(product_id) FROM Product)

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product_Genre 
WHERE product_id IN (SELECT product_id 
					 FROM product 
					 WHERE title = 'Producten met één genre (1/2)' 
						OR title = 'Producten met één genre (2/2)')
GO

DELETE FROM Product
WHERE title = 'Producten met één genre (1/2)' 
	OR title = 'Producten met één genre (2/2)'
GO


-- Insert twee producten met twee genres
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @ProductTitle TITLE = 'Producten met twee genres (1/2)'

INSERT INTO @GenreTableType
VALUES ('Action'), ('Horror')

EXEC spProductInsert 'Movie', @ProductTitle, 3.00, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = (SELECT MAX(product_id) FROM Product)

SET @ProductTitle = 'Producten met twee genres (2/2)'

EXEC spProductInsert 'Movie', @ProductTitle, 3.00, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = (SELECT MAX(product_id) FROM Product)

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product_Genre 
WHERE product_id IN (SELECT product_id 
					 FROM product 
					 WHERE title = 'Producten met twee genres (1/2)' 
						OR title = 'Producten met twee genres (2/2)')
GO

DELETE FROM Product
WHERE title = 'Producten met twee genres (1/2)' 
	OR title = 'Producten met twee genres (2/2)'
GO


-- Verwijder genre van product (standaard genre 'No genre allocated' terugplaatsen)
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @ProductTitle TITLE = 'Product met één genre om te verwijderen'

INSERT INTO @GenreTableType
VALUES ('Documentary')

-- Eerst product toevoegen
EXEC spProductInsert 'Movie', @ProductTitle, 1.50, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = (SELECT MAX(product_id) FROM Product)

DECLARE @PRID ID = (SELECT product_id FROM Product WHERE title = 'Product met één genre om te verwijderen');

-- Genre nu verwijderen om aan te tonen dat standaard genre wordt toegevoegd
EXEC spProductGenreDelete @PRID, @GenreTableType

-- Nu dient de standaard genre er weer te staan
SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = @PRID

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product_Genre 
WHERE product_id IN (SELECT product_id 
					 FROM product 
					 WHERE title = 'Product met één genre om te verwijderen')
GO

DELETE FROM Product
WHERE title = 'Product met één genre om te verwijderen'
GO


-- Verwijder meerdere genres van product (standaard genre 'No genre allocated' terugplaatsen)
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @ProductTitle TITLE = 'Product met twee genres om te verwijderen'

INSERT INTO @GenreTableType
VALUES ('Documentary'), ('Action')

-- Eerst product toevoegen
EXEC spProductInsert 'Movie', @ProductTitle, 1.50, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = (SELECT MAX(product_id) FROM Product)

DECLARE @PRID ID = (SELECT product_id FROM Product WHERE title = 'Product met twee genres om te verwijderen');

-- Genre nu verwijderen om aan te tonen dat standaard genre wordt toegevoegd
EXEC spProductGenreDelete @PRID, @GenreTableType

-- Nu dient de standaard genre er weer te staan
SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = @PRID

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product_Genre 
WHERE product_id IN (SELECT product_id 
					 FROM product 
					 WHERE title = 'Product met twee genres om te verwijderen')
GO

DELETE FROM Product
WHERE title = 'Product met twee genres om te verwijderen'
GO