

--CREAR NUEVA COLUMNA META PARA LA TABLA QUE RELACIONA AL CURSO Y EL DOCENTE
alter table BTO_CURSO_DOCENTE add META varchar(10) default 'NOLVL';

update BTO_CURSO_DOCENTE set  META= 'PREA1' where curso=4;
update BTO_CURSO_DOCENTE set  META= 'PREA1' where curso=5;
update BTO_CURSO_DOCENTE set  META= 'A1' where curso=6;
update BTO_CURSO_DOCENTE set  META= 'A2' where curso=7;
update BTO_CURSO_DOCENTE set  META= 'A2' where curso=8;
update BTO_CURSO_DOCENTE set  META= 'B1' where curso=9;
update BTO_CURSO_DOCENTE set  META= 'B1' where curso=10;
update BTO_CURSO_DOCENTE set  META= 'B1' where curso=11;