create table BTO_META_DOCENTE(
    CLAVE NUMBER GENERATED BY DEFAULT AS IDENTITY,
    CURSO INTEGER NOT NULL,
    DOCENTE_ID INTEGER NOT NULL,
    SUBNIVEL_ID VARCHAR(10) not null,
    SUBNIVEL_INICIAL VARCHAR(10) not null,--FILL BY DOCENTE
    META VARCHAR(10) default 'NOLVL',--APP COURSE GOAL LEVEL
    HORAS_SEMANAL numeric default 0,--FILL BY DOCENTE
    PRIMARY KEY (CLAVE)
);

--ALTER TABLE BTO_GRUPO_DOCENTE DROP CONSTRAINT BTO_GRUPO_DOCENTE_UNIQUES;
ALTER TABLE BTO_META_DOCENTE add CONSTRAINT BTO_META_DOCENTE_UNIQUES UNIQUE (CURSO, DOCENTE_ID);



commit;

