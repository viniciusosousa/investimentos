-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Tempo de geração: 03/07/2020 às 00:57
-- Versão do servidor: 10.4.13-MariaDB
-- Versão do PHP: 7.4.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: financas
--
CREATE DATABASE IF NOT EXISTS financas DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE financas;

DELIMITER $$
--
-- Procedimentos
--
DROP PROCEDURE IF EXISTS `atualiza_dados`$$
CREATE DEFINER=`u0_a378`@`localhost` PROCEDURE `atualiza_dados` ()  begin
    declare i int default 2;

    CREATE TEMPORARY TABLE financas.tmp_id_carteira as
    SELECT ID, ID_TIPO_APLICACAO, COD_PAPEL
    FROM financas.tb_aplicacoes
    ORDER BY ID_TIPO_APLICACAO, COD_PAPEL, DATA_OPERACAO, ID_TIPO_OPERACAO;


    ALTER TABLE financas.tmp_id_carteira
    MODIFY id int(11),
    ADD COLUMN id_index int auto_increment primary key first,
    ADD COLUMN indice int after id_index;

    CREATE TEMPORARY TABLE financas.tmp_primeiro_id as
    SELECT ID_TIPO_APLICACAO, COD_PAPEL, MIN(id_index) pri_id_index
    from financas.tmp_id_carteira
    group by id_tipo_aplicacao, cod_papel;

    UPDATE financas.tmp_id_carteira, financas.tmp_primeiro_id
    SET tmp_id_carteira.indice = tmp_id_carteira.id_index - tmp_primeiro_id.pri_id_index + 1
    WHERE tmp_id_carteira.cod_papel = tmp_primeiro_id.cod_papel
    and tmp_id_carteira.id_tipo_aplicacao = tmp_primeiro_id.id_tipo_aplicacao;

    update financas.tb_aplicacoes, financas.tmp_id_carteira
    set tb_aplicacoes.indice = tmp_id_carteira.indice
    where tb_aplicacoes.id = tmp_id_carteira.id;

    update financas.tb_aplicacoes
    set
    vl_medio =0,
    qtd_total=0,
    vl_total=0,
    vl_medio_ant=0,
    qtd_total_ant=0,
    vl_total_ant=0,
    resultado=0;

	select @max_indice := max(indice) from financas.tb_aplicacoes;

    update financas.tb_aplicacoes
    set vl_medio = valor_unitario,
        qtd_total = qtd,
        vl_total = qtd * valor_unitario
    where indice = 1;

    while i <= @max_indice do
    update financas.tb_aplicacoes atual, financas.tb_aplicacoes ant
    set atual.vl_medio = case atual.id_tipo_operacao
                        when 2 then ant.vl_medio
                        when 1 then (ant.vl_total+(atual.qtd*atual.valor_unitario))/(atual.qtd+ant.qtd_total)
                        end,
    atual.vl_total = case atual.id_tipo_operacao
                        when 2 then ant.vl_total - (atual.qtd*ant.vl_medio)
                        when 1 then ant.vl_total + (atual.qtd*atual.valor_unitario)
                        end,
    atual.qtd_total = case atual.id_tipo_operacao
                        when 2 then ant.qtd_total - atual.qtd
                        when 1 then ant.qtd_total + atual.qtd
                        end,
    atual.resultado = case atual.id_tipo_operacao
                        when 1 then 0
                        when 2 then (atual.qtd*atual.valor_unitario)-(atual.qtd*ant.vl_medio)
                        end,
    atual.vl_medio_ant = ant.vl_medio,
    atual.qtd_total_ant = ant.qtd_total,
    atual.vl_total_ant = ant.vl_total
    where atual.cod_papel = ant.cod_papel
    and atual.id_tipo_aplicacao = ant.id_tipo_aplicacao
    and atual.indice = i
    and ant.indice = i - 1;

	set i = i +1;
    end while;

end$$

