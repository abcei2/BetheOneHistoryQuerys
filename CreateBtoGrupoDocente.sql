create table BTO_GRUPO_DOCENTE(
    CLAVE NUMBER GENERATED BY DEFAULT AS IDENTITY,
    CURSO NUMERIC NOT NULL,
    GRUPO VARCHAR(10) NOT NULL,
    DOCENTE_ID NUMERIC NOT NULL,
    FECHA_REGISTRO TIMESTAMP (6) default CURRENT_TIMESTAMP,   
    PRIMARY KEY (CLAVE)
    );

ALTER TABLE BTO_GRUPO_DOCENTE DROP CONSTRAINT BTO_GRUPO_DOCENTE_UNIQUES;
ALTER TABLE BTO_GRUPO_DOCENTE add CONSTRAINT BTO_GRUPO_DOCENTE_UNIQUES UNIQUE (CURSO, GRUPO, DOCENTE_ID);

INSERT INTO BTO_GRUPO_DOCENTE
(CURSO, GRUPO, DOCENTE_ID )
select CURSO, GRUPO,DOCENTE_ID from(
    SELECT CURSO, '01' as GRUPO, DOCENTE_ID
    FROM BTO_CURSO_DOCENTE group by CURSO, DOCENTE_ID 
    FETCH FIRST 20000 ROWS ONLY -- I don't know why this is needed but whithout this, query doesnwork on insert.
);  
