/*
 Constraint 6. Genres voor films en spellen zijn verschillend, deze mogen niet bij het verkeerde media-item gebruikt worden. 
			   Hetzelfde geld voor Review aspecten.

 Uitwerking Triggers
*/

-- Eerst voegen we een extra kolom genaamd product_type toe om een relatie te leggen tussen de genre en het type product
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'product_type'
          AND Object_ID = Object_ID(N'dbo.Genre'))
BEGIN
	ALTER TABLE Genre
	ADD product_type TYPE
;END
GO


-- Extra genre toegevoegd welke wordt toegekend aan een nieuw product
IF NOT EXISTS (SELECT * 
			   FROM Genre 
			   WHERE genre_name = 'No genre allocated')
BEGIN
	INSERT INTO Genre
	VALUES ('No genre allocated')
;END
GO


-- De in eerste instantie aanwezige genres behoren bij een movie, derhalve wordt het product_type toegevoegd
IF EXISTS (SELECT * FROM Genre WHERE product_type != NULL)
BEGIN
	UPDATE Genre
	SET product_type = 'Movie'
	WHERE genre_name IN (SELECT genre_name FROM Product_Genre) 

	UPDATE Genre
	SET product_type = 'Movie'
	WHERE genre_name = 'No genre allocated'
;END
GO


-- Omdat we enkele genres hebben welke voor een movie en een game beschikbaar zijn, 
-- maken we de combinatie van genre_name en product_type uniek als Primary Key
ALTER TABLE Product_Genre
DROP CONSTRAINT IF EXISTS [FK_PRODUCT__IS OF GEN_GENRE]
GO
ALTER TABLE Genre
DROP CONSTRAINT IF EXISTS PK_GENRE
GO
ALTER TABLE Genre
ALTER COLUMN product_type TYPE NOT NULL
GO
ALTER TABLE Genre
ADD CONSTRAINT PK_GENRE_TYPE PRIMARY KEY (genre_name, product_type)
GO


-- Nu voegen we de juiste genres toe voor games
IF NOT EXISTS (SELECT * FROM Genre WHERE product_type = 'Game')
BEGIN
	INSERT INTO Genre
	VALUES ('No genre allocated', 'Game')
		, ('Action', 'Game')
		, ('Action-Adventure', 'Game')
		, ('Adventure', 'Game')
		, ('MMO', 'Game')
		, ('Role-playing', 'Game')
		, ('Simulation', 'Game')
		, ('Strategy', 'Game')
;END
GO

