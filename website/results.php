<?php

$keyword_keys = array_keys($_GET);
print_r($keys);

$stm = "Select * From youtoob_table Where ";

foreach ($keys as $akey){
	$keyword = $_GET[$akey];
	$stm .= "keywords like '%$keyword%'  ";
}
$stm = rtrim($stm," AND");

print $stm;


?>
