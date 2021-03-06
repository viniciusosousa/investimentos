SET GLOBAL storage_engine = MyISAM;

CREATE DATABASE IF NOT EXISTS FINANCAS;

USE FINANCAS;

CREATE TABLE IF NOT EXISTS tb_aplicacoes (
ID INT AUTO_INCREMENT PRIMARY KEY,
DATA_OPERACAO DATE,
ID_TIPO_APLICACAO INT,
COD_PAPEL VARCHAR(12),
ID_TIPO_OPERACAO INT,
QTD INT,
VALOR_UNITARIO FLOAT,
INDEX ID_TIPO_APLICACAO(ID_TIPO_APLICACAO),
INDEX COD_PAPEL(COD_PAPEL),
INDEX ID_TIPO_OPERACAO(ID_TIPO_OPERACAO)
) ENGINE = MYISAM;

CREATE TABLE IF NOT EXISTS tb_tipo_aplicacao (
ID INT AUTO_INCREMENT PRIMARY KEY,
NOME_TIPO_APLICACAO VARCHAR(50)
) ENGINE = MYISAM;

INSERT IGNORE INTO tb_tipo_aplicacao VALUES
(1, 'Açoes'),
(2, 'Tesouro SELIC');

CREATE TABLE IF NOT EXISTS tb_tipo_operacao (
ID INT AUTO_INCREMENT PRIMARY KEY,
NOME_TIPO_OPERACAO VARCHAR(50)
) ENGINE = MYISAM;

INSERT IGNORE INTO tb_tipo_operacao VALUES
(1, 'Compra'),
(2, 'Venda');
