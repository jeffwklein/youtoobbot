<?php

include 'stemmer.php';

$sort = $_GET['sort'];

$keyword_keys = array_keys($_GET);
array_pop($keyword_keys);

sort($keyword_keys);

$bool_array = array();

$half = count($keyword_keys)/2;
for($i=0; $i<$half-1; $i++){
	$bool_array[$i] = array_shift($keyword_keys);
}

foreach ($keyword_keys as $the_key){
	if(preg_match('/ /', $_GET[$the_key]) ||  $_GET[$the_key] == ''){
		$url = "http://128.192.99.232/youtoobbot/index.php";
		$post_str = "fail=1";

		$ch = curl_init();

		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $post_str);

		$result = curl_exec($ch);
		curl_close($ch);
		exit;
	}
}

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

$stm = "Select * From yt_data Where ";

for($j=0; $j<count($keyword_keys); $j++){
	$word    = $_GET[$keyword_keys[$j]];
	$keyword = PorterStemmer::Stem($word);
	if($_GET[$bool_array[$j]]) $bool    = $_GET[$bool_array[$j]];
	else $bool = '';
	$stm .= "(keywords like '% $keyword %' or keywords like '$keyword %')  $bool ";
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
						<li><a href='$post_url'><b>Reddit Post</b></a></li>
						<li><b>Youtube Views</b> - $views</li>
						<li><b>Reddit Votes</b>  - $votes</li>
						<li><b>Keywords</b> - $keywords</li>
						<li><b>$date</b></li>
					</ul>
				</td>
			</tr>";
}


print "
			</table>
		</div>
	</html>";


?>
