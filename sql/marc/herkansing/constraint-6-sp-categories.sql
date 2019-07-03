--  --------------------------------------------------------
--  Constraint 6 - Stored Procedures (categories) 
--  --------------------------------------------------------
-- Review aspecten voor films en spellen zijn verschillend, deze mogen niet bij het verkeerde media-item gebruikt worden. 
USE odisee
go

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'product_type'
          AND Object_ID = Object_ID(N'dbo.Category'))
BEGIN
	ALTER TABLE Category
	ADD product_type TYPE
END;
go

IF EXISTS (SELECT * 
	FROM Category 
	WHERE product_type IS NULL)
BEGIN
	UPDATE Category
	SET product_type = 'Movie'
END;
go 

IF NOT EXISTS (SELECT * 
		FROM Category 
		WHERE product_type = 'Game')
BEGIN
	INSERT INTO Category
	VALUES ('Gameplay', 'Game')
		, ('Challenge', 'Game')
		, ('Graphics and Sound', 'Game')
;END
go

--  --------------------------------------------------------
--  Stored Procedure
--  --------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'SP_ReviewCategoryInsert' AND [type] = 'P')
BEGIN
	DROP PROCEDURE [dbo].[SP_ReviewCategoryInsert];
END;
go

CREATE PROCEDURE SP_ReviewCategoryInsert
(@productId	ID,
 @emailadres EMAIL,
 @category CATEGORY,
 @score INT
)
AS
	BEGIN

		SET NOCOUNT, XACT_ABORT ON;

		IF @productId IS NULL
		THROW 50001, 'No value is given for parameter "productId"', 1;

		IF @emailadres IS NULL
		THROW 50001, 'No value is given for parameter "emailadres"', 1;

		IF @category IS NULL
		THROW 50001, 'No value is given for parameter "category"', 1;

		IF @score IS NULL
		THROW 50001, 'No value is given for parameter "score"', 1;

		BEGIN TRY

		IF NOT EXISTS(SELECT * 
				FROM Product AS p
				WHERE product_id = @productId
					AND @category IN (SELECT category_name FROM Category AS c WHERE c.product_type = p.product_type))

		THROW 50001, 'No valid category for this type of product.', 1;	

			INSERT INTO Review_Category 
			VALUES (@productId, @emailadres, @category, @score)

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
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'SP_ReviewCategoryUpdate' AND [type] = 'P')
BEGIN
	DROP PROCEDURE [dbo].[SP_ReviewCategoryUpdate];
END;
go

CREATE PROCEDURE SP_ReviewCategoryUpdate
(@productId	ID,
 @oldCategory CATEGORY,
 @newCategory CATEGORY
)
AS
	BEGIN

		SET NOCOUNT, XACT_ABORT ON;

		IF @productId IS NULL
		THROW 50001, 'No value is given for parameter "productId"', 1;

		IF @oldCategory IS NULL
		THROW 50001, 'No value is given for parameter "oldCategory"', 1;

		IF @newCategory IS NULL
		THROW 50001, 'No value is given for parameter "newCategory"', 1;

		BEGIN TRY

		IF NOT EXISTS(SELECT * 
				FROM Product AS p
				WHERE product_id = @productId
					AND @newCategory IN (SELECT category_name FROM Category AS c WHERE c.product_type = p.product_type))

		THROW 50001, 'No valid category for this type of product.', 1;	

			UPDATE Review_Category
			SET category_name = @newCategory 
			WHERE product_id = @productId 
				AND category_name = @oldCategory 

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
-- [01] Eén ongeldige review category toevoegen niet behorende bij product type Movie
-- [02] Eén ongeldige review category toevoegen niet behorende bij product type Game
-- [03] Eén geldige review category toevoegen aan Movie
-- [04] Eén geldige review category toevoegen aan Game
-- [05] Review category van Movie updaten naar review category van Game
-- [06] Review category van Game updaten naar review category van Movie
-- [07] Review category van Movie updaten naar review category van Movie
-- [08] Review category van Game updaten naar review category van Game

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 01] : Eén ongeldige review category toevoegen niet behorende bij product type Movie
-- Result: Throw Error

BEGIN TRANSACTION;

EXEC SP_ReviewCategoryInsert 2, 'info@info.nl', 'Challenge', 8

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 02] : Eén ongeldige review category toevoegen niet behorende bij product type Game
-- Result: Throw Error

BEGIN TRANSACTION;

EXEC SP_ReviewCategoryInsert 412363, 'info@info.nl', 'Acting', 8

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 03] : Eén geldige review category toevoegen aan Movie
-- Result: Success
BEGIN TRANSACTION;

EXEC SP_ReviewCategoryInsert 2, 'info@info.nl', 'Cinematography', 8

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 04] : Eén geldige review category toevoegen aan Game
-- Result: Success
BEGIN TRANSACTION;

EXEC SP_ReviewCategoryInsert 412363, 'info@info.nl', 'Challenge', 8

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 05] : Review category van Movie updaten naar review category van Game
-- Result: Throw Error
BEGIN TRANSACTION;

EXEC SP_ReviewCategoryUpdate 194492, 'Acting', 'Gameplay'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 06] : Review category van Game updaten naar review category van Movie
-- Result: Throw Error
BEGIN TRANSACTION;

-- Testdata aanmaken
EXEC SP_ReviewCategoryInsert 412363, 'info@info.nl', 'Gameplay', 8

EXEC SP_ReviewCategoryUpdate 194492, 'Gameplay', 'Comedy'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 07] : Review category van Movie updaten naar review category van Movie
-- Result: Success
BEGIN TRANSACTION;

EXEC SP_ReviewCategoryUpdate 194492, 'Acting', 'Music and Sound'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 08] : Review category van Game updaten naar review category van Game
-- Result: Success
BEGIN TRANSACTION;

-- Testdata aanmaken
EXEC SP_ReviewCategoryInsert 412363, 'info@info.nl', 'Gameplay', 8

EXEC SP_ReviewCategoryUpdate 412363, 'Gameplay', 'Challenge'

ROLLBACK TRANSACTION;