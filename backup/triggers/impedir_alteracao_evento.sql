delimiter // 

create trigger impedir_alteraçao_evento_passado
before update on evento
for each row
begin 
    if old.data_hora < curdate() then 
        signal sqlstate '45000'
        set message_text = 'Não é permitido alterar eventos que ja ocorreram.';
    end if;
end;//

delimiter ; 

