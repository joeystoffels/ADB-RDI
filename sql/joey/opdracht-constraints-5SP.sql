USE odisee;
GO

-- Drop constraint on Review if exists
ALTER TABLE [dbo].[Review] DROP CONSTRAINT IF EXISTS [CK_category_filled_check]
GO

-- Drop trigger on Review if exists
DROP TRIGGER IF EXISTS TR_Review_AI_AU
DROP PROCEDURE IF EXISTS USP_Review_Insert
DROP PROCEDURE IF EXISTS USP_Review_Update_ProductId
GO

--  --------------------------------------------------------
--  Stored procedure
--  --------------------------------------------------------
CREATE PROCEDURE USP_Review_Insert (
	@ProductID INT,
	@EmailAddress VARCHAR(255),
	@ReviewDate DATE,
	@Description VARCHAR(255),
	@AverageScore INT
)
AS

	SET NOCOUNT, XACT_ABORT ON

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
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

	COMMIT TRANSACTION;
GO


--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 01
-- SP insert tests
-- Info: Execute the following statements one by one in sequence to check the SP.

BEGIN TRANSACTION;
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
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Stored procedure
--  --------------------------------------------------------
CREATE PROCEDURE USP_Review_Update_ProductId (
	@PreviousProductID INT,
	@ProductID INT,
	@EmailAddress VARCHAR(255)
)
AS

	SET NOCOUNT, XACT_ABORT ON

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
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

		UPDATE Review
		SET product_id = @ProductID
		WHERE product_id = @PreviousProductID
		AND email_address = @EmailAddress

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
		THROW;
	END CATCH

	COMMIT TRANSACTION;
GO

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 02
-- SP update test
-- Info: Execute the following statements one by one in sequence to check the trigger.

BEGIN TRANSACTION;
-- Setup testdata
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Plot', 8),
(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
(345635, 'joey.stoffels@gmail.com', 'Cinematography', 8);

INSERT INTO Product
VALUES	(9999998, 'Movie', null, 'testproduct', null, null, 2.00, 1998, null, null, null)

INSERT INTO Review_Category
VALUES (9999998, 'joey.stoffels@gmail.com', 'Plot', 8),
(9999998, 'joey.stoffels@gmail.com', 'Acting', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 5);

-- No score given for Music and Sound or cinematography, should throw error code 50004
EXEC USP_Review_Update_ProductId 345635, 9999998, 'joey.stoffels@gmail.com';

-- Now add a Cinematography score
INSERT INTO Review_Category
VALUES (9999998, 'joey.stoffels@gmail.com', 'Cinematography', 8);

-- Should fail since it cannot find any matching scores with new emailaddress
EXEC USP_Review_Update_ProductId 345635, 9999998, 'joey.stoffels@gmail.com';

-- Check if update succeeded
SELECT * FROM Review WHERE product_id = 9999998;
ROLLBACK TRANSACTION;