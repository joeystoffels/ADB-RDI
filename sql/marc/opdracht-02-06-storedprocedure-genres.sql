/*
 Constraint 6. Genres voor films en spellen zijn verschillend, deze mogen niet bij het verkeerde media-item gebruikt worden. 
			   Hetzelfde geld voor Review aspecten.

 Uitwerking Stored Procedures (Genres)
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

ALTER TABLE Product_Genre
DROP CONSTRAINT IF EXISTS [FK_PRODUCT__IS OF GEN_GENRE]
GO
ALTER TABLE Genre
DROP CONSTRAINT IF EXISTS PK_GENRE
GO

-- De in eerste instantie aanwezige genres behoren bij een movie, derhalve wordt het product_type toegevoegd
IF EXISTS (SELECT * FROM Genre WHERE product_type = NULL)
BEGIN
	UPDATE Genre
	SET product_type = 'Movie'
;END
GO

-- Nu voegen we de juiste genres toe voor games
IF NOT EXISTS (SELECT * FROM Genre WHERE product_type = 'Game')
BEGIN
	INSERT INTO Genre
	VALUES ('Action', 'Game')
		, ('Action-Adventure', 'Game')
		, ('Adventure', 'Game')
		, ('MMO', 'Game')
		, ('Role-playing', 'Game')
		, ('Simulation', 'Game')
		, ('Strategy', 'Game')
;END
GO

-- Extra genre toegevoegd welke wordt toegekend aan een nieuw product
IF NOT EXISTS (SELECT * 
			   FROM Genre 
			   WHERE genre_name = 'No genre allocated')
BEGIN
	INSERT INTO Genre
	VALUES ('No genre allocated', 'Movie'), ('No genre allocated', 'Game') 
;END
GO

-- Omdat we enkele genres hebben welke voor een movie en een game beschikbaar zijn, 
-- maken we de combinatie van genre_name en product_type uniek als Primary Key
ALTER TABLE Genre
ALTER COLUMN product_type TYPE NOT NULL
GO
ALTER TABLE Genre
ADD CONSTRAINT PK_GENRE_TYPE PRIMARY KEY (genre_name, product_type)
GO

-- Bij het toevoegen van een product, worden de genres als Table Valued Parameter meegegeven 
DROP TYPE IF EXISTS GenreTableType
GO
CREATE TYPE GenreTableType AS TABLE (genre_name GENRE PRIMARY KEY)
GO


-- Stored procedure om product toe te kunnen voegen, bevat t.b.v. demo alleen verplichte velden (geen, ��n en twee genres)
DROP PROCEDURE IF EXISTS spProductInsert
GO
CREATE PROCEDURE spProductInsert (@product_type TYPE, @title TITLE, @price PRICE, @genres GenreTableType READONLY)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);

	-- Eerst product toevoegen
	INSERT INTO Product (product_id, product_type, title, movie_default_price)
	VALUES (@PRID, @product_type, @title, @price)

	IF((SELECT COUNT(*) FROM @genres) = 0)
	BEGIN
		INSERT INTO Product_Genre VALUES (@PRID, 'No genre allocated');
	END

	IF((SELECT COUNT(*) FROM @genres) > 0)
	BEGIN
		IF((SELECT product_type FROM Product WHERE product_id = @PRID) = 'Movie')
		BEGIN
			IF ((SELECT COUNT(*) FROM Genre WHERE genre_name IN (SELECT genre_name FROM @genres) AND product_type = 'Movie') = 0)
			BEGIN
				RAISERROR('Genre kan niet voor dit type product worden gebruikt.', 16, 1);
				RETURN;
			;END
		;END

		IF((SELECT product_type FROM Product WHERE product_id = @PRID) = 'Game')
		BEGIN
			IF ((SELECT COUNT(*) FROM Genre WHERE genre_name IN (SELECT genre_name FROM @genres) AND product_type = 'Game') = 0)
			BEGIN
				RAISERROR('Genre kan niet voor dit type product worden gebruikt.', 16, 1);
				RETURN;
			;END
		;END

		-- Nu ook genres toevoegen
		INSERT INTO Product_Genre
		SELECT @PRID, genre_name
		FROM @genres
	;END	

;END
GO

-- SP updaten genrenaam
DROP PROCEDURE IF EXISTS spProductGenreUpdate
GO
CREATE PROCEDURE spProductGenreUpdate (@PRID ID, @oldGenre GENRE, @newGenre GENRE)
AS
BEGIN

	SET NOCOUNT ON;

	IF((SELECT product_type FROM Product WHERE product_id = @PRID) = 'Movie')
	BEGIN
		IF ((SELECT COUNT(*) FROM Genre WHERE genre_name = @newGenre AND product_type = 'Movie') = 0)
		BEGIN
			RAISERROR('Genre kan niet voor dit type product worden gebruikt.', 16, 1);
			RETURN;
		;END
	;END

	IF((SELECT product_type FROM Product WHERE product_id = @PRID) = 'Game')
	BEGIN
		IF ((SELECT COUNT(*) FROM Genre WHERE genre_name = @newGenre AND product_type = 'Game') = 0)
		BEGIN
			RAISERROR('Genre kan niet voor dit type product worden gebruikt.', 16, 1);
			RETURN;
		;END
	;END

	UPDATE Product_Genre
	SET genre_name = @newGenre WHERE product_id = @PRID AND genre_name = @oldGenre

;END
GO

/*

	Testscenario's:

	|X| Insert product zonder genre (krijgt standaard genre 'No genre allocated' toegekend)
	|X| Insert product (movie) met ��n geldige genre
	|X| Insert product (movie) met ��n ongeldige genre, resulteert in foutmelding
	|X| Insert product (game) met ��n geldige genre
	|X| Insert product (game) met ��n ongeldige genre, resulteert in foutmelding
	|X| Update product (movie) met een geldige genre
	|X| Update product (movie) met een ongeldige genre
	|X| Update product (game) met een geldige genre
	|X| Update product (game) met een ongeldige genre

*/


