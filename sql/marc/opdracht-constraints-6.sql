/* 
    Opdracht Constraints
    Implementeer onderstaande constraints. Het kan zijn dat je een aantal al tijdens de casus DDDQ heb geïdentificeerd en/of zelfs al gemaakt. 
	Lever in dat geval die code weer in voor deze casus. Indien je de constraints procedureel oplost, maak je zowel een Stored Procedure als een After Trigger. 
	
	Zorg voor nette error handling in jouw code en schrijf een complete testset voor beide constraint implementaties. 
	Leg uit of de SP of Trigger jouw voorkeur heeft en uiteraard waarom. Als je bij een constraint vindt dat een Instead Of Trigger de betere variant is, 
	maak je die ook en leg je uit waarom dit de beste oplossing is voor deze constraint.

	6) Genres voor films en spellen zijn verschillend, deze mogen niet bij het verkeerde media-item gebruikt worden. 
	   Hetzelfde geld voor Review aspecten.

	 Genres Game:

	 - Action
	 - Action-Adventure
	 - Adventure
	 - MMO
	 - Role-playing
	 - Simulation
	 - Strategy

	 Genres Movie:

	 - Action
	 - Adult
	 - Adventure
	 - Animation
	 - Comedy
	 - Crime
	 - Documentary
	 - Drama
	 - Family
	 - Fantasy
	 - Film-Noir
	 - Horror
	 - Music
	 - Musical
	 - Mystery
	 - Romance
	 - Sci-Fi
	 - Short
	 - Thriller
	 - War
	 - Western

	 Review aspecten Game
	 
	 Review aspecten Movie
*/

-- Film toevoegen, met gebruikmaking genre voor film
-- Film toevoegen met gebruikmakng genre voor game, resulteert in foutmelding
-- Game toevoegen met gebruikmaking genre voor game
-- Game toevoegen met gebruikmaking genre voor film, resulteert in foutmelding
-- Game toevoegen met gebruikmaking genre voor film en game
-- Film toevoegen met gebruikmaking genre voor film en game
-- Genre toevoegen voor film
-- Genre toevoegen voor game
-- Film updaten, met gebruikmaking genre voor film
-- Film updaten met gebruikmakng genre voor game, resulteert in foutmelding
-- Game updaten met gebruikmaking genre voor game
-- Game updaten met gebruikmaking genre voor film, resulteert in foutmelding
-- Game updaten met gebruikmaking genre voor film en game
-- Film updaten met gebruikmaking genre voor film en game
-- Genre updaten voor film
-- Genre updaten voor game
