USE odisee;
GO

DROP PROCEDURE IF EXISTS spReviewCategoryInsert
GO

-- Toevoegen van extra kolom, product_type
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'product_type'
          AND Object_ID = Object_ID(N'dbo.Category'))
BEGIN
ALTER TABLE Category
ADD product_type TYPE
;END
GO

-- De in eerste instantie aanwezige categories behoren bij een movie, derhalve wordt het product_type toegevoegd
IF NOT EXISTS(SELECT category_name FROM Category WHERE product_type = 'Movie')
BEGIN
	UPDATE Category
	SET product_type = 'Movie'
;END
GO

IF NOT EXISTS (SELECT * FROM Category WHERE product_type = 'Game')
BEGIN
	INSERT INTO Category
	VALUES ('Gameplay', 'Game')
		, ('Challenge', 'Game')
		, ('Graphics and Sound', 'Game')
;END
GO

-- Omdat we enkele reviews hebben welke voor een movie en een game beschikbaar zijn, 
-- maken we de combinatie van category_name en product_type uniek als Primary Key
ALTER TABLE Review_Category
DROP CONSTRAINT IF EXISTS [FK_REVIEW_C_REVIEWCAT_CATEGORY]
GO
ALTER TABLE Category
DROP CONSTRAINT IF EXISTS PK_CATEGORY
GO
ALTER TABLE Category
ALTER COLUMN product_type TYPE NOT NULL
GO
ALTER TABLE Category
ADD CONSTRAINT PK_CATEGORY_TYPE PRIMARY KEY (category_name, product_type)
GO

-- Aamaken van table valued parameter tabel waardoor meerdere categorieén toegevoegd kunnen worden
DROP TYPE IF EXISTS CategoryTableType
GO
CREATE TYPE CategoryTableType AS TABLE (category_name CATEGORY PRIMARY KEY, score int)
GO

--  --------------------------------------------------------
--  Stored procedure
--  --------------------------------------------------------
CREATE PROCEDURE spReviewCategoryInsert (@PRID ID, @email EMAIL, @categories CategoryTableType READONLY)
AS
BEGIN
	
	SET NOCOUNT ON;

	IF((SELECT COUNT(*) FROM @categories) = 0)
	BEGIN
		RAISERROR('Geen review categorieén opgegeven. Opdracht kan niet worden uitgevoerd.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END

	IF((SELECT product_type FROM Product WHERE product_id = @PRID) = 'Movie')
	BEGIN
		IF ((SELECT COUNT(*) FROM Category WHERE category_name IN (SELECT category_name FROM @categories) AND product_type = 'Movie') = 0)
		BEGIN
			RAISERROR('Review categorie kan niet voor dit type product worden gebruikt.', 16, 1);
			RETURN;
		;END
	;END

	IF((SELECT product_type FROM Product WHERE product_id = @PRID) = 'Game')
	BEGIN
		IF ((SELECT COUNT(*) FROM Category WHERE category_name IN (SELECT category_name FROM @categories) AND product_type = 'Game') = 0)
		BEGIN
			RAISERROR('Review categorie kan niet voor dit type product worden gebruikt.', 16, 1);
			RETURN;
		;END
	;END

	-- Eerst review category (beoordeling) toevoegen
	INSERT INTO Review_Category
	SELECT @PRID, @email, category_name, score
	FROM @categories

;END
GO

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 01
-- Insert review (movie) met één juiste category
-- Result: Success
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product WHERE product_type = 'Movie')
DECLARE @CategoryTableType CategoryTableType

INSERT INTO @CategoryTableType
VALUES ('Acting', 9)

EXEC spReviewCategoryInsert @PRID, 'testdata@han.nl', @CategoryTableType;

SELECT * FROM Review_Category WHERE product_id = @PRID
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 02
-- Insert review (movie) met één onjuiste category
-- Result: Throw Error
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product WHERE product_type = 'Movie')
DECLARE @CategoryTableType CategoryTableType

INSERT INTO @CategoryTableType
VALUES ('Graphics and Sound', 6)

PRINT 'Hier verwachten we een foutmelding'
EXEC spReviewCategoryInsert @PRID, 'testdata@han.nl', @CategoryTableType;
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 03
-- Insert review (movie) met twee juiste categories
-- Result: Success
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product WHERE product_type = 'Movie')
DECLARE @CategoryTableType CategoryTableType

INSERT INTO @CategoryTableType
VALUES ('Acting', 9), ('Plot', 5)

EXEC spReviewCategoryInsert @PRID, 'testdata@han.nl', @CategoryTableType;

SELECT * FROM Review_Category WHERE product_id = @PRID
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 04
-- Insert review (game) met één juiste category
-- Result: Success
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product WHERE product_type = 'Game')
DECLARE @CategoryTableType CategoryTableType

INSERT INTO @CategoryTableType
VALUES ('Gameplay', 9)

EXEC spReviewCategoryInsert @PRID, 'testdata@han.nl', @CategoryTableType;

SELECT * FROM Review_Category WHERE product_id = @PRID
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 05
-- Insert review (game) met één onjuiste category
-- Result: Throw Error
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product WHERE product_type = 'Game')
DECLARE @CategoryTableType CategoryTableType

INSERT INTO @CategoryTableType
VALUES ('Plot', 9)

PRINT 'Hier verwachten we een foutmelding'
EXEC spReviewCategoryInsert @PRID, 'testdata@han.nl', @CategoryTableType;

SELECT * FROM Review_Category WHERE product_id = @PRID
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 06
-- Insert review (game) met twee juiste categories
-- Result: Success
BEGIN TRANSACTION;
DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product WHERE product_type = 'Game')
DECLARE @CategoryTableType CategoryTableType

INSERT INTO @CategoryTableType
VALUES ('Graphics and Sound', 9), ('Gameplay', 5)

EXEC spReviewCategoryInsert @PRID, 'testdata@han.nl', @CategoryTableType;

SELECT * FROM Review_Category WHERE product_id = @PRID
ROLLBACK TRANSACTION;