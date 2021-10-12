
 select  count(usuario_id), 
 case when estado is null then 'Inactive' else estado end from
(
         
    select  user1.usuario_id usuario_id2, count(user1.usuario_id), 
    (
         CASE WHEN count(user1.usuario_id) >= 8 THEN 'Active'
         WHEN count(user1.usuario_id) < 8 AND count(user1.usuario_id)>= 1 THEN 'Pasive' 
         ELSE 'Inactive' END
    ) estado
    from bto_usuario user1
    inner join BTO_PROGRESO progreso on user1.usuario_id= progreso.usuario_id

-- END FIRST PART
    --where fecha between '14/05/19 06:20:19PM' and '09/06/27 11:42:23AM'

-- START SECOND PART
    group by  user1.usuario_id
) 
right join (
    select usuario_id from(
         select ROW_NUMBER() OVER (ORDER BY max(docente.id)  desc) id, 
         CASE WHEN docente.id is null THEN 0 ELSE docente.id END docente_id,  
         user1.usuario_id usuario_id,  
         max(user1.codigo_colegio) codigo_colegio,
         max(user1.CODIGO_SECRETARIA) CODIGO_SECRETARIA,
         curso.curso curso,
         curso.grupo grupo          
         from BTO_USUARIO user1 
         LEFT JOIN BTO_DOCENTE  docente ON user1.codigo_colegio= docente.codigo_dane_est
         LEFT JOIN BTO_GRUPO_DOCENTE1 curso ON curso.docente_id= docente.id         
         -- TAKES ONLY STUDENTS WITH THE SAME COURSE AS TEACHER 
         --(STUDENTS IN TEACHER COURSE) OR STUDENTS WITHOUT TEACHER
         where (ltrim(user1.curso, '0')=TO_CHAR(curso.curso) and substr(user1.grupo,3,4)=curso.grupo) --TEMPORAL SUBSTR 
         or docente.codigo_dane_est is null          
         group by  docente.id, user1.usuario_id,user1.grupo, curso.grupo, curso.curso
      )       
-- END SECOND PART
   -- CONDICIONES por ; docente.id = xx, curso.curso=xx, user1.codigo_colegio=xxxx, user1.codigo_secretaria=xxx, ej;

-- START LAST PART
    group by  usuario_id
) user_selecter on user_selecter.usuario_id=usuario_id2 group by  estado;










