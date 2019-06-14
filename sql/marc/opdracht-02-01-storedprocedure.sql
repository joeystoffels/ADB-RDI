USE odisee;
GO

ALTER TABLE Product_Genre
DROP CONSTRAINT IF EXISTS FK_PRODUCT__PRODUCT_G_PRODUCT
GO

-- Extra genre welke wordt toegekend aan een nieuw product
IF NOT EXISTS (SELECT * 
			   FROM Genre 
			   WHERE genre_name = 'No genre allocated')
BEGIN
	INSERT INTO Genre
	VALUES ('No genre allocated')
;END
GO

DROP PROCEDURE IF EXISTS spProductInsert
DROP PROCEDURE IF EXISTS spProductGenreInsert
DROP PROCEDURE IF EXISTS spProductGenreDelete
GO

-- Bij het toevoegen van een product, worden de genres als Table Valued Parameter meegegeven
DROP TYPE IF EXISTS GenreTableType
CREATE TYPE GenreTableType AS TABLE (genre_name GENRE PRIMARY KEY)
GO

--  --------------------------------------------------------
--  Stored procedure
--  --------------------------------------------------------
CREATE PROCEDURE spProductInsert (@product_type TYPE, @title TITLE, @price PRICE, @genres GenreTableType READONLY)
AS
BEGIN

    SET NOCOUNT, XACT_ABORT ON

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	BEGIN TRANSACTION;

	DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

	IF EXISTS(SELECT * FROM @genres)
	BEGIN
		INSERT INTO Product_Genre VALUES (@PRID, 'No genre allocated');
	END

	-- Product toevoegen
	INSERT INTO Product (product_id, product_type, title, movie_default_price)
	VALUES (@PRID, @product_type, @title, @price)

	-- Genres toevoegen
	INSERT INTO Product_Genre
	SELECT @PRID, genre_name
	FROM @genres

	COMMIT TRANSACTION;

;END
GO

--  --------------------------------------------------------
--  Stored procedure
--  --------------------------------------------------------
CREATE PROCEDURE spProductGenreInsert (@product_id ID, @genres GenreTableType READONLY)
AS
BEGIN

    SET NOCOUNT, XACT_ABORT ON

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	BEGIN TRANSACTION;

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

	COMMIT TRANSACTION;

;END
GO

--  --------------------------------------------------------
--  Stored procedure
--  --------------------------------------------------------
CREATE PROCEDURE spProductGenreDelete (@product_id ID, @genres GenreTableType READONLY)
AS
BEGIN

    SET NOCOUNT, XACT_ABORT ON

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	BEGIN TRANSACTION;

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

    COMMIT TRANSACTION;

;END

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 01
-- Insert product zonder genre
-- Result: Success
BEGIN TRANSACTION;

DECLARE @GenreTableType GenreTableType
DECLARE @ProductTitle TITLE = 'Product zonder genres'

EXEC spProductInsert 'Movie', @ProductTitle, 3.00, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p 
	JOIN Product_Genre AS pg
		ON p.product_id=pg.product_id
WHERE p.product_id = (SELECT MAX(product_id) FROM Product)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 02
-- Insert product met één genre
-- Result: Success
BEGIN TRANSACTION;

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

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 03
-- Insert product met twee genres
-- Result: Success
BEGIN TRANSACTION;

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

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 04
-- Insert genre met verwijzing naar bestaand product
-- Result: Success
BEGIN TRANSACTION;

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

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 05
-- Insert twee genres met verwijzing naar bestaand product
-- Result: Success
BEGIN TRANSACTION;

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

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 06
-- Insert genre met verwijzing naar niet-bestaand product
-- Result: Throw Error
BEGIN TRANSACTION;

DECLARE @GenreTableType GenreTableType
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO @GenreTableType
VALUES ('Action')

PRINT 'Hier verwachten we een foutmelding.';
EXEC spProductGenreInsert @PRID, @GenreTableType

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 07
-- Insert twee producten zonder genre
-- Result: Success
BEGIN TRANSACTION;

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

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 08
-- Insert twee producten met één genre
-- Result: Success
BEGIN TRANSACTION;

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

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 09
-- Insert twee producten met twee genres
-- Result: Success
BEGIN TRANSACTION;

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

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 10
-- Verwijder genre van product (standaard genre 'No genre allocated' terugplaatsen)
-- Result: Success
BEGIN TRANSACTION;

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

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 11
-- Verwijder meerdere genres van product (standaard genre 'No genre allocated' terugplaatsen)
-- Result: Success
BEGIN TRANSACTION;

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

ROLLBACK TRANSACTION;