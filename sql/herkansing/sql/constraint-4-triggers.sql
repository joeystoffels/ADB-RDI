USE odisee;
GO
DROP TRIGGER IF EXISTS TR_WatchMovieInPeriod;
DROP PROCEDURE IF EXISTS SP_InsertDemoData;
GO

--  --------------------------------------------------------
--  Trigger
--  --------------------------------------------------------
CREATE TRIGGER TR_WatchMovieInPeriod ON Purchase
AFTER INSERT, UPDATE
AS
     BEGIN
         SET NOCOUNT ON; -- Stops the message that shows the count of the number of rows affected

         IF NOT EXISTS
         (
             SELECT *
             FROM inserted
         )
             RETURN;
         BEGIN TRY
--              PRINT 'In try block';
             IF EXISTS
             (
                 SELECT 'No Subscription'
                 FROM inserted AS I
                 WHERE NOT EXISTS
                 (
                     SELECT 'Subscription'
                     FROM User_Subscription AS US
                     WHERE I.purchase_date BETWEEN US.subscription_startdate
                       AND ISNULL(subscription_enddate, DATEADD(year, 100, I.purchase_date))
                 )
             )
                 THROW 54002, 'Product(s) can not be purchased outside a subscription period', 1;
         END TRY
         BEGIN CATCH
             THROW; -- Using TROW handles ROLLBACK and bubbles up the thrown error.
         END CATCH;
     END;
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
-- [01] Film valt voor de abonnementperiode
-- [02] Film valt na de abonnementperiode
-- [03] Film valt gelijk aan de startdag van de abonnementperiode.
-- [04] Film valt gelijk aan de einddag van de abonnementperiode.
-- [05] Film valt tussen abbonementsperiode's in
-- [06] Film valt in een periode waarin er geen einddag bekend is.
-- [07] Film valt in meerdere abonnementperiodes

-- First insert demo data
DELETE FROM User_Subscription WHERE email_address = 'test@test.nl'
DELETE FROM [User] WHERE email_address = 'test@test.nl'
EXEC SP_InsertDemoData;


-- [Scenario 01] : Film valt voor de abonnementperiode
-- Result: Throw Error
BEGIN TRANSACTION;
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
INSERT INTO Purchase
VALUES
(123123, 
 'test@test.nl', 
 '2019-05-05', 
 3.00
);
ROLLBACK TRANSACTION;


-- [Scenario 03] : Film valt gelijk aan de startdag van de abonnementperiode.
-- Result: Success
BEGIN TRANSACTION;
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
INSERT INTO Purchase
VALUES
(123123, 
 'test@test.nl', 
 '2019-06-02', 
 3.00
);
ROLLBACK TRANSACTION;


-- [Scenario 08] :
-- Film valt tussen abbonementsperiode's in (Throw Error) &
-- Film valt in een periode waarin er geen einddag bekend is. (Success)
-- Result: Throw Error
BEGIN TRANSACTION;
INSERT INTO Purchase
VALUES
(123123, 
 'test@test.nl', 
 '2018-04-01', 
 3.00
),
(123124, 
 'test@test.nl', 
 '2019-06-02', 
 3.00
);
ROLLBACK TRANSACTION;


-- [Scenario 09] :
-- Film valt in een periode waarin er geen einddag bekend is. (Success)
-- Film valt in een periode waarin er geen einddag bekend is. (Success)
-- Result: Success
BEGIN TRANSACTION;
INSERT INTO Purchase
VALUES
(123123, 
 'test@test.nl', 
 '2019-06-02', 
 3.00
),
(123124, 
 'test@test.nl', 
 '2019-06-02', 
 3.00
);
ROLLBACK TRANSACTION;


--  --------------------------------------------------------
--  Cleanup
--  --------------------------------------------------------
DROP TRIGGER IF EXISTS TR_WatchMovieInPeriod;
DROP PROCEDURE IF EXISTS SP_DemoData;
GO