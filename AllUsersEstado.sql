 --select count(usuario_id), estado
 --START FIRST PART
 select * from (    
     select usuario_id, 
     correo,  primer_nombre, segundo_nombre, 
     primer_apellido,segundo_apellido, 
     tipo_documento, documento, ultima_conexion,
     case when estado is null then 'Inactive' else estado end estado
     from
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
     --   where fecha between '14/05/27 06:20:19PM' and '09/06/27 11:42:23AM'
    -- START SECOND PART
        group by  user1.usuario_id
         
    ) 
    right join (
        select usuario_id, 
            correo,primer_nombre, segundo_nombre,
            primer_apellido,segundo_apellido,tipo_documento, documento, ultima_conexion 
            from(
             select ROW_NUMBER() OVER (ORDER BY max(docente.id)  desc) id, 
             CASE WHEN docente.id is null THEN 0 ELSE docente.id END docente_id,  
             user1.usuario_id usuario_id,  
             max(user1.codigo_colegio) codigo_colegio,
             max(user1.CODIGO_SECRETARIA) CODIGO_SECRETARIA,
             curso.curso curso,
             curso.grupo grupo,          
             
             correo, primer_nombre, segundo_nombre,
             primer_apellido,segundo_apellido,
             user1.tipo_documento tipo_documento, documento,
             max(progreso.fecha) ultima_conexion
             
             from BTO_USUARIO user1 
             LEFT JOIN BTO_DOCENTE  docente ON user1.codigo_colegio= docente.codigo_dane_est
             LEFT JOIN BTO_GRUPO_DOCENTE curso ON curso.docente_id= docente.id    
             LEFT JOIN BTO_PROGRESO progreso on progreso.usuario_id = user1.usuario_id
             -- TAKES ONLY STUDENTS WITH THE SAME COURSE AS TEACHER 
             --(STUDENTS IN TEACHER COURSE) OR STUDENTS WITHOUT TEACHER
             where (ltrim(user1.curso, '0')=TO_CHAR(curso.curso) and user1.grupo=curso.grupo) 
             or docente.codigo_dane_est is null          
             group by  docente.id, user1.usuario_id,user1.grupo, curso.grupo, curso.curso,
             primer_nombre, segundo_nombre,primer_apellido,
             segundo_apellido, correo, user1.tipo_documento,documento 
          )      
  
    -- END SECOND PART
       -- CONDICIONES por ; docente.id = xx, curso.curso=xx, user1.codigo_colegio=xxxx, user1.codigo_secretaria=xxx, ej;
    
    -- START LAST PART
        group by  usuario_id,
        primer_nombre, segundo_nombre,primer_apellido,
        segundo_apellido,correo, tipo_documento, documento, ultima_conexion
    ) user_selecter on user_selecter.usuario_id=usuario_id2
)
-- where estado='Inactive'
--group by estado ;








