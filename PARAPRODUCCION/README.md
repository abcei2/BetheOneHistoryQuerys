### Introducción
La presente guía breve pretende explicar los pasos a seguir para actualizar el entorno de certificación de betheone.

### Consideraciones
Comparten esquema y datos iniciales de la base de datos de certificación se observa que:
- (PREOCUPACIÓN LEVE) COMPARTIERON INFORMACIÓN DE  TABLAS AUN SIN QUE EXISTIERAN EN EL ESQUEMA COMPARTIDO.
- NO EXISTEN LAS SIGUIENTES BASES DE DATOS EN EL ESQUEMA Q COMPARTIERON:
    - BTO_LOCATION.
    - BTO_LIMITCATEGORY.
    - BTO_SUBNIVEL.

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



