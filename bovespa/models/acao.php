<?php
namespace vini\bovespa\models;
use vini\app\Model;

class Acao extends Model
{
    private $_codPapel;
	private $_acao;

    const SQL_ACAO =  "SELECT  data_pregao
                              ,preco_ult
                              ,preco_med
                              ,var_dia
                              ,var_mes
                              ,var_ano
                              ,qtd_total
                               FROM financas.vw_hist_cotacao
                               WHERE cod_papel=";

    public function __construct()
    {
		parent::__construct();
		$this->_acao = array();
		if(isset($_GET['cod_papel']))
			$this->carregaAcao($_GET['cod_papel']);
	}

	public function codPapel()
	{
		return $this->_cod_papel;
	}

	private function carregaAcao($codigoBovespa)
	{
		$this->_cod_papel = $codigoBovespa;
		$this->sql = self::SQL_ACAO;
		$this->sql .= '"'.$this->_cod_papel.'"';
		$this->sql .= ' ORDER BY '.$this->orderby('DATA_PREGAO');
		$this->query();
		while($this->fetchRow(true))
		{
			array_push($this->_acao, $this->linhas);
		}
	}

	public function acao()
	{
		return $this->_acao;
	}
}