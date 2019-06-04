-- Constraint #5, Trigger uitwerking
-- Voor een geldige film recensie zijn cijfers voor Plot en Acting verplicht
-- en dient minimaal een van de rubrieken Cinematography en Music and Sound te
-- worden beoordeeld. Als hieraan is voldaan, dan wordt de recensie geaccepteerd
-- en wordt het totaalcijfer berekend.

-- Drop existing constraint on Review

ALTER TABLE [dbo].[Review] DROP CONSTRAINT IF EXISTS [CK_category_filled_check]
GO

DROP TRIGGER IF EXISTS TR_TEST_AI_AU
GO
CREATE TRIGGER TR_TEST_AI_AU ON Review
AFTER INSERT, UPDATE
AS
BEGIN

	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT * FROM Inserted) RETURN;

	BEGIN TRY

		IF NOT EXISTS (
			SELECT *
			FROM Review_Category RC
			INNER JOIN Inserted I ON RC.product_id = I.product_id
			AND RC.email_address = I.email_address)

		THROW 50001, 'No matching scores found for any category.', 1;

		IF NOT EXISTS (
			SELECT *
			FROM Review_Category RC
			INNER JOIN Inserted I ON RC.product_id = I.product_id
			AND RC.email_address = I.email_address
			WHERE RC.category_name = 'Acting'
			AND RC.score IS NOT NULL)

		THROW 50002, 'Score for category Acting is missing', 1;

		IF NOT EXISTS (
			SELECT *
			FROM Review_Category RC
			INNER JOIN Inserted I ON RC.product_id = I.product_id
			AND RC.email_address = I.email_address
			WHERE RC.category_name = 'Plot'
			AND RC.score IS NOT NULL)

		THROW 50003, 'Score for category Plot is missing', 1;

		IF NOT EXISTS (
			SELECT *
			FROM Review_Category RC
			INNER JOIN Inserted I ON RC.product_id = I.product_id
			AND RC.email_address = I.email_address
			WHERE RC.category_name = 'Cinematography'
			OR RC.category_name = 'Music and Sound'
			AND RC.score IS NOT NULL)

		THROW 50004, 'Score for category Cinematography or Music and Sound is missing', 1;

	END TRY
	BEGIN CATCH
		PRINT 'In catch block of TR_TEST_AI_AU';
		THROW;
	END CATCH
END;



-- Trigger tests
-- Info: Execute the following statements one by one in sequence to check the SP.

-- No scores given for any category, should throw error code 50001
INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'bla', 5);

-- Add a score for categoy Acting
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Acting', 8);

-- No score given for Plot, should throw error code 50003
INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'bla', 5);

-- Remove score for Acting
DELETE FROM Review_Category
WHERE product_id = 345635 AND category_name = 'Acting' AND email_address = 'joey.stoffels@gmail.com'

-- Add a score for categoy Plot
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Plot', 8);

-- No score given for Acting, should throw error code 50002
INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'bla', 5);

-- Now add a score for categoy Acting
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Acting', 8);

-- No score given for Music and Sound, should throw error code 50004
INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'bla', 5);

-- Now add a score for categoy Cinematography
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Cinematography', 8);

-- Cinematography now present, should succeed.
INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'bla', 5);

-- Remove added review
DELETE FROM Review
WHERE product_id = 345635 AND email_address = 'joey.stoffels@gmail.com';

-- Remove score for Cinematography
DELETE FROM Review_Category
WHERE product_id = 345635 AND category_name = 'Cinematography'

-- Add a score for categoy Music and Sound
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Music and Sound', 8);

-- Music and Sound now present, should succeed.
INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'bla', 5);

-- Cleanup actions
DELETE FROM Review_Category
WHERE product_id = 345635 AND email_address = 'joey.stoffels@gmail.com'

DELETE FROM Review
WHERE product_id = 345635 AND email_address = 'joey.stoffels@gmail.com';


