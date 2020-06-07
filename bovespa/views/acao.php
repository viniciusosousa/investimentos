<h1>Histórico <?= $this->model->codPapel() ?></h1>
<a href="<?= $this->home(true) ?>">Home</a> |
<a target="_blank" href="https://br.tradingview.com/chart/?symbol=BMFBOVESPA:<?= $this->model->codPapel() ?>">Gráfico TradingView</a> |
<a target="_blank" href="https://br.advfn.com/bolsa-de-valores/bovespa/<?= $this->model->codPapel() ?>/cotacao">Gráfico ADVFN</a>
<!-- TradingView Widget BEGIN
<div class="tradingview-widget-container">
  <div id="tradingview_146e7"></div>
  <div class="tradingview-widget-copyright"><a href="https://br.tradingview.com/symbols/BMFBOVESPA-<?= $this->model->codPapel() ?>/" rel="noopener" target="_blank"><span class="blue-text">Gráfico <?= $this->model->codPapel() ?></span></a> por TradingView</div>
  <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
  <script type="text/javascript">
  new TradingView.widget(
  {
  "width": 980,
  "height": 610,
  "symbol": "BMFBOVESPA:<?= $this->model->codPapel() ?>",
  "interval": "D",
  "timezone": "Etc/UTC",
  "theme": "Light",
  "style": "1",
  "locale": "br",
  "toolbar_bg": "#f1f3f6",
  "enable_publishing": false,
  "allow_symbol_change": true,
  "container_id": "tradingview_146e7"
}
  );
  </script>
</div>
--TradingView Widget END -->
<?php

	$arrayDados=$this->model->acao();
	$htmlColunasTitulo = '';
	$colunas = array_keys($arrayDados[0]);
	foreach ($colunas as $coluna)
	{
		$htmlColunasTitulo .= '<th scope="col" data-column-id="'.$coluna.'">';
		$this->addParams('orderby', $coluna);
		$htmlColunasTitulo .= '<a href="'.$this->home().'">'.$coluna.'</a>';
		$this->removeParams('orderby');
		if($this->orderby) $this->addParams('orderby', $this->orderby);
		$htmlColunasTitulo .= '</th>';
	}

	$htmlLinhasBody = '';
	foreach ($arrayDados as $rs)
	{
		$htmlColunasBody = '';
		$value = '';
		for ($x=0; $x < count($rs); $x++)
		{
			$coluna = array_keys($rs)[$x];
			$linha = $rs[$coluna];

			switch($coluna){
			case 'Fav':
				$this->addParams('fav', $rs['COD_PAPEL']);
				$value = '<a href="'.$this->home().'">';
				$this->removeParams('fav');
				$flFavorito = $rs['Fav'];
				$value .= '<i class="'.(($flFavorito)?'fas':'far').' fa-heart"></i></a>';
			break;

			case 'SEGMENTO':
				$this->addParams('segmento', $linha);
				$value = '<a href="'.$this->home().'">'.$linha.'</a>';
				$this->removeParams('segmento');
				if ($this->model->segmento) $this->addParams('segmento', $this->model->segmento);
			break;

			case 'COD_PAPEL':
				$value = '<a href="'.$_SERVER['PHP_SELF'].'?'.'cod_papel='.$linha.'">'.$linha.'</a>';
			break;

			default:
			$htmlColunasBody .= '<td>'.$this->formatData($coluna, $linha).'</td>';
			}
    	}
        $htmlLinhasBody .= '<tr>'.$htmlColunasBody.'</tr>';
	}


	$htmlTable  ='<table id="dados" class="table table-striped table-bordered" style="font-size: 6pt">';
	$htmlTable .='<thead><tr>'.$htmlColunasTitulo.'</tr></thead>';
	$htmlTable .='<tbody>'.$htmlLinhasBody.'</tbody>';
	$htmlTable .= '</table>';
	echo $htmlTable;
?>