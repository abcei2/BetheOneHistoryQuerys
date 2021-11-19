insert into BTO_ROLES (nombre,role_id) values('Instituto',5);
commit;

alter table BTOP_USUARIOS_RESTFUL add COLEGIO_ID varchar(30) null;
commit;