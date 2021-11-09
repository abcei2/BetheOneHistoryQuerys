select count(usuario_id) cantidad,avg(desempeno) desempeno, mision_clave, nivel_clave from
( 
   select distinct(user1.usuario_id) usuario_id, 
   minigames.mision_clave mision_clave, 
   progreso.nivel_clave nivel_clave,
   CASE WHEN minigames_ammount=count(distinct(minigame_clave)) THEN 1 ELSE 0 END pass_mission,
   SUM(CORRECTAS)*100/SUM(CORRECTAS+INCORRECTAS+NO_CONTESTADAS) desempeno,
   CASE WHEN docente.id is null THEN 0 ELSE docente.id END docente_id,  
   max(user1.codigo_colegio) codigo_colegio,
   max(user1.CODIGO_SECRETARIA) CODIGO_SECRETARIA,
   curso.curso curso,
   curso.grupo grupo          
   from BTO_PROGRESO progreso
   inner join bto_minigames minigames on minigames.clave=progreso.minigame_clave
   inner join ( 
            select mision_clave, 
            count(clave) minigames_ammount 
            from bto_minigames group by mision_clave
   ) missions on missions.mision_clave=minigames.mision_clave  

   LEFT JOIN BTO_USUARIO user1 on user1.usuario_id=progreso.usuario_id
   LEFT JOIN BTO_DOCENTE  docente ON user1.codigo_colegio= docente.codigo_dane_est
   LEFT JOIN BTO_GRUPO_DOCENTE curso ON curso.docente_id= docente.id         
    
   where (
      (ltrim(user1.curso, '0')=TO_CHAR(curso.curso) and user1.grupo=curso.grupo) 
      or docente.codigo_dane_est is null
   ) and puntaje>=77
   -- END FIRST PART
   ---     and progreso.fecha between :lowProgressDate:
   -- START SECOND  PART      
   group by user1.usuario_id, minigames.mision_clave,
   minigames_ammount, progreso.nivel_clave,
   docente.id,user1.grupo, curso.grupo, curso.curso
) 
where pass_mission=1 
-- END SECOND PART
 -- and docente_id=16070 and curso=11 group by nivel_clave, mision_clave;
 
 group by mision_clave, nivel_clave ;

