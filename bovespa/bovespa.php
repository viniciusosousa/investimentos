<?php
namespace vini\bovespa;
use vini\app\Controller;
use vini\app\Model;
class Bovespa extends Controller
{
    public function __construct()
    {
		parent::__construct();
		$this->path = 'bovespa';
		$this->addUseCase('default','default_responsive.php', 'Ranking');

		$this->addUseCase('acao','acao.php', 'Acao');

		$this->addUseCase('fav','default_responsive.php', 'Ranking');

		$this->addUseCase('carteira','carteira.php', 'Carteira');
    }



	protected function formatData($coluna, $linha){
		$value ='';
		if (strpos($coluna,'VAR') !== false){
			$cor = ($linha > 0) ? 'text-success':'text-danger';
			$value ='<span class="'.$cor.'">'.number_format($linha,2,',','.').'%</span>';
		} elseif (strpos($coluna,'PRECO') !== false  ){
			$value = number_format($linha,2,',','.');
		} elseif (strpos($coluna,'QTD') !== false ){
			$value = number_format($linha,0,',','.');
		} else {
			$value = $linha;
		}
		return $value;
	}

}
?>