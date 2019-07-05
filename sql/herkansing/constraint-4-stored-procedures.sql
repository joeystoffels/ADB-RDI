USE odisee;
GO
DROP PROCEDURE IF EXISTS SP_PurchaseInsert;
DROP PROCEDURE IF EXISTS SP_InsertDemoData;
DROP PROCEDURE IF EXISTS SP_DeleteDemoData;
GO

--  --------------------------------------------------------
--  Stored procedure
--  --------------------------------------------------------
CREATE PROCEDURE SP_PurchaseInsert
(@productId     ID, 
 @email_address EMAIL, 
 @purchase_date DATE, 
 @price         PRICE
)
AS
     SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS
        (
            SELECT 'Subscription'
            FROM User_Subscription AS US
            WHERE @purchase_date BETWEEN US.subscription_startdate AND ISNULL(subscription_enddate, DATEADD(year, 100, @purchase_date))
        )
            THROW 54001, 'Product(s) can not be purchased outside a subscription period', 1;
        INSERT INTO Purchase
        VALUES
        (@productId, 
         @email_address, 
         @purchase_date, 
         @price
        );

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
     COMMIT TRANSACTION;
GO

--  --------------------------------------------------------
--  Demo data
--  --------------------------------------------------------

CREATE PROCEDURE SP_InsertDemoData
AS
    BEGIN
        SET NOCOUNT ON;
        INSERT INTO [User]
        VALUES
        ('test@test.nl', 
         'The Netherlands', 
         'Test user', 
         'Delete', 
         'this user', 
         'M', 
         NULL
        );
        INSERT INTO User_Subscription
        VALUES
        ('test@test.nl', 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         '2017-03-01', 
         '2018-03-01', 
         3.00
        );
        INSERT INTO User_Subscription
        VALUES
        ('test@test.nl', 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         '2018-05-01', 
         '2019-05-01', 
         3.00
        );
        INSERT INTO User_Subscription
        VALUES
        ('test@test.nl', 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         '2019-06-01', 
         NULL, 
         3.00
        );
    END;
GO
CREATE PROCEDURE SP_DeleteDemoData
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @email NVARCHAR(4000)= 'test@test.nl';
        DECLARE @startDate01 DATE= '2017-03-01';
        DECLARE @endDate01 DATE= '2018-03-01';
        DECLARE @startDate02 DATE= '2018-05-01';
        DECLARE @endDate02 DATE= '2019-05-01';
        DECLARE @startDate03 DATE= '2019-06-01';
        DELETE FROM Purchase
        WHERE email_address = @email;
        DELETE FROM User_Subscription
        WHERE email_address = @email;
        DELETE FROM [User]
        WHERE email_address = @email;
    END;
GO

EXEC SP_DeleteDemoData;

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [01] Film valt voor de abonnementperiode
-- [02] Film valt na de abonnementperiode
-- [03] Film valt gelijk aan de startdag van de abonnementperiode.
-- [04] Film valt gelijk aan de einddag van de abonnementperiode.
-- [05] Film valt tussen abbonementsperiode's in
-- [06] Film valt in een periode waarin er geen einddag bekend is.
-- [07] Film valt in meerdere abonnementperiodes
--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- [Scenario 01] : Film valt voor de abonnementperiode
-- Result: Throw Error
EXEC SP_InsertDemoData;
EXEC SP_PurchaseInsert 
     1, 
     'test@test.nl', 
     '2010-01-01', 
     3.2;
EXEC SP_DeleteDemoData;


-- [Scenario 02] : Film valt na de abonnementperiode
-- Result: Throw Error
EXEC SP_InsertDemoData;
EXEC SP_PurchaseInsert
     1,
     'test@test.nl',
     '2019-05-15',
     3.2;
EXEC SP_DeleteDemoData;

-- [Scenario 03] : Film valt gelijk aan de startdag van de abonnementperiode.
-- Result: Success
EXEC SP_InsertDemoData;
EXEC SP_PurchaseInsert
     1,
     'test@test.nl',
     '2017-03-01',
     3.2;
EXEC SP_DeleteDemoData;

-- [Scenario 04] : Film valt gelijk aan de einddag van de abonnementperiode.
-- Result: Success
EXEC SP_InsertDemoData;
EXEC SP_PurchaseInsert
     1,
     'test@test.nl',
     '2018-03-01',
     3.2;
EXEC SP_DeleteDemoData;

-- [Scenario 05] : Film valt tussen abbonementsperiode's in.
-- Result: Throw Error
EXEC SP_InsertDemoData;
EXEC SP_PurchaseInsert
     1,
     'test@test.nl',
     '2018-04-01',
     3.2;
EXEC SP_DeleteDemoData;

-- [Scenario 06] : Film valt in een periode waarin er geen einddag bekend is.
-- Result: Success
EXEC SP_InsertDemoData;
EXEC SP_PurchaseInsert
     1,
     'test@test.nl',
     '2019-06-02',
     3.2;
EXEC SP_DeleteDemoData;

--  --------------------------------------------------------
--  Cleanup
--  --------------------------------------------------------
DROP TRIGGER IF EXISTS TR_WatchMovieInPeriod;
DROP PROCEDURE IF EXISTS SP_InsertDemoData;  
DROP PROCEDURE IF EXISTS SP_DeleteDemoData;
GO