<?php 

$array = get_keywords();
$keys_str = '';
foreach ($array as $key) {
	 $keys_str .= "<option value='$key'>$key</option>";
}		


print_start_screen($keys_str);

function get_keywords(){
	
	$return_str;
	$array;

	$db = new mysqli('localhost','root', '', 'youtoob');

	$the_stm  = "Select * FROM yt_keys";
	$sth = $db->prepare($the_stm);
	$sth->bind_result($key);
	$sth->execute();
	
	$i=0;
	while($sth->fetch()){
		$array[$i] = $key;
		$i++;	
	}

	return $array;
}

function print_start_screen($keys_str) {
	print "
	<!DOCTYPE html>
	<head>
		<link href='../css/bootstrap.css' rel='stylesheet' media='screen'>
		<script>
			function add_row() {
				var myTable = document.getElementById('mytable');
				var tot     = myTable.rows.length;
				var newRow  = myTable.insertRow(tot);
				var name_s  = \"key\" + tot; 
				var bool_s  = \"bool\" + tot;
			
				var cell1 = newRow.insertCell(0);
				var cell2 = newRow.insertCell(1);

				alert('dd');

				var options = \"$keys_str\"; 

				cell1.innerHTML = \"<select class='form-control' name=\" + name_s + \" >\" + options + \"</select>\";
				cell2.innerHTML = \"<select class='form-control' name=\" + bool_s + \" ><option value=''>Select</option><option value='or'>OR</option><option value='and'>AND</option></select>\";

			}

			function runScript(e) {
				    if (e.keyCode == 13) {
			        var tb = document.getElementById('row-add');
			         eval(tb.value);
			         add_row();
						return false;
				    }
			}

		</script>
	</head>
	<center>
		<div class='jumbotron' align=center>
			<H1 align=center>Boolean Reddit Youtoobbot Search</H1>
			<form action='/youtoobbot/results.php'>
				<table class='table' align=center id='mytable'>
					<tr>
						<th style='width:100px'>Keywords</th>
						<th style='width:50px'>Boolean Value</th>
					</tr>
					<tr>
						<td>
							<select class='form-control' name=key1>$keys_str	
							</select>
						</td>
						<td>
							<select class='form-control' name=bool1>
								<option value=''>Select</option>
								<option value='or'>OR</option>
								<option value='and'>AND</option>
							</select>
						</td>
					</tr>
				</table>
				<a class='btn btn-primary btn-sm' style='margin-bottom:10px' onclick='add_row()'>Add Row</a><BR>
				<button type=submit class='btn btn-success btn-lg' align='center'>Search</button>
			</form>
		</div>
	</center>
	</html>";
}

?>
