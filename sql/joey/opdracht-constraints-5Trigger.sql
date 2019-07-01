USE odisee;
GO

-- Drop constraint on Review if exists
ALTER TABLE [dbo].[Review] DROP CONSTRAINT IF EXISTS [CK_category_filled_check]
GO

DROP TRIGGER IF EXISTS TR_Review_AI_AU
GO

----------------------------------------------------------
-- Trigger
----------------------------------------------------------
CREATE TRIGGER TR_Review_AI_AU ON Review
AFTER INSERT, UPDATE
AS
BEGIN

	SET NOCOUNT ON;

	-- Trigger should not process if insert table is empty.
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
		PRINT 'In catch block of TR_Review_AI_AU';
		THROW;
	END CATCH
END;


----------------------------------------------------------
-- Testscenario's
----------------------------------------------------------
-- Scenario 01
-- No scores given for any category
-- Result: Throw error 50001
BEGIN TRANSACTION
INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 5);
ROLLBACK TRANSACTION;


-- Scenario 02
-- No score given for Plot
-- Result: Throws error 50003
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Acting', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 5);
ROLLBACK TRANSACTION


-- Scenario 03
-- No score given for Acting
-- Result: Throws error 50002
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Plot', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 5);
ROLLBACK TRANSACTION


-- Scenario 04
-- No score given for Music and Sound or Cinematography
-- Result: Throws error 50004
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 5);
ROLLBACK TRANSACTION


-- Scenario 05
-- All required scores available with Cinematography
-- Result: Success
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Cinematography', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 5);
ROLLBACK TRANSACTION


-- Scenario 06
-- All required scores available with Music and Sound
-- Result: Success
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Music and Sound', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 5);
ROLLBACK TRANSACTION


-- Scenario 07
-- No score given for Music and Sound or cinematography
-- Result: Throws error 50004
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

UPDATE Review
SET product_id = 9999998
WHERE product_id = 345635 AND email_address = 'joey.stoffels@gmail.com';
ROLLBACK TRANSACTION


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

UPDATE Review
SET product_id = 9999998
WHERE product_id = 345635 AND email_address = 'joey.stoffels@gmail.com';
ROLLBACK TRANSACTION