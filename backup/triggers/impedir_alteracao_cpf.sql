delimiter //
create trigger impedir_alteracao_cpf 
before update on usuario 
for each row 
begin 
    if old.cpf <> new.cpf then
        signal sqlstate '45000'
        set message_text = 'Não é permitido alterar CPF de um usúario já cadastrado';
    end if;
end; //

delimiter ;