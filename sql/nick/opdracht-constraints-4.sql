--  --------------------------------------------------------
-- Constraint 4:
-- De datum waarop een film wordt bekeken valt binnen de/een abonnementperiode.
--  --------------------------------------------------------

USE odisee;
GO
DROP TRIGGER IF EXISTS TR_WatchMovieInPeriod;
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
             IF EXISTS
             (


                 Select * from [User] AS U
				 INNER JOIN User_Subscription AS US ON U.email_address = US.email_address
				 where U.email_address = 'nickhartjes@gmail.com'
             )
                 THROW 50001, 'Beautifull error message, readable for users...', 1;
         END TRY
         BEGIN CATCH
             THROW; -- Using TROW handles ROLLBACK and bubbles up the thrown error.
         END CATCH;
     END;
	 GO

--  --------------------------------------------------------
--  Demo data
--  --------------------------------------------------------
INSERT INTO User_Subscription  VALUES ('nickhartjes@gmail.com', 'The Netherlands', 'Basic', 'Basic', '2018-12-01', '2019-05-07', 3.00);
INSERT INTO User_Subscription  VALUES ('nickhartjes@gmail.com', 'The Netherlands', 'Basic', 'Basic', '2019-05-01', '2019-05-07', 3.00);
INSERT INTO User_Subscription  VALUES ('nickhartjes@gmail.com', 'The Netherlands', 'Basic', 'Basic', '2019-05-01', '2019-05-07', 3.00);


--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Film valt voor de abonnementperiode
-- Film valt na de abonnementperiode
-- Film valt gelijk aan de startdag van de abonnementperiode.
-- Film valt gelijk aan de einddag van de abonnementperiode.
-- Film valt tussen abbonementsperiode's in
-- Film valt in een periode waarin er geen einddag bekend is.
-- Film valt in meerdere abonnementperiodes

DECLARE @DATUM1 DATE;
DECLARE @DATUM2 DATE;
SELECT @DATUM1 = MIN(DateMarriage)
FROM MARRIAGE
WHERE HusbandID = 1
      AND DateDivorce IS NULL;
SELECT @DATUM2 = MIN(DateMarriage)
FROM MARRIAGE
WHERE HusbandID = 3
      AND DateDivorce IS NULL;
--eentje fout
INSERT INTO Marriage
VALUES
(1, 
 3, 
 DATEADD(day, -60, @DATUM1), 
 DATEADD(day, -55, @DATUM1)
),
(3, 
 8, 
 DATEADD(day, -10, @DATUM2), 
 DATEADD(day, -8, @DATUM2)
);
--beiden goed
--INSERT INTO Marriage 
--	values (1,3, DATEADD(day, -48, @DATUM1), DATEADD(day, -30, @DATUM1)),
--	(3,8, DATEADD(day, -49, @DATUM2), DATEADD(day, -40, @DATUM2));
GO