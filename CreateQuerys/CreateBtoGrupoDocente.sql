create table BTO_GRUPO_DOCENTE(
    CLAVE NUMBER GENERATED BY DEFAULT AS IDENTITY,
    CURSO NUMERIC NOT NULL,
    GRUPO VARCHAR(10) NOT NULL,
    DOCENTE_ID NUMERIC NOT NULL,
    FECHA_REGISTRO TIMESTAMP (6) default CURRENT_TIMESTAMP,   
    PRIMARY KEY (CLAVE)
    );

ALTER TABLE BTO_GRUPO_DOCENTE add CONSTRAINT BTO_GRUPO_DOCENTE_UNIQUES UNIQUE (CURSO, GRUPO, DOCENTE_ID);


-- DONT USE COMMENTS!

-- declare

-- GRUPO_VAL varchar2(20);  
-- BEGIN
--     FOR i IN 1..20 LOOP
--         IF i>=10 THEN
--             :GRUPO_VAL := TO_CHAR(i);
--         ELSE
--             :GRUPO_VAL := '0'||TO_CHAR(i);
--         END IF;    
--         INSERT INTO BTO_GRUPO_DOCENTE
--         (CURSO, GRUPO, DOCENTE_ID )
--         SELECT CURSO, :GRUPO_VAL as GRUPO, DOCENTE_ID
--         FROM BTO_CURSO_DOCENTE group by CURSO, DOCENTE_ID 
--         FETCH FIRST 20000 ROWS ONLY; -- I don't know why this is needed but whithout this, query doesnwork on insert.
--       END LOOP;
-- END;

-- commit



