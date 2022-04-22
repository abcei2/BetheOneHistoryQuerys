PRIMERO:
CREATEDOCENTEVIEW.sql
SEGUNDO:
correr el jar con las opciones correctas.
TECERO:
-BTO_LOCATION.sql
-BTO_SUBNIVEL.sql
-BTO_META_NACIONAL.sql






-------- DOCKER----------------------
mkdir /home/santi/oradata.
chmod -R a+w /home/santi/oradata

sudo docker run --name oracle21c -p 1521:1521 -p 5500:5500 -e ORACLE_PDB=orcl -e ORACLE_PWD=admin -e INIT_SGA_SIZE=3000 -e INIT_PGA_SIZE=1000 -v /home/santi/oradata/:/opt/oracle/oradata  oracle/database:21.3.0-ee


sudo docker exec -it {idContendor} bash
-----------------------------------
----------- DB -------------------------
export ORACLE_SID=ORCLCDB
sqlplus / AS SYSDBA
CREATE USER betheone IDENTIFIED BY betheone;
GRANT ALL PRIVILEGES TO betheone;
CREATE DIRECTORY dir_betheone_dmp as '/home/oracle/import/';
GRANT IMP_FULL_DATABASE TO betheone;


en el bash:
impdp betheone/betheone@orcl DIRECTORY=dir_betheone_dmp DUMPFILE=EXPDPBETHE.dmp LOGFILE=log_import.log SCHEMAS=BETHEONE

CREATE TABLESPACE TB_BETHEONE_DAT 
   DATAFILE '/home/oracle/betheone.dbf' 
   SIZE 100m;

---DROP DIRECTORY dir_betheone_dmp;
---DROP USER betheone CASCADE;