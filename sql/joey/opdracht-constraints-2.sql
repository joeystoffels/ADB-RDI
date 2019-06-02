-- Constraint #2
-- Bij een film met previous part, is de film later uitgebracht dan het previous part.

DROP TRIGGER IF EXISTS TR_Products_AI_AU
GO
CREATE TRIGGER TR_Products_AI_AU ON Product
AFTER INSERT, UPDATE
AS
BEGIN

	SET NOCOUNT ON;
	IF NOT EXISTS (SELECT product_type FROM inserted WHERE product_type = 'Movie' AND previous_product_id IS NOT NULL) RETURN;

	BEGIN TRY

		IF EXISTS (
			SELECT *
			FROM Product P
			INNER JOIN inserted I ON P.product_id = I.previous_product_id
			WHERE P.publication_year <= I.publication_year)

		THROW 50001, 'publication_year of previous_product_id is after the inserted/updated products publication_year!', 1;
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


-- Should fail because its publication_year is before 1999.
INSERT INTO Product
VALUES	(9999998, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 2000, null, null, null)

-- Should succeed because its publication_year is after 1999.
INSERT INTO Product
VALUES	(9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1998, null, null, null)

-- Rollback
DELETE FROM PRODUCT WHERE product_id = 9999999



-- Should fail because its publication_year is before 1999 (2002).
UPDATE Product
SET previous_product_id = 345635 WHERE product_id = 313503

-- Should succeed because its publication_year is after 1999 (1996).
UPDATE Product
SET previous_product_id = 345635 WHERE product_id = 313508

-- Rollback
UPDATE Product
SET previous_product_id = null WHERE product_id = 313508



-- Should fail because it has the same publication_year.
INSERT INTO Product
VALUES (9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null)

-- Should fail because it has the same publication_year.
UPDATE Product
SET previous_product_id = 345635 WHERE product_id = 313799



-- Should fail because the first entry is violating the trigger rules.
INSERT INTO Product
VALUES	(9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1989, null, null, null),
		(9999998, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null)

-- Should fail because the second entry is violating the trigger rules.
INSERT INTO Product
VALUES	(9999998, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null),
		(9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1989, null, null, null)

-- Should succeed because both entries have a publication_year before 1999.
INSERT INTO Product
VALUES	(9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1989, null, null, null),
		(9999998, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1988, null, null, null)

-- Rollback
DELETE FROM PRODUCT WHERE product_id = 9999999
DELETE FROM PRODUCT WHERE product_id = 9999998