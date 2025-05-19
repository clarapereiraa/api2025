delimiter //

create procedure registrar_compra(
    in p_id_usuario int,
    in p_id_ingresso int,
    in p_quantidade int,
)
begin 
    declare v_id_compra int;
     declare v_data_evento datetime;

    --obtem a data do evento
    select e.data_hora into v_data_evento
    from ingresso i
    join evento e on i.fk_id_evento = e.id_evento
    where i.id_ingresso = p_id_ingresso;

    --verificar se a data do evento é menor que a atual
    if date(v_data_evento) < curdate() then
        signal sqlstate '45000'
        set message_text = 'ERRO_PROCEDURE - Não é possível comprar ingressos para evento passados.';
end if;

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

-- procedure para resumo do usuario
delimiter $$

create procedure resumo_usuario(in pid int)
begin 
    declare nome  varchar(100);
    declare email varchar(100);
    declare totalrs decimal(10, 2);
    declare faixa varchar(20);

    -- Buscar o nome e o email do usuário
    select u.name , u.email into nome, email 
    from usuario u
    where u.id_usuario = pid;

    -- Chamada das funções específicas já criadas 
    set totalrs = calcula_total_gasto(pid);
    set faixa = buscar_faixa_etaria_usuario(pid);

    -- Mostra os dados formatos
    select nome as nome_usuario,
           email as email_usuario,
           totalrs as total_gasto,
           faixa as faixa_etaria;
end; $$
delimiter ;

--  Total ingressos vendidos

delimiter $$

create function total_ingressos_vendidos(id_evento int)
returns int
not deterministic
begin
    declare total int;

    -- Calcula o total de ingressos vendidos para o evento
    select ifnull(sum(ic.quantidade), 0) into total
    from ingresso_compra ic
    join ingresso i on ic.fk_id_ingresso = i.id_ingresso
    where i.fk_id_evento = id_evento;

    return total;
end; $$

delimiter ;

-- Renda total evento 

delimiter $$

create function renda_total_evento(id_evento int)
returns decimal(10,2)
not deterministic
begin
    declare total decimal(10,2);

    -- Calcula a renda total do evento (preço * quantidade de ingressos vendidos)
    select ifnull(sum(i.preco * ic.quantidade), 0) into total
    from ingresso_compra ic
    join ingresso i on ic.fk_id_ingresso = i.id_ingresso
    where i.fk_id_evento = id_evento;

    return total;
end; $$

delimiter ;


-- Resumo evento

delimiter $$

create procedure resumo_evento(in id_evento int)
begin
    declare nome_evento varchar(100);
    declare data_hora date;  
    declare total_ingressos int;
    declare renda decimal(10,2);

    -- Buscar o nome e a data do evento
    select e.nome, e.data_hora into nome_evento, data_hora
    from evento e
    where e.id_evento = id_evento;

    -- Chamada das funções específicas já criadas
    set total_ingressos = total_ingressos_vendidos(id_evento);
    set renda = renda_total_evento(id_evento);

    -- Exibe os dados formatados
    select nome_evento as nome,
           data_hora as data,
           total_ingressos as ingressos_vendidos,
           renda as renda_total;
end; $$

delimiter ;