--
-- Funções
--
DROP FUNCTION IF EXISTS `var_preco`$$
CREATE DEFINER=`pma`@`%` FUNCTION `var_preco` (`atual` FLOAT, `anterior` FLOAT) RETURNS DECIMAL(10,2) RETURN round(if(COALESCE(anterior,0) = 0,0, COALESCE(atual, 0) / anterior - 1) * 100,2)$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura stand-in para view aux_corte_mes
-- (Veja abaixo para a visão atual)
--
DROP VIEW IF EXISTS `aux_corte_mes`;
CREATE TABLE `aux_corte_mes` (
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view aux_corte_mes_final
-- (Veja abaixo para a visão atual)
--
DROP VIEW IF EXISTS `aux_corte_mes_final`;
CREATE TABLE `aux_corte_mes_final` (
);

-- --------------------------------------------------------

--
-- Estrutura para tabela dim_acao_favoritos
--

DROP TABLE IF EXISTS dim_acao_favoritos;
CREATE TABLE dim_acao_favoritos (
  ID int(11) NOT NULL,
  COD_PAPEL varchar(100) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela dim_setor_economico
--

DROP TABLE IF EXISTS dim_setor_economico;
CREATE TABLE dim_setor_economico (
  ID int(11) NOT NULL,
  SETOR_ECONOMICO varchar(100) DEFAULT NULL,
  SUBSETOR varchar(100) DEFAULT NULL,
  SEGMENTO varchar(100) DEFAULT NULL,
  EMPRESA varchar(100) DEFAULT NULL,
  CODIGO varchar(100) DEFAULT NULL,
  COD_SEGMENTO varchar(100) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela foo
--

DROP TABLE IF EXISTS foo;
CREATE TABLE foo (
  id int(10) UNSIGNED NOT NULL,
  val smallint(5) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela mapa_data_7d
--

DROP TABLE IF EXISTS mapa_data_7d;
CREATE TABLE mapa_data_7d (
  PRAZO_TERMO varchar(3) DEFAULT NULL,
  COD_PAPEL varchar(12) DEFAULT NULL,
  COD_BDI int(11) DEFAULT NULL,
  DATA_PREGAO date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela mapa_data_30d
--

DROP TABLE IF EXISTS mapa_data_30d;
CREATE TABLE mapa_data_30d (
  PRAZO_TERMO varchar(3) DEFAULT NULL,
  COD_PAPEL varchar(12) DEFAULT NULL,
  COD_BDI int(11) DEFAULT NULL,
  DATA_PREGAO date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela mapa_data_corte
--

DROP TABLE IF EXISTS mapa_data_corte;
CREATE TABLE mapa_data_corte (
  DATA_PREGAO date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela mapa_data_ini_ano
--

DROP TABLE IF EXISTS mapa_data_ini_ano;
CREATE TABLE mapa_data_ini_ano (
  PRAZO_TERMO varchar(3) DEFAULT NULL,
  COD_PAPEL varchar(12) DEFAULT NULL,
  COD_BDI int(11) DEFAULT NULL,
  DATA_PREGAO date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela mapa_data_mes_ant
--

DROP TABLE IF EXISTS mapa_data_mes_ant;
CREATE TABLE mapa_data_mes_ant (
  PERIODO date DEFAULT NULL,
  PRAZO_TERMO varchar(3) DEFAULT NULL,
  COD_PAPEL varchar(12) DEFAULT NULL,
  COD_BDI int(11) DEFAULT NULL,
  DATA_PREGAO date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela tb_alteracao_cotas
--

DROP TABLE IF EXISTS tb_alteracao_cotas;
CREATE TABLE tb_alteracao_cotas (
  id int(11) NOT NULL,
  tipo int(11) DEFAULT NULL,
  cod_papel varchar(50) DEFAULT NULL,
  NOVO_COD_PAPEL varchar(30) DEFAULT NULL,
  multiplo float DEFAULT NULL,
  data_inicial date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela tb_aplicacoes
--

DROP TABLE IF EXISTS tb_aplicacoes;
CREATE TABLE tb_aplicacoes (
  ID int(11) NOT NULL,
  DATA_OPERACAO date DEFAULT NULL,
  ID_TIPO_APLICACAO int(11) DEFAULT NULL,
  COD_PAPEL varchar(12) DEFAULT NULL,
  ID_TIPO_OPERACAO int(11) DEFAULT NULL,
  QTD int(11) DEFAULT NULL,
  VALOR_UNITARIO decimal(10,2) DEFAULT NULL,
  INDICE int(11) NOT NULL,
  vl_medio decimal(10,2) NOT NULL DEFAULT 0.00,
  vl_medio_ant decimal(10,2) NOT NULL DEFAULT 0.00,
  qtd_total int(11) NOT NULL DEFAULT 0,
  qtd_total_ant int(11) NOT NULL DEFAULT 0,
  vl_total decimal(10,2) NOT NULL DEFAULT 0.00,
  vl_total_ant decimal(10,2) NOT NULL DEFAULT 0.00,
  resultado decimal(10,2) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela tb_bdi
--

DROP TABLE IF EXISTS tb_bdi;
CREATE TABLE tb_bdi (
  COD_BDI int(11) NOT NULL,
  DESC_BDI varchar(100) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela tb_cotacao_historica
--

DROP TABLE IF EXISTS tb_cotacao_historica;
CREATE TABLE tb_cotacao_historica (
  ID int(11) NOT NULL,
  TIP_REG int(11) DEFAULT NULL,
  PERIODO date DEFAULT NULL,
  DATA_PREGAO date DEFAULT NULL,
  COD_BDI int(11) DEFAULT NULL,
  COD_PAPEL varchar(12) DEFAULT NULL,
  TP_MERC int(11) DEFAULT NULL,
  NOM_RES varchar(12) DEFAULT NULL,
  ESP_PAPEL varchar(10) DEFAULT NULL,
  PRAZO_TERMO varchar(3) DEFAULT NULL,
  MOD_REF varchar(4) DEFAULT NULL,
  PRECO_ABER float DEFAULT NULL,
  PRECO_MAX float DEFAULT NULL,
  PRECO_MIN float DEFAULT NULL,
  PRECO_MED float DEFAULT NULL,
  PRECO_ULT float DEFAULT NULL,
  PRECO_OFER_COMPRA float DEFAULT NULL,
  PRECO_OFER_VENDA float DEFAULT NULL,
  PRECO_FECH_ANTERIOR float DEFAULT 0,
  PRECO_FECH_SEM_ANTERIOR float DEFAULT 0,
  PRECO_FECH_MES_ANTERIOR float DEFAULT 0,
  PRECO_FECH_30D float NOT NULL DEFAULT 0,
  PRECO_INI_ANO float DEFAULT 0,
  PRECO_FECH_ANTERIOR_MEDIO float DEFAULT 0,
  PRECO_FECH_SEM_ANTERIOR_MEDIO float DEFAULT 0,
  PRECO_FECH_MES_ANTERIOR_MEDIO float DEFAULT 0,
  PRECO_FECH_30D_MEDIO float NOT NULL DEFAULT 0,
  PRECO_INI_ANO_MEDIO float DEFAULT 0,
  TOT_NEG int(11) DEFAULT NULL,
  QTD_TOTAL int(11) DEFAULT NULL,
  VOL_TOTAL float DEFAULT NULL,
  PRECO_EXERC float DEFAULT NULL,
  IND_PRECOS int(11) DEFAULT NULL,
  DATA_VENC date DEFAULT NULL,
  FAT_COTACAO int(11) DEFAULT NULL,
  PRECO_PONTOS1 float DEFAULT NULL,
  PRECO_PONTOS float DEFAULT NULL,
  COD_ISIN varchar(12) DEFAULT NULL,
  DISMES varchar(3) DEFAULT NULL,
  FL_PROCESSADO int(11) DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela tb_data_corte
--

DROP TABLE IF EXISTS tb_data_corte;
CREATE TABLE tb_data_corte (
  CORTE_INICIAL date DEFAULT NULL,
  CORTE_FINAL date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela tb_mapa_data
--

DROP TABLE IF EXISTS tb_mapa_data;
CREATE TABLE tb_mapa_data (
  ID int(11) NOT NULL,
  DATA_PREGAO date DEFAULT NULL,
  DATA_PREGAO_ANT date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela tb_preco_anterior
--

DROP TABLE IF EXISTS tb_preco_anterior;
CREATE TABLE tb_preco_anterior (
  DATA_PREGAO date DEFAULT NULL,
  DATA_PREGAO_ANT date DEFAULT NULL,
  COD_BDI int(11) DEFAULT NULL,
  COD_PAPEL varchar(12) DEFAULT NULL,
  PRAZO_TERMO varchar(3) DEFAULT NULL,
  PRECO_ULT float DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela tb_preco_ini_ano
--

DROP TABLE IF EXISTS tb_preco_ini_ano;
CREATE TABLE tb_preco_ini_ano (
  COD_BDI int(11) DEFAULT NULL,
  COD_PAPEL varchar(12) DEFAULT NULL,
  PRAZO_TERMO varchar(3) DEFAULT NULL,
  PRECO_ABER float DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela tb_preco_mes_ant
--

DROP TABLE IF EXISTS tb_preco_mes_ant;
CREATE TABLE tb_preco_mes_ant (
  PERIODO date DEFAULT NULL,
  CORTE_MES date DEFAULT NULL,
  COD_BDI int(11) DEFAULT NULL,
  COD_PAPEL varchar(12) DEFAULT NULL,
  PRAZO_TERMO varchar(3) DEFAULT NULL,
  PRECO_ULT float DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela tb_tipo_aplicacao
--

DROP TABLE IF EXISTS tb_tipo_aplicacao;
CREATE TABLE tb_tipo_aplicacao (
  ID int(11) NOT NULL,
  NOME_TIPO_APLICACAO varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela tb_tipo_operacao
--

DROP TABLE IF EXISTS tb_tipo_operacao;
CREATE TABLE tb_tipo_operacao (
  ID int(11) NOT NULL,
  NOME_TIPO_OPERACAO varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura para tabela tmp_cotacao_historica
--

DROP TABLE IF EXISTS tmp_cotacao_historica;
CREATE TABLE tmp_cotacao_historica (
  TIP_REG int(11) DEFAULT NULL,
  PERIODO date DEFAULT NULL,
  DATA_PREGAO date DEFAULT NULL,
  COD_BDI int(11) DEFAULT NULL,
  COD_PAPEL varchar(12) DEFAULT NULL,
  TP_MERC int(11) DEFAULT NULL,
  NOM_RES varchar(12) DEFAULT NULL,
  ESP_PAPEL varchar(10) DEFAULT NULL,
  PRAZO_TERMO varchar(3) DEFAULT NULL,
  MOD_REF varchar(4) DEFAULT NULL,
  PRECO_ABER float DEFAULT NULL,
  PRECO_MAX float DEFAULT NULL,
  PRECO_MIN float DEFAULT NULL,
  PRECO_MED float DEFAULT NULL,
  PRECO_ULT float DEFAULT NULL,
  PRECO_OFER_COMPRA float DEFAULT NULL,
  PRECO_OFER_VENDA float DEFAULT NULL,
  PRECO_FECH_ANTERIOR float DEFAULT NULL,
  PRECO_FECH_SEM_ANTERIOR float DEFAULT NULL,
  PRECO_FECH_MES_ANTERIOR float DEFAULT NULL,
  PRECO_FECH_30D float DEFAULT 0,
  PRECO_INI_ANO float DEFAULT NULL,
  PRECO_FECH_ANTERIOR_MEDIO float DEFAULT NULL,
  PRECO_FECH_SEM_ANTERIOR_MEDIO float DEFAULT NULL,
  PRECO_FECH_MES_ANTERIOR_MEDIO float DEFAULT NULL,
  PRECO_FECH_30D_MEDIO float DEFAULT 0,
  PRECO_INI_ANO_MEDIO float DEFAULT NULL,
  TOT_NEG int(11) DEFAULT NULL,
  QTD_TOTAL int(11) DEFAULT NULL,
  VOL_TOTAL float DEFAULT NULL,
  PRECO_EXERC float DEFAULT NULL,
  IND_PRECOS int(11) DEFAULT NULL,
  DATA_VENC date DEFAULT NULL,
  FAT_COTACAO int(11) DEFAULT NULL,
  PRECO_PONTOS1 float DEFAULT NULL,
  PRECO_PONTOS float DEFAULT NULL,
  COD_ISIN varchar(12) DEFAULT NULL,
  DISMES varchar(3) DEFAULT NULL,
  FL_PROCESSADO int(11) DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura stand-in para view vw_dia_cotacao
-- (Veja abaixo para a visão atual)
--
DROP VIEW IF EXISTS `vw_dia_cotacao`;
CREATE TABLE `vw_dia_cotacao` (
`DATA_PREGAO` date
,`COD_EMPR` varchar(4)
,`COD_PAPEL` varchar(12)
,`NOM_RES` varchar(12)
,`PRECO_FECH_ANTERIOR` float
,`PRECO_FECH_MES_ANTERIOR` float
,`PRECO_ULT` float
,`PRECO_MED` float
,`PRECO_INI_ANO` float
,`QTD_TOTAL` int(11)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view vw_hist_cotacao
-- (Veja abaixo para a visão atual)
--
DROP VIEW IF EXISTS `vw_hist_cotacao`;
CREATE TABLE `vw_hist_cotacao` (
`DATA_PREGAO` date
,`COD_EMPR` varchar(4)
,`COD_PAPEL` varchar(12)
,`NOM_RES` varchar(12)
,`PRECO_FECH_ANTERIOR` float
,`PRECO_FECH_MES_ANTERIOR` float
,`PRECO_ULT` float
,`PRECO_MED` float
,`PRECO_INI_ANO` float
,`QTD_TOTAL` int(11)
,`VAR_DIA` double(19,2)
,`VAR_MES` double(19,2)
,`VAR_ANO` double(19,2)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view vw_mais_negociadas_ultm_prgo
-- (Veja abaixo para a visão atual)
--
DROP VIEW IF EXISTS `vw_mais_negociadas_ultm_prgo`;
CREATE TABLE `vw_mais_negociadas_ultm_prgo` (
`DATA_PREGAO` date
,`COD_EMPR` varchar(4)
,`COD_PAPEL` varchar(12)
,`NOM_RES` varchar(12)
,`PRECO_FECH_ANTERIOR` float
,`PRECO_FECH_MES_ANTERIOR` float
,`PRECO_ULT` float
,`PRECO_INI_ANO` float
,`PRECO_FECH_ANTERIOR_MEDIO` float
,`PRECO_FECH_MES_ANTERIOR_MEDIO` float
,`PRECO_MED` float
,`PRECO_INI_ANO_MEDIO` float
,`QTD_TOTAL` int(11)
,`VAR_DIA` decimal(10,2)
,`VAR_SEM_ANT` decimal(10,2)
,`VAR_MES` decimal(10,2)
,`VAR_30D` decimal(10,2)
,`VAR_ANO` decimal(10,2)
,`VAR_DIA_MED` decimal(10,2)
,`VAR_SEM_ANT_MED` decimal(10,2)
,`VAR_MES_MED` decimal(10,2)
,`VAR_30D_MED` decimal(10,2)
,`VAR_ANO_MED` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view vw_mais_negociadas_ultm_prgo_setor
-- (Veja abaixo para a visão atual)
--
DROP VIEW IF EXISTS `vw_mais_negociadas_ultm_prgo_setor`;
CREATE TABLE `vw_mais_negociadas_ultm_prgo_setor` (
`SETOR_ECONOMICO` varchar(100)
,`SUBSETOR` varchar(100)
,`SEGMENTO` varchar(100)
,`DATA_PREGAO` date
,`COD_EMPR` varchar(4)
,`COD_PAPEL` varchar(12)
,`NOM_RES` varchar(12)
,`PRECO_FECH_ANTERIOR` float
,`PRECO_FECH_MES_ANTERIOR` float
,`PRECO_ULT` float
,`PRECO_INI_ANO` float
,`PRECO_FECH_ANTERIOR_MEDIO` float
,`PRECO_FECH_MES_ANTERIOR_MEDIO` float
,`PRECO_MED` float
,`PRECO_INI_ANO_MEDIO` float
,`QTD_TOTAL` int(11)
,`VAR_DIA` decimal(10,2)
,`VAR_SEM_ANT` decimal(10,2)
,`VAR_MES` decimal(10,2)
,`VAR_30D` decimal(10,2)
,`VAR_ANO` decimal(10,2)
,`VAR_DIA_MED` decimal(10,2)
,`VAR_SEM_ANT_MED` decimal(10,2)
,`VAR_MES_MED` decimal(10,2)
,`VAR_30D_MED` decimal(10,2)
,`VAR_ANO_MED` decimal(10,2)
,`FL_FAVORITO` int(1)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view vw_mapa_data
-- (Veja abaixo para a visão atual)
--
DROP VIEW IF EXISTS `vw_mapa_data`;
CREATE TABLE `vw_mapa_data` (
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view vw_pregao_anterior
-- (Veja abaixo para a visão atual)
--
DROP VIEW IF EXISTS `vw_pregao_anterior`;
CREATE TABLE `vw_pregao_anterior` (
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view vw_ultimo_foto
-- (Veja abaixo para a visão atual)
--
DROP VIEW IF EXISTS `vw_ultimo_foto`;
CREATE TABLE `vw_ultimo_foto` (
`PRI_FOTO_PRGO` date
,`ULTM_FOTO_PRGO` date
);

-- --------------------------------------------------------

--
-- Estrutura para view aux_corte_mes
--
DROP TABLE IF EXISTS `aux_corte_mes`;

DROP VIEW IF EXISTS aux_corte_mes;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW aux_corte_mes  AS  select vw_mapa_data.PERIODO AS PERIODO,vw_mapa_data.PERIODO + interval 1 month AS PROX_PERIODO,min(vw_mapa_data.DATA_PREGAO) AS PRI_PREGAO_MES,max(vw_mapa_data.DATA_PREGAO) AS ULT_PREGAO_MES,min(vw_mapa_data.DATA_PREGAO_ANT) AS CORTE_MES from vw_mapa_data group by '','' ;

-- --------------------------------------------------------

--
-- Estrutura para view aux_corte_mes_final
--
DROP TABLE IF EXISTS `aux_corte_mes_final`;

DROP VIEW IF EXISTS aux_corte_mes_final;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW aux_corte_mes_final  AS  select aux_corte_mes.PERIODO AS PERIODO,if(aux_corte_mes_1.ULT_PREGAO_MES is null,aux_corte_mes.PRI_PREGAO_MES,aux_corte_mes_1.ULT_PREGAO_MES) AS CORTE_MES from (aux_corte_mes left join aux_corte_mes aux_corte_mes_1 on(aux_corte_mes.PERIODO = aux_corte_mes_1.PROX_PERIODO)) ;

-- --------------------------------------------------------

--
-- Estrutura para view vw_dia_cotacao
--
DROP TABLE IF EXISTS `vw_dia_cotacao`;

DROP VIEW IF EXISTS vw_dia_cotacao;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW vw_dia_cotacao  AS  select tb_cotacao_historica.DATA_PREGAO AS DATA_PREGAO,left(tb_cotacao_historica.COD_PAPEL,4) AS COD_EMPR,tb_cotacao_historica.COD_PAPEL AS COD_PAPEL,tb_cotacao_historica.NOM_RES AS NOM_RES,tb_cotacao_historica.PRECO_FECH_ANTERIOR AS PRECO_FECH_ANTERIOR,tb_cotacao_historica.PRECO_FECH_MES_ANTERIOR AS PRECO_FECH_MES_ANTERIOR,tb_cotacao_historica.PRECO_ULT AS PRECO_ULT,tb_cotacao_historica.PRECO_MED AS PRECO_MED,tb_cotacao_historica.PRECO_INI_ANO AS PRECO_INI_ANO,tb_cotacao_historica.QTD_TOTAL AS QTD_TOTAL from (tb_cotacao_historica join tb_bdi on(tb_cotacao_historica.COD_BDI = tb_bdi.COD_BDI)) where tb_bdi.COD_BDI = 2 ;

-- --------------------------------------------------------

--
-- Estrutura para view vw_hist_cotacao
--
DROP TABLE IF EXISTS `vw_hist_cotacao`;

DROP VIEW IF EXISTS vw_hist_cotacao;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW vw_hist_cotacao  AS  select vw_dia_cotacao.DATA_PREGAO AS DATA_PREGAO,vw_dia_cotacao.COD_EMPR AS COD_EMPR,vw_dia_cotacao.COD_PAPEL AS COD_PAPEL,vw_dia_cotacao.NOM_RES AS NOM_RES,vw_dia_cotacao.PRECO_FECH_ANTERIOR AS PRECO_FECH_ANTERIOR,vw_dia_cotacao.PRECO_FECH_MES_ANTERIOR AS PRECO_FECH_MES_ANTERIOR,vw_dia_cotacao.PRECO_ULT AS PRECO_ULT,vw_dia_cotacao.PRECO_MED AS PRECO_MED,vw_dia_cotacao.PRECO_INI_ANO AS PRECO_INI_ANO,vw_dia_cotacao.QTD_TOTAL AS QTD_TOTAL,round(if(vw_dia_cotacao.PRECO_FECH_ANTERIOR = 0,0,vw_dia_cotacao.PRECO_ULT / vw_dia_cotacao.PRECO_FECH_ANTERIOR - 1) * 100,2) AS VAR_DIA,round(if(vw_dia_cotacao.PRECO_FECH_MES_ANTERIOR = 0,0,vw_dia_cotacao.PRECO_ULT / vw_dia_cotacao.PRECO_FECH_MES_ANTERIOR - 1) * 100,2) AS VAR_MES,round(if(vw_dia_cotacao.PRECO_INI_ANO = 0,0,vw_dia_cotacao.PRECO_ULT / vw_dia_cotacao.PRECO_INI_ANO - 1) * 100,2) AS VAR_ANO from vw_dia_cotacao ;

-- --------------------------------------------------------

--
-- Estrutura para view vw_mais_negociadas_ultm_prgo
--
DROP TABLE IF EXISTS `vw_mais_negociadas_ultm_prgo`;

DROP VIEW IF EXISTS vw_mais_negociadas_ultm_prgo;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW vw_mais_negociadas_ultm_prgo  AS  select ch.DATA_PREGAO AS DATA_PREGAO,left(ch.COD_PAPEL,4) AS COD_EMPR,ch.COD_PAPEL AS COD_PAPEL,ch.NOM_RES AS NOM_RES,ch.PRECO_FECH_ANTERIOR AS PRECO_FECH_ANTERIOR,ch.PRECO_FECH_MES_ANTERIOR AS PRECO_FECH_MES_ANTERIOR,ch.PRECO_ULT AS PRECO_ULT,ch.PRECO_INI_ANO AS PRECO_INI_ANO,ch.PRECO_FECH_ANTERIOR_MEDIO AS PRECO_FECH_ANTERIOR_MEDIO,ch.PRECO_FECH_MES_ANTERIOR_MEDIO AS PRECO_FECH_MES_ANTERIOR_MEDIO,ch.PRECO_MED AS PRECO_MED,ch.PRECO_INI_ANO_MEDIO AS PRECO_INI_ANO_MEDIO,ch.QTD_TOTAL AS QTD_TOTAL,var_preco(ch.PRECO_ULT,ch.PRECO_FECH_ANTERIOR) AS VAR_DIA,var_preco(ch.PRECO_ULT,ch.PRECO_FECH_SEM_ANTERIOR) AS VAR_SEM_ANT,var_preco(ch.PRECO_ULT,ch.PRECO_FECH_MES_ANTERIOR) AS VAR_MES,var_preco(ch.PRECO_ULT,ch.PRECO_FECH_30D) AS VAR_30D,var_preco(ch.PRECO_ULT,ch.PRECO_INI_ANO) AS VAR_ANO,var_preco(ch.PRECO_MED,ch.PRECO_FECH_ANTERIOR) AS VAR_DIA_MED,var_preço(ch.PRECO_MED,ch.PRECO_FECH_SEM_ANTERIOR_MEDIO) AS VAR_SEM_ANT_MED,var_preco(ch.PRECO_MED,ch.PRECO_FECH_MES_ANTERIOR_MEDIO) AS VAR_MES_MED,var_preco(ch.PRECO_MED,ch.PRECO_FECH_30D) AS VAR_30D_MED,var_preco(ch.PRECO_MED,ch.PRECO_INI_ANO_MEDIO) AS VAR_ANO_MED from tb_cotacao_historica ch where ch.DATA_PREGAO = (select vw_ultimo_foto.ULTM_FOTO_PRGO from vw_ultimo_foto) and ch.COD_BDI = 2 WITH CASCADED CHECK OPTION ;

-- --------------------------------------------------------

--
-- Estrutura para view vw_mais_negociadas_ultm_prgo_setor
--
DROP TABLE IF EXISTS `vw_mais_negociadas_ultm_prgo_setor`;

DROP VIEW IF EXISTS vw_mais_negociadas_ultm_prgo_setor;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW vw_mais_negociadas_ultm_prgo_setor  AS  select se.SETOR_ECONOMICO AS SETOR_ECONOMICO,se.SUBSETOR AS SUBSETOR,se.SEGMENTO AS SEGMENTO,up.DATA_PREGAO AS DATA_PREGAO,up.COD_EMPR AS COD_EMPR,up.COD_PAPEL AS COD_PAPEL,up.NOM_RES AS NOM_RES,up.PRECO_FECH_ANTERIOR AS PRECO_FECH_ANTERIOR,up.PRECO_FECH_MES_ANTERIOR AS PRECO_FECH_MES_ANTERIOR,up.PRECO_ULT AS PRECO_ULT,up.PRECO_INI_ANO AS PRECO_INI_ANO,up.PRECO_FECH_ANTERIOR_MEDIO AS PRECO_FECH_ANTERIOR_MEDIO,up.PRECO_FECH_MES_ANTERIOR_MEDIO AS PRECO_FECH_MES_ANTERIOR_MEDIO,up.PRECO_MED AS PRECO_MED,up.PRECO_INI_ANO_MEDIO AS PRECO_INI_ANO_MEDIO,up.QTD_TOTAL AS QTD_TOTAL,up.VAR_DIA AS VAR_DIA,up.VAR_SEM_ANT AS VAR_SEM_ANT,up.VAR_MES AS VAR_MES,up.VAR_30D AS VAR_30D,up.VAR_ANO AS VAR_ANO,up.VAR_DIA_MED AS VAR_DIA_MED,up.VAR_SEM_ANT_MED AS VAR_SEM_ANT_MED,up.VAR_MES_MED AS VAR_MES_MED,up.VAR_30D_MED AS VAR_30D_MED,up.VAR_ANO_MED AS VAR_ANO_MED,if(fav.COD_PAPEL is null,0,1) AS FL_FAVORITO from ((vw_mais_negociadas_ultm_prgo up left join dim_acao_favoritos fav on(up.COD_PAPEL = fav.COD_PAPEL)) left join dim_setor_economico se on(up.COD_EMPR = se.CODIGO)) order by up.QTD_TOTAL desc ;

-- --------------------------------------------------------

--
-- Estrutura para view vw_mapa_data
--
DROP TABLE IF EXISTS `vw_mapa_data`;

DROP VIEW IF EXISTS vw_mapa_data;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW vw_mapa_data  AS  select distinct financas.tb_mapa_data.PERIODO AS PERIODO,financas.tb_mapa_data.DATA_PREGAO AS DATA_PREGAO,tb_mapa_data1.DATA_PREGAO AS DATA_PREGAO_ANT,financas.tb_mapa_data.`ID` AS `ID`,financas.tb_mapa_data.`ID` - 1 AS ID_ANTERIOR from (tb_mapa_data left join tb_mapa_data tb_mapa_data1 on(if(financas.tb_mapa_data.`ID` = 1,1,financas.tb_mapa_data.`ID` - 1) = tb_mapa_data1.`ID`)) ;

-- --------------------------------------------------------

--
-- Estrutura para view vw_pregao_anterior
--
DROP TABLE IF EXISTS `vw_pregao_anterior`;

DROP VIEW IF EXISTS vw_pregao_anterior;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW vw_pregao_anterior  AS  select vw_mapa_data.PERIODO AS PERIODO,vw_mapa_data.DATA_PREGAO AS DATA_PREGAO,financas.tb_mapa_data.DATA_PREGAO AS DATA_PREGAO_ANT,aux_corte_mes_final.CORTE_MES AS CORTE_MES from ((vw_mapa_data join tb_mapa_data on(financas.tb_mapa_data.`ID` = vw_mapa_data.ID_ANTERIOR)) left join aux_corte_mes_final on(vw_mapa_data.PERIODO = aux_corte_mes_final.PERIODO)) ;

-- --------------------------------------------------------

--
-- Estrutura para view vw_ultimo_foto
--
DROP TABLE IF EXISTS `vw_ultimo_foto`;

DROP VIEW IF EXISTS vw_ultimo_foto;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW vw_ultimo_foto  AS  select min(tb_mapa_data.DATA_PREGAO) AS PRI_FOTO_PRGO,max(tb_mapa_data.DATA_PREGAO) AS ULTM_FOTO_PRGO from tb_mapa_data ;

--
-- Índices de tabelas apagadas
--

--
-- Índices de tabela dim_acao_favoritos
--
ALTER TABLE dim_acao_favoritos
  ADD PRIMARY KEY (ID),
  ADD UNIQUE KEY COD_PAPEL (COD_PAPEL),
  ADD KEY COD_PAPEL_2 (COD_PAPEL);

--
-- Índices de tabela dim_setor_economico
--
ALTER TABLE dim_setor_economico
  ADD PRIMARY KEY (ID);

--
-- Índices de tabela foo
--
ALTER TABLE foo
  ADD PRIMARY KEY (id);

--
-- Índices de tabela mapa_data_7d
--
ALTER TABLE mapa_data_7d
  ADD KEY CINDEX_30D (PRAZO_TERMO,COD_PAPEL,COD_BDI,DATA_PREGAO);

--
-- Índices de tabela mapa_data_30d
--
ALTER TABLE mapa_data_30d
  ADD KEY CINDEX_30D (PRAZO_TERMO,COD_PAPEL,COD_BDI,DATA_PREGAO);

--
-- Índices de tabela mapa_data_ini_ano
--
ALTER TABLE mapa_data_ini_ano
  ADD KEY DATA_INDEX (DATA_PREGAO,COD_BDI,COD_PAPEL,PRAZO_TERMO);

--
-- Índices de tabela mapa_data_mes_ant
--
ALTER TABLE mapa_data_mes_ant
  ADD KEY DATA_INDEX (DATA_PREGAO,COD_BDI,COD_PAPEL,PRAZO_TERMO),
  ADD KEY PERIODO_INDEX (PERIODO,COD_BDI,COD_PAPEL,PRAZO_TERMO);

--
-- Índices de tabela tb_alteracao_cotas
--
ALTER TABLE tb_alteracao_cotas
  ADD PRIMARY KEY (id),
  ADD KEY tipo (tipo),
  ADD KEY cod_papel (cod_papel),
  ADD KEY data_inicial (data_inicial);

--
-- Índices de tabela tb_aplicacoes
--
ALTER TABLE tb_aplicacoes
  ADD PRIMARY KEY (ID),
  ADD KEY ID_TIPO_APLICACAO (ID_TIPO_APLICACAO),
  ADD KEY COD_PAPEL (COD_PAPEL),
  ADD KEY ID_TIPO_OPERACAO (ID_TIPO_OPERACAO);

--
-- Índices de tabela tb_bdi
--
ALTER TABLE tb_bdi
  ADD PRIMARY KEY (COD_BDI);

--
-- Índices de tabela tb_cotacao_historica
--
ALTER TABLE tb_cotacao_historica
  ADD PRIMARY KEY (ID),
  ADD KEY COD_BDI (COD_BDI),
  ADD KEY DATA_PREGAO (DATA_PREGAO),
  ADD KEY chave_preco (DATA_PREGAO,PRAZO_TERMO,COD_PAPEL,COD_BDI),
  ADD KEY chave_preco_periodo (PERIODO,PRAZO_TERMO,COD_BDI,COD_PAPEL),
  ADD KEY chave_papel (PRAZO_TERMO,COD_BDI,COD_PAPEL),
  ADD KEY FL_PROCESSADO (FL_PROCESSADO);

--
-- Índices de tabela tb_mapa_data
--
ALTER TABLE tb_mapa_data
  ADD PRIMARY KEY (ID),
  ADD KEY DATA_PREGAO (DATA_PREGAO),
  ADD KEY DATA_PREGAO_ANT (DATA_PREGAO_ANT);

--
-- Índices de tabela tb_preco_anterior
--
ALTER TABLE tb_preco_anterior
  ADD KEY PRECO_ANT (PRAZO_TERMO,COD_PAPEL,COD_BDI,DATA_PREGAO);

--
-- Índices de tabela tb_preco_ini_ano
--
ALTER TABLE tb_preco_ini_ano
  ADD KEY PRECO_INI_ANO (PRAZO_TERMO,COD_PAPEL,COD_BDI);

--
-- Índices de tabela tb_preco_mes_ant
--
ALTER TABLE tb_preco_mes_ant
  ADD KEY PRECO_ANT (PRAZO_TERMO,COD_PAPEL,COD_BDI,PERIODO);

--
-- Índices de tabela tb_tipo_aplicacao
--
ALTER TABLE tb_tipo_aplicacao
  ADD PRIMARY KEY (ID);

--
-- Índices de tabela tb_tipo_operacao
--
ALTER TABLE tb_tipo_operacao
  ADD PRIMARY KEY (ID);

--
-- Índices de tabela tmp_cotacao_historica
--
ALTER TABLE tmp_cotacao_historica
  ADD KEY COD_PAPEL (COD_PAPEL),
  ADD KEY DATA_PREGAO (DATA_PREGAO);

--
-- AUTO_INCREMENT de tabelas apagadas
--

--
-- AUTO_INCREMENT de tabela dim_acao_favoritos
--
ALTER TABLE dim_acao_favoritos
  MODIFY ID int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela dim_setor_economico
--
ALTER TABLE dim_setor_economico
  MODIFY ID int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela foo
--
ALTER TABLE foo
  MODIFY id int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela tb_alteracao_cotas
--
ALTER TABLE tb_alteracao_cotas
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela tb_aplicacoes
--
ALTER TABLE tb_aplicacoes
  MODIFY ID int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela tb_cotacao_historica
--
ALTER TABLE tb_cotacao_historica
  MODIFY ID int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela tb_mapa_data
--
ALTER TABLE tb_mapa_data
  MODIFY ID int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela tb_tipo_aplicacao
--
ALTER TABLE tb_tipo_aplicacao
  MODIFY ID int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela tb_tipo_operacao
--
ALTER TABLE tb_tipo_operacao
  MODIFY ID int(11) NOT NULL AUTO_INCREMENT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
