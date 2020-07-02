<?php
namespace vini\app;

class Controller
{
    protected $home;
    protected $orderby;
	protected $useCases = [];
    protected $models = [];
	protected $views = [];
	private   $useCase;
    protected $output = '';
	protected $model = null;
	protected $path ='';
        public function __construct(){
	    $this->useCase = (isset($_GET['v']))?$_GET['v']:'default';
	}

	protected function addUseCase($useCase, $view, $model = NULL){
		array_push($this->useCases, $useCase);
		$this->views[$useCase] = $view;
		if(!is_null($model))
			$this->models[$useCase] = $model;
}

	public function render($file){

		if(isset($this->models[$this->useCase])){
		$model = "\\vini\\".$this->path."\\models\\".$this->models[$this->useCase];
		$this->model = new $model;
		}
		$view = $this->path.'/views/'.$this->views[$this->useCase];
		if(file_exists($view)){
            ob_start();
            include $view;
            $this->output = ob_get_clean();
        }
		include $file;
	}


	protected function renderArrayJSON($arrayDados)
	{
		echo json_encode($arrayDados);
	}

	protected function renderOption($iterator, $selectedValue, $number = false)
	{
		$option = '';
$limite = (\is_array($iterator))?count($iterator):$iterator;
		for ($i=1; $i<=$limite; $i++ ){
			$value = (\is_array($iterator))?$iterator[$i-1]:$i;
			$selected = ($selectedValue==$value)?' selected':'';
			$option .= '<option value="'.$value.'"'.$selected.'>';
			$option .= ($number)?number_format($value,0,',','.'):$value;
			$option .='</option>';
      	}
		echo $option;
	}


	public function home($root=false)
	{
        return $_SERVER['PHP_SELF'].((count($_GET) && !$root)?('?'.$this->params()):'');
	}

    protected function params(){
        $i=0;
        $params = '';
        foreach ($_GET as $key => $value){
            $params .= (($i)?'&':'').$key.'='.$value;
            $i++;
        }
        return $params;
    }

    protected function addParams($key, $value){
        $_GET[$key] = $value;
    }

    protected function removeParams($key){
        unset($_GET[$key]);
    }
}
?>