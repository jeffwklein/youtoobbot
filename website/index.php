<?php 



$array = get_keywords();
$keys_str = '';
foreach ($array as $key) {
	 $keys_str .= "<option value='$key'>$key</option>";
}		


print_start_screen($_POST['fail']);

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

function print_start_screen($alert) {
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

				var options = \"$keys_str\"; 

				cell1.innerHTML = \"<input type=text class='form-control' name=\" + name_s + \"/>\";
				cell2.innerHTML = \"<select class='form-control' name=\" + bool_s + \" id ='\" + bool_s + \"' disabled><option value='OR'>OR</option><option value='AND'>AND</option></select>\";
				
				var id = \"bool\" + (tot-1);
				document.getElementById(id).disabled=false;
			}
			function del_row() {
				var myTable = document.getElementById('mytable');
				if(myTable.rows.length > 2){	
					var del_i   = myTable.rows.length - 1;
					myTable.deleteRow(del_i);
				
					var id  = \"bool\" + (del_i-1);
					document.getElementById(id).disabled = true;
				}
				else{
					alert('Can only delete if there is more than one row');
				}
			}

			</script>
	</head>
	";
	if($alert){
		print "<script>alert('Must have only one word per text box, but atleast one')</script>";
	}
	print "
	<center>
		<div class='jumbotron' align=center>
			<H1 align=center>Boolean Reddit Youtoobbot Search</H1>
			<form action='/youtoobbot/results.php'>
				<table class='table' align=center id='mytable' style='width:500px'>
					<tr>
						<th style='width:100px'>Keywords</th>
						<th style='width:50px'>Boolean Value</th>
					</tr>
					<tr>
						<td>
							<input class='form-control' name=key1 type=text>	
							</input>
						</td>
						<td>
							<select class='form-control' name=bool1 id='bool1' disabled>
								<option value='OR'>OR</option>
								<option value='AND'>AND</option>
							</select>
						</td>
					</tr>
				</table>
				<a class='btn btn-primary btn-sm' style='margin-bottom:10px' onclick='add_row()'>Add Row</a>
				<a class='btn btn-danger btn-sm' style='margin-bottom:10px; margin-left:10px;' onclick='del_row()'>Delete Last Row</a><BR>
				<BR>
				<H4 align=center>Sort By</H4>
				<table align=center>
					<tr align=left><td><input name=sort value='title' type='radio' checked>Title A-Z</input></td></tr>
					<tr align=left><td><input name=sort value='views' type='radio'>Youtube View Count</input></td></tr>
					<tr align=left><td><input name=sort value='votes' type='radio'>Reddit Vote Count</input></td></tr>
				</table>
				<BR>
				<button type=submit class='btn btn-success btn-lg' align='center'>Search</button>
			</form>
		</div>
	</center>
	</html>";
}

?>
