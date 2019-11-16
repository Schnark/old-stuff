#!/usr/bin/perl
use strict;

#tr <gedichte.csv '\t' '$' | sort -t '$' -k 3b | tr '$' '\t' >gedichte.sort.csv
#perl <gedichte.sort.csv -ne '(undef, $autor, $titel, $anfang, $jahr, $bearb) = split(/\t/); print "|-\n| $autor\n| $titel\n| $anfang\n| $jahr\n| $bearb";' > gedichte.ausgabe

my %autoren = ("Albert Kleinschmidt" => "Kleinschmidt, Albert",
               "Alois Schreiber" => "Schreiber, Alois",
               "Amalie von Imhoff" => "Imhoff, Amalie von",
               "August Friedrich Ernst Langbein" => "Langbein, August Friedrich Ernst",
               "Bernhard Vermehren" => "Vermehren, Bernhard",
               "Hans Bötticher" => "Bötticher, Hans",
               "Louise Otto" => "Otto, Louise"); #Autoren (Weiterleitungen)
my @gedichte = (); #noch keine Gedichte
my %anfaenge = ("Karawane" => "jolifanto bambla ô falli bambla"); #nicht erkannte oder falsche Gedichtanfänge

my $seite; #Titel der Seite
my ($istautor, $istgedicht); #Ist Seite Autor oder Gedicht?
my ($vorname, $nachname); #Vor- und Nachname von Autoren
my ($titel,  $autor,  $jahr,  $bearb); #Titel, Autor, Jahr und Bearbeitungsstand bei Gedichten
my $anfang; #Gedichtanfang
my ($warteaufanfang, $zeile1, $zeile2, $zeile3, $zeile4); #Hilfsvar. für erste Zeile

while (<>) { #zeilenweise einlesen
#if ($. eq 100000) {last}; #zum Testen
chomp;
if (m!<title>(.*)</title>!) { #beim Titel alle Werte zurücksetzen
$seite = $1;
$istautor = 0; $istgedicht = 0;
$vorname = ""; $nachname = "";
$titel = ""; $autor = ""; $jahr = ""; $bearb = "";
$anfang = "";
$warteaufanfang = 0; $zeile1 = ""; $zeile2 = ""; $zeile3 = ""; $zeile4 = "";
next;
}

$istautor = 1 if (m/\{\{Personendaten/); #Vorlage Personendaten
$istgedicht = 1 if (m/\[\[Kategorie:Gedicht(\]\]|\|)/); #Kategorie Gedicht

$vorname = $1 if ($istautor and m/(?:^|\|)\s*VORNAMEN\s*=(.*)$/);
$nachname = $1 if ($istautor and m/(?:^|\|)\s*NACHNAME\s*=(.*)$/);

$titel = $1 if (m/(?:^|\|)\s*TITEL\s*=(.*)$/);
$autor = $1 if (m/(?:^|\|)\s*AUTOR\s*=(.*)$/);
$jahr = $1 if ($jahr eq "" and m/JAHR\s*=(.*)$/);
$bearb = $1 if (m/(?:^|\|)\s*BEARBEITUNGSSTAND\s*=(.*?)(?:\}\}|$)/);

$warteaufanfang = 1 if ($anfang eq "" and m/&lt;.*poem.*&gt;/);

if ($anfang eq "" and $warteaufanfang and not m/^\s*(?:&lt;.*poem.*&gt;)?\s*(?:\{\{LineCenter.*\}\})?\s*$/ )
           {$anfang = $_; $warteaufanfang = 0;}

$anfang = $zeile1 if (m/\{\{Zeile\|5\}\}/);

($zeile1, $zeile2, $zeile3, $zeile4) = ($zeile2, $zeile3, $zeile4, $_) if (not m/^:*\s*$/);

if (m!</text>!) { #am Textende auswerten
if ($istautor) {
$vorname =~ s/^\s*//; $vorname =~ s/\s*$//;
$nachname =~ s/^\s*//; $nachname =~ s/\s*$//;
$vorname =~ s!&lt;/?u&gt;!!g;
$nachname .= ", " if $vorname and $nachname;
$nachname .= $vorname;
$autoren{$seite} = $nachname;
}
if ($istgedicht) {
$titel =~ s/\t/ /g; $titel =~ s/^\s*//; $titel =~ s/\s*$//;
$autor =~ s/\t/ /g; $autor =~ s/^\s*//; $autor =~ s/\s*$//;
$autor = "[[".$1."]]" if $autor =~ m/\[\[(.*?)(?:\|.*)?\]\]/;
#$jahr  =~ s/\t/ /g; $jahr  =~ s/^\s*//; $jahr  =~ s/\s*$//;
if ($jahr =~ m/(\d\d\d\d(?:[-\/]\d+)?)/) {$jahr = $1;} else {$jahr = "";}
$bearb =~ s/\t/ /g; $bearb =~ s/^\s*//; $bearb =~ s/\s*$//;
$anfang =~ s/\t/ /g;
$anfang =~ s/'''//g;
$anfang =~ s/''//g;
$anfang =~ s!&lt;/?u&gt;!!g;
$anfang =~ s!&lt;/?center&gt;!!g;
$anfang =~ s!&lt;/?tt&gt;!!;
$anfang =~ s/^:*//;
$anfang =~ s/&lt;.*poem.*&gt;//;
$anfang =~ s/\{\{Seite[^}]*\}\}//;
$anfang =~ s/^\{\{idt[^}]*\}\}//gi;
$anfang =~ s/^\s*//; $anfang =~ s/\s*$//;
$anfang = $anfaenge{$seite} || $anfang;
push (@gedichte, "$seite\t$titel\t$autor\t$jahr\t$bearb\t$anfang");
}
}
}

#print "Name\tAutorenlink\tTitel\tAnfang\tJahr\tBearb.\n";
my ($inhalt, $name);
foreach $inhalt (@gedichte) {
($seite, $titel, $autor, $jahr, $bearb, $anfang) = split(/\t/, $inhalt);
if ($titel eq $seite) {$titel = "[[".$titel."]]";} else {$titel = "[[$seite|$titel]]";}
$name = $autor;
if ($autor =~ m/^\[\[.*\]\]$/) {
($name = $autor) =~ s/[\[\]]//g;
$name = $autoren{$name} if ($autoren{$name});
substr($autor, -2) = "";
$autor = "$autor|$name]]";
}
#$inhalt = "$name\t$autor\t$titel\t$anfang\t$jahr\t$bearb\n";
$inhalt = "$name\t$autor\t$titel\t$anfang\t$jahr\n";
$inhalt =~ s/&gt;/>/g;
$inhalt =~ s/&lt;/</g;
$inhalt =~ s/&quot;/"/g;
$inhalt =~ s/&amp;/&/g;
print $inhalt;
}