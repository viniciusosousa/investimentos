<?php
namespace vini\bovespa;
use vini\app\Controller;
use vini\app\Model;
class Bovespa extends Controller
{
	public function __construct()
    	{
		parent::__construct('bovespa');
		$this->addUseCase('default','ranking.twig.html', 'Ranking');
		$this->addUseCase('acao','acao.php', 'Acao');
		$this->addUseCase('fav','default_responsive.php', 'Ranking');
		$this->addUseCase('carteira','ranking.twig.html', 'Carteira');
	
	/*
		$this->addUseCase('default','default_responsive.php', 'Ranking');
		$this->addUseCase('acao','acao.php', 'Acao');
		$this->addUseCase('fav','default_responsive.php', 'Ranking');
		$this->addUseCase('carteira','carteira.php', 'Carteira');*/
   	 }	

}
?>
