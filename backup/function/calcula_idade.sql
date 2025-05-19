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