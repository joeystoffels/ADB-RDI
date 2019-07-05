--  --------------------------------------------------------
--  Constraint 6 - Stored Procedure (genres)
--  --------------------------------------------------------
-- Genres voor films en spellen zijn verschillend, deze mogen niet bij het verkeerde media-item gebruikt worden. 
USE odisee
go

IF EXISTS (SELECT * 
	FROM sys.objects WHERE [name] = 'FK_PRODUCT__PRODUCT_G_PRODUCT' 
		AND [type] = 'F')
BEGIN
	ALTER TABLE Product_Genre
	DROP CONSTRAINT FK_PRODUCT__PRODUCT_G_PRODUCT
END;
go

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'product_type'
          AND Object_ID = Object_ID(N'dbo.Genre'))
BEGIN
	ALTER TABLE Genre
	ADD product_type TYPE
END;
go

IF EXISTS (SELECT * 
	FROM Genre 
	WHERE product_type IS NULL)
BEGIN
	UPDATE Genre
	SET product_type = 'Movie'
END;
go 

-- Omdat we enkele genres hebben welke voor een movie en een game beschikbaar zijn, 
-- maken we de combinatie van genre_name en product_type uniek als Primary Key
ALTER TABLE Product_Genre
DROP CONSTRAINT IF EXISTS [FK_PRODUCT__IS OF GEN_GENRE]
ALTER TABLE Genre
DROP CONSTRAINT IF EXISTS PK_GENRE
ALTER TABLE Genre
ALTER COLUMN product_type TYPE NOT NULL
ALTER TABLE Genre
ADD CONSTRAINT PK_GENRE_TYPE PRIMARY KEY (genre_name, product_type)
go

IF NOT EXISTS (SELECT * 
		FROM Genre 
		WHERE product_type = 'Game')
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
go

--  --------------------------------------------------------
--  Stored Procedure
--  --------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'SP_ProductGenreInsert' AND [type] = 'P')
BEGIN
	DROP PROCEDURE [dbo].[SP_ProductGenreInsert];
END;
go

CREATE PROCEDURE SP_ProductGenreInsert
(@productId	ID, 
 @genre		GENRE
)
AS

		SET NOCOUNT, XACT_ABORT ON;

		BEGIN TRANSACTION;

		BEGIN TRY

		IF @productId IS NULL
		THROW 56007, 'No value is given for parameter "productId"', 1;
			
			IF NOT EXISTS(SELECT * 
				FROM Product 
				WHERE product_id = @productId)

			THROW 56008, 'Given product does not exist.', 1;

			IF NOT EXISTS(SELECT * 
				FROM Product AS p
				WHERE product_id = @productId
					AND @genre IN (SELECT genre_name FROM Genre AS g WHERE g.product_type = p.product_type))

			THROW 56009, 'No valid genre for this type of product.', 1;		

			INSERT INTO Product_Genre 
			VALUES (@productId, @genre)

			COMMIT TRANSACTION;

		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
			THROW;
		END CATCH
go

--  --------------------------------------------------------
--  Stored Procedure
--  --------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'SP_ProductGenreUpdate' AND [type] = 'P')
BEGIN
	DROP PROCEDURE [dbo].[SP_ProductGenreUpdate];
END;
go

CREATE PROCEDURE SP_ProductGenreUpdate
(@productId	ID, 
 @oldGenre	GENRE,
 @newGenre	GENRE
)
AS

		SET NOCOUNT, XACT_ABORT ON;

		BEGIN TRANSACTION;

		BEGIN TRY
			
			IF @productId IS NULL
			THROW 56010, 'No value is given for parameter "productId"', 1;

			IF NOT EXISTS(SELECT * 
				FROM Product 
				WHERE product_id = @productId)

			THROW 56011, 'Given product does not exist.', 1;

			IF NOT EXISTS(SELECT * 
				FROM Product AS p
				WHERE product_id = @productId
					AND @newGenre IN (SELECT genre_name FROM Genre AS g WHERE g.product_type = p.product_type))

			THROW 56012, 'No valid genre for this type of product.', 1;		

			UPDATE Product_Genre
			SET genre_name = @newGenre 
			WHERE product_id = @productId 
				AND genre_name = @oldGenre

			COMMIT TRANSACTION;
	
		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
			THROW;
		END CATCH
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [01] Eén ongeldige genre toevoegen niet behorende bij product type Movie
-- [02] Eén ongeldige genre toevoegen niet behorende bij product type Game
-- [03] Eén geldige genre toevoegen aan Movie
-- [04] Eén geldige genre toevoegen aan Game
-- [05] Genre van Movie updaten naar genre van Game
-- [06] Genre van Game updaten naar genre van Movie
-- [07] Genre van Movie updaten naar genre van Movie
-- [08] Genre van Game updaten naar genre van Game

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 01] : Eén ongeldige genre toevoegen niet behorende bij product type Movie
-- Result: Throw Error

BEGIN TRANSACTION;

EXEC SP_ProductGenreInsert 2, 'MMO'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 02] : Eén ongeldige genre toevoegen niet behorende bij product type Game
-- Result: Throw Error

BEGIN TRANSACTION;

EXEC SP_ProductGenreInsert 412363, 'Horror'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 03] : Eén geldige genre toevoegen aan Movie
-- Result: Success

BEGIN TRANSACTION;

EXEC SP_ProductGenreInsert 2, 'Fantasy'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 04] : Eén geldige genre toevoegen aan Game
-- Result: Success

BEGIN TRANSACTION;

EXEC SP_ProductGenreInsert 412363, 'MMO'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 05] : Genre van Movie updaten naar genre van Game
-- Result: Throw Error

BEGIN TRANSACTION;

EXEC SP_ProductGenreUpdate 2, 'Comedy', 'MMO'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 06] : Genre van Game updaten naar genre van Movie
-- Result: Throw Error

BEGIN TRANSACTION;

-- Testdata aanmaken
EXEC SP_ProductGenreInsert 412363, 'MMO'

EXEC SP_ProductGenreUpdate 412363, 'MMO', 'Comedy'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 07] : Genre van Movie updaten naar genre van Movie
-- Result: Success

BEGIN TRANSACTION;

EXEC SP_ProductGenreUpdate 2, 'MMO', 'Comedy'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 08] : Genre van Game updaten naar genre van Game
-- Result: Success

BEGIN TRANSACTION;

-- Testdata aanmaken
EXEC SP_ProductGenreInsert 412363, 'MMO'

EXEC SP_ProductGenreUpdate 412363, 'MMO', 'Action-Adventure'

ROLLBACK TRANSACTION;
