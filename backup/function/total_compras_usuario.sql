delimiter $$
create function total_compras_usuario(id_usuario int)
returns int
reads sql data
begin 
    declare total int;

    select count(*) into total
    from compra
    where id_usuario = compra.fk_id_usuario;

    return total;
end; $$
delimiter ; 

select total_compras_usuario(2) as 'Total de compras';