delimiter //

create procedure registrar_compra(
    in p_id_usuario int,
    in p_id_ingressos int,
    in p_quantidade int
)
begin
    declare v_id_compra int;
    declare v_data_evento datetime;

    select e.data_hora into v_data_evento
    from ingresso i
    join evento e on i.fk_id_evento = e.id_evento
    where i.id_ingresso = p_id_ingressos;

    if date(v_data_evento) < curdate() then
        signal sqlstate '45000'
        set message_text = 'ERRO_PROCEDURE - não é possível comprar ingressos para eventos passados.';
    end if;

    insert into compra (data_compra, fk_id_usuario)
    values (now(), p_id_usuario);

    set v_id_compra = last_insert_id();

    insert into ingresso_compra (fk_id_compra, fk_id_ingresso, quantidade)
    values (v_id_compra, p_id_ingressos, p_quantidade);

end
//

delimiter ;

