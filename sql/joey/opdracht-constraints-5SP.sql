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
			AND RC.email_address = @EmailAddress
			AND RC.category_name = 'Acting'
			AND RC.score IS NOT NULL)

		THROW 55001, 'Score for category Acting is missing', 1;

		IF NOT EXISTS (
			SELECT *
			FROM Review_Category RC
			WHERE RC.product_id = @ProductID
			AND RC.email_address = @EmailAddress
			AND RC.category_name = 'Plot'
			AND RC.score IS NOT NULL)

		THROW 55002, 'Score for category Plot is missing', 1;

		IF NOT EXISTS (
			SELECT *
			FROM Review_Category RC
			WHERE RC.product_id = @ProductID
			AND RC.email_address = @EmailAddress
			AND RC.category_name = 'Cinematography'
			OR RC.category_name = 'Music and Sound'
			AND RC.score IS NOT NULL)

		THROW 55003, 'Score for category Cinematography or Music and Sound is missing', 1;
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


----------------------------------------------------------
-- Testscenario's
----------------------------------------------------------
-- Scenario 01
-- No score given for acting
-- Result: Throw error 50001
BEGIN TRANSACTION
DECLARE @DATE DATETIME = GETDATE();
EXEC USP_Review_Insert 345635, 'joey.stoffels@gmail.com', @DATE, 'description', 8;
ROLLBACK TRANSACTION;


-- Scenario 02
-- No score given for Plot
-- Result: Throws error 50002
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Acting', 8);

DECLARE @DATE DATETIME = GETDATE();
EXEC USP_Review_Insert 345635, 'joey.stoffels@gmail.com', @DATE, 'description', 8;
ROLLBACK TRANSACTION;


-- Scenario 03
-- No score given for Acting
-- Result: Throws error 50001
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Plot', 8);

DECLARE @DATE DATETIME = GETDATE();
EXEC USP_Review_Insert 345635, 'joey.stoffels@gmail.com', @DATE, 'description', 8;
ROLLBACK TRANSACTION;


-- Scenario 04
-- No score given for Music and Sound or Cinematography
-- Result: Throws error 50003
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8);

DECLARE @DATE DATETIME = GETDATE();
EXEC USP_Review_Insert 345635, 'joey.stoffels@gmail.com', @DATE, 'description', 8;
ROLLBACK TRANSACTION;


-- Scenario 05
-- All required scores available with Cinematography
-- Result: Success
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Cinematography', 8);

DECLARE @DATE DATETIME = GETDATE();
EXEC USP_Review_Insert 345635, 'joey.stoffels@gmail.com', @DATE, 'description', 8;
ROLLBACK TRANSACTION;


-- Scenario 06
-- All required scores available with Music and Sound
-- Result: Success
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Music and Sound', 8);

DECLARE @DATE DATETIME = GETDATE();
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
			AND RC.email_address = @EmailAddress
			AND RC.category_name = 'Acting'
			AND RC.score IS NOT NULL)

		THROW 55001, 'Score for category Acting is missing', 1;

		IF NOT EXISTS (
			SELECT *
			FROM Review_Category RC
			WHERE RC.product_id = @ProductID
			AND RC.email_address = @EmailAddress
			AND RC.category_name = 'Plot'
			AND RC.score IS NOT NULL)

		THROW 55002, 'Score for category Plot is missing', 1;

		IF NOT EXISTS (
			SELECT *
			FROM Review_Category RC
			WHERE RC.product_id = @ProductID
			AND RC.email_address = @EmailAddress
			AND RC.category_name = 'Cinematography'
			OR RC.category_name = 'Music and Sound'
			AND RC.score IS NOT NULL)

		THROW 55003, 'Score for category Cinematography or Music and Sound is missing', 1;

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

GO

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------

-- Scenario 07
-- No score given for Music and Sound or cinematography
-- Result: Throws error 50003
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Cinematography', 8);

INSERT INTO Product
VALUES	(9999998, 'Movie', null, 'testproduct', null, null, 2.00, 1998, null, null, null)

INSERT INTO Review_Category
VALUES	(9999998, 'joey.stoffels@gmail.com', 'Plot', 8),
		(9999998, 'joey.stoffels@gmail.com', 'Acting', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8);

EXEC USP_Review_Update_ProductId 345635, 9999998, 'joey.stoffels@gmail.com';
ROLLBACK TRANSACTION;

-- Scenario 08
-- All required scores available with Cinematography
-- Result: Success
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Cinematography', 8);

INSERT INTO Product
VALUES	(9999998, 'Movie', null, 'testproduct', null, null, 2.00, 1998, null, null, null)

INSERT INTO Review_Category
VALUES	(9999998, 'joey.stoffels@gmail.com', 'Plot', 8),
		(9999998, 'joey.stoffels@gmail.com', 'Acting', 8),
		(9999998, 'joey.stoffels@gmail.com', 'Cinematography', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8);

EXEC USP_Review_Update_ProductId 345635, 9999998, 'joey.stoffels@gmail.com';
ROLLBACK TRANSACTION;