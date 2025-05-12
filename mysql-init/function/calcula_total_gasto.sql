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