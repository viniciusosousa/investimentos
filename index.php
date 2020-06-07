<?php
use \vini\bovespa\bovespa;

error_reporting(E_ALL);

spl_autoload_register(function (String $class)
{
    $vendor = 'vini';
	$file = str_replace($vendor, __DIR__, $class).'.php';
    $file = str_replace('\\', DIRECTORY_SEPARATOR, $file);
    //echo $file."\n";
	if (file_exists($file)) {
        require($file);
        }
});

$app = new Bovespa;
$app->render('app/default.template.php');