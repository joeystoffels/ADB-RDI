-- Constraint #5, Stored Procedure uitwerking
-- Voor een geldige film recensie zijn cijfers voor Plot en Acting verplicht
-- en dient minimaal een van de rubrieken Cinematography en Music and Sound te 
-- worden beoordeeld. Als hieraan is voldaan, dan wordt de recensie geaccepteerd 
-- en wordt het totaalcijfer berekend. 

-- Drop constraint on Review if exists
ALTER TABLE [dbo].[Review] DROP CONSTRAINT IF EXISTS [CK_category_filled_check]
GO

-- Drop trigger on Review if exists
DROP TRIGGER IF EXISTS TR_Review_AI_AU
GO

DROP PROCEDURE IF EXISTS USP_Review_Insert
GO
CREATE PROCEDURE USP_Review_Insert (
	@ProductID INT,
	@EmailAddress VARCHAR(255),
	@ReviewDate DATE,
	@Description VARCHAR(255),
	@AverageScore INT
)
AS
	SET NOCOUNT, XACT_ABORT ON

	--SET TRANSACTION ISOLATION LEVEL ...
	BEGIN TRANSACTION;

	BEGIN TRY

		IF NOT EXISTS (
			SELECT * 
			FROM Review_Category RC
			WHERE RC.product_id = @ProductID
			AND RC.email_address = @EmailAddress)

		THROW 50001, 'No matching scores found for any category.', 1;

		IF NOT EXISTS (
			SELECT * 
			FROM Review_Category RC
			WHERE RC.product_id = @ProductID
			AND RC.email_address = @EmailAddress
			AND RC.category_name = 'Acting' 
			AND RC.score IS NOT NULL)

		THROW 50002, 'Score for category Acting is missing', 1;

		IF NOT EXISTS (
			SELECT * 
			FROM Review_Category RC
			WHERE RC.product_id = @ProductID
			AND RC.email_address = @EmailAddress
			AND RC.category_name = 'Plot' 
			AND RC.score IS NOT NULL)

		THROW 50003, 'Score for category Plot is missing', 1;

		IF NOT EXISTS (
			SELECT * 
			FROM Review_Category RC
			WHERE RC.product_id = @ProductID
			AND RC.email_address = @EmailAddress
			AND RC.category_name = 'Cinematography' 
			OR RC.category_name = 'Music and Sound' 
			AND RC.score IS NOT NULL)

		THROW 50004, 'Score for category Cinematography or Music and Sound is missing', 1;
		INSERT INTO Review
		VALUES (@ProductId, @EmailAddress,
				@ReviewDate, @Description,
				@AverageScore)

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
		THROW;
	END CATCH
GO


-- SP insert tests
/*
	@ProductID INT,
	@EmailAddress VARCHAR(255),
	@ReviewDate DATE,
	@Description VARCHAR(255),
	@AverageScore INT
*/

-- No scores given for any category, should throw error code 50001
DECLARE @DATE DATE = GETDATE();
EXEC USP_Review_Insert 345635, 'joey.stoffels@gmail.com', @DATE, 'description', 8;

-- Add a score for categoy Acting
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Acting', 8);

-- No score given for Plot, should throw error code 50003
-- DECLARE @DATE DATE = GETDATE();
EXEC USP_Review_Insert 345635, 'joey.stoffels@gmail.com', @DATE, 'description', 8;

-- Remove score for Acting
DELETE FROM Review_Category
WHERE product_id = 345635 AND category_name = 'Acting' AND email_address = 'joey.stoffels@gmail.com'

-- Add a score for categoy Plot
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Plot', 8);

-- No score given for Acting, should throw error code 50002
-- DECLARE @DATE DATE = GETDATE();
EXEC USP_Review_Insert 345635, 'joey.stoffels@gmail.com', @DATE, 'description', 8;

-- Now add a score for categoy Acting
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Acting', 8);

-- No score given for Music and Sound, should throw error code 50004
-- DECLARE @DATE DATE = GETDATE();
EXEC USP_Review_Insert 345635, 'joey.stoffels@gmail.com', @DATE, 'description', 8;

-- Now add a score for categoy Cinematography
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Cinematography', 8);

-- Cinematography now present, should succeed.
-- DECLARE @DATE DATE = GETDATE();
EXEC USP_Review_Insert 345635, 'joey.stoffels@gmail.com', @DATE, 'description', 8;

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
-- DECLARE @DATE DATE = GETDATE();
EXEC USP_Review_Insert 345635, 'joey.stoffels@gmail.com', @DATE, 'description', 8;

-- Cleanup actions
DELETE FROM Review_Category
WHERE product_id = 345635 AND email_address = 'joey.stoffels@gmail.com'

DELETE FROM Review
WHERE product_id = 345635 AND email_address = 'joey.stoffels@gmail.com';
