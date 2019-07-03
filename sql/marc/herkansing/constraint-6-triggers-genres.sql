--  --------------------------------------------------------
--  Constraint 6 - Triggers 
--  --------------------------------------------------------
-- Genres voor films en spellen zijn verschillend, deze mogen niet bij het verkeerde media-item gebruikt worden. 
-- Hetzelfde geld voor Review aspecten.
USE odisee
go

IF EXISTS (SELECT * 
	FROM sys.objects WHERE [name] = 'FK_PRODUCT__PRODUCT_G_PRODUCT' 
		AND [type] = 'F')
BEGIN
	ALTER TABLE Product_Genre
	DROP CONSTRAINT FK_PRODUCT__PRODUCT_G_PRODUCT
END;

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'product_type'
          AND Object_ID = Object_ID(N'dbo.Genre'))
BEGIN
	ALTER TABLE Genre
	ADD product_type TYPE
END;

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
--  Trigger
--  --------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'ProductGenre_AI_AU' AND [type] = 'TR')
BEGIN
	DROP TRIGGER [dbo].ProductGenre_AI_AU;
END;
go

CREATE TRIGGER ProductGenre_AI_AU
ON Product_Genre
AFTER INSERT, UPDATE
AS
BEGIN
	
	SET NOCOUNT ON;

	IF EXISTS (SELECT genre_name 
		FROM inserted AS i
			JOIN Product AS p 
				ON i.product_id = p.product_id
		WHERE i.genre_name NOT IN (SELECT genre_name 
								   FROM Genre 
									WHERE product_type = p.product_type)
	)

	THROW 50001, 'No valid genre for this type of product.', 1;

;END
go

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [01] Eén ongeldige genre toevoegen niet behorende bij product type Movie
-- [02] Twee ongeldige genres toevoegen niet behorende bij product type Movie
-- [03] Eén ongeldige genre toevoegen niet behorende bij product type Game
-- [04] Twee ongeldige genres toevoegen niet behorende bij product type Game
-- [05] Eén ongeldige genre toevoegen aan Game en één ongeldige genre toevoegen aan Movie
-- [06] Twee ongeldige genres toevoegen aan Game en twee ongeldige genres toevoegen aan Movie
-- [07] Eén geldige genre toevoegen aan Movie
-- [08] Twee geldige genres toevoegen aan Movie
-- [09] Eén geldige genre toevoegen aan Game
-- [10] Twee geldige genres toevoegen aan Game
-- [11] Eén geldige genre toevoegen aan Movie en één geldige genre toevoegen aan Game
-- [12] Twee geldige genres toevoegen aan Movie en twee geldige genres toevoegen aan Game
-- [13] Genre van Movie updaten naar genre van Game
-- [14] Genre van Game updaten naar genre van Movie
-- [15] Genre van Movie updaten naar genre van Movie
-- [16] Genre van Game updaten naar genre van Game

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 01] : Eén ongeldige genre toevoegen niet behorende bij product type Movie
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES (2, 'MMO')

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 02] : Twee ongeldige genres toevoegen niet behorende bij product type Movie
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES (2, 'MMO'), (2, 'Action-Adventure')

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 03] : Eén ongeldige genre toevoegen niet behorende bij product type Game
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES (412363, 'Horror')

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 04] : Twee ongeldige genres toevoegen niet behorende bij product type Game
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES (412363, 'Horror'), (412363, 'Comedy')

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 05] : Eén ongeldige ongeldige genre toevoegen aan Game en één ongeldige genre toevoegen aan Movie
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES (412363, 'Comedy'), (2, 'MMO')

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 06] : Twee ongeldige genres toevoegen aan Game en twee ongeldige genres toevoegen aan Movie
-- Result: Throw Error

BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES (412363, 'Comedy'), (412363, 'Horror'), (2, 'MMO'), (2, 'Fantasy')

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 07] : Eén geldige genre toevoegen aan Movie
-- Result: Success
BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES (2, 'Fantasy')

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 08] : Twee geldige genres toevoegen aan Movie
-- Result: Success
BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES (2, 'Fantasy'), (2, 'Horror')

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 09] : Eén geldige genre toevoegen aan Game
-- Result: Success
BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES (412363, 'MMO')

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 10] : Twee geldige genres toevoegen aan Game
-- Result: Success
BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES (412363, 'MMO'), (412363, 'Role-playing')

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 11] : Eén geldige genre toevoegen aan Movie en één geldige genre toevoegen aan Game
-- Result: Success
BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES (412363, 'Role-playing'), (2, 'Horror')

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 12] : Twee geldige genres toevoegen aan Movie en twee geldige genres toevoegen aan Game
-- Result: Success
BEGIN TRANSACTION;

INSERT INTO Product_Genre
VALUES (412363, 'Role-playing'), (412363, 'MMO'), (2, 'Horror'), (2, 'Action')

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 13] : Genre van Movie updaten naar genre van Game
-- Result: Throw Error
BEGIN TRANSACTION;

UPDATE Product_Genre
SET genre_name = 'MMO' 
WHERE product_id = 2 
	AND genre_name = 'Comedy'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 14] : Genre van Game updaten naar genre van Movie
-- Result: Throw Error
BEGIN TRANSACTION;

-- Testdata aanmaken
INSERT INTO Product_Genre
VALUES (412363, 'Role-playing')

UPDATE Product_Genre
SET genre_name = 'Horror' 
WHERE product_id = 412363

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 15] : Genre van Movie updaten naar genre van Movie
-- Result: Success
BEGIN TRANSACTION;

UPDATE Product_Genre
SET genre_name = 'Horror' 
WHERE product_id = 2 
	AND genre_name = 'Comedy'

ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 16] : Genre van Game updaten naar genre van Game
-- Result: Success
BEGIN TRANSACTION;

-- Testdata aanmaken
INSERT INTO Product_Genre
VALUES (412363, 'Role-playing')

UPDATE Product_Genre
SET genre_name = 'MMO' 
WHERE product_id = 412363

ROLLBACK TRANSACTION;
