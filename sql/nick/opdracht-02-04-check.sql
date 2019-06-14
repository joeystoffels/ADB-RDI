USE odisee;
GO;
--  --------------------------------------------------------
--  Check procedure
--  --------------------------------------------------------
CREATE FUNCTION dbo.IsPurchaseInSubscriptionPeriod
(@email_address EMAIL ,@purchase_date DATE
)
RETURNS BIT
AS
     BEGIN
         DECLARE @count SMALLINT;
         DECLARE @return BIT;
         SELECT @count = COUNT(email_address)
         FROM User_Subscription
         WHERE email_address = @email_address
               AND subscription_startdate <= @purchase_date
               AND ISNULL(subscription_enddate, '2099-12-31') >= @purchase_date;
         IF(@count = 0)
             SET @return = 'false';
             ELSE
             SET @return = 'true';
         RETURN @return;
     END;
    GO

ALTER TABLE Purchase
ADD CONSTRAINT CK_CheckPurchaseInSubscription CHECK(dbo.IsPurchaseInSubscriptionPeriod(email_address, purchase_date) = 'true');
GO

--  --------------------------------------------------------
--  Demo data
--  --------------------------------------------------------

CREATE PROCEDURE SP_InsertDemoData
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @email NVARCHAR(4000)= 'test@test.nl';
        DECLARE @startDate01 DATE= '2017-03-01';
        DECLARE @endDate01 DATE= '2018-03-01';
        DECLARE @startDate02 DATE= '2018-05-01';
        DECLARE @endDate02 DATE= '2019-05-01';
        DECLARE @startDate03 DATE= '2019-06-01';
        INSERT INTO [User]
        VALUES
        (@email, 
         'The Netherlands', 
         'Test user', 
         'Delete', 
         'this user', 
         'M', 
         NULL
        );
        INSERT INTO User_Subscription
        VALUES
        (@email, 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         @startDate01, 
         @endDate01, 
         3.00
        ),
        (@email, 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         @startDate02, 
         @endDate02, 
         3.00
        ),
        (@email, 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         @startDate03, 
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
        DELETE FROM [User]
        WHERE email_address = @email;
        DELETE FROM User_Subscription
        WHERE email_address = @email;
    END;
GO

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
BEGIN TRANSACTION;
EXEC SP_DemoData;
INSERT INTO Purchase
VALUES
(123123, 
 'test@test.nl', 
 '2010-01-01', 
 3.00
);
ROLLBACK TRANSACTION;

-- [Scenario 02] : Film valt na de abonnementperiode
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_DemoData;
INSERT INTO Purchase
VALUES
(123123, 
 'test@test.nl', 
 '2020-01-01', 
 3.00
);
ROLLBACK TRANSACTION;

-- [Scenario 03] : Film valt gelijk aan de startdag van de abonnementperiode.
-- Result: Success
BEGIN TRANSACTION;
EXEC SP_DemoData;
INSERT INTO Purchase
VALUES
(123123, 
 'test@test.nl', 
 '2017-03-01', 
 3.00
);
ROLLBACK TRANSACTION;

-- [Scenario 04] : Film valt gelijk aan de einddag van de abonnementperiode.
-- Result: Success
BEGIN TRANSACTION;
EXEC SP_DemoData;
INSERT INTO Purchase
VALUES
(123123, 
 'test@test.nl', 
 '2018-03-01', 
 3.00
);
ROLLBACK TRANSACTION;

-- [Scenario 05] : Film valt tussen abbonementsperiode's in.
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_DemoData;
INSERT INTO Purchase
VALUES
(123123, 
 'test@test.nl', 
 '2018-04-01', 
 3.00
);
ROLLBACK TRANSACTION;

-- [Scenario 06] : Film valt in een periode waarin er geen einddag bekend is.
-- Result: Success
BEGIN TRANSACTION;
EXEC SP_DemoData;
INSERT INTO Purchase
VALUES
(123123, 
 'test@test.nl', 
 '2019-06-02', 
 3.00
);
ROLLBACK TRANSACTION;

-- [Scenario 07] : Film valt in een periode waarin er geen einddag bekend is.
-- Result: Success
BEGIN TRANSACTION;
EXEC SP_DemoData;
INSERT INTO Purchase
VALUES
(123123, 
 'test@test.nl', 
 '2019-06-02', 
 3.00
);
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Cleanup
--  --------------------------------------------------------
ALTER TABLE Purchase DROP CONSTRAINT IsPurchaseInSubscriptionPeriod;
GO
DROP FUNCTION IF EXISTS IsPurchaseInSubscriptionPeriod;
GO