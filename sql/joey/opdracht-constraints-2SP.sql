-- Constraint #2, Stored Procedure uitwerking
-- Bij een film met previous part, is de film later uitgebracht dan het previous part.

DROP PROCEDURE IF EXISTS USP_Products_Insert
GO
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

	--SET TRANSACTION ISOLATION LEVEL ...
	BEGIN TRANSACTION;

	BEGIN TRY

		IF EXISTS (SELECT *
			FROM Product P
			WHERE P.product_id = @PreviousProductId
			AND P.product_type != 'Movie')

		THROW 50001, 'Previous part is not of type Movie', 1;

		IF EXISTS (SELECT *
			FROM Product P
			WHERE P.product_id = @PreviousProductId
			AND P.publication_year <= @PublicationYear)

		THROW 50001, 'Publication_year of previous part is after the inserted/updated product publication year!', 1;

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
GO


-- SP tests
-- Info: Product_id 345635 has publication_year 1999.
-- Assumption: Months and days are not stored, making us unable to determine if the previous_part was released
-- before or after the current product, thus we assume that the same publication_year violates the trigger rules.

-- Should fail because its publication year is before 1999.
EXEC USP_Products_Insert 9999998, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 2000, null, null, null

-- Should succeed because its publication year is after 1999.
EXEC USP_Products_Insert 9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1998, null, null, null

-- Rollback
DELETE FROM PRODUCT WHERE product_id = 9999999

-- Should fail because it has the same publication year.
EXEC USP_Products_Insert 9999999, 'Movie', 345635, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null

-- Should fail because previous part is of type 'Game'.
EXEC USP_Products_Insert 9999999, 'Movie', 412331, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null

-- Should bypass trigger and succeed because product type is not 'Movie'.
EXEC USP_Products_Insert 9999998, 'Game', 345635, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null

-- Should bypass trigger and succeed because previous part is null.
EXEC USP_Products_Insert 9999999, 'Movie', null, 'Star Wars Latest', null, null, 2.00, 1999, null, null, null

-- Rollback
DELETE FROM Product WHERE product_id = 9999999
DELETE FROM Product WHERE product_id = 9999998