--GET ALL USERS WHO REACH THE COURSE GOAL OF A TEACHER
-- TEACHER WHO DON'T HAVE REGISTERS ON BTO_CURSO_DOCENTE DO NOT APPEAR IN RESULTS


    
select sum(cantidad) cantidad , max(goals.prioridad),main_table.curso, main_table.grupo,main_table.prioridad, meta from (
select CASE WHEN cantidad_users is null THEN 0 ELSE cantidad_users END cantidad, 
nivel.clave, nivel.prioridad, curso, grupo 
from BTO_NIVELES nivel
left join 
(
   -- TO COUNT ALL USERS PER LVL, ADDING USERS WHICH HAS NO WIN A LEVEL AS 'NO LEVEL' USER
   select  count(usuario_id) cantidad_users, max_prio, curso, grupo from 
   ( 
      select user1.usuario_id usuario_id, 
      CASE WHEN max_prio is null then 0 else max_prio end max_prio,
      user_selecter.curso curso, user_selecter.grupo grupo
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
            where fecha between :lowLvlDate and :highLvlDate              
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
        select usuario_id, curso, grupo from(
            select ROW_NUMBER() OVER (ORDER BY max(docente.id)  desc) id, 
            CASE WHEN docente.id is null THEN 0 ELSE docente.id END docente_id,  
            user1.usuario_id usuario_id,  
            max(user1.codigo_colegio) codigo_colegio,
            max(user1.CODIGO_SECRETARIA) CODIGO_SECRETARIA,
            ltrim(user1.curso, '0') curso,
            user1.grupo grupo    
            from BTO_USUARIO user1 
            LEFT JOIN BTO_DOCENTE  docente ON user1.codigo_colegio= docente.codigo_dane_est
            LEFT JOIN BTO_GRUPO_DOCENTE curso ON curso.docente_id= docente.id         
            -- TAKES ONLY STUDENTS WITH THE SAME COURSE AS TEACHER 
            --(STUDENTS IN TEACHER COURSE) OR STUDENTS WITHOUT TEACHER
            where (ltrim(user1.curso, '0')=TO_CHAR(curso.curso) and user1.grupo=TO_CHAR(curso.grupo)) 
            or docente.codigo_dane_est is null          
            group by  docente.id, user1.usuario_id, user1.grupo, user1.curso
         )
                           
------------------
-- CONDICTION SECTION!
      --  where docente_id= :docenteId
      where codigo_colegio= :codigoColegio
------------------ 
-- START THIRDH PART
         group by usuario_id, curso, grupo
     ) user_selecter on user_selecter.usuario_id=user1.usuario_id
   ) 
   group by max_prio, curso, grupo
)
on nivel.prioridad = max_prio 
where curso is not null and grupo is not null order by curso, grupo, nivel.clave
) main_table
left join(
-- LEFT JOIN PARA OBTENER LA META DE CADA CURSO Y GRUPO, EL PRIMERO SE USA PARA DOCENTE
-- EL SEGUNDO PA INSTITUCION

----------------------
   ---DOCENTE---
   select TO_CHAR(grupo.curso) curso, grupo.grupo grupo, meta, prioridad 
   from  BTO_GRUPO_DOCENTE grupo
   inner join BTO_META_DOCENTE meta_docente on meta_docente.docente_id=grupo.docente_id 
   and grupo.curso=meta_docente.curso 
   inner join BTO_NIVELES nivel on nivel.CLAVE=meta_docente.meta
   where grupo.docente_id= :docenteId
   order by grupo.curso, grupo.grupo   

   ---INSTITUCION---
   select TO_CHAR(grupo_institucion.curso) curso, grupo_institucion.grupo grupo, meta, prioridad 
   from  BTO_GRUPO_INSTITUCION grupo_institucion 
   inner join BTO_META_INSTITUCION meta_institucion on meta_institucion.codigo_colegio=grupo_institucion.codigo_colegio
   and grupo_institucion.curso=meta_institucion.curso 
   inner join BTO_NIVELES nivel on nivel.CLAVE=meta_institucion.meta
   where grupo_institucion.codigo_colegio= :schoolCode
   order by grupo_institucion.curso, grupo_institucion.grupo;
       
--------------------------
--FOURTH PART
) goals on goals.curso=main_table.curso 
and goals.grupo=main_table.grupo
where main_table.prioridad>=goals.prioridad
group by main_table.curso, main_table.grupo,main_table.prioridad, meta;    