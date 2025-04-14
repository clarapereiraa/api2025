--Criação de function
DELIMITER $$
CREATE FUNCTION calcula_idade(datanascimento DATE)
RETURNS INT
DETERMINISTIC
CONTAINS SQL
BEGIN
    DECLARE idade INT;
    SET idade = TIMESTAMPDIFF(YEAR, datanascimento, CURDATE());
    RETURN idade;
END $$
DELIMITER ;


--Verifica se a função especificada foi cirada
show create function calcula_idade;

select name, calcula_idade(data_nascimento) as idade from usuario;

delimiter $$
create function status_sistema()
returns varchar(50)
no sql 
begin
    return 'Sistema operando normalmente';
end; $$
delimiter ;

--execução da query
select status_sistema();

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

--Tabela para criar clausula mofifiles data
create table log_evento(
    id_log int AUTO_INCREMENT PRIMARY KEY,
    mensagem varchar(255),
    data_log datetime DEFAULT current_timestamp
);

delimiter $$
create function registrar_log_evento(texto varchar(255))
returns varchar(50)
deterministic
modifies sql data
begin 
    insert into log_evento(mensagem)
    values(texto);

    return 'Log inserido com sucesso';
end; $$
delimiter ; 

show create function registrar_log_evento;

drop function registrar_log_evento;

delimiter $$
create function registrar_log_evento(texto varchar(255))
returns varchar(50)
not deterministic
modifies sql data
begin 
    insert into log_evento(mensagem)
    values(texto);

    return 'Log inserido com sucesso';
end; $$
delimiter ; 

--ve o estado da variavel de controle para permissoes de criação de funções
show variables like 'log_bin_trust_function_creators';

---altera variavel global do mysql
--precisa ter permissoes de admistrador do banco
set global log_bin_trust_function_creators = 1;

select registrar_log_evento('teste');

delimiter $$

create function mensagem_boas_vindas(nome_usuario varchar(100))
returns varchar(255)
deterministic
contains sql 
begin
    declare msg varchar(255);
    set msg = concat('Olá,' nome_usuario, '! Seja bem-vindo(a) ao sistema VIO')
    return msg;
end; $$

delimiter ;

select routine_name from
information_schema.routines
where routine_type = 'FUNCTION'
and routine_schema = 'vio_clara';

-- maior idade 
delimiter $$

create function is_maior_idade(data_nascimento date)
returns boolean
not deterministic
contains sql
begin
    declare idade int;
    -- utilizando a outra function já criada
    set idade = calcula_idade(data_nascimento);
    return idade >= 18;
end; $$

delimiter ;

-- categorizar usuarios por faixa etária

delimiter $$

create function faixa_etaria(data_nascimento date)
returns varchar(20)
not deterministic
contains sql
begin 
    declare idade int;

    -- cálculo da idade com a função já criada
    set idade = calcula_idade(data_nascimento);

    if idade < 18 then 
        return "menor de idade";
    elseif idade < 60 then 
        return "adulto";
    else
        return "idoso";
    end if;
end; $$

delimiter ; 

-- agrupar usuários por faixa etária
select faixa_etaria(data_nascimento) as faixa, count(*) as quantidade from usuario
group by faixa;

-- identificar uma faixa etária específica 
select name from usuario 
    where faixa_etaria(data_nascimento) = "adulto";

-- calcular a média de idade de usuário
delimiter $$
create function media_idade()
returns decimal(5,2)
not deterministic
reads sql data
begin 
    declare media decimal(5,2);

    -- calculo da media das idades 
    select avg(TIMESTAMPDIFF(year, data_nascimento, CURDATE())) into media from usuario;

    return ifnull(media, 0);
end; $$

delimiter ;

-- selecionar idade específica
select "A média dd idade dos clientes é maior que 30" as resultados where media_idade() > 30;

-- Exercício direcionado
-- cálculo do total gasto por um usuário
DELIMITER $$

CREATE FUNCTION calcula_total_gasto(pid_usuario INT)
RETURNS DECIMAL(10, 2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN 
    DECLARE total DECIMAL(10, 2);

    SELECT SUM(i.preco * ic.quantidade) 
    INTO total
    FROM compra c
    JOIN ingresso_compra ic ON c.id_compra = ic.fk_id_compra
    JOIN ingresso i ON i.id_ingresso = ic.fk_id_ingresso
    WHERE c.fk_id_usuario = pid_usuario;

    RETURN IFNULL(total, 0);
END$$

DELIMITER ;

-- buscar a faixa etaria de um usuario
delimiter $$
create function buscar_faixa_etaria_usuario(pid int)
returns varchar(20)
not deterministic
reads sql data
begin
    declare nascimento date;
    declare faixa varchar(20);
    
    select data_nascimento into nascimento
    from usuario
    where id_usuario = pid;

    set faixa = faixa_etaria(nascimento);

    return faixa;
end; $$
delimiter ;


select buscar_faixa_etaria_usuario(2) as faixa_etaria_usuario;