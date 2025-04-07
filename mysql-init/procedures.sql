delimiter //

create procedure registrar_compra(
    in p_id_usuario int,
    in p_id_ingresso int,
    in p_quantidade int,
)
begin 
    declare v_id_compra int;

    --Criar resgistro na tabele 'compra'
    insert into compra (data_compra, fk_id_usuario)
    values (now(), p_is_usuario);

    --Obter o ID compra recem-criada
    set v_id_compra = last_insert_id();

    --Registrar os ingressos comprados
    insert into ingresso_compra (fk_id_compra, fk_id_ingresso, quantidade)
    values (v_id_compra, p_id_ingresso, p_quantidade);

    end; //

    delimiter ;

delimiter //

create procedure total_ingressos_usuario(
    in p_id_usuario int,
    out p_total_ingressos int
)
begin
    -- Inicializar o valor de saída
    set p_total_ingressos = 0;

    --Consultar e somar todos os ingressos comprados pelos usuário
    select coalesce(sum(ic.quantidade), 0)
    into p_total_ingressos
    from ingresso_compra ic
    join compra c on ic.fk_id_compra = c.id_compra
    where c.fk_id_usuario = p_id_usuario;
end; //

delimiter ;

show procedure status where db = 'vio_clara';

set @total = 0;

call total_ingressos_usuario (2, @total);

delimiter //

create procedure registrar_presenca(
    in p_id_compra int,
    in p_id_evento int
)
begin
    insert into presenca(data_hora_checkin, fk_id_evento, fk_id_compra)
    values (now(), p_id_evento, p_id_compra);
end; //

delimiter ; 

call registrar_presenca(1, 3);

