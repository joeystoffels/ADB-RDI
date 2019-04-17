-- OPDRACHT 01
-- Geef van een film, de hele reeks waar die bij hoort met volgnummer en in de juiste volgorde.
-- Indien hij niet in een reeks zit, is de lijst gewoon één lang met volgnummer 1.
-- Dit moet één statement worden die van een variabel ID de reeks geeft zoals onderstaand voorbeeld:
-- DECLARE @MovieInReeks INT = 207989;

-- jouw statement hier levert onderstaand resultaat:
--
-- ITEM_ID		TITLE				Volgnummer
-- 207992		Matrix, The				1
-- 207989		Matrix Reloaded, The	2
-- 207991		Matrix Revolutions, The	3


DECLARE
--     @MovieInReeks INT = 207992;
    @MovieInReeks INT = 207989;
--     @MovieInReeks INT = 207991;

;
WITH MovieSeries(ITEM_ID, TITLE, Volgnummer)
         AS
         (
             SELECT Movie.product_id, Movie.title, 1
             FROM Product AS Movie
             WHERE Movie.product_id = @MovieInReeks

             UNION ALL

             SELECT NextMovie.product_id, NextMovie.title, ChildMovies.Volgnummer + 1
             FROM Product AS NextMovie
                      INNER JOIN MovieSeries AS ChildMovies ON NextMovie.previous_product_id = ChildMovies.ITEM_ID

             UNION ALL

             SELECT PreviousMovie.product_id, PreviousMovie.title, 100
             FROM Product AS PreviousMovie
                 FULL JOIN Product AS Parent ON Parent.product_id = PreviousMovie.previous_product_id


         )
SELECT *
FROM MovieSeries


----------------------------------
-- Optie 2:
----------------------------------
CREATE TABLE #MovieSeries
(
    ITEM_ID    int NOT NULL,
    TITLE      varchar(255),
    Volgnummer int,
)

DECLARE
    @MovieInReeks INT = 207989;
DECLARE
    @previous_movie INT = @MovieInReeks;
DECLARE
    @next_movie INT = @MovieInReeks;
DECLARE
    @count INT = 0;

INSERT INTO #MovieSeries (ITEM_ID, TITLE, Volgnummer)
SELECT product_id, title, @count
FROM Product
WHERE product_id = @MovieInReeks


WHILE @previous_movie IS NOT NULL
BEGIN
    PRINT @previous_movie
    SET @previous_movie =
            (
                SELECT Parent.product_id
                FROM Product AS Parent
                         FULL JOIN Product AS Child ON Child.previous_product_id = Parent.product_id
                WHERE Child.product_id = @previous_movie
            )
    IF @previous_movie IS NOT NULL
        SET @count = @count - 1
    INSERT INTO #MovieSeries (ITEM_ID, TITLE, Volgnummer)
    SELECT product_id, title, @count
    FROM Product
    WHERE product_id = @previous_movie
END

SET @count = 0;
WHILE @next_movie IS NOT NULL
BEGIN
    SET @next_movie =
            (
                SELECT product_id
                FROM Product
                WHERE previous_product_id = @next_movie
            )
    IF @next_movie IS NOT NULL
        SET @count = @count + 1
    INSERT INTO #MovieSeries (ITEM_ID, TITLE, Volgnummer)
    SELECT product_id, title, @count
    FROM Product
    WHERE product_id = @next_movie
END

SELECT ITEM_ID,
       TITLE,
       Row_number()
               OVER (
                   ORDER BY Volgnummer ASC) AS Volgnummer
FROM #MovieSeries
ORDER BY Volgnummer

DROP TABLE #MovieSeries;
GO