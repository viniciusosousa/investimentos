<?php
namespace vini\app;
use \Twig\Environment;
use \Twig\Loader\FilesystemLoader;
class Controller
{
	protected $home;
    	protected $orderby;
	private   $useCase;
	protected $useCases = [];
    	protected $models = [];
	protected $views = [];
    	protected $output = '';
	protected $model = null;
	private   $path ='';
	protected $twig = null;

	public function __construct($path){
		$this->useCase = (isset($_GET['v']))?$_GET['v']:'default';
		$this->path = $path;
		$this->initTwig();
	}

	protected function addUseCase($useCase, $view, $model = NULL){
		array_push($this->useCases, $useCase);
		$this->views[$useCase] = $view;
		if(!is_null($model))
			$this->models[$useCase] = $model;
	}

	private function initTwig(){
		$loader = new FilesystemLoader($this->path.'/views');
		$this->twig = new Environment($loader);
		$this->twig->addFunction(new \Twig\TwigFunction('renderOption', [$this, 'renderOption'], ['is_safe'=>['html']]));
		$this->twig->addFilter(new \Twig\TwigFilter('format_colors', [$this, 'format_colors'],['is_safe'=>['html']]));
		$this->twig->addFilter(new \Twig\TwigFilter('orderby', [$this, 'orderby']));
	}

	public function format_colors($number){
		$cor = ($number > 0) ? 'text-success':'text-danger';
		return "<span class=\"$cor\">$number</span>";
	}

	public function orderby($orderby){
		$this->addParams('orderby',$orderby);
		$home = $this->home();
		$this->removeParams('orderby');
		return $home;
	}

	public function render($file){

		if(isset($this->models[$this->useCase])){
			$model = "\\vini\\".$this->path."\\models\\".$this->models[$this->useCase];
			$this->model = new $model;
		}

		$this->output = $this->twig->render($this->views[$this->useCase],
		       	['controller'=> $this
			, 'model' => $this->model]
		);

		/*$view = $this->path.'/views/'.$this->views[$this->useCase];
		if(file_exists($view)){
            ob_start();
            include $view;
            $this->output = ob_get_clean();
        }*/
		include $file;
	}


	protected function renderArrayJSON($arrayDados)
	{
		echo json_encode($arrayDados);
	}

	public function renderOption($iterator, $selectedValue, $number = false)
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
		return $option;
	}


	public function home($root=false)
	{
		$home = $_SERVER['PHP_SELF'].((count($_GET) && !$root)?('?'.$this->params()):'');
		return $home;
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
