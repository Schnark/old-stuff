#!/usr/bin/perl
# autorenliste.pl
# Autor: Michael Müller (<https://de.wikipedia.org/wiki/Benutzer:Schnark>)
# Aktualisiert <https://de.wikisource.org/wiki/Liste_der_Autoren>
# Aufruf: bzcat dewikisource-latest-pages-articles.xml.bz2 | autorenliste.pl > ausgabe.txt
use strict;

sub parsedate {
my $string = $_[0];
$string =~ s!&lt;ref(?: .*?)?&gt;.*?&lt;/ref&gt;!!g;
# ref's entfernen, stören nur

$string =~ m/(?:(Mitte|Ende|2. Hälfte)(?:\s+des)?\s+)?(\d\d?)\.?\s*J(?:ahr)?h[^v]*(v.*Chr)?/;
my $mitteende = $1;
my $jahrhundert = $2;
my $vchr = $3 && "-";

if ($jahrhundert) {
   $jahrhundert-- unless ($vchr);
   $jahrhundert *= -1 if ($vchr);
   $jahrhundert *= 100;
   $jahrhundert += 50 if ($mitteende eq "Mitte" or $mitteende eq "2. Hälfte");
   $jahrhundert += 99 if ($mitteende eq "Ende");
   $jahrhundert += 9999 if ($vchr);
   $jahrhundert = substr("0000$jahrhundert", -4);
   return "$vchr$jahrhundert-00-00";
}
$string =~ m"(?!.*(?:\boder\b|/).*\d{4})(?:(\d\d?)(?:\.|\s)\s*)?(?:(\d\d?|Jan|Jän|Feb|Mär|Apr|Mai|Jun|Jul|Aug|Sep|Okt|Nov|Dez)[^\d]+)?(\d{1,4})[^v]*(v.*Chr)?";
#           oder und / ignorieren,...      Tag    Trenner          Monat                                                              Jahr          v. Chr.
#        ... falls noch ein Jahr folgt
my $tag = substr("00$1",-2);

my $monat = $2;
$monat =  1 if ($monat eq "Jan");
$monat =  1 if ($monat eq "Jän");
$monat =  2 if ($monat eq "Feb");
$monat =  3 if ($monat eq "Mär");
$monat =  4 if ($monat eq "Apr");
$monat =  5 if ($monat eq "Mai");
$monat =  6 if ($monat eq "Jun");
$monat =  7 if ($monat eq "Jul");
$monat =  8 if ($monat eq "Aug");
$monat =  9 if ($monat eq "Sep");
$monat = 10 if ($monat eq "Okt");
$monat = 11 if ($monat eq "Nov");
$monat = 12 if ($monat eq "Dez");
$monat = substr("00$monat",-2);

$vchr = $4 && "-";

my $jahr = $3;
$jahr = 9999-$jahr if ($vchr);
$jahr = substr("0000$jahr", -4);
$jahr = "!" if ($jahr eq "0000");

return "$vchr$jahr-$monat-$tag";

#Datum:
#unbekanntes Jahr:     !-mm-dd
# vor Christus:    -yyyy-mm-dd  (yyyy ist 9999 - Jahr v. Chr.
#nach Christus:     yyyy-mm-dd

}

my @ausgabe = ();

my $seite;                    #Titel der Seite
my $istautor;                 #Ist Seite Autor?
my ($vorname, $nachname);     #Vor- und Nachname
my ($geb, $gest);             #Geburts- und Todesdatum
my $besch;                    #Beschreibung

my $letzeaenderung;

