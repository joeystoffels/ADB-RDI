--  --------------------------------------------------------
--  Constraint 6 - Triggers 
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
--  Trigger
--  --------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'ReviewCategory_AI_AU' AND [type] = 'TR')
BEGIN
	DROP TRIGGER [dbo].ReviewCategory_AI_AU;
END;
go

CREATE TRIGGER ReviewCategory_AI_AU
ON Review_Category
AFTER INSERT, UPDATE
AS
BEGIN
	
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT * FROM inserted) RETURN;

	BEGIN TRY

		IF EXISTS (SELECT category_name
			FROM inserted AS i
				JOIN Product AS p 
					ON i.product_id = p.product_id
			WHERE i.category_name NOT IN (SELECT category_name 
										  FROM Category 
										  WHERE product_type = p.product_type)
		)

		THROW 56001, 'No valid category for this type of product.', 1;

	END TRY			 
	BEGIN CATCH
		THROW;
	END CATCH

;END
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [01] Eén ongeldige review category toevoegen niet behorende bij product type Movie
-- [02] Twee ongeldige review categories toevoegen niet behorende bij product type Movie
-- [03] Eén ongeldige review category toevoegen niet behorende bij product type Game
-- [04] Twee ongeldige review categories toevoegen niet behorende bij product type Game
-- [05] Eén ongeldige review category toevoegen aan Game en één ongeldige review category toevoegen aan Movie
-- [06] Twee ongeldige review categories toevoegen aan Game en twee ongeldige review categories toevoegen aan Movie
-- [07] Eén geldige review category toevoegen aan Movie
-- [08] Twee geldige review categories toevoegen aan Movie
-- [09] Eén geldige review category toevoegen aan Game
-- [10] Twee geldige review categories toevoegen aan Game
-- [11] Eén geldige review category toevoegen aan Movie en één geldige review category toevoegen aan Game
-- [12] Twee geldige review categories toevoegen aan Movie en twee geldige review categories toevoegen aan Game
-- [13] Review category van Movie updaten naar review category van Game
-- [14] Review category van Game updaten naar review category van Movie
-- [15] Review category van Movie updaten naar review category van Movie
-- [16] Review category van Game updaten naar review category van Game

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 01] : Eén ongeldige review category toevoegen niet behorende bij product type Movie
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Review_Category
VALUES (2, 'info@info.nl', 'Gameplay', 8)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 02] : Twee ongeldige review categories toevoegen niet behorende bij product type Movie
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Review_Category
VALUES (2, 'info@info.nl', 'Gameplay', 8), (2, 'info@info.nl', 'Challenge', 8)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 03] : Eén ongeldige review category toevoegen niet behorende bij product type Game
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Review_Category
VALUES (412363, 'info@info.nl', 'Acting ', 8)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 04] : Twee ongeldige review categories toevoegen niet behorende bij product type Game
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Review_Category
VALUES (412363, 'info@info.nl', 'Acting ', 8), (412363, 'info@info.nl', 'Plot', 8)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 05] : Eén ongeldige review category toevoegen aan Game en één ongeldige review category toevoegen aan Movie
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Review_Category
VALUES (412363, 'info@info.nl', 'Acting ', 8), (2, 'info@info.nl', 'Challenge', 8)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 06] : Twee ongeldige review categories toevoegen aan Game en twee ongeldige review categories toevoegen aan Movie
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Review_Category
VALUES (412363, 'info@info.nl', 'Acting ', 8), (412363, 'info@info.nl', 'Plot ', 8), (2, 'info@info.nl', 'Challenge', 8), (2, 'info@info.nl', 'Gameplay', 8)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 07] : Eén geldige review category toevoegen aan Movie
-- Result: Success

BEGIN TRANSACTION;

INSERT INTO Review_Category
VALUES (2, 'info@info.nl', 'Plot', 8)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 08] : Twee geldige review categories toevoegen aan Movie
-- Result: Success

BEGIN TRANSACTION;

INSERT INTO Review_Category
VALUES (2, 'info@info.nl', 'Plot', 8), (2, 'info@info.nl', 'Cinematography ', 8)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 09] : Eén geldige review category toevoegen aan Game
-- Result: Success

BEGIN TRANSACTION;

INSERT INTO Review_Category
VALUES (412363, 'info@info.nl', 'Graphics and Sound', 8)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 10] : Twee geldige review categories toevoegen aan Game
-- Result: Success

BEGIN TRANSACTION;

INSERT INTO Review_Category
VALUES (412363, 'info@info.nl', 'Graphics and Sound', 8), (412363, 'info@info.nl', 'Gameplay', 8)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 11] : Eén geldige review category toevoegen aan Movie en één geldige review category toevoegen aan Game
-- Result: Success

BEGIN TRANSACTION;

INSERT INTO Review_Category
VALUES (2, 'info@info.nl', 'Cinematography ', 8), (412363, 'info@info.nl', 'Gameplay', 8)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 12] : Twee geldige review categories toevoegen aan Movie en twee geldige review categories toevoegen aan Game
-- Result: Success

BEGIN TRANSACTION;

INSERT INTO Review_Category
VALUES (412363, 'info@info.nl', 'Graphics and Sound', 8), (412363, 'info@info.nl', 'Gameplay', 8), (2, 'info@info.nl', 'Plot', 8), (2, 'info@info.nl', 'Cinematography ', 8)

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 13] : Review category van Movie updaten naar review category van Game
-- Result: Throw Error

BEGIN TRANSACTION;

UPDATE Review_Category
SET category_name = 'Gameplay' 
WHERE product_id = 194492 
	AND category_name = 'Acting'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 14] : Review category van Game updaten naar review category van Movie
-- Result: Throw Error

BEGIN TRANSACTION;

-- Testdata aanmaken
INSERT INTO Review_Category
VALUES (412363, 'info@info.nl', 'Gameplay', 8)

UPDATE Review_Category
SET category_name = 'Acting' 
WHERE product_id = 412363 
	AND category_name = 'Gameplay'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 15] : Review category van Movie updaten naar review category van Movie
-- Result: Success

BEGIN TRANSACTION;

UPDATE Review_Category
SET category_name = 'Music and Sound' 
WHERE product_id = 194492 
	AND category_name = 'Acting'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 16] : Review category van Game updaten naar review category van Game
-- Result: Success

BEGIN TRANSACTION;

-- Testdata aanmaken
INSERT INTO Review_Category
VALUES (412363, 'info@info.nl', 'Gameplay', 8)

UPDATE Review_Category
SET category_name = 'Challenge' 
WHERE product_id = 412363 
	AND category_name = 'Gameplay'

ROLLBACK TRANSACTION;