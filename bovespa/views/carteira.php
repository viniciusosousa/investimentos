<nav class="navbar navbar-expand-lg navbar-light bg-light">
	<img src="/img/candlestick.png" width="30" height="30" alt="">
	<a class="navbar-brand" href="#">Cateira de ações</a>
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
	<div>Registrar Operação</div>
	<form action="<?= ($this->home()) ?>" method="get">
      <input type="hidden" name="orderby" value="<?= $this->model->orderby(''); ?>">
      <input type="hidden" name="v" value="carteira">
      <div class="form-row">
		<div class="col">
		 <label for="tipo_operacao">Tipo Operacao: </label>
		 <div class="form-check form-check-inline">
  		 <input class="form-check-input" type="radio" name="tipo_operacao" id="tipo_operacao1" value="1">
  		 <label class="form-check-label" for="tipo_operacao1">Compra</label>
		 </div>
		 <div class="form-check form-check-inline">
 		 <input class="form-check-input" type="radio" name="tipo_operacao" id="tipo_operacao2" value="2">
 		 <label class="form-check-label" for="tipo_operacao2">Venda</label>
		 </div>
		 </div>
		</div>
      <div class="form-row">
     	 <div class="col">
      		<label for="cod_papel">Código do Papel</label>
     		 <input type="text" name="cod_papel" class="form-control" value="">
   		 </div>
		 <div class="col">
     		 <label for="data_operacao">Data Operação</label>
			<input type="text" name="data_operacao" class="form-control" value="<?= date("d/m/Y"); ?>">
		 </div>
	  </div>
      <div class="form-row">
      <div class="col">
      <label for="qtd_pagina">Qtd ações: </label>
      <input type="number" name="qtd_acoes" class="form-control" value="">
      </div>
      <div class="col">
      <label for="pagina">Valor unitário: </label>
      <input type="text" name="vl_unitario" class="form-control" value="">
      </div>
      </div>
      <input type="submit" >
	</form>
	</div>
	<div>
		<a href="<?= $this->home(true) ?>">Home</a>&nbsp;|&nbsp;
		<a href="<?= $this->home(true).'?v=fav' ?>">Favoritos</a>&nbsp;|&nbsp;
		<a href="<?= $this->home(true) ?>">Carteira</a>
	</div>
</nav>

<div class="table-responsive-sm">
	<?php
		$arrayDados = $this->model->carteira();
		foreach ($arrayDados as $linha)
		{
			echo '<div class="card">';
			echo '<div class="card-header">';
			echo '<a href="'.$this->home(true).'?v=acao&cod_papel='.$linha['COD_PAPEL'].'"><h5 class="float-left">'.$linha['COD_PAPEL'].' - '.$linha['NOM_RES'].'</h5></a> <h4 class="float-right">'.$this->formatData('PRECO',$linha['vl_unit_aplicacao']).'/'.$this->formatData('PRECO',$linha['PRECO_ULT']).'</h4></div>';
			echo '<div class="card-body">';
			echo '<table class="table table-sm text-center">';
			echo '<thead><tr><th></th>';
			$this->addParams('orderby', 'var_aplicacao');
			echo '<th><a href="'.$this->home().'">C</a></th>';
			$this->removeParams('orderby');
			$this->addParams('orderby', 'VAR_DIA');
			echo '<th><a href="'.$this->home().'">D</a></th>';
			$this->removeParams('orderby');
			$this->addParams('orderby', 'VAR_MES');
			echo '<th><a href="'.$this->home().'">M</a></th>';
			$this->removeParams('orderby');
			$this->addParams('orderby', 'VAR_ANO');
			echo '<th><a href="'.$this->home().'">A</a></th>';
			$this->removeParams('orderby');
			if($this->orderby) $this->addParams('orderby', $this->orderby);
			echo '</tr></thead>';
			echo '<tbody>';
			echo '<tr><td>Ultimo</td>';
			echo '<td>'.$this->formatData('VAR',$linha['var_aplicacao']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_DIA']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_MES']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_ANO']).'</td></tr>';
			echo '<tr><td>Medio</td>';
			echo '<td>'.$this->formatData('VAR',$linha['var_aplicacao_med']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_DIA_MED']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_MES_MED']).'</td>';
			echo '<td>'.$this->formatData('VAR',$linha['VAR_ANO_MED']).'</td></tr>';
			$this->addParams('orderby', 'QTD_TOTAL');
			echo '<tr><td colspan="5"><a href="'.$this->home().'">Volume</a>: '.$this->formatData('QTD',$linha['QTD_TOTAL']).'</td></tr>';
			$this->removeParams('order_by');
			$this->addParams('orderby', 'saldo_operacao');
			echo '<tr><td colspan="5"><a href="'.$this->home().'">Saldo</a>: '.$this->formatData('PRECO',$linha['saldo_operacao']).'</td></tr>';
			$this->removeParams('saldo_operacao');
			$this->addParams('orderby', 'saldo_acumulado');
			echo '<tr><td colspan="5"><a href="'.$this->home().'">Saldo Acum.</a>: '.$this->formatData('PRECO',$linha['saldo_acumulado']).'</td></tr>';
			$this->removeParams('saldo_acumulado');
			echo '<tr><td colspan="5">Valor: '.$this->formatData('PRECO',$linha['montante_atual']).'</td></tr>';
			$operacoes = $this->model->carregaOperacoes($linha['COD_PAPEL']);
			echo '</tbody>';
			echo '</table>';
			echo '<center><b><u>Operacoes</u></b></center>';
			echo '<div class="table-responsive">';
			echo '<table class="table table-sm"><tr><th>dia</th><th>tipo</th><th>qtd</th><th>vl unit.</th><th>vl total</th><th>resultado</th></tr>';
			foreach ($operacoes as $operacao){
				echo '<tr><td>'.date('d/m/y', strtotime($operacao['DATA_OPERACAO'])).'</td>';
				echo '<td>'.(($operacao['ID_TIPO_OPERACAO']=='1')?'C':'V').'</td>';
				echo '<td>'.$this->formatData('QTD',$operacao['QTD']*(($operacao['ID_TIPO_OPERACAO']=='1')?1:-1)).'</td>';
				echo '<td>'.$this->formatData('PRECO',$operacao['VALOR_UNITARIO']*(($operacao['ID_TIPO_OPERACAO']=='1')?1:-1)).'</td>';
				echo '<td>'.$this->formatData('PRECO',$operacao['vl_total']).'</td>';
				echo '<td>'.$this->formatData('PRECO',$operacao['resultado']).'</td></tr>';
			}
			echo '</table>';
			echo '</div>';
			echo '</div></div>';
		}
?>
</div>
<div>Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></div>
<script>
	/*var acoes = <?php /*$this->renderArrayJSON($this->model->acoes()); */?>;*/
</script>
