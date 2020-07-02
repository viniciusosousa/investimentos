<?php use vini\app\Model;
include_once('../app/model.php');
error_reporting(E_ALL);?>
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
    <a href="<?= $_SERVER['PHP_SELF'] ?>?carga=bovespa">Carga Bovespa</a><br/>
    <a href="<?= $_SERVER['PHP_SELF'] ?>?carga=bovespa_atualiza_precos">Atualiza Cortes de Preços Bovespa</a><br/>
    <a href="<?= $_SERVER['PHP_SELF'] ?>?carga=investimentos">Carga Investimentos</a>
     <form action="<?= $_SERVER['PHP_SELF'] ?>" method="post" enctype="multipart/form-data">
     	<input type="hidden" name="carga" value="bovespa">
    	<input type="hidden" name="MAX_FILE_SIZE" value=52428800">
    	<label for="arquivo">Arquivo(Max 15MB): </label>
    	<input type="file" class="form-control" name="arquivo" id="arquivo"></input>
    	<input type="submit" class="form-control" value="enviar"></input>
    </form>
    </div>
    <?php

    if (isset($_FILES['arquivo'])){
      //print_r($_FILES);
      if($_FILES['arquivo']['type']=='application/zip'){
          processaZip($_FILES["arquivo"]["tmp_name"]);
      } else {
          echo '<span style="color: red">Ocorreu um erro</span>';
      }
	}


	const SEL_CORTE	   = "SELECT ULTM_FOTO_PRGO FROM financas.vw_ultimo_foto";

	$corte = new Model;
	$corte->sql = SEL_CORTE;
	$corte->query();
	$corte->fetchRow();
	$dataCorte = \DateTime::createFromFormat('Y-m-d',$corte->linhas[0]);
	//$dataCorte->sub(new \DateInterval('P1D'));
	echo "Ultimo dia carregado: ". $dataCorte->format('d/m/Y').'<br>';
	$dataAtual = new \DateTime;
	$diferenca = $dataAtual->diff($dataCorte);
	if($diferenca->d >=2 || ($diferenca->d==1 && $diferenca->h >= 20)){
		for($i=1; $i <= $diferenca->d; $i++ ){
			$file = 'COTAHIST_D'.$dataCorte->add(new \DateInterval('P1D'))->format('dmY').'.ZIP';
			$path = 'http://bvmf.bmfbovespa.com.br/InstDados/SerHist/'.$file;
			$handle = @fopen($path, 'r');
			if ($handle){
			echo 'Baixando '.$file.'<br>';
			copy($path, $file);
			processaZip($file);
			Model::exeSqlFile('sql/bovespa.sql');
			}
			Model::exeSqlFile('sql/bovespa_atualiza_precos.sql');
		}
	}
	function processaZip($arquivo){
		    echo 'Descompactando arquivo....';
            $zip = new ZipArchive;
            $res = $zip->open($arquivo);
            if ($res === TRUE) {
                $zip->extractTo('txt');
                $name = $zip->getNameIndex(0);
                if (file_exists('txt/COTAHIST.TXT')) unlink('txt/COTAHIST.TXT');
                rename('txt/'.$name, 'txt/COTAHIST.TXT');
                $zip->close();
				if (isset($_FILES["arquivo"]["name"])){
					$ziporiginal = '/data/data/com.termux/files/home/storage/shared/Download/'.$_FILES["arquivo"]["name"];
					if (file_exists($ziporiginal))
						unlink($ziporiginal);
				}
                echo '<span style="color: green">ok</span><br><br>';

	}
}


    ?>
</body>
</html>
<?php

if ( (isset($_GET['carga']) or isset($_POST['carga'])) ){
    $script = ($_GET['carga'] ?:  $_POST['carga']);
    echo '<p style="color: green">Conexão feita com sucesso</p>';
    $filename = __DIR__.DIRECTORY_SEPARATOR.'sql'.DIRECTORY_SEPARATOR.$script.'.sql';
    Model::exeSqlFile($filename);
	echo "******** FIM DO SCRIPT *********";
}
?>

<?php
//http://bvmf.bmfbovespa.com.br/InstDados/SerHist/COTAHIST_A2020.ZIP?>