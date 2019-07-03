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
	BEGIN

		SET NOCOUNT, XACT_ABORT ON;

		IF @productId IS NULL
		THROW 50001, 'No value is given for parameter "productId"', 1;

		IF @genre IS NULL
		THROW 50001, 'No value is given for parameter "genre"', 1;

		BEGIN TRY
			
			IF NOT EXISTS(SELECT * 
				FROM Product 
				WHERE product_id = @productId)

			THROW 50001, 'Given product does not exist.', 1;

			IF EXISTS(SELECT * 
				FROM Product_Genre
				WHERE product_id = @productId
					AND genre_name = 'No genre allocated')

			DELETE FROM Product_Genre 
			WHERE product_id = @productId
				AND genre_name = 'No genre allocated'

			INSERT INTO Product_Genre 
			VALUES (@productId, @genre)

		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
			THROW;
		END CATCH

	;END
go

--  --------------------------------------------------------
--  Stored Procedure
--  --------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'SP_ProductGenreDelete' AND [type] = 'P')
BEGIN
	DROP PROCEDURE [dbo].SP_ProductGenreDelete;
END;
go

CREATE PROCEDURE SP_ProductGenreDelete
(@productId	ID, 
 @genre		GENRE
)
AS
	BEGIN

		SET NOCOUNT, XACT_ABORT ON;

		IF @productId IS NULL
		THROW 50001, 'No value is given for parameter "productId"', 1;

		IF @genre IS NULL
		THROW 50001, 'No value is given for parameter "genre"', 1;

		BEGIN TRY
			
			IF NOT EXISTS(SELECT COUNT(*) AS numOfGenres 
				FROM Product_Genre 
				WHERE product_id = @productId 
				HAVING COUNT(product_id) > 1)

			THROW 50001, 'It is not possible to delete this genre. The minimum amount of genres per product is 1.', 1;

			DELETE FROM Product_Genre 
			WHERE product_id = @productId
				AND genre_name = @genre

		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
			THROW;
		END CATCH

	;END
go

--  --------------------------------------------------------
--  Stored Procedure
--  --------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'SP_ProductInsert' AND [type] = 'P')
BEGIN
	DROP PROCEDURE [dbo].SP_ProductInsert;
END;
go

CREATE PROCEDURE SP_ProductInsert
(@productId					ID, 
 @productType				VARCHAR(255),
 @previousProductId			ID,
 @title						TITLE,
 @coverImage				COVER_IMAGE,
 @description				DESCRIPTION,
 @defaultPrice				PRICE,
 @publicationYear			YEAR,
 @numberOfOnlinePlayers		NUMBER,
 @duration					DURATION,
 @url						VARCHAR(255)
)
AS
	BEGIN

		SET NOCOUNT, XACT_ABORT ON;

		IF @productId IS NULL
		THROW 50001, 'No value is given for parameter "productId"', 1;

		IF @productType IS NULL
		THROW 50001, 'No value is given for parameter "genre"', 1;

		IF @title IS NULL
		THROW 50001, 'No value is given for parameter "title"', 1;

		IF @defaultPrice IS NULL
		THROW 50001, 'No value is given for parameter "defaultPrice"', 1;

		BEGIN TRY
			
			IF NOT EXISTS(SELECT * 
				FROM Product_Genre 
				WHERE product_id = @productId)

			INSERT INTO Product_Genre VALUES (@productId, 'No genre allocated')

			INSERT INTO Product
			VALUES (@productId, 
				@productType,
				@previousProductId,
				@title, 
				@coverImage,
				@description,
				@defaultPrice,
				@publicationYear,
				@numberOfOnlinePlayers,
				@duration,
				@url)

		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
			THROW;
		END CATCH

	;END
go

--  --------------------------------------------------------
--  Stored Procedure
--  --------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'SP_ProductDelete' AND [type] = 'P')
BEGIN
	DROP PROCEDURE [dbo].SP_ProductDelete;
END;
go

