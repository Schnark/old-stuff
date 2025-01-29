<html>
<head>
<title>Auswertung</title>
</head>
<body>
<?PHP 
if (!(isset($_POST["senden"]))){
echo "Dies ist die Auswertungsseite!<br>\n";
echo 'Die Eingabemaske befindet sich <a href="maske.php">hier</a>!';
}
else {
echo "<h3>Auswertung</h3><br>\n";

// wichtige Daten einlesen
$nummer_=$_POST["SNr"];
$vorname_=$_POST["vorname"];
$nachname_=$_POST["nachname"];
$passwort_=$_POST["PW"];

// nicht wichtige Daten auf Existenz prüfen
daten=array( "Gebdatum" => 0,
             "Bild"     => 0,
             "Hobbys"   => 0,
             "allg"     => 0,
             "EMail"    => 0);

if ($_POST["e_geb"]="1") {daten["Gebdatum"]=1;};
if ($_POST["e_dat"]="1") {daten["Bild"]=1;};
if ($_POST["e_hob"]="1") {daten["Hobbys"]=1;};
if ($_POST["e_allg"]="1") {daten["allg"]=1;};
if ($_POST["e_em"]="1") {daten["EMail"]=1;};

$geb_tag=0; $geb_monat=0; $geb_jahr=0;
$bild_=""; $hobbys_=""; $allg_=""; $email_="";

// existierende Daten einlesen
if (daten["Gebdatum"]==1) {$geb_tag=$_POST["tag"];
                           $geb_monat=$_POST["monat"];
                           $geb_jahr=$_POST["jahr"];};
if (daten["Bild"]==1) {$bild_=$_POST["datei"];};
if (daten["Hobbys"]==1) {$hobbys_=$_POST["hobbys"];};
if (daten["allg"]==1) {$allg_=$_POST["allg"];};
if (daten["EMail"]==1) {$email_=$_POST["email"];};

// evt. Sonderzeichen (<, >, ...) in HTML umwandeln
if ($_POST["code"]="Text") {
$hobbys_=htmlspecialchars($hobbys_);
$allg_=htmlspecialchars($allg_);};

// Zeilenumbrüche einfügen und Schrägstriche (/", /', ...) entfernen
$hobbys_=mysql_escape_string(stripslashes(nl2br($hobbys_)));
$allg_=mysql_escape_string(stripslashes(nl2br($allg_)));


$datenbank=""; $tabelle=""; // Tabelle in der Datenbank
$SQL="UPDATE $tabelle SET";
if (daten["Gebdatum"]==1) {$SQL+=" tag=$geb_tag, monat=$geb_monat, jahr=$geb_jahr";};
if (daten["Bild"]==1) {$SQL+=" bild='$datei_'";};
if (daten["Hobbys"]==1) {$SQL+=" hobbys='$hobbys_'";};
if (daten["allg"]==1) {$SQL+=" allg='$allg_'";};
if (daten["email"]==1) {$SQL+=" email='$email_'";};
$SQL+=" WHERE nr=$SNr"; // SQL-Befehl zum ändern

// verbinden und Daten auf Korrektheit überprüfen
$host="localhost"; $user=$SNr_, $Passwort=$passwort_;
mysql_connect($host,$user,$Passwort) or die("Keine Berechtigung um Datenbank aufzurufen!");
mysql_select_db($datenbank) or die("Fehler beim Aufruf der Datenbank!");
$ergebnis=mysql_query("SELECT vorname, nachname FROM $tabelle WHERE nr=$SNr);
$ergebnis=mysql_fetch_assoc($ergebnis);
if (!(($ergebnis["vorname"]==$vorname)&&($ergebnis["nachname"]==$nachname))) {die ("Daten stimmen nicht überein!");}

if (daten["Bild"]==1) {
// Bilddatei kopieren
$verzeichnis=""; //Verzeichnis für die Datei
$extension=substr($datei_,strrpos($datei_,".")); // Endung der Datei
// Datei erhält als Namen die Schülernummer
$datei_=$verzeichnis."/".$SNr_.$extension;
if file_exists($datei_) {unlink($datei_);};
copy($datei,$datei_) or die("Fehler beim Kopieren der Datei");
};

mysql_query($SQL); // Daten aktualisieren
mysql_close();
echo "Die Daten wurden eingetragen.<br>\n";
echo "<a href='javascript:history.back'>Zurück</a>\n";
}?>
</body>
</html>