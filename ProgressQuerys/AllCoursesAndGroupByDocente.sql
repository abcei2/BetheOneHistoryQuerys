
select grupo.curso curso, grupo.grupo grupo
from  BTO_GRUPO_DOCENTE grupo
where grupo.docente_id=:docenteId 
order by grupo.curso, grupo.grupo;