<nav class="navbar navbar-expand-lg navbar-light bg-light">
	<img src="/img/candlestick.png" width="30" height="30" alt="">
	<a class="navbar-brand" href="#">Ranking Ações Bovespa</a>
	<button class="navbar-toggler"
			type="button"
			data-toggle="collapse"
			data-target="#navbarMenu"
			aria-controls="navbarMenu"
			aria-expanded="false"
			aria-label="Toggle navigation">
    	<span class="navbar-toggler-icon"></span>
	</button>
	<div class="collapse navbar-collapse" id="navbarMenu">
	<form action="<?= ($this->home()) ?>" method="get">
      <input type="hidden" name="orderby" value="<?= $this->model->orderby(''); ?>">
      <label for="segmento">Segmento: </label>
      <select name="segmento" class="form-control">
      	<option value="">Nenhum</option>
      	<?php $this->renderOption($this->model->segmentos(), $this->model->segmento); ?>
      </select>
      <div class="form-row">
      <div class="col-xs-6">
      <label for="qtd_pagina">Qtd por Pagina: </label>
      <input type="number" name="qtd_pagina" class="form-control" value="<?= $this->model->itens ?>">
      </div>
      <div class="col-xs-6">
      <label for="pagina">Pagina: </label>
      <select name="pagina" class="form-control">
     	<?php $this->renderOption($this->model->paginas, $this->model->pagina);  ?>
      </select>
      </div>
      </div>
      <div class="form-row">
      <div class="col-xs-6">
      <label for="vol_min">Volume Mínimo: </label>
      <select name="vol_min" class="form-control">
      <option value="0">Todos</option>
      <?php $this->renderOption($this->model->limitesVolume(), $this->model->volMin, true); ?>
      </select>
      </div>
      <div class="col-xs-6">
       <label for="vol_max">Volume Máximo: </label>
      <select name="vol_max" class="form-control">
      <option value="0">Todos</option>
      <?php $this->renderOption($this->model->limitesVolume(), $this->model->volMax, true); ?>
      </select>
      </div>
      <div class="form-row">
      <div class="col-xs-6">
      <label for="nome_papel">Nome do Papel</label>
      <input type="text" name="nome_papel" class="form-control" value="">
      </div>
	  </div>
      </div>
      <input type="submit" >
	</form>
	</div>
	<div>
		<a href="<?= $this->home(true) ?>">Home</a>&nbsp;|&nbsp;
		<a href="<?= $this->home(true).'?v=fav' ?>">Favoritos</a>&nbsp;|&nbsp;
		<a href="<?= $this->home(true).'?v=carteira' ?>">Carteira</a>
	</div>
</nav>

<div class="table-responsive-sm">
	<?php
		echo 'Corte: '.$this->model->dataCorte;
		$arrayDados = $this->model->acoes();
		foreach ($arrayDados as $linha)
		{
			echo '<div class="card">';
			echo '<div class="card-header">';
			$this->addParams('fav', $linha['COD_PAPEL']);
			echo '<a href="'.$this->home().'">';
			$this->removeParams('fav');
			$flFavorito = $linha['Fav'];
			echo '<i class="'.(($flFavorito)?'fas':'far').' fa-heart"></i></a>';
			echo '<a href="'.$this->home(true).'?v=acao&cod_papel='.$linha['COD_PAPEL'].'"><h5 class="float-left">'.$linha['COD_PAPEL'].' - '.$linha['NOM_RES'].'</h5></a> <h4 class="float-right">'.$this->formatData('PRECO',$linha['PRECO_ULT']).'</h4></div>';
			echo '<div class="card-body">';
			echo '<table class="table table-sm text-center">';
			echo '<thead><tr><th></th>';
			$this->addParams('orderby', 'VAR_DIA');
			echo '<th><a href="'.$this->home().'">D</a></th>';
			$this->removeParams('orderby');
			$this->addParams('orderby', 'VAR_SEM_ANT');
			echo '<th><a href="'.$this->home().'">S</a></th>';
			$this->removeParams('orderby');
			$this->addParams('orderby', 'VAR_MES');
			echo '<th><a href="'.$this->home().'">M</a></th>';
			$this->removeParams('orderby');
			$this->addParams('orderby', 'VAR_30D');
			echo '<th><a href="'.$this->home().'">30D</a></th>';
			$this->removeParams('orderby');
			$this->addParams('orderby', 'VAR_ANO');
			echo '<th><a href="'.$this->home().'">A</a></th>';
			$this->removeParams('orderby');
			if($this->orderby) $this->addParams('orderby', $this->orderby);
			echo '</tr></thead>';
			echo '<tbody>';
			echo '<tr><td>Ultimo</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_DIA']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_SEM_ANT']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_MES']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_30D']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_ANO']).'</td></tr>';
			echo '<tr><td>Medio</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_DIA_MED']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_SEM_ANT_MED']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_MES_MED']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_30D_MED']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_ANO_MED']).'</td></tr>';
			$this->addParams('orderby', 'QTD_TOTAL');
			echo '<tr><td colspan="6"><a href="'.$this->home().'">Volume</a>: '.$this->formatData('QTD',$linha['QTD_TOTAL']).'</td></tr>';
			$this->removeParams('orderby');
			echo '</tbody>';
			echo '</table></div>';
			echo '<div class="card-footer text-center">';
			echo '<a target="_blank" href="https://br.tradingview.com/chart/?symbol=BMFBOVESPA:'.$linha['COD_PAPEL'].'">TradingView</a>&nbsp;|&nbsp;';
			echo '<a target="_blank" href="https://br.advfn.com/bolsa-de-valores/bovespa/'.$linha['COD_PAPEL'].'/cotacao">ADVFN</a>';
			echo '</div></div>';
		}
?>
</div>
<div>Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></div>
<script>
	/*var acoes = <?php /*$this->renderArrayJSON($this->model->acoes()); */?>;*/
</script>