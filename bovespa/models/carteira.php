<?php
namespace vini\bovespa\models;
use vini\bovespa\models\ranking;

class Carteira extends Ranking
{
    public $tipo_operacao;
    public $cod_papel;
    public $data_operacao;
    public $qtd_acoes;
    public $vl_unitario;
	private $_carteira;
    const SQL_CARTEIRA =  "SELECT
                           a.segmento
                          ,a.cod_papel
                          ,a.nom_res
                          ,a.preco_ult
						  ,a.var_dia
                          ,a.var_mes
                          ,a.var_ano
                          ,a.var_dia_med
                          ,a.var_mes_med
                          ,a.var_ano_med
                          ,a.qtd_total
						  ,sq_aplicacoes.qtd as qtd_aplicacao
						  ,sq_aplicacoes.valor_unitario as vl_unit_aplicacao
						  ,financas.var_preco(a.preco_ult, sq_aplicacoes.valor_unitario) var_aplicacao
						  ,financas.var_preco(a.preco_med, sq_aplicacoes.valor_unitario) var_aplicacao_med
										,@montante := sq_aplicacoes.qtd * sq_aplicacoes.valor_unitario as montante
,@montante_atual := sq_aplicacoes.qtd * a.preco_ult as montante_atual
,@montante_atual - @montante as saldo_operacao
										FROM financas.vw_mais_negociadas_ultm_prgo_setor a
										INNER JOIN (SELECT cod_papel
                                       				 	,sum(a.qtd*case when id_tipo_operacao=2 then -1 else 1 end) as qtd
                                        				,sum(a.qtd*(a.valor_unitario*case when id_tipo_operacao=2 then -1 else 1 end))/sum(a.qtd) as valor_unitario
                               							FROM financas.tb_aplicacoes a
														group by 1
														having qtd > 0
													) sq_aplicacoes ON a.cod_papel = sq_aplicacoes.cod_papel";

	const SQL_APLICACOES =  "SELECT *
                               FROM financas.tb_aplicacoes";


    const INS_CARTEIRA = "INSERT IGNORE INTO financas.tb_aplicacoes SET ";
    const DEL_CARTEIRA = "DELETE FROM financas.tb_aplicacoes WHERE ID=";

    public function __construct()
    {
		parent::__construct();
		$this->_carteira = array();
		$this->insereOperacao();
		$this->carregaCarteira();
	}

	public function carteira()
	{
		return $this->_carteira;
	}


	private function insereOperacao()
	{
		if(isset($_GET['cod_papel'])){
			$this->sql = self::INS_CARTEIRA
						.'ID_TIPO_APLICACAO=1'
						.', COD_PAPEL="'.$_GET['cod_papel'].'"'
						.', DATA_OPERACAO="'.\DateTime::createFromFormat('d/m/Y', $_GET['data_operacao'])->format('Y-m-d').'"'
						.', ID_TIPO_OPERACAO='.$_GET['tipo_operacao']
						.', QTD='.$_GET['qtd_acoes']
						.', VALOR_UNITARIO='.str_replace(',','.',$_GET['vl_unitario']);
            $this->query();
            unset($_GET['cod_papel'], $_GET['data_operacao'], $_GET['tipo_operacao'], $_GET['qtd_acoes'], $_GET['vl_unitario']);
        }
	}

	private function carregaSegmentos()
	{
		$this->sql = self::SQL_SEGMENTO;

        $this->query();
		while($this->fetchRow())
		{
			array_push($this->_segmentos, $this->linhas[0]);
		}
	}

	private function carregaCarteira()
	{
        $this->sql = self::SQL_CARTEIRA;

        $this->query();

		while($this->fetchRow(true))
		{
			array_push($this->_carteira, $this->linhas);
		}
	}


	public function carregaOperacoes($cod_papel)
	{
        $this->sql = self::SQL_OPERACOES.' WHERE COD_PAPEL="'.$cod_papel.'" ORDER BY DATA_OPERACAO';
        $this->query();
		$operacoes = array();
		while($this->fetchRow(true))
		{
			array_push($operacoes, $this->linhas);
		}
		return $operacoes;
	}
}