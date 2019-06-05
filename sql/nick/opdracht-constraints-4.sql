--  --------------------------------------------------------
-- Constraint 4:
-- De datum waarop een film wordt bekeken valt binnen de/een abonnementperiode.
--  --------------------------------------------------------

USE odisee;
GO
DROP TRIGGER IF EXISTS TR_WatchMovieInPeriod;
DROP PROCEDURE IF EXISTS SP_DemoData; 
GO

--  --------------------------------------------------------
--  Trigger
--  --------------------------------------------------------
CREATE TRIGGER TR_WatchMovieInPeriod ON Purchase
AFTER INSERT, UPDATE
AS
     BEGIN
         SET NOCOUNT ON; -- Stops the message that shows the count of the number of rows affected
         -- Declare variables
         DECLARE @email NVARCHAR(4000);
         DECLARE @purchase_date DATE;
         IF NOT EXISTS
         (
             SELECT *
             FROM inserted
         )
             RETURN; -- If nothing is inserted
         BEGIN TRY
             SET @email =
             (
                 SELECT email_address
                 FROM inserted
             );
             SET @purchase_date =
             (
                 SELECT purchase_date
                 FROM inserted
             );
             IF NOT EXISTS
             (
                 SELECT 'Subscription'
                 FROM User_Subscription
                 WHERE email_address = @email
                       AND subscription_startdate <= @purchase_date
                       AND ISNULL(subscription_enddate, '2099-12-31') >= @purchase_date
             )
                 THROW 50001, 'Movie can not be purchased outside a subscription period ', 1;
         END TRY
         BEGIN CATCH
             THROW; -- Using TROW handles ROLLBACK and bubbles up the thrown error.
         END CATCH;
     END;
	 GO

--  --------------------------------------------------------
--  Demo data
--  --------------------------------------------------------

CREATE PROCEDURE SP_DemoData
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
        ),  (@email, 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         @startDate03, 
         Null, 
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
 '2019-06-02', 
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

--  --------------------------------------------------------
--  Cleanup
--  --------------------------------------------------------
DROP TRIGGER IF EXISTS TR_WatchMovieInPeriod;
DROP PROCEDURE IF EXISTS SP_DemoData;  
GO