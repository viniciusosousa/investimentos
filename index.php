<?php
use \vini\bovespa\Bovespa;

error_reporting(E_ALL);

include_once('vendor/autoload.php');

if(file_exists('install/install.php')){
	include_once 'install/install.php';
}
$app = new Bovespa;
$app->render('app/default.template.php');
