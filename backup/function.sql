

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



