### Carpetas

- **INITIAL:** Son los datos iniciales que se necesitan para montar la plataforma completamente desde 0, sin usuarios ni registros de progresos.
- **PRDO_INITIAL26042022:** Son los valores iniciales supuestamente posee la base de datos de certificación.
- **PROD_SCHEME18042022:** Supuesto esquema de la base de datos de certificación, (backup sin datos).
- **TEST:** Datos que se pueden utilizar para probar en el entorno prueba con el esquema y datos de certificación luego de agregar los datos iniciales, como para observar el comportamiento de las estadisticas calculadas.
- **CREATEDOCENTEVIEW.sql:** Vista que se debe crear antes que se actualice todo el esquema, esta es utilizada por el dashboard para "juntaR" la información de la tabla BTO_DOCENTE y la tabla BTOP_USUARIO_RESTFULL.

### Clona las imágenes de oracle
```bash
git clone https://github.com/oracle/docker-images
cd docker-images/OracleDatabase/SingleInstance/
```
### Compila la imagen
```bash
sudo ./buildContainerImage.sh -v 21.3.0 -e
```
### Corre la imagen con un volumen persistente
##### Crea el directorio donde se aloja la data del contenedor y dale permisos.  

```bash
mkdir /home/user/oradata.
chmod -R a+w /home/santi/oradata
```
##### Corre la imagen refierace a https://github.com/oracle/docker-images para entender las opciones
**LA PRIMERA VEZ NO EJECUTE EL DOCKER CON LA OPCIÓN DE "DETACH"**
```bash
sudo docker run --name oracle21c -p 1521:1521 -p 5500:5500 -e ORACLE_PDB=orcl -e ORACLE_PWD=admin -e INIT_SGA_SIZE=3000 -e INIT_PGA_SIZE=1000 -v /home/santi/oradata/:/opt/oracle/oradata  oracle/database:21.3.0-ee
```
### Volcado de base de datos
##### Clone el repositorio BetheOneHistory en la rama "grupo_docente".
```bash
git clone https://github.com/abcei2/BetheOneHistoryQuerys
cd BetheOneHistoryQuerys/
git checkout grupo_docente
```
##### Copie el esquema a una carpeta y luego al contenedor.
```bash
mkdir import/
cp BetheOneHistoryQuerys/BDDATA/PROD_SCHEME/* import/
sudo docker cp  import/ {idContendor}:/home/oracle
```
##### Conectese al contenedor por bash
```bash
sudo docker exec -it {idContendor} bash
```
##### Conectese a la base de datos dentro de la imagen como SYSDBA
```bash
export ORACLE_SID=ORCLCDB
sqlplus / AS SYSDBA
```
##### Cree el usuario betheone con permisos para importar una base de datos
```sql
CREATE USER betheone IDENTIFIED BY betheone;
GRANT ALL PRIVILEGES TO betheone;
GRANT IMP_FULL_DATABASE TO betheone;
```
##### Cree el directorio 
donde se busca la base de datos que se desea importar
```sql
CREATE DIRECTORY dir_betheone_dmp as '/home/oracle/import/';
```
##### Cree el espacio para la tabla
en este ejemplo se separan 100 mb para la prueba.
```sql
CREATE TABLESPACE TB_BETHEONE_DAT 
   DATAFILE '/home/oracle/betheone.dbf' 
   SIZE 100m;
```
##### Realize el volcado
Salimos de la consola de sqlplus y en el bash del contenedor ejecutamos:
```sql
impdp betheone/betheone@orcl DIRECTORY=dir_betheone_dmp DUMPFILE=EXPDPBETHE.dmp LOGFILE=log_import.log SCHEMAS=BETHEONE
```
##### Si debo repetir el proceso
- Eliminar el usuario ```DROP USER betheone CASCADE;```
- Eliminar el directorio ```DROP DIRECTORY dir_betheone_dmp;```
- Eliminar el espacio de la tabla ```DROP TABLESPACE TB_BETHEONE_DAT;```
- Eliminar el archivo '/home/oracle/betheone.dbf' que se encuentra dentro de el contenedor.
- Repetir los pasos anteriores.

### Consideraciones
Comparten esquema y datos iniciales de la base de datos de certificación se observa que:
- (PREOCUPACIÓN LEVE) COMPARTIERON INFORMACIÓN DE  TABLAS AUN SIN QUE EXISTIERAN EN EL ESQUEMA COMPARTIDO.
- NO EXISTEN LAS SIGUIENTES BASES DE DATOS EN EL ESQUEMA Q COMPARTIERON:
    - BTO_LOCATION.
    - BTO_LIMITCATEGORY.
    - BTO_SUBNIVEL.
- Debemos insertar una fila, pero podemos tirar el sql del archivo BTO_NIVELES.sql sin preocupación.

!!! REVISAR!!!!
***ORA-04098: el disparador 'BETHEONE.BTOP_USUARIOS_RESTFUL_TRG' no es vßlido y ha fallado al revalidar
Lo elimino y todo funciona pero eso viene con el esquema de ellos***
Al copíar el esquema, este trigger presenta problemas, ps no permite crear un usuario, la prueba se hace creando el usuario administrador, la solución temporal es eliminar el trigger y proceder con los demas pasos, así funciona correctamente el servidor de desarrollo con los datos y esquema de certificacion. Sin embargo existe breve preocupación por lo que pueda pasar en el entorno real.

### Actualizar backend del dashboard
Pullear rama feature-history y generar el archivo .jar actualizado.
```bash
./mvnw package spring-boot:repackage
```
Esto genera un archivo .jar en target/be-the-one-1.0.0-SNAPSHOT.jar, este archivo contiene el backend actualizado. Luego el archivo application.properties que debe tener la configuración del backend, tiene la opción spring.jpa.hibernate.ddl-auto, la cual debe tener como valor "update":
```java
spring.jpa.hibernate.ddl-auto=update //si está en none  -> pasarla a update.
```
Al hacerlo, cada que se corra el .jar (el backend) va a actualizar el esquema de base de datos.

### Configurar conexión a base de datos en el application.properties
SERVICE_NAME = orcl, depende de las opciones utilizadas para correr el contenedor, para el presente tutorial se uso orcl.
```java
spring.datasource.url=jdbc:oracle:thin:@//{oracle_db_host}:1521/orcl
spring.datasource.username=betheone
spring.datasource.password=betheone
```

### Pasos a seguir para actualizar entorno de certificación:

1. Crear la vista CREATEDOCENTEVIEW.
    - Ejecutar consulta CREATEDOCENTEVIEW.sql.
2. Correr el archivo .jar, con el application properties actualizado para que se actualice el esquema de la db.
    - ```bash java -jar be-the-one-1.0.0-SNAPSHOT.jar --spring.config.location=.\application.properties ```
3. Insertar información inicial, en el orden listado.
    - BTO_LOCATION.sql
    - BTO_NIVELES.
    - BTO_SUBNIVEL.sql
    - BTO_META_NACIONAL.sql
    - BTO_PERIODOS_ACADEMICOS.sql
