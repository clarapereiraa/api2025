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