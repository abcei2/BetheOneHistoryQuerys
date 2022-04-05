create table BTO_GRUPO_INSTITUCION(
    CLAVE NUMBER GENERATED BY DEFAULT AS IDENTITY,
    CURSO NUMERIC NOT NULL,
    GRUPO VARCHAR(10) NOT NULL,
    CODIGO_COLEGIO VARCHAR(30) not null,
    FECHA_REGISTRO TIMESTAMP (6) default CURRENT_TIMESTAMP,   
    PRIMARY KEY (CLAVE)
    );

ALTER TABLE BTO_GRUPO_INSTITUCION add CONSTRAINT BTO_GRUPO_INSTITUCION_UNIQUES UNIQUE (CURSO, GRUPO, CODIGO_COLEGIO);
commit;





-- DONT USE COMMENTS!

-- declare

-- GRUPO_VAL varchar2(20);  
-- BEGIN
--     FOR i IN 1..11 LOOP
--         FOR k IN 1..20 LOOP
--             IF k>=10 THEN
--                 :GRUPO_VAL := TO_CHAR(k);
--             ELSE
--                 :GRUPO_VAL := '0'||TO_CHAR(k);
--             END IF;    
--             INSERT INTO BTO_GRUPO_INSTITUCION
--             (CURSO, GRUPO, CODIGO_COLEGIO ) values(i,:GRUPO_VAL,'250001000531');
           
--         END LOOP;
--     END LOOP;
-- END;

   
