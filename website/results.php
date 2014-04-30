<?php

$sort = $_GET['sort'];

$keyword_keys = array_keys($_GET);
array_pop($keyword_keys);

sort($keyword_keys);

$bool_array = array();


$half = count($keyword_keys)/2;
for($i=0; $i<$half-1; $i++){
	$bool_array[$i] = array_shift($keyword_keys);
}

$stm = "Select * From youtoob_table Where ";

for($j=0; $j<count($keyword_keys); $j++){
	$keyword = $_GET[$keyword_keys[$j]];
	if($_GET[$bool_array[$j]]) $bool    = $_GET[$bool_array[$j]];
	else $bool = '';
	$stm .= "keywords like '%$keyword%' $bool ";
}

$stm = rtrim($stm," AND");
$stm = rtrim($stm," OR");
$stm = rtrim($stm);
/*
$db = new mysqli('localhost','root', '', 'youtoob');

$sth = $db->prepare($stm);
$sth->bind_result();
$sth->execute();

$results_hash;
while($sth->fetch()){
	$results_hash[] = array();
}
*/

print "
	<!DOCTYPE html>
		<head>
			<title>Search Results</title>
			<link href='../css/bootstrap.css' rel='stylesheet' media='screen'>
		</head>
		<div class='jumbotron' align=center>
			<a href='./index.php' class='btn btn-lg btn-primary' align=center>Home</a>
			<p>$stm</p>
			<table border=1>";

print "
			</table>
		</div>
	</html>";


?>
