-- La cantidad de usuarios en un nivel en cada misión dado un curso, un docente, una secretaria o institución.
-- START FIRST PART
select count(usuario_id) cantidad, nivel.clave, AVG(desempeno) desempeno_promedio, mision_clave from BTO_NIVELES nivel
left join (
    select user_lvls.usuario_id, max_prio, mision_clave, desempeno from 
    (
       
       select  usuario_id, max(max_prio) max_prio from 
       ( 
          select user1.usuario_id usuario_id, CASE WHEN max_prio is null then 0 else max_prio end max_prio
          from BTO_USUARIO user1
    
          left join 
          (   -- SELECT THE MOST HIGH PRIORITY LVL THAT USER WON 
             select usuario_id, CASE WHEN  max(prioridad) is null THEN 0 ELSE max(prioridad) END max_prio from 
             (
                -- SELECT JUST WIN LVLS
                select usuario_id, prioridad 
                from 
                (      
                  select 
                  --ASK WHICH USERS WINS OR NOT IN WHICH LEVEL
                  ( 
                     CASE WHEN prioridad is null or sum(CASE WHEN num_wins>0 THEN 1 ELSE 0 END)>=(select count(*) from BTO_MINIGAMES)
                     THEN 1 ELSE 0 END 
                  )win, 
                  usuario_id, prioridad
                  from
                  (
                  ---FIND USERS AND COUNT HOW MUCH WINS PER LVL PER MINIGAME
                  select  user1.usuario_id, sum(CASE WHEN puntaje>=77 THEN 1 ELSE 0 END) num_wins,
                  nivel_clave, minigame_clave, prioridad
                  from bto_usuario user1
                  left join BTO_PROGRESO progreso on user1.usuario_id= progreso.usuario_id
                  left join BTO_NIVELES nivel on nivel.clave = progreso.nivel_clave
-- END FIRST PART                  
            --where fecha between 'fecha1' and 'fecha2'
-- START SECOND PART
                  group by user1.usuario_id, nivel_clave, minigame_clave, prioridad
                  )
                  info 
                  group by usuario_id,prioridad
                ) 
                where win = 1
             ) 
             group by usuario_id
          ) info on user1.usuario_id = info.usuario_id
         inner join (
            select * from(
               select ROW_NUMBER() OVER (ORDER BY max(docente.id)  desc) id, 
               CASE WHEN docente.id is null THEN 0 ELSE docente.id END docente_id,  
               user1.usuario_id usuario_id,  
               max(user1.codigo_colegio) codigo_colegio,
               max(user1.CODIGO_SECRETARIA) CODIGO_SECRETARIA,
               curso.curso curso,
               curso.grupo grupo          
               from BTO_USUARIO user1 
               LEFT JOIN BTO_DOCENTE  docente ON user1.codigo_colegio= docente.codigo_dane_est
               LEFT JOIN BTO_GRUPO_DOCENTE curso ON curso.docente_id= docente.id         
               -- TAKES ONLY STUDENTS WITH THE SAME COURSE AS TEACHER 
               --(STUDENTS IN TEACHER COURSE) OR STUDENTS WITHOUT TEACHER
               where (ltrim(user1.curso, '0')=TO_CHAR(curso.curso) and substr(user1.grupo,3,4)=curso.grupo) --TEMPORAL SUBSTR 
               or docente.codigo_dane_est is null          
               group by  docente.id, user1.usuario_id,user1.grupo, curso.grupo, curso.curso
            ) 
-- END SECOND PART  
   -- CONDICIONES por ; docente.id = xx, curso.curso=xx, user1.codigo_colegio=xxxx, user1.codigo_secretaria=xxx, ej;
   -- where docente.id= 16070      
-- START THIRD PART  
         ) user_selecter on user_selecter.usuario_id=user1.usuario_id
       ) 
       group by usuario_id
    ) user_lvls
    inner join(
       select distinct(usuario_id) usuario_id, 
         minigames.mision_clave mision_clave, 
         CASE WHEN minigames_ammount=count(distinct(minigame_clave)) THEN 1 ELSE 0 END pass_mission,
         SUM(CORRECTAS)*100/SUM(CORRECTAS+INCORRECTAS+NO_CONTESTADAS) desempeno
         from BTO_PROGRESO progreso
         inner join bto_minigames minigames on minigames.clave=progreso.minigame_clave
         inner join ( 
                  select mision_clave, 
                  count(clave) minigames_ammount 
                  from bto_minigames group by mision_clave
         ) missions on missions.mision_clave=minigames.mision_clave        
-- END THIRD PART  
---     where fecha_progreso between :lowProgressDate:
-- START FOURTH PART      
         group by usuario_id, minigames.mision_clave,minigames_ammount
    ) byminigame on byminigame.usuario_id = user_lvls.usuario_id
    where pass_mission=1    
) on nivel.prioridad = max_prio
group by nivel.clave,mision_clave;

-- END FOURTH PART  











