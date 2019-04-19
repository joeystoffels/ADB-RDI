## Advance Databases - Relational Database Implementation

### Installation with sql file
**Step 01:**
``` console
docker-compose up -d
```
Remember the name of the created container, in this case it's : adb-rdi-casus_db_1

**Step 02:**   
Extract the OdiseeDB.zip file in the files/database folder. 
Now that we have the server up and running and the sql file extracted we have 2 options

Option 01:
``` console
docker cp files/database/OdiseeDB.sql adb-rdi-casus_db_1:/tmp/OdiseeDB.sql
```
Import the sql into the Docker container (May take a while)
``` console
docker exec -it adb-rdi-casus_db_1 /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P yourStrong(!)Password -i /tmp/OdiseeDB.sql
```

Option 02:  
Use an IDE to connect to the database and run the OdibeeDB.sql file


### Installation with bak file
**Step 01:**
``` console
docker-compose up -d
```
Remember the name of the created container, in this case it's : adb-rdi-casus_db_1

**Step 02:**   
Extract the odisee.bak.zip file in the files/database folder. 
Now that we have the server up and running and the bak file extracted we have 2 options

``` console
docker cp files/database/odisee.bak adb-rdi-casus_db_1:/tmp/odisee.bak
```

**Step 03:**  
Option 01: Cli    
Import the sql into the Docker container (May take a while)
``` console
 docker exec -it adb-rdi-casus_db_1 /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P yourStrong(!)Password -Q "RESTORE DATABASE [odisee] FROM DISK = N'/tmp/odisee.bak' WITH FILE = 1, NOUNLOAD, REPLACE, NORECOVERY, STATS = 5"
```

Option 02:   
Use an IDE to connect to the database and run the odisee.bak file

### Planning
Week 17: 22 april t/m 28 april 2019
11. Onderwijsweek 11 (2019-17)	
11.1 RDI - Advanced SQL deel 3	

---------------
vakantie
Week 18: 29 april t/m 5 mei 2019
------------
Week 19: 6 mei t/m 12 mei 2019
12. Onderwijsweek 12 (2019-19)	
12.1 RDI - Transacties, Concurrency en Complex Constraints	

Week 20: 13 mei t/m 19 mei 2019
13. Onderwijsweek 13 (2019-20)	
13.1 RDI - Complexe constraints	

Week 21: 20 mei t/m 26 mei 2019
14. Onderwijsweek 14 (2019-21)	
14.1 RDI - Complexe constraints	

------- Alle opdrachten casus klaar

15. Onderwijsweek 15 (2019-22)	
15.1 RDI - Indexeren	

16. Onderwijsweek 16 (2019-23)	
16.1 RDI - Performance inzichten	

17. Onderwijsweek 17 (2018-24)	
17.1 Toets RDI	
17.2 Casus RDI <-------------------------------------------------------    

18. Onderwijsweek 18 (2018-25)	
18.1 Toets DDDQ (HER)	
18.2 Casus DDDQ (HER)	

19. Onderwijsweek 19 (2018-26)	
19.1 Casus RDT	




20. Onderwijsweek 20 (2019-27)	
20.1 Toets RDI (HER)	
20.2 Casus RDI (HER)	
20.3 Presentaties RDT	
21. Onderwijsweek 21 (2019-28)	
21.1 Presentaties RDT	
22. Onderwijsweek 22 (2019-34)	
22.1 Casus RDT (HER)



Week 16: 15 april t/m 21 april 2019



Joey:
Wk 17/18/19 werken aan casus en onderzoek (+extra vrij opnemen v/h werk)
Wk 20/21 op de zaterdagen bezet ivm vliegen
Wk 20 zondag afronden '80% versie' onderzoek
Wk 21 zondag afronden casus opdrachten



