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
    @MovieInReeks INT = 207992;
--     @MovieInReeks INT = 207989;
--     @MovieInReeks INT = 207991;
;
WITH MovieSeries(ITEM_ID, TITLE, Volgnummer)
         AS
         (
             -- Get movie
             SELECT Movie.product_id, Movie.title, 1
             FROM Product AS Movie
             WHERE Movie.product_id = @MovieInReeks
             UNION ALL
             -- Get next parts of the movie series
             SELECT NextMovie.product_id, NextMovie.title, ParentMovie.Volgnummer + 1
             FROM Product AS NextMovie
                      INNER JOIN MovieSeries AS ParentMovie ON NextMovie.previous_product_id = ParentMovie.ITEM_ID
                  -- Get the previous parts of the movie series
--              UNION ALL
--              SELECT PreviousMovie.product_id, PreviousMovie.title, ChildMovie.Volgnummer - 1
--              FROM Product AS PreviousMovie
--                       INNER JOIN MovieSeries AS ChildMovie ON PreviousMovie.product_id = ChildMovie.
         )
SELECT *
FROM MovieSeries


----------------------------------
-- Optie 2:
----------------------------------

DECLARE
 --   @MovieInReeks INT = 207992;
 --    @MovieInReeks INT = 207989;
     @MovieInReeks INT = 207991;

DECLARE @PreviousMovieInReeks INT = @MovieInReeks;
DECLARE previous_movie_cursor CURSOR FOR
        SELECT *
        FROM Product
        --WHERE previous_product_id = @PreviousMovieInReeks

OPEN previous_movie_cursor
WHILE @@FETCH_STATUS = 0  
BEGIN  
   -- This is executed as long as the previous fetch succeeds.  
   FETCH NEXT FROM previous_movie_cursor;  
END  
  
CLOSE previous_movie_cursor;  
DEALLOCATE previous_movie_cursor;  
------------------------------------------------------

DECLARE contact_cursor CURSOR FOR  
SELECT * FROM Product  
WHERE title LIKE 'B%'  
ORDER BY title;  
  
OPEN contact_cursor;  
  
-- Perform the first fetch.  
FETCH NEXT FROM contact_cursor;  
  
-- Check @@FETCH_STATUS to see if there are any more rows to fetch.  
WHILE @@FETCH_STATUS = 0  
BEGIN  
   -- This is executed as long as the previous fetch succeeds.  
   FETCH FROM contact_cursor;  
END  
  
CLOSE contact_cursor;  
DEALLOCATE contact_cursor;  
GO  