-- DESAFIO MYSQL - TRANSACOES, PROCEDURES, BACKUP E RECOVERY
-- Execute este script no MySQL Workbench conectado ao servidor MySQL.
-- ATENCAO: o script RECRIA SOMENTE tabelas que comecam com desafio_ no banco ecommerce.
-- Se o seu banco tiver outro nome, altere 'ecommerce' neste script.

CREATE DATABASE IF NOT EXISTS ecommerce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce;

-- PREPARACAO: tabelas demonstrativas do e-commerce (InnoDB permite ROLLBACK).
DROP EVENT IF EXISTS ev_desafio_limpeza_log;
DROP PROCEDURE IF EXISTS sp_desafio_registrar_pedido;
DROP TRIGGER IF EXISTS trg_desafio_estoque;
DROP TABLE IF EXISTS desafio_pedidos;
DROP TABLE IF EXISTS desafio_log_estoque;
DROP TABLE IF EXISTS desafio_produtos;

CREATE TABLE desafio_produtos (
    id_produto INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE desafio_pedidos (
    id_pedido INT PRIMARY KEY,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    status_pedido VARCHAR(30) NOT NULL,
    CONSTRAINT fk_desafio_produto FOREIGN KEY (id_produto)
        REFERENCES desafio_produtos(id_produto)
) ENGINE=InnoDB;

CREATE TABLE desafio_log_estoque (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    estoque_anterior INT NOT NULL,
    estoque_atual INT NOT NULL,
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO desafio_produtos (id_produto, nome, preco, estoque) VALUES
    (1, 'Teclado', 100.00, 20),
    (2, 'Mouse', 50.00, 15);

-- PARTE 1 - CODE 1: TRANSACAO SEM PROCEDURE E COM COMMIT
SET autocommit = 0;
START TRANSACTION;
UPDATE desafio_produtos SET preco = preco + 5.00 WHERE id_produto = 1;
COMMIT; -- confirma alteracao de 100.00 para 105.00
SELECT * FROM desafio_produtos;

-- PARTE 1 - CODE 2: SAVEPOINT, ROLLBACK PARCIAL E COMMIT
START TRANSACTION;
UPDATE desafio_produtos
   SET estoque = estoque - 2
 WHERE id_produto = 1 AND estoque >= 2;

INSERT INTO desafio_pedidos (id_pedido, id_produto, quantidade, status_pedido)
VALUES (1001, 1, 2, 'CONFIRMADO');

SAVEPOINT antes_do_desconto;
UPDATE desafio_produtos SET preco = preco * 0.50 WHERE id_produto = 1;
-- Desfaz SOMENTE o desconto, preservando o pedido e a baixa no estoque.
ROLLBACK TO SAVEPOINT antes_do_desconto;
COMMIT;
SELECT * FROM desafio_produtos;
SELECT * FROM desafio_pedidos;

-- PARTE 2 - CODE 3: TRANSACAO DENTRO DE UMA PROCEDURE
DELIMITER $$
CREATE PROCEDURE sp_desafio_registrar_pedido(
    IN p_id_pedido INT,
    IN p_id_produto INT,
    IN p_quantidade INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ROLLBACK: a transacao falhou; nenhuma alteracao foi gravada.' AS resultado;
    END;

    START TRANSACTION;

    IF p_quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantidade invalida';
    END IF;

    UPDATE desafio_produtos
       SET estoque = estoque - p_quantidade
     WHERE id_produto = p_id_produto AND estoque >= p_quantidade;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Produto inexistente ou estoque insuficiente';
    END IF;

    INSERT INTO desafio_pedidos (id_pedido, id_produto, quantidade, status_pedido)
    VALUES (p_id_pedido, p_id_produto, p_quantidade, 'CONFIRMADO');

    COMMIT;
    SELECT 'COMMIT: pedido realizado com sucesso.' AS resultado;
END$$
DELIMITER ;

-- Teste que funciona (estoque do produto 1 passa de 18 para 15).
CALL sp_desafio_registrar_pedido(1002, 1, 3);

-- Teste que falha: id_pedido 1001 ja existe.
-- O UPDATE no estoque acontece antes do INSERT falhar, mas o handler faz ROLLBACK.
CALL sp_desafio_registrar_pedido(1001, 1, 1);

-- O estoque continua 15 depois da tentativa que falhou.
SELECT * FROM desafio_produtos;
SELECT * FROM desafio_pedidos;

-- PARTE 3 - RECURSOS ADICIONAIS PARA INCLUIR NO BACKUP
-- Trigger: registra cada alteracao futura de estoque.
DELIMITER $$
CREATE TRIGGER trg_desafio_estoque
AFTER UPDATE ON desafio_produtos
FOR EACH ROW
BEGIN
    IF NEW.estoque <> OLD.estoque THEN
        INSERT INTO desafio_log_estoque
            (id_produto, estoque_anterior, estoque_atual)
        VALUES (NEW.id_produto, OLD.estoque, NEW.estoque);
    END IF;
END$$
DELIMITER ;

-- Event: criado DESABILITADO para nao executar automaticamente.
-- A definicao do evento sera exportada pelo mysqldump --events.
CREATE EVENT ev_desafio_limpeza_log
ON SCHEDULE EVERY 1 DAY
DISABLE
DO DELETE FROM desafio_log_estoque
   WHERE data_alteracao < NOW() - INTERVAL 90 DAY;

-- Teste do trigger.
CALL sp_desafio_registrar_pedido(1003, 2, 1);
SELECT * FROM desafio_log_estoque;

-- Banco adicional para testar backup de MULTIPLOS bancos.
CREATE DATABASE IF NOT EXISTS ecommerce_relatorios
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_relatorios;
CREATE TABLE IF NOT EXISTS desafio_resumo (
    id INT PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL
) ENGINE=InnoDB;
INSERT INTO desafio_resumo (id, descricao)
VALUES (1, 'Segundo banco para teste de backup')
ON DUPLICATE KEY UPDATE descricao = VALUES(descricao);

-- Volta ao ecommerce e exibe os objetos que devem aparecer no backup.
USE ecommerce;
SHOW PROCEDURE STATUS WHERE Db = 'ecommerce';
SHOW TRIGGERS FROM ecommerce;
SHOW EVENTS FROM ecommerce;
SET autocommit = 1;
