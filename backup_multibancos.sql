-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: ecommerce
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `ecommerce`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `ecommerce` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `ecommerce`;

--
-- Table structure for table `desafio_log_estoque`
--

DROP TABLE IF EXISTS `desafio_log_estoque`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `desafio_log_estoque` (
  `id_log` int NOT NULL AUTO_INCREMENT,
  `id_produto` int NOT NULL,
  `estoque_anterior` int NOT NULL,
  `estoque_atual` int NOT NULL,
  `data_alteracao` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_log`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `desafio_log_estoque`
--

LOCK TABLES `desafio_log_estoque` WRITE;
/*!40000 ALTER TABLE `desafio_log_estoque` DISABLE KEYS */;
INSERT INTO `desafio_log_estoque` VALUES (1,2,15,14,'2026-11-11 05:08:34');
/*!40000 ALTER TABLE `desafio_log_estoque` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `desafio_pedidos`
--

DROP TABLE IF EXISTS `desafio_pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `desafio_pedidos` (
  `id_pedido` int NOT NULL,
  `id_produto` int NOT NULL,
  `quantidade` int NOT NULL,
  `status_pedido` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_pedido`),
  KEY `fk_desafio_produto` (`id_produto`),
  CONSTRAINT `fk_desafio_produto` FOREIGN KEY (`id_produto`) REFERENCES `desafio_produtos` (`id_produto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `desafio_pedidos`
--

LOCK TABLES `desafio_pedidos` WRITE;
/*!40000 ALTER TABLE `desafio_pedidos` DISABLE KEYS */;
INSERT INTO `desafio_pedidos` VALUES (1001,1,2,'CONFIRMADO'),(1002,1,3,'CONFIRMADO'),(1003,2,1,'CONFIRMADO');
/*!40000 ALTER TABLE `desafio_pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `desafio_produtos`
--

DROP TABLE IF EXISTS `desafio_produtos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `desafio_produtos` (
  `id_produto` int NOT NULL,
  `nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `preco` decimal(10,2) NOT NULL,
  `estoque` int NOT NULL,
  PRIMARY KEY (`id_produto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `desafio_produtos`
--

LOCK TABLES `desafio_produtos` WRITE;
/*!40000 ALTER TABLE `desafio_produtos` DISABLE KEYS */;
INSERT INTO `desafio_produtos` VALUES (1,'Teclado',105.00,15),(2,'Mouse',50.00,14);
/*!40000 ALTER TABLE `desafio_produtos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_desafio_estoque` AFTER UPDATE ON `desafio_produtos` FOR EACH ROW BEGIN
    IF NEW.estoque <> OLD.estoque THEN
        INSERT INTO desafio_log_estoque
            (id_produto, estoque_anterior, estoque_atual)
        VALUES (NEW.id_produto, OLD.estoque, NEW.estoque);
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping events for database 'ecommerce'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `ev_desafio_limpeza_log` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `ev_desafio_limpeza_log` ON SCHEDULE EVERY 1 DAY STARTS '2026-11-11 02:08:34' ON COMPLETION NOT PRESERVE DISABLE DO DELETE FROM desafio_log_estoque
   WHERE data_alteracao < NOW() - INTERVAL 90 DAY */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'ecommerce'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_desafio_registrar_pedido` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_desafio_registrar_pedido`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `ecommerce_relatorios`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `ecommerce_relatorios` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `ecommerce_relatorios`;

--
-- Table structure for table `desafio_resumo`
--

DROP TABLE IF EXISTS `desafio_resumo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `desafio_resumo` (
  `id` int NOT NULL,
  `descricao` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `desafio_resumo`
--

LOCK TABLES `desafio_resumo` WRITE;
/*!40000 ALTER TABLE `desafio_resumo` DISABLE KEYS */;
INSERT INTO `desafio_resumo` VALUES (1,'Segundo banco para teste de backup');
/*!40000 ALTER TABLE `desafio_resumo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'ecommerce_relatorios'
--

--
-- Dumping routines for database 'ecommerce_relatorios'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-11  2:10:31