while (<>) {                  #zeilenweise einlesen
#if ($. eq 100000) {last};     #zum Testen
chomp;

$letzeaenderung = $1 if (m!<timestamp>(.*)</timestamp>! && $1 gt $letzeaenderung);

if (m!<title>(.*)</title>!) { #beim Titel alle Werte zurücksetzen
$seite = $1;
$istautor = 0;
$vorname = ""; $nachname = "";
$geb = ""; $gest = "";
$besch = "";
next;
}

$istautor = 1 if /\{\{Personendaten/;          #Vorlage Personendaten -> Autor
$istautor = 0 if /(?:^|\|)\s*PERSON\s*=\s*\S/; #PERSON=               -> kein Autor

$vorname  = $1 if $istautor and /(?:^|\|)\s*VORNAMEN\s*=(.*)$/;
$nachname = $1 if $istautor and /(?:^|\|)\s*NACHNAME\s*=(.*)$/;
$besch    = $1 if $istautor and /(?:^|\|)\s*KURZBESCHREIBUNG\s*=(.*)$/;
$geb      = $1 if $istautor and /(?:^|\|)\s*GEBURTSDATUM\s*=(.*)$/;
$gest     = $1 if $istautor and /(?:^|\|)\s*STERBEDATUM\s*=(.*)$/;

if (m!</text>!) { #am Textende auswerten
if ($istautor and ($vorname or $nachname) and $seite !~ /Wikisource:/) {
$vorname  =~ s/^\s*//; $vorname  =~ s/\s*$//;
$nachname =~ s/^\s*//; $nachname =~ s/\s*$//;
$besch    =~ s/^\s*//; $besch    =~ s/\s*$//;
$geb      =~ s/^\s*//; $geb      =~ s/\s*$//;
$gest     =~ s/^\s*//; $gest     =~ s/\s*$//;

$nachname .= ", " if $vorname and $nachname;
$nachname .= $vorname;

my $temp = $nachname;
$temp =~ s/Ä/Ae/g; $temp =~ s/ä/ae/g;
$temp =~ s/Ö/Oe/g; $temp =~ s/ö/oe/g;
$temp =~ s/Ü/Ue/g; $temp =~ s/ü/ue/g;
$temp =~ s/ß/ss/g;
$temp =~ s/Æ/Ae/g; $temp =~ s/æ/ae/g;
$temp =~ s/Ø/Oe/g; $temp =~ s/ø/oe/g;
$temp =~ s/ő/oe/g;
$temp =~ s/Á/A/g; $temp =~ s/á/a/g;
$temp =~ s/À/A/g; $temp =~ s/à/a/g;
$temp =~ s/ă/a/g;
$temp =~ s/ç/c/g;
$temp =~ s/č/c/g;
$temp =~ s/Ć/C/g; $temp =~ s/ć/c/g;
$temp =~ s/É/E/g; $temp =~ s/é/e/g;
$temp =~ s/È/E/g; $temp =~ s/è/e/g;
$temp =~ s/Ë/E/g; $temp =~ s/ë/e/g;
$temp =~ s/Ł/L/g; $temp =~ s/ł/l/g;
$temp =~ s/ř/r/g;
$temp =~ s/Ó/O/g; $temp =~ s/ó/o/g;
$temp =~ s/Ò/O/g; $temp =~ s/ò/o/g;
$temp =~ s/Ô/O/g; $temp =~ s/ô/o/g;
$temp =~ s/Š/S/g; $temp =~ s/š/s/g;
$temp =~ s/Þ/Th/g; $temp =~ s/þ/th/g;
$temp =~ s/Ý/Y/g; $temp =~ s/ý/y/g;
$temp =~ s/ž/z/g;
$temp =~ s/’//g;

my $name = "data-sort-value=\"$temp\" | [[$seite|$nachname]]";

$temp = parsedate($geb);
$geb = "data-sort-value=\"$temp\" | $geb";

$temp = parsedate($gest);
$gest = "data-sort-value=\"$temp\" | $gest";

push (@ausgabe, "|-\n| $name\n| $geb\n| $gest\n| $besch\n");
}
}
}

my $anzahl = scalar @ausgabe;
my ($jahr, $monat, $tag, $stunde, $minute, $sekunde) = $letzeaenderung =~ /(\d{4})-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)Z/;
$monat += 0; $tag += 0; $stunde += 0; #führende 0 entfernen
print <<EOH;
Diese Liste der Autoren enthält alle $anzahl Autoren, zu denen in Wikisource eine Autorenseite existiert<ref>Stand: $tag. $monat. $jahr, $stunde:$minute (UTC)</ref>.
Die Liste kann mit den Buttons neben den Spaltenüberschriften nach der jeweiligen Spalte sortiert werden.

<!--
Diese Liste wurde durch ein Computerprogramm erstellt, das die Daten verwendet, die aus den Infoboxen auf den Autorenseiten stammen.
Sollten daher Fehler vorhanden sein, sollten diese jeweils dort korrigiert werden.
-->
{| class="wikitable sortable"
! Name
! data-sort-type="text" | Geb.-datum
! data-sort-type="text" | Tod.-datum
! Beschreibung
EOH

my $inhalt;
foreach $inhalt (sort {lc($a) cmp lc($b);} @ausgabe) {
$inhalt =~ s/&gt;/>/g;
$inhalt =~ s/&lt;/</g;
$inhalt =~ s/&quot;/"/g;
$inhalt =~ s/&amp;/&/g;
print $inhalt;
}

print <<EOT;
|}

== Anmerkungen ==
<references />

[[Kategorie:Listen]]
EOT
