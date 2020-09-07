<?php 
use vini\app\Model;
error_reporting(E_ALL);
include_once('../vendor/autoload.php');
$self = $_SERVER['PHP_SELF'];

function processaForm(){
if (isset($_FILES['arquivo'])){
      //print_r($_FILES);
	if($_FILES['arquivo']['type']=='application/zip'){
		processaZip($_FILES["arquivo"]["tmp_name"]);
		Model::exeSqlFile('sql/bovespa.sql');
		echo '<b>***Fim do script***</b>';
	} else {
		echo '<span style="color: red">Ocorreu um erro</span>';
      	}
}
}

function processaCargaManual(){
if ( (isset($_GET['carga']) or isset($_POST['carga'])) ){
    $script = ($_GET['carga'] ?:  $_POST['carga']);
    echo '<p style="color: green">Conexão feita com sucesso</p>';
    $filename = __DIR__.DIRECTORY_SEPARATOR.'sql'.DIRECTORY_SEPARATOR.$script.'.sql';
    Model::exeSqlFile($filename);
    echo '<b>***Fim do script***</b>';
}
}

function cargasAutoB3(){ 
	$fl_cargaliberada = false;
	$corte = new Model;
	$corte->sql = "SELECT ULTM_FOTO_PRGO FROM financas.vw_ultimo_foto";
	$corte->query();
	$corte->fetchRow();
	$dataCorte = \DateTime::createFromFormat('Y-m-d',$corte->linhas[0]);
	echo "Ultimo dia carregado: ". $dataCorte->format('d/m/Y').'<br>';
	$dataAtual = new \DateTime;
	$diferenca = $dataAtual->diff($dataCorte);
	if($diferenca->d >=2 || ($diferenca->d==1 && $diferenca->h >= 20)){
		for($i=1; $i <= $diferenca->d; $i++ ){
			$file = 'COTAHIST_D'.$dataCorte->add(new \DateInterval('P1D'))->format('dmY').'.ZIP';
			$path = 'http://bvmf.bmfbovespa.com.br/InstDados/SerHist/'.$file;
			$handle = @fopen($path, 'r');
			if ($handle){
				$fl_cargaliberada = true;
              			echo 'Baixando '.$file.'<br>';
              			copy($path, $file);
              			processaZip($file);
              			Model::exeSqlFile('sql/bovespa.sql');
			}
		}
		if($fl_cargaliberada){
			Model::exeSqlFile('sql/bovespa_atualiza_precos.sql');
			echo '<b>***Fim do script***</b>';

		}
	}
}
	
function processaZip($arquivo){
	echo 'Descompactando arquivo....';

	$zip = new ZipArchive;
	$res = $zip->open($arquivo);
	if ($res === TRUE) {
		$zip->extractTo('txt');
                $name = $zip->getNameIndex(0);
		if (file_exists('txt/COTAHIST.TXT'))
			unlink('txt/COTAHIST.TXT');
                rename('txt/'.$name, 'txt/COTAHIST.TXT');
                $zip->close();
		if (isset($_FILES["arquivo"]["name"])){
			$ziporiginal = '/data/data/com.termux/files/home/storage/shared/Download/'.$_FILES["arquivo"]["name"];
			if (file_exists($ziporiginal))
				unlink($ziporiginal);
		}
		if (file_exists($arquivo))
				unlink($arquivo);

                echo '<span style="color: green">ok</span><br><br>';

	}
}



?>

<DOCTYPE! html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8"></meta>
    <title>Processos de Carga</title>
	<meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    <style>
    .thead-dark a {
        color: white;
        }
    code {
        color:black;
    }
    </style>
</head>
<body>
    <div class="container">
    <h1>Processos de carga</h1>
    <a href="<?= $self ?>?carga=bovespa">Carga Bovespa</a><br/>
    <a href="<?= $self ?>?carga=bovespa_atualiza_precos">Atualiza Cortes de Preços Bovespa</a><br/>
    <a href="<?= $self ?>?carga=investimentos">Carga Investimentos</a>
     <form action="<?= $self ?>" method="post" enctype="multipart/form-data">
     	<input type="hidden" name="carga" value="bovespa">
    	<input type="hidden" name="MAX_FILE_SIZE" value=52428800">
    	<label for="arquivo">Arquivo(Max 15MB): </label>
    	<input type="file" class="form-control" name="arquivo" id="arquivo"></input>
    	<input type="submit" class="form-control" value="enviar"></input>
    </form>
    </div>
	<?php
		processaForm();
		processaCargaManual();
		cargasAutoB3();
	?>
</body>
</html>
