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

		IF (
			SELECT COUNT(*)
			FROM Review_Category RC
			INNER JOIN Inserted I ON RC.product_id = I.product_id
			AND RC.email_address = I.email_address
			WHERE RC.category_name = 'Acting'
			AND RC.score IS NOT NULL) < (SELECT COUNT(*) FROM Inserted)

		THROW 55001, 'Score for category Acting is missing', 1;

		IF (
			SELECT COUNT(*)
			FROM Review_Category RC
			INNER JOIN Inserted I ON RC.product_id = I.product_id
			AND RC.email_address = I.email_address
			WHERE RC.category_name = 'Plot'
			AND RC.score IS NOT NULL) < (SELECT COUNT(*) FROM Inserted)

		THROW 55002, 'Score for category Plot is missing', 1;

		IF (
			SELECT COUNT(*)
			FROM Review_Category RC
			INNER JOIN Inserted I ON RC.product_id = I.product_id
			AND RC.email_address = I.email_address
			WHERE RC.category_name = 'Cinematography'
			OR RC.category_name = 'Music and Sound'
			AND RC.score IS NOT NULL) < (SELECT COUNT(*) FROM Inserted)

		THROW 55003, 'Score for category Cinematography or Music and Sound is missing', 1;

	END TRY
	BEGIN CATCH
		PRINT 'In catch block of TR_Review_AI_AU';
		THROW;
	END CATCH
END;


----------------------------------------------------------
-- Testscenario's
----------------------------------------------------------
-- [01] Review toevoegen zonder scores
-- [02] Review toevoegen met score voor acting, zonder score voor plot
-- [03] Review toevoegen met score voor plot, zonder score voor acting
-- [04] Review toevoegen met score voor acting en plot
-- [05] Review toevoegen met score voor acting, plot en cinematography
-- [06] Review toevoegen met score voor acting, plot en music and sound
-- [07] Review updaten met een product_id waar alleen plot en acting scores voor zijn
-- [08] Review updaten met een product_id waar plot, acting en cinematography aanwezig zijn
-- [09] Twee reviews toevoegen waarbij de tweede geen scores heeft
-- [10] Twee reviews toevoegen waarbij de tweede geen plot score heeft
-- [11] Twee reviews toevoegen waarbij de tweede geen cinematography of music and sound score heeft
-- [12] Twee reviews toevoegen waarbij beide reviews de scores beschikbaar heeft
-- [13] Twee reviews toevoegen waarbij de tweede review een ander emailadres is dan van de scores


-- Scenario 01
-- No score given for acting
-- Result: Throw error 55001
BEGIN TRANSACTION
INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8);
ROLLBACK TRANSACTION;


-- Scenario 02
-- No score given for Plot
-- Result: Throws error 55002
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Acting', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8);
ROLLBACK TRANSACTION;


-- Scenario 03
-- No score given for Acting
-- Result: Throws error 55001
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES (345635, 'joey.stoffels@gmail.com', 'Plot', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8);
ROLLBACK TRANSACTION;


-- Scenario 04
-- No score given for Music and Sound or Cinematography
-- Result: Throws error 55003
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8);
ROLLBACK TRANSACTION;


-- Scenario 05
-- All required scores available with Cinematography
-- Result: Success
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Cinematography', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8);
ROLLBACK TRANSACTION;


-- Scenario 06
-- All required scores available with Music and Sound
-- Result: Success
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Music and Sound', 8);

INSERT INTO Review
VALUES (345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8);
ROLLBACK TRANSACTION;


-- Scenario 07
-- No score given for Music and Sound or cinematography
-- Result: Throws error 55003
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

UPDATE Review
SET product_id = 9999998
WHERE product_id = 345635 AND email_address = 'joey.stoffels@gmail.com';
ROLLBACK TRANSACTION;


-- Scenario 09
-- No category scores available for second Review entry
-- Result: Throws error 55001
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Cinematography', 8);

INSERT INTO Review
VALUES	(345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8),
		(345636, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8);
ROLLBACK TRANSACTION


-- Scenario 10
-- Second entry has no Plot score
-- Result: Throws error 55002
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Cinematography', 8),
		(345636, 'joey.stoffels@gmail.com', 'Acting', 8);

INSERT INTO Review
VALUES	(345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8),
		(345636, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8);
ROLLBACK TRANSACTION


-- Scenario 11
-- Second entry has no Cinematorgraphy or Music and Sound score
-- Result: Throws error 55003
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Cinematography', 8),
		(345636, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345636, 'joey.stoffels@gmail.com', 'Plot', 8);

INSERT INTO Review
VALUES	(345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8),
		(345636, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8);
ROLLBACK TRANSACTION


-- Scenario 12
-- Both entries have valid category scores
-- Result: Succeed
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Cinematography', 8),
		(345636, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345636, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345636, 'joey.stoffels@gmail.com', 'Cinematography', 8);

INSERT INTO Review
VALUES	(345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8),
		(345636, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8);
ROLLBACK TRANSACTION


-- Scenario 13
-- Other emailaddress for second entry, no score found for Acting
-- Result: Throws error 55001
BEGIN TRANSACTION
INSERT INTO Review_Category
VALUES	(345635, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345635, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345635, 'joey.stoffels@gmail.com', 'Cinematography', 8),
		(345636, 'joey.stoffels@gmail.com', 'Acting', 8),
		(345636, 'joey.stoffels@gmail.com', 'Plot', 8),
		(345636, 'joey.stoffels@gmail.com', 'Music and Sound', 8);

INSERT INTO Review
VALUES	(345635, 'joey.stoffels@gmail.com', GETDATE(), 'description', 8),
		(345636, 'nickhartjes@gmail.com', GETDATE(), 'description', 8);
ROLLBACK TRANSACTION