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