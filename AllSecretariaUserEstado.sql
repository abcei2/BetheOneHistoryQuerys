select  count(usuario_id) cantidad, user_selecter.codigo_secretaria1 codigo_secretaria,
nombre_secretaria, case when estado is null then 'Inactive' else estado end ESTADO from
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
     select usuario_id, codigo_secretaria1, nombre_secretaria from
    (   
        select 
         user1.usuario_id usuario_id,  user1.codigo_secretaria codigo_secretaria1,
         BTO_SECRETARIA.nombre nombre_secretaria
         from BTO_USUARIO user1 
         join BTO_SECRETARIA on BTO_SECRETARIA.clave=user1.codigo_secretaria
         group by  user1.usuario_id,  user1.codigo_secretaria, BTO_SECRETARIA.nombre
    )          
    group by  usuario_id, codigo_secretaria1, nombre_secretaria
) user_selecter on user_selecter.usuario_id=usuario_id2
group by  estado,user_selecter.codigo_secretaria1, nombre_secretaria  order by user_selecter.codigo_secretaria1;