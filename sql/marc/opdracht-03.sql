-- 3.	Geef de 10 films met de hoogste mediaan van hun reviews. Wat zegt dit getal over een film?

/*
 In deze versie een distinct gebruikt. Krijg namelijk meerdere rijen terug doordat scores per film over meerdere
 rijen zijn verdeeld.
 */

SELECT DISTINCT P.title AS FilmTitel
	,AVG(RC.score) OVER (PARTITION BY RC.product_id) AS Mediaan
FROM Review_Category RC
JOIN Product P ON P.product_id = RC.product_id
ORDER BY Mediaan DESC
