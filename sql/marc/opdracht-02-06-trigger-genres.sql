USE odisee;
GO

DROP TRIGGER IF EXISTS trgProductGenreInsertValidGenreForType
GO

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

--  --------------------------------------------------------
--  Trigger
--  --------------------------------------------------------
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


--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 01
-- Insert product zonder genre (krijgt standaard genre 'No genre allocated' toegekend)
-- Result: Success
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie zonder genre', 3.50)

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 02
-- Insert product (movie) met één geldige genre
-- Result: Success
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie met één geldige genre', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Action')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 03
-- Insert product (movie) met één ongeldige genre, resulteert in foutmelding
-- Result: Throw Error
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie met één ongeldige genre', 3.50)

PRINT 'Hier verwachten we een foutmelding'
INSERT INTO Product_Genre
VALUES (@PRID, 'Role-playing')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 04
-- Insert product (game) met één geldige genre
-- Result: Success
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Game', 'Game met één geldige genre', 2.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'MMO')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 05
-- Insert product (game) met één ongeldige genre, resulteert in foutmelding
-- Result: Throw Error
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Game', 'Game met één ongeldige genre', 3.50)

PRINT 'Hier verwachten we een foutmelding'
INSERT INTO Product_Genre
VALUES (@PRID, 'Documentary')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 06
-- Insert twee producten (movie) met één geldige genre
-- Result: Success
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie met één geldige genre (1/2)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Action')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID

SET @PRID = @PRID+1;

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie met één geldige genre (2/2)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Horror')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 07
-- Insert twee producten (movie) met twee geldige genres
-- Result: Success
BEGIN TRANSACTION;
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
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 08
-- Insert twee producten (game) met één geldige genre
-- Result: Success
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Game', 'Game met één geldige genre (1/2)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Action')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID

SET @PRID = @PRID+1;

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Game', 'Game met één geldige genre (2/2)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'MMO')

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 09
-- Insert twee producten (game) met twee geldige genres
-- Result: Success
BEGIN TRANSACTION;
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
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 10
-- Update product (movie) met een geldige genre
-- Result: Success
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie updaten van genre(1)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Adventure')

SELECT * FROM Product_Genre WHERE product_id = @PRID

UPDATE Product_Genre
SET genre_name = 'Horror'
WHERE product_id = @PRID

SELECT * FROM Product_Genre WHERE product_id = @PRID
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 11
-- Update product (movie) met een ongeldige genre
-- Result: Throw Error
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Movie', 'Movie updaten van genre(1)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Romance')

SELECT * FROM Product_Genre WHERE product_id = @PRID

PRINT 'Hier verwachten we een foutmelding'
UPDATE Product_Genre
SET genre_name = 'Action-Adventure'
WHERE product_id = @PRID

SELECT * FROM Product_Genre WHERE product_id = @PRID
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 12
-- Update product (game) met een geldige genre
-- Result: Success
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Game', 'Game updaten van genre(1)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Action-Adventure')

SELECT * FROM Product_Genre WHERE product_id = @PRID

UPDATE Product_Genre
SET genre_name = 'Simulation'
WHERE product_id = @PRID

SELECT * FROM Product_Genre WHERE product_id = @PRID
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 12
-- Update product (game) met een ongeldige genre
-- Result: Throw Error
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

INSERT INTO Product (product_id, product_type, title, movie_default_price)
VALUES (@PRID, 'Game', 'Game updaten van genre(1)', 3.50)

INSERT INTO Product_Genre
VALUES (@PRID, 'Action-Adventure')

SELECT * FROM Product_Genre WHERE product_id = @PRID

PRINT  'Hier verwachten we een foutmelding'
UPDATE Product_Genre
SET genre_name = 'Romance'
WHERE product_id = @PRID

SELECT * FROM Product_Genre WHERE product_id = @PRID
ROLLBACK TRANSACTION;