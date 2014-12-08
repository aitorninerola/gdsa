<?php
session_start();
if(empty($_SESSION['dir'])) header("Location: index.php");
?>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Documento sin título</title>
<link rel="stylesheet" type="text/css" href="estil.css">
</head>

<body>
<div class="seccions"><h2>SED proves grup 3.1</h2></div>
<hr>
<div class="seccions">
<p>Paràmetres</p>
<form id="form2" name="form2" method="post">
        <label for="select2">KNN:</label>
<select name="knn" required>
      <option value="1" <?php if(!isset($_POST["knn"]) or $_POST["knn"] == 1) echo "selected=\"selected\""; ?>>1</option>
      <option value="2" <?php if(isset($_POST["knn"]) and $_POST["knn"] == 2) echo "selected=\"selected\""; ?>>2</option>
      <option value="3"<?php if(isset($_POST["knn"]) and $_POST["knn"] == 3) echo "selected=\"selected\""; ?>>3</option>
      <option value="4"<?php if(isset($_POST["knn"]) and $_POST["knn"] == 4) echo "selected=\"selected\""; ?>>4</option>
      <option value="5"<?php if(isset($_POST["knn"]) and $_POST["knn"] == 5) echo "selected=\"selected\""; ?>>5</option>
      <option value="6"<?php if(isset($_POST["knn"]) and $_POST["knn"] == 6) echo "selected=\"selected\""; ?>>6</option>
      <option value="7"<?php if(isset($_POST["knn"]) and $_POST["knn"] == 7) echo "selected=\"selected\""; ?>>7</option>
      <option value="8"><?php if(isset($_POST["knn"]) and $_POST["knn"] == 8) echo "selected=\"selected\""; ?>8</option>
    </select>
    &nbsp;&nbsp;
<input name="executa" type="submit" id="submit" formaction="<?php echo $_SERVER['PHP_SELF'];?>" value="Executa">
<div class="seccions">
<?php
if(isset($_POST["executa"])){
	echo "<br>Analitzant... <br>";
require('connexio.php');
global $tags, $score;
$categories = array(0=>"concert",1=>"conference",2=>"exhibition",3=>"fashion",4=>"other",5=>"protest",6=>"sports",7=>"theater_dance",8=>"non_event");
$dirn = ($_SESSION["dir"] != 1) ? "/img/train-1/" : "/img/train-2/";
$knn = (isset($_POST["knn"])) ? $_POST["knn"] : 1;

function tags($id, $mysqli){
	$sql = "SELECT tag FROM gdsa_tags WHERE document_id =\"".$id."\";";
		$tags = "";
		if($resultat2 = $mysqli->query($sql)){
			while($fila2 = $resultat2->fetch_assoc()){
				$tags .= " " . $fila2["tag"];
			}
		}
}

$tic = time();
$dir = getcwd().$dirn; // img/train-2 prova
$img = scandir($dir);
$llista= "";
	foreach($img as $val){ if(preg_match('/.txt/i', $val)) $llista .= "\"".basename($val, '.txt')."\","; } //emplena la llista d'elements a mostrar
	$llista .= "\"\""; //afageix un element buit per l'última coma

$sql = "
	SELECT D.document_id, D.date_taken, D.title, D.latitude, D.longitude, C.event_type
	FROM gdsa_datainfo D JOIN gdsa_classified C 
	ON D.document_id = 	C.document_id 
	WHERE D.document_id IN(".$llista.");";
if($resultat = $mysqli->query($sql)){
	while($fila = $resultat->fetch_assoc()){
		tags($fila["document_id"],$mysqli);
		$coord = (!empty($fila["latitude"]) and !empty($fila["longitude"])) ? "".$fila["latitude"] . " " . $fila["longitude"] : "";
		$text = "\"" .$fila["title"] . " " . $tags . " " .$coord. " " .$fila["date_taken"] . "\"";
		
		$sql = "
		SELECT classe, MATCH (titol,etiquetes,coord,captura)  AGAINST (".$text." IN BOOLEAN MODE) as score FROM gdsa_dades ORDER BY score DESC LIMIT ".intval($knn).";
		";
		if($resultat2 = $mysqli->query($sql)){
		$score = array("concert"=>0,"conference"=>0,"exhibition"=>0,"fashion"=>0,"other"=>0,"protest"=>0,"sports"=>0,"theater_dance"=>0,"non_event"=>0 );
			while($fila2 = $resultat2->fetch_assoc()){
				$score[trim($fila2["classe"])]++;
			}
			$insert[] = '("'.$fila["document_id"].'","'.trim(array_search(max($score),$score)).'","'.trim($fila["event_type"]).'")';
		}
	}
} echo "Dades analitzades.<br><br>";

if($mysqli->query("TRUNCATE TABLE gdsa_confmat")){
$query = 'INSERT INTO gdsa_confmat (document, etiqueta, categoria) VALUES '.implode(',', $insert);
if($mysqli->query($query)) echo "Matriu de confusió creada correctament:<br><br>"; else echo "NO s'ha pogut crear la matriu de confusió.";

for($i = 0; $i < 9; $i++){
	for($j=0; $j < 9; $j++){
		$sql = "SELECT count(*) AS total FROM gdsa_confmat WHERE categoria=\"".$categories[$i]."\" AND etiqueta=\"".$categories[$j]."\";";
		if($resultat = $mysqli->query($sql)){ while($fila = $resultat->fetch_assoc()) $val = $fila["total"];}
		$resnum[$i][$j] = (!empty($val)) ? $val : 0; 
	}	
}
}

echo '
<table width="1000" border="1" cellspacing="0" align="center" >
  <tbody>
    <tr>
      <td align="center">-</td>
      <td><b>concert</b></td>
      <td><b>conference</b></td>
      <td><b>exhibition</b></td>
      <td><b>fashion</b></td>
      <td><b>other</b></td>
      <td><b>protest</b></td>
      <td><b>sports</b></td>
      <td><b>theater_dance</b></td>
      <td><b>non_event</b></td>
    </tr>
	';
for($i = 0; $i < 9; $i++){
	echo'
	<tr><td><b>'.$categories[$i].'</td></b>';
		for($j=0; $j < 9; $j++){
			echo'
		  <td align="center">'.$resnum[$i][$j].'</td>
		  ';
		}
		echo '</tr>';
}
echo '</tbody></table>';
$t = abs($tic - time());
echo "<br>Temps emprat: $t s";
}
?>
<p>
 <a href="index.php"><input name="button" type="button" class="formulari"  value="&lt;&lt;&lt;" /></a>
</p>
</div>
</body>
</html>