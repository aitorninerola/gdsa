<?php // connexio a la base de dades
$host = "aitorninjqdatab.mysql.db";
$user = "aitorninjqdatab";
$pass = "92mpjB9fURgJ";
$db_name = "aitorninjqdatab";

$mysqli = new mysqli($host, $user, $pass, $db_name);
if ($mysqli->connect_errno) {
    echo "DB Connection error: (" . $mysqli->connect_errno . ")";
}
?>