DROP TRIGGER IF EXISTS trgProductGenreInsertValidGenreForType
GO
CREATE TRIGGER trgProductGenreInsertValidGenreForType
ON Product_Genre
AFTER INSERT, UPDATE
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @PRID ID = (SELECT product_id FROM inserted);
	DECLARE @genre GENRE = (SELECT genre_name FROM inserted AS i);

	IF((SELECT product_type FROM Product WHERE product_id = @PRID) = 'Movie')
	BEGIN
		IF ((SELECT COUNT(*) FROM Genre WHERE genre_name = @genre AND product_type = 'Movie') = 0)
		BEGIN
			RAISERROR('Genre kan niet voor dit type product worden gebruikt.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		;END
	;END

	IF((SELECT product_type FROM Product WHERE product_id = @PRID) = 'Game')
	BEGIN
		IF ((SELECT COUNT(*) FROM Genre WHERE genre_name = @genre AND product_type = 'Game') = 0)
		BEGIN
			RAISERROR('Genre kan niet voor dit type product worden gebruikt.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		;END
	;END
	
;END
GO


/*

	Testscenario's:

	|X| Insert product zonder genre (krijgt standaard genre 'No genre allocated' toegekend)
	|X| Insert product (movie) met ��n geldige genre
	|X| Insert product (movie) met ��n ongeldige genre, resulteert in foutmelding
	|X| Insert product (game) met ��n geldige genre
	|X| Insert product (game) met ��n ongeldige genre, resulteert in foutmelding
	|X| Insert twee producten (movie) met ��n geldige genre
	|X| Insert twee producten (movie) met twee geldige genres
	|X| Insert twee producten (game) met ��n geldige genre
	|X| Insert twee producten (game) met twee geldige genres
	|| Update product (movie) met een geldige genre
	|| Update product (movie) met een ongeldige genre
	|| Update product (game) met een geldige genre
	|| Update product (game) met een ongeldige genre

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


-- Insert product (movie) met ��n geldige genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie met ��n geldige genre', 3.50)

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
WHERE product_id=(SELECT product_id FROM Product WHERE title = 'Movie met ��n geldige genre')
GO


-- Insert product (movie) met ��n ongeldige genre, resulteert in foutmelding
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie met ��n ongeldige genre', 3.50)

PRINT 'Hier verwachten we een foutmelding'
INSERT INTO Product_Genre
VALUES (@PRID, 'Role-playing')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

COMMIT TRANSACTION
GO


-- Insert product (game) met ��n geldige genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Game', 'Game met ��n geldige genre', 2.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'MMO')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

COMMIT TRANSACTION
GO

-- Opruimen van testdata
DELETE FROM Product
WHERE product_id=(SELECT product_id FROM Product WHERE title = 'Game met ��n geldige genre')
GO


-- Insert product (game) met ��n ongeldige genre, resulteert in foutmelding
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Game', 'Game met ��n ongeldige genre', 3.50)

PRINT 'Hier verwachten we een foutmelding'
INSERT INTO Product_Genre
VALUES (@PRID, 'Documentary')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

COMMIT TRANSACTION
GO


-- Insert twee producten (movie) met ��n geldige genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie met ��n geldige genre (1/2)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Action')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID

SET @PRID = @PRID+1;

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie met ��n geldige genre (2/2)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Horror')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID

COMMIT TRANSACTION
GO

-- Opruimen van testdata
DELETE FROM Product_Genre
WHERE product_id IN (SELECT product_id FROM Product WHERE title = 'Movie met ��n geldige genre (1/2)' OR title = 'Movie met ��n geldige genre (2/2)')
GO

DELETE FROM Product
WHERE product_id IN (SELECT product_id FROM Product WHERE title = 'Movie met ��n geldige genre (1/2)' OR title = 'Movie met ��n geldige genre (2/2)')
GO


-- Insert twee producten (movie) met twee geldige genres
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie met twee geldige genres (1/2)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Action')

INSERT INTO Product_Genre
VALUES (@PRID, 'Adventure')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID

SET @PRID = @PRID+1;

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie met twee geldige genres (2/2)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Horror')

INSERT INTO Product_Genre
VALUES (@PRID, 'Fantasy')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID

COMMIT TRANSACTION
GO

-- Opruimen van testdata
DELETE FROM Product_Genre
WHERE product_id IN (SELECT product_id FROM Product WHERE title = 'Movie met twee geldige genres (1/2)' OR title = 'Movie met twee geldige genres (2/2)')
GO

DELETE FROM Product
WHERE product_id IN (SELECT product_id FROM Product WHERE title = 'Movie met twee geldige genres (1/2)' OR title = 'Movie met twee geldige genres (2/2)')
GO


-- Insert twee producten (game) met ��n geldige genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Game', 'Game met ��n geldige genre (1/2)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Action')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID

SET @PRID = @PRID+1;

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Game', 'Game met ��n geldige genre (2/2)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'MMO')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID

COMMIT TRANSACTION
GO

-- Opruimen van testdata
DELETE FROM Product_Genre
WHERE product_id IN (SELECT product_id FROM Product WHERE title = 'Game met ��n geldige genre (1/2)' OR title = 'Game met ��n geldige genre (2/2)')
GO

DELETE FROM Product
WHERE product_id IN (SELECT product_id FROM Product WHERE title = 'Game met ��n geldige genre (1/2)' OR title = 'Game met ��n geldige genre (2/2)')
GO


-- Insert twee producten (game) met twee geldige genres
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Game', 'Game met twee geldige genres (1/2)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Action')

INSERT INTO Product_Genre
VALUES (@PRID, 'Role-playing')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID

SET @PRID = @PRID+1;

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Game', 'Game met twee geldige genres (2/2)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Adventure')

INSERT INTO Product_Genre
VALUES (@PRID, 'Strategy')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID

COMMIT TRANSACTION
GO

-- Opruimen van testdata
DELETE FROM Product_Genre
WHERE product_id IN (SELECT product_id FROM Product WHERE title = 'Game met twee geldige genres (1/2)' OR title = 'Game met twee geldige genres (2/2)')
GO

DELETE FROM Product
WHERE product_id IN (SELECT product_id FROM Product WHERE title = 'Game met twee geldige genres (1/2)' OR title = 'Game met twee geldige genres (2/2)')
GO