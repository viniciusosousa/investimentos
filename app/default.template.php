<DOCTYPE! html>
<html lang="pt-BR">
  <head>
	<meta charset="UTF-8"/>
	<title>Ranking Ações Bovespa</title>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="node_modules/bootstrap/dist/css/bootstrap.min.css">
	<link rel="stylesheet" href="node_modules/@fortawesome/fontawesome-free/css/all.min.css">
	<link rel="stylesheet" href="node_modules/jquery-bootgrid/dist/jquery.bootgrid.min.css">
	<link href="https://fonts.googleapis.com/css?family=Montserrat&display=swap" rel="stylesheet">
	<script src="node_modules/jquery/dist/jquery.min.js"></script>
	<script src="node_modules/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
	<script src="node_modules/jquery-bootgrid/dist/jquery.bootgrid.min.js"></script>

	<style>
		body {
			font-family: 'Montserrat', sans-serif;
		}
      		.thead-dark  {
          		color: white;
          	}
	</style>
  </head>

  <body>
      <div class="container-fluid">
      <?= $this->output ?>
      </div>
</body>
</html>
