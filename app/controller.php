<?php
namespace vini\app;

class Controller
{
    protected $home;
    protected $orderby;
    protected $model;
	protected $view;
    protected $output;

    protected function includeView($file){

        if (file_exists($file)){
            ob_start();
            include $file;
            return ob_get_clean();
        }
        return false;
    }

	public function render($output){
		 echo $this->includeView($output);
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