<?php // connexio a la base de dades
$host = "localhost";
$user = "root";
$pass = "";
$db_name = "mediaeval";

$mysqli = new mysqli($host, $user, $pass, $db_name);
if ($mysqli->connect_errno) {
    echo "DB Connection error: (" . $mysqli->connect_errno . ")";
}
?>