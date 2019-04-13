-------------------------------------------------------------------
--  The Matrix
-------------------------------------------------------------------

-- SELECT product_id, previous_product_id, title, publication_year
-- FROM Product
-- WHERE title LIKE 'matrix%'
-- AND product_type = 'Movie';

-- product_id	previous_product_id	title	publication_year
-- 207986	NULL	Matrix Defence, The	2003
-- 207987	NULL	Matrix Online, The	2004
-- 207988	NULL	Matrix Recalibrated, The	2004
-- 207989	NULL	Matrix Reloaded, The	2003
-- 207990	NULL	Matrix Revisited, The	2001
-- 207991	NULL	Matrix Revolutions, The	2003
-- 207992	NULL	Matrix, The	1999
-- 397121	NULL	Matrix"	1993

-------------------------------------------------------------------

-- 207989	NULL	Matrix Reloaded, The	2003
-- has parent
-- 207992	NULL	Matrix, The	1999
UPDATE dbo.Product
SET previous_product_id = 207992
WHERE product_id = 207989

-- 207991	NULL	Matrix Revolutions, The	2003
-- has parent
-- 207989	NULL	Matrix Reloaded, The	2003
UPDATE dbo.Product
SET previous_product_id = 207989
WHERE product_id = 207991


-------------------------------------------------------------------
--  Lord of the Rings
-------------------------------------------------------------------

-- SELECT product_id, previous_product_id, title, publication_year
-- FROM Product
-- WHERE title LIKE 'lord of the rings%'
-- AND product_type = 'Movie';

-- product_id	previous_product_id	title	publication_year
-- 194492	NULL	Lord of the Rings	1990
-- 194493	NULL	Lord of the Rings, The	1978
-- 194494	NULL	Lord of the Rings: Game One	1985
-- 194495	NULL	Lord of the Rings: Return of the King, The (2003/II)	2003
-- 194496	NULL	Lord of the Rings: The Battle for Middle-Earth, The	2004
-- 194497	NULL	Lord of the Rings: The Fellowship of the Ring, The	2001
-- 194498	NULL	Lord of the Rings: The Fellowship of the Ring, The	2002
-- 194499	NULL	Lord of the Rings: The Quest Fulfilled, The	2003
-- 194500	NULL	Lord of the Rings: The Return of the King, The	2003
-- 194501	NULL	Lord of the Rings: The Third Age	2004
-- 194502	NULL	Lord of the Rings: The Two Towers, The	2002
-- 194503	NULL	Lord of the Rings: The Two Towers, The (2002/II)	2002
-- 194504	NULL	Lord of the Rings: The War of the Ring, The	2003
-- 194505	NULL	Lord of the Rings: Vol. I, The	1990
-- 194506	NULL	Lord of the Rings: Vol. II, The	1992

-------------------------------------------------------------------

-- 194502	NULL	Lord of the Rings: The Two Towers, The	2002
-- has parent
-- 194498	NULL	Lord of the Rings: The Fellowship of the Ring, The	2002
UPDATE dbo.Product
SET previous_product_id = 194498
WHERE product_id = 194502

-- 194500	NULL	Lord of the Rings: The Return of the King, The	2003
-- has parent
-- 194502	NULL	Lord of the Rings: The Two Towers, The	2002
UPDATE dbo.Product
SET previous_product_id = 194502
WHERE product_id = 194500


