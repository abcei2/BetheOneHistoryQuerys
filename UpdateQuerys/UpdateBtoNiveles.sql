alter table BTO_NIVELES add PRIORIDAD number default 0;

update BTO_NIVELES set prioridad=1 where CLAVE = 'PREA1' ;
update BTO_NIVELES set prioridad=2 where CLAVE = 'A1' ;
update BTO_NIVELES set prioridad=3 where CLAVE = 'A2' ;
update BTO_NIVELES set prioridad=4 where CLAVE = 'B1' ;