CREATE PROCEDURE SP_ProductDelete
(@productId	ID)
AS
	BEGIN

		SET NOCOUNT, XACT_ABORT ON;

		IF @productId IS NULL
		THROW 50001, 'No value is given for parameter "productId"', 1;

		BEGIN TRY
			
			IF NOT EXISTS(SELECT * 
				FROM Product_Genre 
				WHERE product_id = @productId)

			THROW 50001, 'Given product does not exist.', 1;

			DELETE FROM Product_Genre 
			WHERE product_id = @productId

			DELETE FROM Product
			WHERE product_id = @productId

		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
			THROW;
		END CATCH

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
-- [13] Genre toevoegen aan niet bestaande film of spel
-- [14] Product verwijderen, ook bijbehorende genres verwijderen
-- [15] Product verwijderen, niet bestaand product

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 01] : Film toevoegen zonder genre
-- Result: Success (standard genre added)

BEGIN TRANSACTION;

EXEC SP_ProductInsert 999999, 'Movie', null, 'Scenario 01 - Test', null, null, 2.50, 2019, null, null, null

-- Toon testdata
SELECT * 
FROM Product 
WHERE product_id = 999999
-- Toon testdata
SELECT * 
FROM Product_Genre 
WHERE product_id = 999999

ROLLBACK TRANSACTION
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 02] : Spel toevoegen zonder genre
-- Result: Success (standard genre added)

BEGIN TRANSACTION;

EXEC SP_ProductInsert 999999, 'Game', null, 'Scenario 02 - Test', null, null, 3.00, 2018, 4, null, null

-- Toon testdata
SELECT * 
FROM Product 
WHERE product_id = 999999
-- Toon testdata
SELECT * 
FROM Product_Genre 
WHERE product_id = 999999

ROLLBACK TRANSACTION
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 03] : Film en spel toevoegen zonder genre
-- Result: Success (standard genre added)

BEGIN TRANSACTION;

EXEC SP_ProductInsert 999999, 'Movie', null, 'Scenario 03 - Test film', null, null, 2.50, 2019, null, null, null
EXEC SP_ProductInsert 999998, 'Game', null, 'Scenario 03 - Test spel', null, null, 3.00, 2018, 4, null, null

-- Toon testdata
SELECT * 
FROM Product 
WHERE product_id = 999999 
	OR product_id = 999998
-- Toon testdata
SELECT * 
FROM Product_Genre
WHERE product_id = 999999 
	OR product_id = 999998

ROLLBACK TRANSACTION
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 04] : Film toevoegen met één genre
-- Result: Success

BEGIN TRANSACTION;

EXEC SP_ProductInsert 999999, 'Movie', null, 'Scenario 04 - Test', null, null, 2.50, 2019, null, null, null

-- Toon eerst de standaard toegevoegde genre
SELECT * 
FROM Product_Genre 
WHERE product_id = 999999

-- Toon testdata
SELECT * 
FROM Product 
WHERE product_id = 999999

EXEC SP_ProductGenreInsert 999999, 'Action'

-- Toon testdata
SELECT * 
FROM Product_Genre 
WHERE product_id = 999999

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 05] : Film toevoegen met twee genres
-- Result: Success

BEGIN TRANSACTION;

EXEC SP_ProductInsert 999999, 'Movie', null, 'Scenario 05 - Test', null, null, 2.50, 2019, null, null, null

-- Toon eerst de standaard toegevoegde genre
SELECT * 
FROM Product_Genre 
WHERE product_id = 999999

-- Toon testdata
SELECT * 
FROM Product 
WHERE product_id = 999999

EXEC SP_ProductGenreInsert 999999, 'Action'
EXEC SP_ProductGenreInsert 999999, 'Horror'

-- Toon testdata
SELECT * 
FROM Product_Genre 
WHERE product_id = 999999

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 06] : Spel toevoegen met één genre
-- Result: Success

BEGIN TRANSACTION;

EXEC SP_ProductInsert 999999, 'Game', null, 'Scenario 06 - Test', null, null, 3.00, 2018, null, null, null

-- Toon eerst de standaard toegevoegde genre
SELECT * 
FROM Product_Genre 
WHERE product_id = 999999

