USE odisee;
GO

DROP TRIGGER IF EXISTS TR_Products_AI_AU
GO

--  --------------------------------------------------------
--  Trigger
--  --------------------------------------------------------
CREATE TRIGGER TR_Products_AI_AU ON Product
AFTER INSERT, UPDATE
AS
BEGIN

	SET NOCOUNT ON;
	
	-- Trigger should not process if insert table is empty.
	IF NOT EXISTS (SELECT * FROM inserted) RETURN;

	-- Should not process if there are no Movie types inserted.
	IF NOT EXISTS (SELECT * FROM inserted WHERE product_type = 'Movie') RETURN;

	-- Should not process when a previous_product_id exists.
	IF NOT EXISTS (SELECT * FROM inserted WHERE previous_product_id IS NOT NULL) RETURN;

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	BEGIN TRANSACTION;

	BEGIN TRY
		PRINT 'In try block of TR_Products_AI_AU';

		IF EXISTS (
			SELECT * 
			FROM inserted
			WHERE product_type != 'Movie')

		THROW 50001, 'Batch insert contains non-Movie type(s)!', 1;

		IF EXISTS (
			SELECT *
			FROM Product P
			INNER JOIN inserted I ON P.product_id = I.previous_product_id
			WHERE P.product_type != 'Movie')

		THROW 50002, 'Previous part is not of type Movie', 1;

		IF EXISTS (
			SELECT *
			FROM Product P
			INNER JOIN inserted I ON P.product_id = I.previous_product_id
			WHERE P.publication_year >= I.publication_year)

		THROW 50003, 'Publication_year of previous part is after the inserted/updated product publication year!', 1;

	END TRY
	BEGIN CATCH
		PRINT 'In catch block of TR_Products_AI_AU';
		THROW;
	END CATCH

	COMMIT TRANSACTION;
END;


-- Trigger tests
-- Info: Product_id 345635 has publication_year 1999.
-- Assumption: Months and days are not stored, making us unable to determine if the previous_part was released
-- before or after the current product, thus we assume that the same publication_year violates the trigger rules.

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 01
-- Should fail because its publication year is before 1999
-- Result: Throw error 50003
BEGIN TRANSACTION;
INSERT INTO Product
VALUES	(9999998, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1998, null, null, null)
ROLLBACK TRANSACTION;


-- Scenario 02
-- Should succeed because its publication year is after 1999
-- Result: Success
BEGIN TRANSACTION;
INSERT INTO Product
VALUES	(9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 2000, null, null, null)
ROLLBACK TRANSACTION;


-- Scenario 03
-- Should fail because its publication year is before 1999 (2002)
-- Result: Throw error 50003
BEGIN TRANSACTION;
UPDATE Product
SET previous_product_id = 313503 WHERE product_id = 345635
ROLLBACK TRANSACTION;


-- Scenario 04
-- Should succeed because its publication year is after 1999 (1996)
-- Result: Success
BEGIN TRANSACTION;
UPDATE Product
SET previous_product_id = 313508  WHERE product_id = 345635
ROLLBACK TRANSACTION;


-- Scenario 05
-- Should fail because it has the same publication year
-- Result: Throw error 50003
BEGIN TRANSACTION;
INSERT INTO Product
VALUES (9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null)
ROLLBACK TRANSACTION;


-- Scenario 06
-- Should fail because it has the same publication year
-- Result: Throw error 50003
BEGIN TRANSACTION;
UPDATE Product
SET previous_product_id = 313799 WHERE product_id = 345635
ROLLBACK TRANSACTION;


-- Scenario 07
-- Should fail because the first entry is violating the trigger rules
-- Result: Throw error 50003
BEGIN TRANSACTION;
INSERT INTO Product
VALUES	(9999998, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null),
		(9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1989, null, null, null)
ROLLBACK TRANSACTION;


-- Scenario 08
-- Should fail because the second entry is violating the trigger rules
-- Result: Throw error 50003
BEGIN TRANSACTION;
INSERT INTO Product
VALUES	(9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1988, null, null, null),
		(9999998, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 2000, null, null, null)
ROLLBACK TRANSACTION;


-- Scenario 09
-- Should succeed because both entries have a publication_year before 1999
-- Result: Success
BEGIN TRANSACTION;
INSERT INTO Product
VALUES	(9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 2000, null, null, null),
		(9999998, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 2010, null, null, null)
ROLLBACK TRANSACTION;


-- Scenario 10
-- Should fail because previous part is of type 'Game'
-- Result: Throw error 50002
BEGIN TRANSACTION;
INSERT INTO Product
VALUES (9999999, 'Movie', 412331, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null)
ROLLBACK TRANSACTION;


-- Scenario 11
-- Should bypass trigger and succeed because product type is not 'Movie'
-- Result: Success
BEGIN TRANSACTION;
INSERT INTO Product
VALUES (9999998, 'Game', 345635, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null)
ROLLBACK TRANSACTION;


-- Scenario 12
-- Should bypass trigger and succeed because previous part is null
-- Result: Success
BEGIN TRANSACTION;
INSERT INTO Product
VALUES (9999999, 'Movie', null, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null)
ROLLBACK TRANSACTION;


-- Scenario 13
-- Should fail because insert contains a non-movie type
-- Result: Throw error 50001
BEGIN TRANSACTION;
INSERT INTO Product
VALUES	(9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 2000, null, null, null),
		(9999998, 'Game', 345635, 'Star Wars Latest', null, null, 2.00, 2010, null, null, null)
ROLLBACK TRANSACTION;


-- Scenario 14
-- Should succeed despite the null at previous_product_id
-- Result: Success
BEGIN TRANSACTION;
INSERT INTO Product
VALUES	(9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 2000, null, null, null),
		(9999998, 'Movie', null, 'Star Wars Latest', null, null, 2.00, 2010, null, null, null)
ROLLBACK TRANSACTION;


-- Scenario 13
-- Should fail because insert contains a non-movie type
-- Result: Throw error 50001
BEGIN TRANSACTION;
INSERT INTO Product
VALUES	(9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 2000, null, null, null),
		(9999998, 'Game', null, 'Star Wars Latest', null, null, 2.00, 2010, null, null, null)
ROLLBACK TRANSACTION;