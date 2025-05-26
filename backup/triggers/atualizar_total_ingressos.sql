delimiter //

create trigger atualizar_total_ingressos
after insert on ingresso_compra
for each row
begin
    declare v_id_evento int;
    declare v_quantidade int;

    -- buscar o evento do ingresso comprado
    select i.fk_id_evento into v_id_evento
    from ingresso i
    where i.id_ingresso = new.fk_id_ingresso;

    set v_quantidade = new.quantidade;

    -- verificar se o evento já está no resumo
    if exists (
        select 1 from resumo_evento where id_evento = v_id_evento
    ) then
        update resumo_evento
        set total_ingressos = total_ingressos + v_quantidade
        where id_evento = v_id_evento;
    else
        insert into resumo_evento (id_evento, total_ingressos)
        values (v_id_evento, v_quantidade);
    end if;
end; //

delimiter ;

-- criação da tabela resuma_evento
create table resumo_evento (
    id_evento int primary key,
    total_ingressos int not null,
    foreign key (id_evento) references evento(id_evento)
);

insert into evento (nome, descricao, data_hora, local, fk_id_organizador)
values ('alvar', 'festa eletronica', '2025-05-30 00:00:00', 'olhos d agua', 3);

insert into ingresso (preco, tipo, fk_id_evento)
values (500.00, 'vip', 5);

insert into ingresso (preco, tipo, fk_id_evento)
values (300.00, 'pista', 5);

ip: 10.89.240.66