-- Toon testdata
SELECT * 
FROM Product 
WHERE product_id = 999999

-- Genre toevoegen
EXEC SP_ProductGenreInsert 999999, 'Action'

-- Toon testdata
SELECT * 
FROM Product_Genre 
WHERE product_id = 999999

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 07] : Spel toevoegen met twee genres
-- Result: Success

BEGIN TRANSACTION;

EXEC SP_ProductInsert 999999, 'Game', null, 'Scenario 07 - Test', null, null, 3.00, 2018, null, null, null

-- Toon testdata
SELECT * 
FROM Product 
WHERE product_id = 999999

-- Twee genres toevoegen
EXEC SP_ProductGenreInsert 999999, 'Action'
EXEC SP_ProductGenreInsert 999999, 'Horror'

-- Toon testdata
SELECT * 
FROM Product_Genre 
WHERE product_id = 999999

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 08] : Film en spel toevoegen met één genre
-- Result: Success

BEGIN TRANSACTION;

EXEC SP_ProductInsert 999999, 'Movie', null, 'Scenario 08 - Test film', null, null, 2.50, 2019, null, null, null
EXEC SP_ProductInsert 999998, 'Game', null, 'Scenario 08 - Test spel', null, null, 3.00, 2018, 4, null, null

-- Toon testdata
SELECT * 
FROM Product 
WHERE product_id = 999999 
	OR product_id = 999998

-- Twee genres toevoegen
EXEC SP_ProductGenreInsert 999999, 'Action'
EXEC SP_ProductGenreInsert 999998, 'Horror'

-- Toon testdata
SELECT * 
FROM Product_Genre
WHERE product_id = 999999 
	OR product_id = 999998

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 09] : Film en spel toevoegen met twee genres
-- Result: Success

BEGIN TRANSACTION;

EXEC SP_ProductInsert 999999, 'Movie', null, 'Scenario 09 - Test film', null, null, 2.50, 2019, null, null, null
EXEC SP_ProductInsert 999998, 'Game', null, 'Scenario 09 - Test spel', null, null, 3.00, 2018, 4, null, null

-- Toon testdata
SELECT * 
FROM Product 
WHERE product_id = 999999 
	OR product_id = 999998

-- Vier genres toevoegen
EXEC SP_ProductGenreInsert 999999, 'Action'
EXEC SP_ProductGenreInsert 999999, 'Horror'
EXEC SP_ProductGenreInsert 999998, 'Sci-fi'
EXEC SP_ProductGenreInsert 999998, 'Fantasy'


-- Toon testdata
SELECT * 
FROM Product_Genre
WHERE product_id = 999999 
	OR product_id = 999998

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 10] : Alle genres van film of spel verwijderen
-- Result: Throw Error

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

EXEC SP_ProductGenreDelete 2, 'Comedy'
EXEC SP_ProductGenreDelete 2, 'Crime'

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 11] : Eén genre van film of spel verwijderen
-- Result: Success

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

EXEC SP_ProductGenreDelete 2, 'Comedy'

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 12] : Genre toevoegen aan niet bestaande film of spel
-- Result: Throw Error

BEGIN TRANSACTION;

EXEC SP_ProductGenreInsert 9999999, 'Action'

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 13] : Genre toevoegen aan bestaande film of spel
-- Result: Success

BEGIN TRANSACTION;

EXEC SP_ProductGenreInsert 2, 'Action'

ROLLBACK TRANSACTION;
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 14] : Product verwijderen, ook bijbehorende genres verwijderen
-- Result: Success
BEGIN TRANSACTION 

EXEC SP_ProductDelete 2

-- Records verwijderd, geen resultaten in Product of Product_Genre
SELECT * FROM Product WHERE product_id = 2
SELECT * FROM Product_Genre WHERE product_id = 2

ROLLBACK TRANSACTION
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 15] : Product verwijderen, niet bestaand product
-- Result: Throw Error
BEGIN TRANSACTION 

EXEC SP_ProductDelete 999999

ROLLBACK TRANSACTION
go