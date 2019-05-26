/*
 Constraint 6. Genres voor films en spellen zijn verschillend, deze mogen niet bij het verkeerde media-item gebruikt worden. 
			   Hetzelfde geld voor Review aspecten.

 Uitwerking Triggers
*/

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
UPDATE Category
SET product_type = 'Movie'


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

-- Toevoegen van review categories voor games
IF NOT EXISTS (SELECT * FROM Category WHERE product_type = 'Game')
BEGIN
	INSERT INTO Category
	VALUES ('Gameplay', 'Game')
		, ('Challenge', 'Game')
		, ('Graphics and Sound', 'Game')
;END
GO

DROP TRIGGER IF EXISTS trgReviewCategoryInsertValidCategoryForType
GO
CREATE TRIGGER trgReviewCategoryInsertValidCategoryForType
ON Review_Category
AFTER INSERT, UPDATE
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @PRID ID = (SELECT product_id FROM inserted);
	DECLARE @category CATEGORY = (SELECT category_name FROM inserted AS i);

	IF((SELECT product_type FROM Product WHERE product_id = @PRID) = 'Movie')
	BEGIN
		IF ((SELECT COUNT(*) FROM Category WHERE category_name = @category AND product_type = 'Movie') = 0)
		BEGIN
			RAISERROR('Review categorie kan niet voor dit type product worden gebruikt.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		;END
	;END

	IF((SELECT product_type FROM Product WHERE product_id = @PRID) = 'Game')
	BEGIN
		IF ((SELECT COUNT(*) FROM Category WHERE category_name = @category AND product_type = 'Game') = 0)
		BEGIN
			RAISERROR('Review categorie kan niet voor dit type product worden gebruikt.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		;END
	;END
	
;END
GO

/*

	Testscenario's:

	|X| Insert review (movie) met één juiste category
	|X| Insert review (movie) met één onjuiste category
	|X| Insert review (movie) met twee juiste categories
	|X| Insert review (game) met één juiste category
	|X| Insert review (game) met één onjuiste category
	|X| Insert review (game) met twee juiste categories

*/

-- Insert review (movie) met één juiste category
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product WHERE product_type = 'Movie')

INSERT INTO Review_Category
VALUES (@PRID, 'testdata@han.nl', 'Acting', 9)

SELECT * FROM Review_Category WHERE product_id = @PRID

ROLLBACK TRANSACTION
GO


-- Insert review (movie) met één onjuiste category
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product WHERE product_type = 'Movie')

PRINT 'Hier verwachten we een foutmelding'
INSERT INTO Review_Category
VALUES (@PRID, 'testdata@han.nl', 'Gameplay', 6)

ROLLBACK TRANSACTION
GO


-- Insert review (movie) met twee juiste categories
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product WHERE product_type = 'Movie')

INSERT INTO Review_Category
VALUES (@PRID, 'testdata@han.nl', 'Acting', 9)

INSERT INTO Review_Category
VALUES (@PRID, 'testdata@han.nl', 'Plot', 5)

SELECT * FROM Review_Category WHERE product_id = @PRID

ROLLBACK TRANSACTION
GO


-- Insert review (game) met één juiste category
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product WHERE product_type = 'Game')

INSERT INTO Review_Category
VALUES (@PRID, 'testdata@han.nl', 'Gameplay', 9)

SELECT * FROM Review_Category WHERE product_id = @PRID

ROLLBACK TRANSACTION
GO


-- Insert review (game) met één onjuiste category
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product WHERE product_type = 'Game')

PRINT 'Hier verwachten we een foutmelding'
INSERT INTO Review_Category
VALUES (@PRID, 'testdata@han.nl', 'Plot', 6)

ROLLBACK TRANSACTION
GO


-- Insert review (game) met twee juiste categories
BEGIN TRANSACTION

DECLARE @PRID ID = (SELECT MAX(product_id) FROM Product WHERE product_type = 'Game')

INSERT INTO Review_Category
VALUES (@PRID, 'testdata@han.nl', 'Gameplay', 9)

INSERT INTO Review_Category
VALUES (@PRID, 'testdata@han.nl', 'Challenge', 5)

SELECT * FROM Review_Category WHERE product_id = @PRID

ROLLBACK TRANSACTION
GO