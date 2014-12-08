<?php if(!isset($_POST["executa"])) header("Location: sed.php"); ?>
<?php
session_start();
$_SESSION['dir']=$_REQUEST['train'];

$tic = time();

$dir = ($_SESSION['dir'] == 1) ? "/img/train-1/" : "/img/train-2/";

global $tags;
require('connexio.php');

$dir1 = getcwd().$dir;
$img1 = scandir($dir1);
$list = "";

foreach($img1 as $val){
	if(preg_match('/.txt/i', $val))
	$list .= "\"".basename($val, '.txt')."\",";
}

$list .= "\"\"";

$sql = "SELECT D.document_id, D.date_taken, D.title, D.latitude, D.longitude, C.event_type 
FROM gdsa_datainfo D join gdsa_classified C 
ON C.document_id = D.document_id
AND D.document_id IN(".$list.");";
if($resultat = $mysqli->query($sql)){
	while($fila = $resultat->fetch_assoc()){
		$sql = "SELECT tag FROM gdsa_tags WHERE document_id =\"".$fila["document_id"]."\";";
		$tags = "";
		if($resultat2 = $mysqli->query($sql)){
			while($fila2 = $resultat2->fetch_assoc()){
				$tags .= " " . $fila2["tag"];
			}
		}
		
	//inserir les dades
	$coord = $fila["latitude"] . " " .$fila["longitude"];
	$insert[] = "(\"".$fila["document_id"]."\",\"".$mysqli->real_escape_string($fila["title"])."\",\"".$mysqli->real_escape_string($tags)."\",\"".$coord."\",\"".$fila["date_taken"]."\",\"".trim($fila["event_type"])."\")";
	}
	$mysqli->query("TRUNCATE TABLE gdsa_dades");
	$sql = 'INSERT INTO gdsa_dades (document, titol, etiquetes, coord, captura, classe) VALUES '.implode(',',$insert);
	if($mysqli->query($sql)) echo "<p>Entrenament correcte."; else echo "<p>ERROR en l'entrenament. ";	
}
$t = abs($tic - time());
echo "&nbsp;&nbsp;Temps emprat: $t s</p>";
echo '
</form>

</div>
';

?>
<?php header("Location: classificador.php"); ?>
