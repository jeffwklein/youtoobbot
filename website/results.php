<?php

print "
	<!DOCTYPE html>
		<head>
			<title>Search Results</title>
			<link href='../css/bootstrap.css' rel='stylesheet' media='screen'>
		</head>
		<div class='jumbotron' align=center>
			<a href='./index.php' class='btn btn-lg btn-primary' align=center>Home</a>
			<H2>Search Results</H2>
			<p>$stm</p>
			<table class='table' style='width:600px;'>";

$sort = $_GET['sort'];

$keyword_keys = array_keys($_GET);
array_pop($keyword_keys);

sort($keyword_keys);

$bool_array = array();


$half = count($keyword_keys)/2;
for($i=0; $i<$half-1; $i++){
	$bool_array[$i] = array_shift($keyword_keys);
}

$stm = "Select * From yt_data Where ";

for($j=0; $j<count($keyword_keys); $j++){
	$keyword = $_GET[$keyword_keys[$j]];
	if($_GET[$bool_array[$j]]) $bool    = $_GET[$bool_array[$j]];
	else $bool = '';
	$stm .= "keywords like '%$keyword%' $bool ";
}

$stm = rtrim($stm," AND");
$stm = rtrim($stm," OR");
$stm = rtrim($stm);

if($sort == 'title') $stm .= ' ORDER BY title ASC';
if($sort == 'views') $stm .= ' ORDER BY views DESC';
if($sort == 'votes') $stm .= ' ORDER BY votes DESC';

print $stm;

$db = new mysqli('localhost','root', '', 'youtoob');

$sth = $db->prepare($stm);
$sth->bind_result($url, $title, $post_url, $date, $pic, $keywords, $views, $votes);
$sth->execute();

$results_hash;
while($sth->fetch()){
	print "<tr valign='middle'>
				<td align=right>
					<a class='' href='$url'/>
						<img src='$pic' style='width:200px; height:200px;' />
					</a>
				</td>
				<td align=left>
					<a href='$url'><H3>$title</H3></a>	
					<ul style='list-style-type: none;'>
						<li><a href='$post_url'>Reddit Post</a></li>
						<li>Youtube Views - $views</li>
						<li>Reddit Votes  - $votes</li>
						<li>Keywords - $keywords</li>
						<li>$date</li>
					</ul>
				</td>
			</tr>";
}


print "
			</table>
		</div>
	</html>";


?>