-------------------------------------------------------------------
--  Star Wars
-------------------------------------------------------------------
-- product_id	previous_product_id	title	publication_year
-- 313459	NULL	Star Wars	1977
-- 313460	NULL	Star Wars	1983
-- 313461	NULL	Star Wars	1988
-- 313462	NULL	Star Wars City	1985
-- 313463	NULL	Star Wars Holiday Special, The	1978
-- 313464	NULL	Star Wars Rogue Leader: Rogue Squadron 2	2001
-- 313465	NULL	Star Wars Rogue Squadron III: Rebel Strike	2003
-- 313466	NULL	Star Wars: Battlefront	2004
-- 313467	NULL	Star Wars: Bounty Hunter	2002
-- 313468	NULL	Star Wars: Dark Forces	1994
-- 313469	NULL	Star Wars: Demolition	2000
-- 313470	NULL	Star Wars: Episode I - Battle for Naboo	2001
-- 313471	NULL	Star Wars: Episode I - Jedi Power Battles	2000
-- 313472	NULL	Star Wars: Episode I - Racer	1999
-- 313473	NULL	Star Wars: Episode I - The Gungan Frontier	1999
-- 313474	NULL	Star Wars: Episode I - The Phantom Menace	1999
-- 313475	NULL	Star Wars: Episode I - The Phantom Menace (1999/II)	1999
-- 313476	NULL	Star Wars: Episode II - Attack of the Clones	2002
-- 313477	NULL	Star Wars: Episode III - Revenge of the Sith	2005
-- 313478	NULL	Star Wars: Episode V - The Empire Strikes Back	1980
-- 313479	NULL	Star Wars: Episode VI - Return of the Jedi	1983
-- 313480	NULL	Star Wars: Force Commander	2000
-- 313481	NULL	Star Wars: Galactic Battlegrounds	2001
-- 313482	NULL	Star Wars: Galaxies	2002
-- 313483	NULL	Star Wars: Jedi Arena	1983
-- 313484	NULL	Star Wars: Jedi Knight - Dark Forces II	1997
-- 313485	NULL	Star Wars: Jedi Knight - Jedi Academy	2003
-- 313486	NULL	Star Wars: Jedi Knight - Mysteries of the Sith	1998
-- 313487	NULL	Star Wars: Jedi Knight II - Jedi Outcast	2002
-- 313488	NULL	Star Wars: Jedi Starfighter	2002
-- 313489	NULL	Star Wars: Knights of the Old Republic	2003
-- 313490	NULL	Star Wars: Masters of Ters Ksi	1998
-- 313491	NULL	Star Wars: Millennium Falcon CD-ROM Playset	1998
-- 313492	NULL	Star Wars: Obi-Wan	2001
-- 313493	NULL	Star Wars: Racer Revenge	2002
-- 313496	NULL	Star Wars: Republic Commando	2005
-- 313497	NULL	Star Wars: Return of the Jedi - Death Star Battle	1983
-- 313498	NULL	Star Wars: Rogue Squadron	1998
-- 313499	NULL	Star Wars: Shadows of the Empire	1996
-- 313500	NULL	Star Wars: Starfighter	2001
-- 313501	NULL	Star Wars: Super Bombad Racing	2001
-- 313502	NULL	Star Wars: The Arcade Game	1984
-- 313503	NULL	Star Wars: The Clone Wars	2002
-- 313504	NULL	Star Wars: The Empire Strikes Back	1982
-- 313505	NULL	Star Wars: Tie Fighter Collector's CD-ROM	1995
-- 313506	NULL	Star Wars: X-Wing	1995
-- 313507	NULL	Star Wars: X-Wing Alliance	1999
-- 313508	NULL	Star Wars: X-Wing vs. TIE Fighter	1996
-- 313509	NULL	Star Wars: Yoda Stories	1997
-- 406411	NULL	Star Wars: Clone Wars"	2003

-------------------------------------------------------------------

-- 313478   Star Wars: Episode V - The Empire Strikes Back	1980
-- has parent
-- 313459	Star Wars	1977
UPDATE dbo.Product
SET previous_product_id = 313459
WHERE product_id = 313478

-- 313479	NULL	Star Wars: Episode VI - Return of the Jedi	1983
-- has parent
-- 313478   Star Wars: Episode V - The Empire Strikes Back	1980
UPDATE dbo.Product
SET previous_product_id = 313478
WHERE product_id = 313479

-- 313474	NULL	Star Wars: Episode I - The Phantom Menace	1999
-- has parent
-- 313479	NULL	Star Wars: Episode VI - Return of the Jedi	1983
UPDATE dbo.Product
SET previous_product_id = 313479
WHERE product_id = 313474

-- 313476	NULL	Star Wars: Episode II - Attack of the Clones	2002
-- has parent
-- 313474	NULL	Star Wars: Episode I - The Phantom Menace	1999
UPDATE dbo.Product
SET previous_product_id = 313474
WHERE product_id = 313476

-- 313477	NULL	Star Wars: Episode III - Revenge of the Sith	2005
-- has parent
-- 313476	NULL	Star Wars: Episode II - Attack of the Clones	2002
UPDATE dbo.Product
SET previous_product_id = 313476
WHERE product_id = 313477



-------------------------------------------------------------------
--  Controle functie
-------------------------------------------------------------------
SELECT *
FROM dbo.Product
WHERE previous_product_id IS NOT NULL

