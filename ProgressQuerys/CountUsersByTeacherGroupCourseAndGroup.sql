select count(usuario_id) cantidad,curso, grupo from(
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
where docente_id=:docenteId
group by curso, grupo;