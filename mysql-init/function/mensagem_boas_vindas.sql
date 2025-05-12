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
