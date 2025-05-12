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
