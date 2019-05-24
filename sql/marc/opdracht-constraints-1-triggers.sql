/*
 Constraint 1. Een film of spel hoort altijd bij minimaal één genre.
*/


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


-- Trigger voor het inserten van een Product
DROP TRIGGER IF EXISTS trgProductInsert
GO
CREATE TRIGGER trgProductInsert
ON Product
AFTER INSERT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @PRID ID = (SELECT DISTINCT product_id FROM inserted);
	
	IF NOT EXISTS (
		SELECT *
		FROM Product_Genre AS pg
			INNER JOIN inserted AS i
				ON pg.product_id=i.product_id
	)
	BEGIN
		INSERT INTO Product_Genre VALUES (@PRID, 'No genre allocated');
	END;

END
GO


-- Trigger voor het verwijderen van een Product
DROP TRIGGER IF EXISTS trgProductDelete
GO
CREATE TRIGGER trgProductDelete
ON Product
AFTER DELETE
AS
BEGIN

	SET NOCOUNT ON;

	DELETE FROM Product_Genre
	WHERE product_id IN (SELECT product_id FROM deleted)

;END


-- Trigger voor het verwijderen van een Product_Genre
DROP TRIGGER IF EXISTS trgProductGenreDelete
GO
CREATE TRIGGER trgProductGenreDelete
ON Product_Genre
AFTER DELETE
AS
BEGIN

	SET NOCOUNT ON;

	-- Tijdelijke tabel maken voor wanneer we meerdere records gaan verwijderen
	SELECT product_id, ROW_NUMBER() OVER(ORDER BY product_id) AS ROW
	INTO #Temp
	FROM deleted;

	DECLARE @COUNTER INT = (SELECT MAX(ROW) FROM #Temp);
	DECLARE @ROW INT;

	-- Door verschillende records loopen en zodoende verwijderen
	WHILE(@COUNTER != 0)
	BEGIN

		-- Toevoegen van default genre 'No genre allocated' wanneer alle genres worden verwijderd
		IF (
			(SELECT product_id FROM #Temp t WHERE ROW = @COUNTER) 
				IN (SELECT product_id FROM Product)
					AND (SELECT COUNT(*) FROM Product_Genre pg WHERE pg.product_id = (SELECT product_id FROM #Temp t WHERE ROW = @COUNTER)) = 0
		)
		BEGIN
			INSERT INTO Product_Genre VALUES ((SELECT product_id FROM #Temp t WHERE ROW = @COUNTER), 'No genre allocated');
		END
		SET @COUNTER = (@COUNTER - 1)
	;END

END
GO


-- Trigger voor het inserten van een Product_Genre
DROP TRIGGER IF EXISTS trgProductGenreInsert
GO
CREATE TRIGGER trgProductGenreInsert
ON Product_Genre
AFTER INSERT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @PRID ID = (SELECT DISTINCT product_id FROM inserted)

	-- Foutmelding gooien wanneer genre niet aan bestaand product gekoppeld kan worden
	IF NOT EXISTS (
		SELECT *
		FROM Product AS p
		INNER JOIN inserted AS i
			ON p.product_id=i.product_id
	)
	BEGIN
		RAISERROR('Er bestaat geen product bij deze genre. Genre kan niet worden toegevoegd.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END;

	-- Verwijderen van default genre 'No genre allocated' wanneer er een genre wordt toegevoegd
	IF EXISTS (
		SELECT *
		FROM Product_Genre pg
		WHERE pg.product_id = (SELECT DISTINCT product_id FROM inserted)
			AND pg.genre_name != 'No genre allocated'
	)
	BEGIN
		DELETE FROM Product_Genre
		WHERE product_id = @PRID AND genre_name = 'No genre allocated'
	END;

END
GO


/*

	Testscenario's:

	|X| Insert product zonder genre
	|X| Insert product met één genre
	|X| Insert product met twee genres
	|X| Insert genre met verwijzing naar bestaand product
	|X| Insert twee genres met verwijzing naar bestaand product
	|X| Insert genre met verwijzing naar niet-bestaand product
	|X| Insert twee producten zonder genre
	|X| Insert twee producten met één genre
	|X| Insert twee producten met twee genres
	|X| Verwijder genre van product (standaard genre 'No genre allocated' terugplaatsen)

*/



-- Insert product zonder genre (krijgt standaard genre 'No genre allocated' toegekend)
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie zonder genre', 3.50)

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product
WHERE title = 'Movie zonder genre'
GO


-- Insert product met één genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie met één genre', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Action')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

COMMIT TRANSACTION
GO

-- Opruimen van testdata
DELETE FROM Product
WHERE product_id=(SELECT product_id FROM Product WHERE title = 'Movie met één genre')
GO


-- Insert product met twee genres
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie met twee genres', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Action'), (@PRID, 'Animation')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

COMMIT TRANSACTION
GO

-- Opruimen van testdata
DELETE FROM Product
WHERE product_id IN (SELECT product_id FROM Product WHERE title = 'Movie met twee genres')
GO


-- Insert genre met verwijzing naar bestaand product
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(p.product_id) FROM Product AS p WHERE p.product_type = 'Movie' 
	AND (SELECT COUNT(*) FROM Product_Genre pg WHERE p.product_id=pg.product_id) > 1);

INSERT INTO Product_Genre
VALUES (@PRID, 'Action')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

COMMIT TRANSACTION
GO

-- Opruimen van testdata
DELETE FROM Product_Genre
WHERE product_id = ((SELECT MAX(p.product_id) FROM Product AS p WHERE p.product_type = 'Movie' 
	AND (SELECT COUNT(*) FROM Product_Genre pg WHERE p.product_id=pg.product_id) > 1)) 
	AND genre_name = 'Action'
GO


-- Insert twee genres met verwijzing naar bestaand product
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(p.product_id) FROM Product AS p WHERE p.product_type = 'Movie' 
	AND (SELECT COUNT(*) FROM Product_Genre pg WHERE p.product_id=pg.product_id) > 1);

INSERT INTO Product_Genre
VALUES (@PRID, 'Action'), (@PRID, 'Documentary')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

COMMIT TRANSACTION
GO

-- Opruimen van testdata
DELETE FROM Product_Genre
WHERE product_id = ((SELECT MAX(p.product_id) FROM Product AS p WHERE p.product_type = 'Movie' 
	AND (SELECT COUNT(*) FROM Product_Genre pg WHERE p.product_id=pg.product_id) > 1)) 
	AND (genre_name = 'Action' OR genre_name = 'Documentary')
GO


-- Insert genre met verwijzing naar niet-bestaand product, gooit foutmelding:
-- 'Er bestaat geen product bij deze genre. Genre kan niet worden toegevoegd'
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);
PRINT 'Onderstaande foutmelding verwachten we, mag dus worden genegeerd.';
INSERT INTO Product_Genre
VALUES (@PRID, 'Action')

COMMIT TRANSACTION
GO


-- Insert twee producten zonder genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);
INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie 1/2 zonder genre', 3.00)

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

SET @PRID = (SELECT MAX(product_id)+1 FROM Product);
INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie 2/2 zonder genre', 4.00)

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product
WHERE title = 'Movie 1/2 zonder genre' OR title = 'Movie 2/2 zonder genre'
GO


-- Insert twee producten met één genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie 1/2 met één genre', 3.00)

INSERT INTO Product_Genre
VALUES (@PRID, 'Horror')

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

SET @PRID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie 2/2 met één genre', 4.00)

INSERT INTO Product_Genre
VALUES (@PRID, 'Comedy')

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product_Genre
WHERE product_id IN (SELECT product_id FROM Product WHERE title = 'Movie 1/2 met één genre' OR title = 'Movie 2/2 met één genre')
GO

DELETE FROM Product
WHERE title = 'Movie 1/2 met één genre' OR title = 'Movie 2/2 met één genre'
GO


-- Insert twee producten met twee genres
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie 1/2 met twee genres', 3.00)

INSERT INTO Product_Genre
VALUES (@PRID, 'Horror'), (@PRID, 'Action')

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

SET @PRID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie 2/2 met twee genres', 4.00)

INSERT INTO Product_Genre
VALUES (@PRID, 'Comedy'), (@PRID, 'Documentary')

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

COMMIT TRANSACTION
GO

-- Opschonen van testdata
DELETE FROM Product_Genre
WHERE product_id IN (SELECT product_id FROM Product WHERE title = 'Movie 1/2 met twee genres' OR title = 'Movie 2/2 met twee genres')
GO

DELETE FROM Product
WHERE title = 'Movie 1/2 met twee genres' OR title = 'Movie 2/2 met twee genres'
GO


-- Verwijder genre van product (standaard genre 'No genre allocated' terugplaatsen)
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product_Genre WHERE (SELECT COUNT(product_id) FROM Product_Genre) > 1);

DELETE FROM Product_Genre
WHERE product_id = @PRID

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

-- Wijzigingen niet doorvoeren
ROLLBACK TRANSACTION