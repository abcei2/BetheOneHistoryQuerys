 select  count(usuario_id) cantidad, departamento,  case when estado is null then 'Inactive' else estado end ESTADO from
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
  --  where fecha between '14/05/19 06:20:19PM' and '09/06/27 11:42:23AM'

-- START SECOND PART
    group by  user1.usuario_id
) 
right join (
     select usuario_id, departamento from
    (
         select
        user1.usuario_id usuario_id,  departamentos.NOMBRE departamento
        from BTO_USUARIO user1 
        join BTO_SECRETARIA secretaria on secretaria.clave=user1.codigo_secretaria
                 
        inner join BTO_LOCATION location1 on location1.codigo_secretaria = secretaria.clave
        inner join BTO_DEPARTAMENTOS departamentos on departamentos.CODIGO=location1.DEPARTAMENTO_CODIGO

        group by  user1.usuario_id, departamentos.NOMBRE
    )          
    group by  usuario_id, departamento 
) user_selecter on user_selecter.usuario_id=usuario_id2
group by  estado,departamento;