-- Insert product zonder genre (krijgt standaard genre 'No genre allocated' toegekend)
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);
DECLARE @GenreTableType GenreTableType;

EXEC spProductInsert 'Movie', 'Movie zonder genre', 3.50, @GenreTableType

SELECT p.product_id, p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

ROLLBACK TRANSACTION
GO


-- Insert product (movie) met ��n geldige genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);
DECLARE @GenreTableType GenreTableType;

INSERT INTO @GenreTableType
VALUES ('Action')

EXEC spProductInsert 'Movie', 'Movie met ��n geldige genre', 3.50, @GenreTableType

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

ROLLBACK TRANSACTION
GO


-- Insert product (movie) met ��n ongeldige genre, resulteert in foutmelding
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);
DECLARE @GenreTableType GenreTableType;

INSERT INTO @GenreTableType
VALUES ('Role-playing')

PRINT 'Hier verwachten we een foutmelding'
EXEC spProductInsert 'Movie', 'Movie met ��n ongeldige genre', 3.50, @GenreTableType

ROLLBACK TRANSACTION
GO


-- Insert product (game) met ��n geldige genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);
DECLARE @GenreTableType GenreTableType;

INSERT INTO @GenreTableType
VALUES ('MMO')

EXEC spProductInsert 'Game', 'Game met ��n geldige genre', 3.50, @GenreTableType

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

ROLLBACK TRANSACTION
GO


-- Insert product (game) met ��n ongeldige genre, resulteert in foutmelding
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);
DECLARE @GenreTableType GenreTableType;

INSERT INTO @GenreTableType
VALUES ('Documentary')

PRINT 'Hier verwachten we een foutmelding'
EXEC spProductInsert 'Game', 'Game met ��n ongeldige genre', 3.50, @GenreTableType

SELECT p.title, pg.genre_name 
FROM Product AS p
	INNER JOIN Product_Genre AS pg 
		ON p.product_id=pg.product_id 
WHERE p.product_id=@PRID;

ROLLBACK TRANSACTION
GO


-- Update product (movie) met een geldige genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);
DECLARE @GenreTableType GenreTableType;

INSERT INTO @GenreTableType
VALUES ('Adventure')

EXEC spProductInsert 'Movie', 'Movie updaten van genre(1)', 3.50, @GenreTableType

SELECT * FROM Product_Genre WHERE product_id = @PRID

EXEC spProductGenreUpdate @PRID, 'Adventure', 'Fantasy'

SELECT * FROM Product_Genre WHERE product_id = @PRID

ROLLBACK TRANSACTION
GO


-- Update product (movie) met een ongeldige genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);
DECLARE @GenreTableType GenreTableType;

INSERT INTO @GenreTableType
VALUES ('Romance')

EXEC spProductInsert 'Movie', 'Movie updaten van genre(1)', 3.50, @GenreTableType

PRINT 'Hier verwachten we een foutmelding'
EXEC spProductGenreUpdate @PRID, 'Romance', 'Action-Adventure'

SELECT * FROM Product_Genre WHERE product_id = @PRID

ROLLBACK TRANSACTION
GO


-- Update product (game) met een geldige genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);
DECLARE @GenreTableType GenreTableType;

INSERT INTO @GenreTableType
VALUES ('Action-Adventure')

EXEC spProductInsert 'Game', 'Game updaten van genre(1)', 3.50, @GenreTableType

SELECT * FROM Product_Genre WHERE product_id = @PRID

EXEC spProductGenreUpdate @PRID, 'Action-Adventure', 'Simulation'

SELECT * FROM Product_Genre WHERE product_id = @PRID

ROLLBACK TRANSACTION
GO

-- Update product (game) met een ongeldige genre
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id)+1 FROM Product);
DECLARE @GenreTableType GenreTableType;

INSERT INTO @GenreTableType
VALUES ('Action-Adventure')

EXEC spProductInsert 'Game', 'Game updaten van genre(1)', 3.50, @GenreTableType

PRINT  'Hier verwachten we een foutmelding'
EXEC spProductGenreUpdate @PRID, 'Action-Adventure', 'Romance'

ROLLBACK TRANSACTION
GO