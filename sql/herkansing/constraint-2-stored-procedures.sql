USE odisee;
GO

DROP TRIGGER IF EXISTS TR_Products_AI_AU
DROP PROCEDURE IF EXISTS USP_Products_Insert
DROP PROCEDURE IF EXISTS USP_Products_Update_PreviousProductId
GO

--  --------------------------------------------------------
--  Stored procedure
--  --------------------------------------------------------
CREATE PROCEDURE USP_Products_Insert (
	@ProductID INT,
	@ProductType VARCHAR(255),
	@PreviousProductId INT,
	@Title VARCHAR(255),
	@CoverImage VARCHAR(255),
	@Description VARCHAR(255),
	@MovieDefaultPrice NUMERIC(5,2),
	@PublicationYear INT,
	@NrOnlinePlayers INT,
	@Duration INT,
	@Url VARCHAR(255)
)
AS

	SET NOCOUNT, XACT_ABORT ON

	-- SP should only process if @ProductType = 'Movie' and @PreviousProductId is not null.
	IF @ProductType != 'Movie' RETURN;
	IF @PreviousProductId IS NULL RETURN;

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	BEGIN TRANSACTION;

	BEGIN TRY

		IF EXISTS (
			SELECT *
			FROM Product P
			WHERE P.product_id = @PreviousProductId
			AND P.product_type != 'Movie')

		THROW 52002, 'Previous part is not of type Movie', 1;

		IF EXISTS (
			SELECT *
			FROM Product P
			WHERE P.product_id = @PreviousProductId
			AND P.publication_year >= @PublicationYear)

		THROW 52003, 'Publication_year of previous part is after the inserted product publication year!', 1;

		INSERT INTO Product
		VALUES (@ProductId, @ProductType,
				@PreviousProductId, @Title,
				@CoverImage, @Description,
				@MovieDefaultPrice, @PublicationYear,
				@NrOnlinePlayers, @Duration, @Url)

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
		THROW;
	END CATCH

	COMMIT TRANSACTION;
GO


-- SP insert tests
-- Info: Product_id 345635 has publication_year 1999.
-- Assumption: Months and days are not stored, making us unable to determine if the previous_part was released
-- before or after the current product, thus we assume that the same publication_year violates the trigger rules.

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [01] Movie toevoegen met publication_year voor het publication_year van zijn previous_part
-- [02] Movie toevoegen met publication_year na het publication_year van zijn previous_part
-- [03] Movie toevoegen met hetzelfde publication_year als het publication_year van zijn previous_part
-- [04] Movie toevoegen met previous_part als product_type 'Game'
-- [05] Game toevoegen
-- [06] Movie toevoegen met geen previous_part


-- Scenario 01
-- Publication year is before 1999
-- Result: Throw Error 52003
BEGIN TRANSACTION;
EXEC USP_Products_Insert 9999998, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1998, null, null, null
ROLLBACK TRANSACTION;


-- Scenario 02
-- Publication year is after 1999
-- Result: Success
BEGIN TRANSACTION;
EXEC USP_Products_Insert 9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 2000, null, null, null
ROLLBACK TRANSACTION;


-- Scenario 03
-- Same publication year
-- Result: Throw Error 52003
BEGIN TRANSACTION;
EXEC USP_Products_Insert 9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null
ROLLBACK TRANSACTION;


-- Scenario 04
-- Previous part is of type 'Game' instead of 'Movie'
-- Result: Throw Error 52002
BEGIN TRANSACTION;
EXEC USP_Products_Insert 9999999, 'Movie', 412331, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null
ROLLBACK TRANSACTION;


-- Scenario 05
-- Bypass SP because product type is not 'Movie'
-- Result: Success
BEGIN TRANSACTION;
EXEC USP_Products_Insert 9999998, 'Game', 345635, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null
ROLLBACK TRANSACTION;


-- Scenario 06
-- Bypass SP because previous part is null
-- Result: Success
BEGIN TRANSACTION;
EXEC USP_Products_Insert 9999999, 'Movie', null, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Stored procedure
--  --------------------------------------------------------
CREATE PROCEDURE USP_Products_Update_PreviousProductId (
	@ProductID INT,
	@PreviousProductId INT
)
AS
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	BEGIN TRANSACTION;

	SET NOCOUNT, XACT_ABORT ON

	-- SP should only process if @ProductType = 'Movie' and @PreviousProductId is not null.
	IF @PreviousProductId IS NULL RETURN;
	IF (SELECT product_type FROM Product WHERE product_id = @ProductID) != 'Movie' RETURN;

	BEGIN TRANSACTION;

	BEGIN TRY

		IF EXISTS (SELECT *
			FROM Product P
			WHERE P.product_id = @PreviousProductId
			AND P.product_type != 'Movie')

		THROW 52002, 'Previous part is not of type Movie', 1;

		IF EXISTS (SELECT *
			FROM Product P
			WHERE P.product_id = @PreviousProductId
			AND P.publication_year >= (SELECT publication_year FROM Product WHERE product_id = @ProductID))

		THROW 52003, 'Publication_year of previous part is after the updated product publication year!', 1;

		UPDATE Product
		SET previous_product_id = @PreviousProductId
		WHERE product_id = @ProductID

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
		THROW;
	END CATCH

	COMMIT TRANSACTION;

GO

-- SP update tests
-- Info: Product_id 345635 has publication_year 1999.
-- Assumption: Months and days are not stored, making us unable to determine if the previous_part was released
-- before or after the current product, thus we assume that the same publication_year violates the trigger rules.

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [07] Product_id updaten met product_id waarbij publication_year na het publication_year van zijn previous_part ligt
-- [08] Product_id updaten met product_id waarbij publication_year voor het publication_year van zijn previous_part ligt
-- [09] Product_id updaten met product_id waarbij publication_year hetzelfde is als het publication_year van zijn previous_part


-- Scenario 07
-- Publication year is after 1999 (2002).
-- Result: Throw error 52003
BEGIN TRANSACTION;
EXEC USP_Products_Update_PreviousProductId 345635, 313503
ROLLBACK TRANSACTION;


-- Scenario 08
-- Publication year is before 1999 (1996).
-- Result: Success
BEGIN TRANSACTION;
EXEC USP_Products_Update_PreviousProductId 345635, 313508
ROLLBACK TRANSACTION;


-- Scenario 09
-- Same publication year.
-- Result: Throw error
BEGIN TRANSACTION;
EXEC USP_Products_Update_PreviousProductId 345635, 313799
ROLLBACK TRANSACTION;