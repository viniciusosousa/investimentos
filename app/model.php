<?php
namespace vini\app;

class Model
{
    const SERVER = "0.0.0.0:3306";
    const UNAME = "root";

    public static $conn;
    public $rs;
    public $sql;

    public $colunas;
    public $linhas;

	public function __construct()
	{
		Model::Connect();
	}

    public static function connect()
    {
        if(!isset(Model::$conn)){
            Model::$conn = new \mysqli(Model::SERVER, Model::UNAME);
            if(Model::$conn->connect_error)
                die("Erro ao conectar: ".Model::$conn->connect_error);
            Model::$conn->set_charset("utf8");
        }
        return Model::$conn;
    }

    public function fetchRow($assoc = false)
    {
	if(isset($this->rs)){
            $this->linhas = ($assoc)?$this->rs->fetch_assoc():$this->rs->fetch_row();
            return $this->linhas;
        }
        return false;
    }

    public function query()
    {
        if($this->sql){
        /*echo $this->sql.'<br>';*/
        $this->rs = Model::$conn->query($this->sql);
		if(!$this->rs) die(Model::$conn->error);
        if(isset($this->rs) and gettype($this->rs)=='object'){
            $objcolunas = $this->rs->fetch_fields();
            $this->colunas = array_map(function($obj){return $obj->name;}, $objcolunas);
        }
       }
    return $this->rs;
    }

    public static function exeSqlFile($filename){
        $file = fopen($filename, 'r') or die("Nao foi possível abrir o arquivo $filename");
        $sql = explode(";",fread($file, filesize($filename)));
        fclose($file);

        $qtdSql = count($sql);
       // echo '<code>';
        Model::Connect();
        for ($x=0; $x < $qtdSql; $x++ ){
            if (!empty(trim($sql[$x]))){
                	//	echo $sql[$x]."......";
			              if (Model::$conn->query($sql[$x]) === TRUE) {
				                // echo '<span style="color: green">ok</span><br><br>';
			              } else {
				                // echo '<span style="color: red">Erro: '.Model::$conn->error.'</span><br><br>';
			              }
           }

        }
        //echo '</code>';
    }

    public function orderby($default){
        return (!empty($_GET['orderby'])?$_GET['orderby']:$default);
    }
}
?>
