<?php
namespace vini\bovespa;
use vini\app\Controller;
use vini\app\Model;
use vini\bovespa\models\ranking;
use vini\bovespa\models\carteira;
use vini\bovespa\models\acao as AcaoModel;

class Bovespa extends Controller
{
    public function __construct()
    {

	    $view = '';

		if(isset($_GET['v'])){
            $view = $_GET['v'];
        }

        switch($view){
            case 'acao':
                $this->model = new AcaoModel;
                $this->output .= $this->includeView('bovespa/views/acao.php');
            break;

			case 'fav':
				$this->model = new Ranking;
                $this->output .= $this->includeView('bovespa/views/default_responsive.php');
			break;

			case 'carteira':
				$this->model = new Carteira;
                $this->output .= $this->includeView('bovespa/views/carteira.php');
			break;

            default:
				$this->model = new Ranking;
                $this->output .= $this->includeView('bovespa/views/default_responsive.php');
        }
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