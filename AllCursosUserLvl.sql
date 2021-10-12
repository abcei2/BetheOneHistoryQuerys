
-- La cantidad de usuarios en un nivel en cada curso dado un docente, una secretaria o institución.
-- START FIRST PART
select CASE WHEN cantidad_users is null THEN 0 ELSE cantidad_users END, 
nivel.clave, curso 
from BTO_NIVELES nivel
left join 
(
   -- TO COUNT ALL USERS PER LVL, ADDING USERS WHICH HAS NO WIN A LEVEL AS 'NO LEVEL' USER
   select  count(usuario_id) cantidad_users, max_prio, curso from 
   ( 
      select user1.usuario_id usuario_id, 
      CASE WHEN max_prio is null then 0 else max_prio end max_prio,
      user_selecter.curso curso
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
        select usuario_id, curso from(
            select ROW_NUMBER() OVER (ORDER BY max(docente.id)  desc) id, 
            CASE WHEN docente.id is null THEN 0 ELSE docente.id END docente_id,  
            user1.usuario_id usuario_id,  
            max(user1.codigo_colegio) codigo_colegio,
            max(ltrim(user1.curso, '0')) curso,
            user1.grupo grupo, 
            max(user1.CODIGO_SECRETARIA) CODIGO_SECRETARIA
            from BTO_USUARIO user1 
            LEFT JOIN BTO_DOCENTE  docente ON user1.codigo_colegio= docente.codigo_dane_est
            LEFT JOIN BTO_CURSO_DOCENTE curso ON curso.docente_id= docente.id
            where ltrim(user1.curso, '0')=TO_CHAR(curso.curso) or docente.codigo_dane_est is null 
            group by  docente.id, user1.usuario_id, grupo, curso.curso
         )
                           
-- END SECOND PART
   -- CONDICIONES por ; docente.id = xx, curso.curso=xx, user1.codigo_colegio=xxxx, user1.codigo_secretaria=xxx, ej;
   -- where docente.id= 16070    
-- START LAST PART
         group by usuario_id, curso  
     ) user_selecter on user_selecter.usuario_id=user1.usuario_id
   ) 
   group by max_prio, curso
)

on nivel.prioridad = max_prio where curso is not null order by curso ;

-- END LAST PART