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

	-- Should not process when no previous_product_id exists.
	IF NOT EXISTS (SELECT * FROM inserted WHERE previous_product_id IS NOT NULL) RETURN;

	BEGIN TRY
		PRINT 'In try block of TR_Products_AI_AU';

		IF EXISTS (
			SELECT * 
			FROM inserted
			WHERE product_type != 'Movie')

		THROW 52001, 'Batch insert contains non-Movie type(s)!', 1;

		IF EXISTS (
			SELECT *
			FROM Product P
			INNER JOIN inserted I ON P.product_id = I.previous_product_id
			WHERE P.product_type != 'Movie')

		THROW 52002, 'Previous part is not of type Movie', 1;

		IF EXISTS (
			SELECT *
			FROM Product P
			INNER JOIN inserted I ON P.product_id = I.previous_product_id
			WHERE P.publication_year >= I.publication_year)

		THROW 52003, 'Publication_year of previous part is after the inserted/updated product publication year!', 1;

	END TRY
	BEGIN CATCH
		PRINT 'In catch block of TR_Products_AI_AU';
		THROW;
	END CATCH
END;


-- Trigger tests
-- Info: Product_id 345635 has publication_year 1999.
-- Assumption: Months and days are not stored, making us unable to determine if the previous_part was released
-- before or after the current product, thus we assume that the same publication_year violates the trigger rules.

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [01] Movie toevoegen met publication_year voor het publication_year van zijn previous_part
-- [02] Movie toevoegen met publication_year na het publication_year van zijn previous_part
-- [03] Product_id updaten met product_id waarbij publication_year voor het publication_year van zijn previous_part ligt
-- [04] Product_id updaten met product_id waarbij publication_year na het publication_year van zijn previous_part ligt
-- [05] Movie toevoegen met hetzelfde publication_year als het publication_year van zijn previous_part
-- [06] Product_id updaten met product_id waarbij publication_year hetzelfde is als het publication_year van zijn previous_part
-- [07] Twee movies toevoegen, eerste heeft zelfde publication_year als previous_part
-- [08] Twee movies toevoegen, tweede heeft publication_year na het publication_year van zijn previous_part
-- [09] Twee movies toevoegen, beide met publication_year na het publication_year van zijn previous_part
-- [10] Movie toevoegen met previous_part als product_type 'Game'
-- [11] Game toevoegen
-- [12] Movie toevoegen met geen previous_part
-- [13] Movie en game toevoegen
-- [14] Twee movies toevoegen, tweede heeft geen previous_part
-- [15] Movie en game toevoegen, game bevat geen previous_part
-- [16] Movie en game toevoegen, beide zonder previous part


-- Scenario 01
-- Should fail because its publication year is before 1999
-- Result: Throw error 52003
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


-- Scenario 15
-- Should fail because insert contains a non-movie type
-- Result: Throw error 50001
BEGIN TRANSACTION;
INSERT INTO Product
VALUES	(9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 2000, null, null, null),
		(9999998, 'Game', null, 'Star Wars Latest', null, null, 2.00, 2010, null, null, null)
ROLLBACK TRANSACTION;


-- Scenario 16
-- Should succeed because both entries have no previous_type
-- Result: Success
BEGIN TRANSACTION;
INSERT INTO Product
VALUES	(9999999, 'Movie', null, 'Star Wars Latest', null, null, 2.00, 2000, null, null, null),
		(9999998, 'Game', null, 'Star Wars Latest', null, null, 2.00, 2010, null, null, null)
ROLLBACK TRANSACTION;