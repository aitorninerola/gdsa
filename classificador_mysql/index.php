<!doctype html>
<html>
<head>
<meta charset="utf-8">
<link rel="stylesheet" type="text/css" href="estil.css">
<title>Documento sin título</title>
</head>

<body>
<div class="seccions"><h2>SED proves grup 3.1</h2></div><hr>
<div class="seccions"><p>Carrega les dades d'entrenament  </p>
<form id="form1" name="fentr" method="post" action="classificador.php">
  Entrenament:
    <input name="train" type="radio" required="required" id="train1" value="1" <?php if(isset($_POST["train"]) and $_POST["train"]==1) echo 'checked' ?>> 
    Train 1&nbsp;&nbsp;
    <input name="train" type="radio" required="required" id="train2" value="2" <?php if(isset($_POST["train"]) and $_POST["train"]==2) echo 'checked' ?>> Train 2&nbsp;&nbsp;
<input name="carrega" type="submit" id="carrega" form="form1" formaction="pasarela.php" value="Carrega">
  </p>

  </form>
</div>
</body>
</html>