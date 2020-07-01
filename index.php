<?php
use \vini\bovespa\bovespa;

error_reporting(E_ALL);

spl_autoload_register(function (String $class)
{
    //echo "\r\nclass: ".$class."\n";
	$vendor = 'vini';
	$file = str_replace($vendor, __DIR__, $class).'.php';

    $file = str_replace('\\', DIRECTORY_SEPARATOR, $file);
    //echo "\r\npath: ".$file."\n";
	if (file_exists($file)) {
        require($file);
        }
});
if(file_exists('install/install.php')){
	include_once 'install/install.php';
}
$app = new Bovespa;
$app->render('app/default.template.php');