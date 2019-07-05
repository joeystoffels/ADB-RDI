USE odisee;
GO
DROP PROCEDURE IF EXISTS SP_UserSubscriptionInsert;
DROP PROCEDURE IF EXISTS SP_InsertDemoData;
GO

--  --------------------------------------------------------
--  Stored procedure
--  --------------------------------------------------------
CREATE PROCEDURE SP_UserSubscriptionInsert
(
     @email_address EMAIL,
 @country_name COUNTRY,
 @subscription_type TYPE,
 @subscription_type_name VARCHAR(255),
 @startDate DATE,
 @endDate DATE,
 @monthly_fee PRICE
)
AS

    SET NOCOUNT, XACT_ABORT ON

    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	BEGIN TRANSACTION;

    BEGIN TRY

    IF EXISTS
        (
            SELECT *
            FROM User_Subscription
            WHERE ISNULL(@endDate, DATEADD(year, 100, @endDate)) <= subscription_startdate
               OR ISNULL(subscription_enddate, DATEADD(year, 100, GETDATE())) >= @startDate
                AND email_address = @email_address
        )
        THROW 53001, 'Inserted subscription(s) overlaps an excisting subscription period.', 1;

    INSERT INTO User_Subscription
    VALUES
    (@email_address,
     @country_name,
     @subscription_type,
     @subscription_type_name,
     @startDate,
     @endDate,
     @monthly_fee
    );
    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
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

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 01:
-- [XXXXX]
--   [XXXXX]
-- The enddate of the inserted subscription overlaps an startDate of an other subscription;
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
EXEC SP_UserSubscriptionInsert 'test@test.nl',  'The Netherlands', 'Basic', 'Basic', '2017-02-28', '2018-02-28', 3.00
ROLLBACK TRANSACTION;

-- Scenario 02:
--    [XXXXX]
-- [XXXXX]
-- The startDate of the inserted subscription overlaps an endDate of an other subscription;
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
EXEC SP_UserSubscriptionInsert 'test@test.nl',  'The Netherlands', 'Basic', 'Basic', '2017-03-02', '2018-03-02', 3.00
ROLLBACK TRANSACTION;

-- Scenario 03:
--  [XXX]
-- [XXXXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
EXEC SP_UserSubscriptionInsert 'test@test.nl',  'The Netherlands', 'Basic', 'Basic', '2017-03-02', '2018-02-28', 3.00
ROLLBACK TRANSACTION;

-- Scenario 04:
-- [XXXXXX]
--  [XXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
EXEC SP_UserSubscriptionInsert 'test@test.nl',  'The Netherlands', 'Basic', 'Basic', '2017-02-28', '2018-03-02', 3.00
ROLLBACK TRANSACTION;

-- Scenario 05:
--        [XXXX]
-- [XXXX]        [XXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
EXEC SP_UserSubscriptionInsert 'test@test.nl',  'The Netherlands', 'Basic', 'Basic', '2018-03-02', '2019-03-02', 3.00
ROLLBACK TRANSACTION;

-- Scenario 06:
-- [XXXX]
-- [XXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
EXEC SP_UserSubscriptionInsert 'test@test.nl',  'The Netherlands', 'Basic', 'Basic', '2017-03-01', '2018-03-01', 3.00
ROLLBACK TRANSACTION;

-- Scenario 07:
--       [XXXX]
-- [XXXX ---> geen einde
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
EXEC SP_UserSubscriptionInsert 'test@test.nl',  'The Netherlands', 'Basic', 'Basic', '2019-06-05', '2019-07-01', 3.00
ROLLBACK TRANSACTION;

-- Scenario 08:
--       [XXXX]
-- [XXXX] 
-- Result: Success
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
DELETE FROM User_Subscription
WHERE subscription_startdate = '2019-06-01'
      AND subscription_enddate IS NULL;
EXEC SP_UserSubscriptionInsert 'test@test.nl',  'The Netherlands', 'Basic', 'Basic', '2019-06-05', '2019-07-01', 3.00
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Cleanup
--  --------------------------------------------------------
DROP PROCEDURE IF EXISTS SP_UserSubscriptionInsert;
DROP PROCEDURE IF EXISTS SP_InsertDemoData;
GO