#!/usr/bin/perl

=for nobody
$magicWords = array(
	'redirect'                => array( '0', '#WEITERLEITUNG', '#REDIRECT' ),
	'notoc'                   => array( '0', '__KEIN_INHALTSVERZEICHNIS__', '__KEININHALTSVERZEICHNIS__', '__NOTOC__' ),
	'nogallery'               => array( '0', '__KEINE_GALERIE__', '__KEINEGALERIE__', '__NOGALLERY__' ),
	'forcetoc'                => array( '0', '__INHALTSVERZEICHNIS_ERZWINGEN__', '__FORCETOC__' ),
	'toc'                     => array( '0', '__INHALTSVERZEICHNIS__', '__TOC__' ),
	'noeditsection'           => array( '0', '__ABSCHNITTE_NICHT_BEARBEITEN__', '__NOEDITSECTION__' ),
	'noheader'                => array( '0', '__KEINKOPF__', '__KEIN_HEADER__', '__KEIN_KOPF__', '__KEINHEADER__', '__NOHEADER__' ),
	'currentmonth'            => array( '1', 'JETZIGER_MONAT', 'JETZIGER_MONAT_2', 'CURRENTMONTH', 'CURRENTMONTH2' ),
	'currentmonth1'           => array( '1', 'JETZIGER_MONAT_1', 'CURRENTMONTH1' ),
	'currentmonthname'        => array( '1', 'JETZIGER_MONATSNAME', 'CURRENTMONTHNAME' ),
	'currentmonthnamegen'     => array( '1', 'JETZIGER_MONATSNAME_GENITIV', 'CURRENTMONTHNAMEGEN' ),
	'currentmonthabbrev'      => array( '1', 'JETZIGER_MONATSNAME_KURZ', 'CURRENTMONTHABBREV' ),
	'currentday'              => array( '1', 'JETZIGER_KALENDERTAG', 'CURRENTDAY' ),
	'currentday2'             => array( '1', 'JETZIGER_KALENDERTAG_2', 'CURRENTDAY2' ),
	'currentdayname'          => array( '1', 'JETZIGER_WOCHENTAG', 'CURRENTDAYNAME' ),
	'currentyear'             => array( '1', 'JETZIGES_JAHR', 'CURRENTYEAR' ),
	'currenttime'             => array( '1', 'JETZIGE_UHRZEIT', 'CURRENTTIME' ),
	'currenthour'             => array( '1', 'JETZIGE_STUNDE', 'CURRENTHOUR' ),
	'localmonth'              => array( '1', 'LOKALER_MONAT', 'LOKALER_MONAT_2', 'LOCALMONTH', 'LOCALMONTH2' ),
	'localmonth1'             => array( '1', 'LOKALER_MONAT_1', 'LOCALMONTH1' ),
	'localmonthname'          => array( '1', 'LOKALER_MONATSNAME', 'LOCALMONTHNAME' ),
	'localmonthnamegen'       => array( '1', 'LOKALER_MONATSNAME_GENITIV', 'LOCALMONTHNAMEGEN' ),
	'localmonthabbrev'        => array( '1', 'LOKALER_MONATSNAME_KURZ', 'LOCALMONTHABBREV' ),
	'localday'                => array( '1', 'LOKALER_KALENDERTAG', 'LOCALDAY' ),
	'localday2'               => array( '1', 'LOKALER_KALENDERTAG_2', 'LOCALDAY2' ),
	'localdayname'            => array( '1', 'LOKALER_WOCHENTAG', 'LOCALDAYNAME' ),
	'localyear'               => array( '1', 'LOKALES_JAHR', 'LOCALYEAR' ),
	'localtime'               => array( '1', 'LOKALE_UHRZEIT', 'LOCALTIME' ),
	'localhour'               => array( '1', 'LOKALE_STUNDE', 'LOCALHOUR' ),
	'numberofpages'           => array( '1', 'SEITENANZAHL', 'NUMBEROFPAGES' ),
	'numberofarticles'        => array( '1', 'ARTIKELANZAHL', 'NUMBEROFARTICLES' ),
	'numberoffiles'           => array( '1', 'DATEIANZAHL', 'NUMBEROFFILES' ),
	'numberofusers'           => array( '1', 'BENUTZERANZAHL', 'NUMBEROFUSERS' ),
	'numberofactiveusers'     => array( '1', 'AKTIVE_BENUTZER', 'NUMBEROFACTIVEUSERS' ),
	'numberofedits'           => array( '1', 'BEARBEITUNGSANZAHL', 'NUMBEROFEDITS' ),
	'numberofviews'           => array( '1', 'BETRACHTUNGEN', 'NUMBEROFVIEWS' ),
	'pagename'                => array( '1', 'SEITENNAME', 'PAGENAME' ),
	'pagenamee'               => array( '1', 'SEITENNAME_URL', 'PAGENAMEE' ),
	'namespace'               => array( '1', 'NAMENSRAUM', 'NAMESPACE' ),
	'namespacee'              => array( '1', 'NAMENSRAUM_URL', 'NAMESPACEE' ),
	'talkspace'               => array( '1', 'DISKUSSIONSNAMENSRAUM', 'DISK_NR', 'TALKSPACE' ),
	'talkspacee'              => array( '1', 'DISKUSSIONSNAMENSRAUM_URL', 'DISK_NR_URL', 'TALKSPACEE' ),
	'subjectspace'            => array( '1', 'HAUPTNAMENSRAUM', 'SUBJECTSPACE', 'ARTICLESPACE' ),
	'subjectspacee'           => array( '1', 'HAUPTNAMENSRAUM_URL', 'SUBJECTSPACEE', 'ARTICLESPACEE' ),
	'fullpagename'            => array( '1', 'VOLLER_SEITENNAME', 'FULLPAGENAME' ),
	'fullpagenamee'           => array( '1', 'VOLLER_SEITENNAME_URL', 'FULLPAGENAMEE' ),
	'subpagename'             => array( '1', 'UNTERSEITE', 'SUBPAGENAME' ),
	'subpagenamee'            => array( '1', 'UNTERSEITE_URL', 'SUBPAGENAMEE' ),
	'basepagename'            => array( '1', 'OBERSEITE', 'BASEPAGENAME' ),
	'basepagenamee'           => array( '1', 'OBERSEITE_URL', 'BASEPAGENAMEE' ),
	'talkpagename'            => array( '1', 'DISKUSSIONSSEITE', 'DISK', 'TALKPAGENAME' ),
	'talkpagenamee'           => array( '1', 'DISKUSSIONSSEITE_URL', 'DISK_URL', 'TALKPAGENAMEE' ),
	'subjectpagename'         => array( '1', 'HAUPTSEITE', 'SUBJECTPAGENAME', 'ARTICLEPAGENAME' ),
	'subjectpagenamee'        => array( '1', 'HAUPTSEITE_URL', 'SUBJECTPAGENAMEE', 'ARTICLEPAGENAMEE' ),
	'subst'                   => array( '0', 'ERS:', 'SUBST:' ),
	'safesubst'               => array( '0', 'SICHER_ERS:', 'SICHERERS:', 'SAFESUBST:' ),
	'img_thumbnail'           => array( '1', 'miniatur', 'mini', 'thumbnail', 'thumb' ),
	'img_manualthumb'         => array( '1', 'miniatur=$1', 'mini=$1', 'thumbnail=$1', 'thumb=$1' ),
	'img_right'               => array( '1', 'rechts', 'right' ),
	'img_left'                => array( '1', 'links', 'left' ),
	'img_none'                => array( '1', 'ohne', 'none' ),
	'img_center'              => array( '1', 'zentriert', 'center', 'centre' ),
	'img_framed'              => array( '1', 'gerahmt', 'framed', 'enframed', 'frame' ),
	'img_frameless'           => array( '1', 'rahmenlos', 'frameless' ),
	'img_page'                => array( '1', 'seite=$1', 'seite_$1', 'page=$1', 'page $1' ),
	'img_upright'             => array( '1', 'hochkant', 'hochkant=$1', 'hochkant $1', 'upright', 'upright=$1', 'upright $1' ),
	'img_border'              => array( '1', 'rand', 'border' ),
	'img_baseline'            => array( '1', 'grundlinie', 'baseline' ),
	'img_sub'                 => array( '1', 'tiefgestellt', 'tief', 'sub' ),
	'img_super'               => array( '1', 'hochgestellt', 'hoch', 'super', 'sup' ),
	'img_top'                 => array( '1', 'oben', 'top' ),
	'img_text_top'            => array( '1', 'text-oben', 'text-top' ),
	'img_middle'              => array( '1', 'mitte', 'middle' ),
	'img_bottom'              => array( '1', 'unten', 'bottom' ),
	'img_text_bottom'         => array( '1', 'text-unten', 'text-bottom' ),
	'img_link'                => array( '1', 'verweis=$1', 'link=$1' ),
	'img_alt'                 => array( '1', 'alternativtext=$1', 'alt=$1' ),
	'int'                     => array( '0', 'NACHRICHT:', 'INT:' ),
	'sitename'                => array( '1', 'PROJEKTNAME', 'SITENAME' ),
	'ns'                      => array( '0', 'NR:', 'NS:' ),
	'nse'                     => array( '0', 'NR_URL:', 'NSE:' ),
	'localurl'                => array( '0', 'LOKALE_URL:', 'LOCALURL:' ),
	'localurle'               => array( '0', 'LOKALE_URL_C:', 'LOCALURLE:' ),
	'articlepath'             => array( '0', 'ARTIKELPFAD', 'ARTICLEPATH' ),
	'scriptpath'              => array( '0', 'SKRIPTPFAD', 'SCRIPTPATH' ),
	'stylepath'               => array( '0', 'STILPFAD', 'STYLEPFAD', 'STYLEPATH' ),
	'grammar'                 => array( '0', 'GRAMMATIK:', 'GRAMMAR:' ),
	'gender'                  => array( '0', 'GESCHLECHT:', 'GENDER:' ),
	'notitleconvert'          => array( '0', '__KEINE_TITELKONVERTIERUNG__', '__NOTITLECONVERT__', '__NOTC__' ),
	'nocontentconvert'        => array( '0', '__KEINE_INHALTSKONVERTIERUNG__', '__NOCONTENTCONVERT__', '__NOCC__' ),
	'currentweek'             => array( '1', 'JETZIGE_KALENDERWOCHE', 'CURRENTWEEK' ),
	'currentdow'              => array( '1', 'JETZIGER_WOCHENTAG_ZAHL', 'CURRENTDOW' ),
	'localweek'               => array( '1', 'LOKALE_KALENDERWOCHE', 'LOCALWEEK' ),
	'localdow'                => array( '1', 'LOKALER_WOCHENTAG_ZAHL', 'LOCALDOW' ),
	'revisionid'              => array( '1', 'REVISIONSID', 'REVISIONID' ),
	'revisionday'             => array( '1', 'REVISIONSTAG', 'REVISIONDAY' ),
	'revisionday2'            => array( '1', 'REVISIONSTAG2', 'REVISIONDAY2' ),
	'revisionmonth'           => array( '1', 'REVISIONSMONAT', 'REVISIONMONTH' ),
	'revisionmonth1'          => array( '1', 'REVISIONSMONAT1', 'REVISIONMONTH1' ),
	'revisionyear'            => array( '1', 'REVISIONSJAHR', 'REVISIONYEAR' ),
	'revisiontimestamp'       => array( '1', 'REVISIONSZEITSTEMPEL', 'REVISIONTIMESTAMP' ),
	'revisionuser'            => array( '1', 'REVISIONSBENUTZER', 'REVISIONUSER' ),
	'fullurl'                 => array( '0', 'VOLLSTÄNDIGE_URL:', 'FULLURL:' ),
	'fullurle'                => array( '0', 'VOLLSTÄNDIGE_URL_C:', 'FULLURLE:' ),
	'canonicalurl'            => array( '0', 'KANONISCHE_URL:', 'CANONICALURL:' ),
	'canonicalurle'           => array( '0', 'KANONISCHE_URL_C:', 'CANONICALURLE:' ),
	'lcfirst'                 => array( '0', 'INITIAL_KLEIN:', 'LCFIRST:' ),
	'ucfirst'                 => array( '0', 'INITIAL_GROSS:', 'UCFIRST:' ),
	'lc'                      => array( '0', 'KLEIN:', 'LC:' ),
	'uc'                      => array( '0', 'GROSS:', 'UC:' ),
	'raw'                     => array( '0', 'ROH:', 'RAW:' ),
	'displaytitle'            => array( '1', 'SEITENTITEL', 'DISPLAYTITLE' ),
	'newsectionlink'          => array( '1', '__NEUER_ABSCHNITTSLINK__', '__PLUS_LINK__', '__NEWSECTIONLINK__' ),
	'nonewsectionlink'        => array( '1', '__KEIN_NEUER_ABSCHNITTSLINK__', '__KEIN_PLUS_LINK__', '__NONEWSECTIONLINK__' ),
	'currentversion'          => array( '1', 'JETZIGE_VERSION', 'CURRENTVERSION' ),
	'urlencode'               => array( '0', 'URLENKODIERT:', 'URLENCODE:' ),
	'anchorencode'            => array( '0', 'ANKERENKODIERT:', 'SPRUNGMARKEENKODIERT:', 'ANCHORENCODE' ),
	'currenttimestamp'        => array( '1', 'JETZIGER_ZEITSTEMPEL', 'CURRENTTIMESTAMP' ),
	'localtimestamp'          => array( '1', 'LOKALER_ZEITSTEMPEL', 'LOCALTIMESTAMP' ),
	'directionmark'           => array( '1', 'TEXTAUSRICHTUNG', 'DIRECTIONMARK', 'DIRMARK' ),
	'language'                => array( '0', '#SPRACHE:', '#LANGUAGE:' ),
	'contentlanguage'         => array( '1', 'INHALTSSPRACHE', 'CONTENTLANGUAGE', 'CONTENTLANG' ),
	'pagesinnamespace'        => array( '1', 'SEITEN_IM_NAMENSRAUM:', 'SEITEN_IN_NR:', 'SEITEN_NR:', 'PAGESINNAMESPACE:', 'PAGESINNS:' ),
	'numberofadmins'          => array( '1', 'ADMINANZAHL', 'NUMBEROFADMINS' ),
	'formatnum'               => array( '0', 'ZAHLENFORMAT', 'FORMATNUM' ),
	'padleft'                 => array( '0', 'FÜLLENLINKS', 'PADLEFT' ),
	'padright'                => array( '0', 'FÜLLENRECHTS', 'PADRIGHT' ),
	'special'                 => array( '0', 'spezial', 'special' ),
	'defaultsort'             => array( '1', 'SORTIERUNG:', 'DEFAULTSORT:', 'DEFAULTSORTKEY:', 'DEFAULTCATEGORYSORT:' ),
	'filepath'                => array( '0', 'DATEIPFAD:', 'FILEPATH:' ),
	'tag'                     => array( '0', 'markierung', 'tag' ),
	'hiddencat'               => array( '1', '__VERSTECKTE_KATEGORIE__', '__WARTUNGSKATEGORIE__', '__HIDDENCAT__' ),
	'pagesincategory'         => array( '1', 'SEITEN_IN_KATEGORIE', 'SEITEN_KAT', 'PAGESINCATEGORY', 'PAGESINCAT' ),
	'pagesize'                => array( '1', 'SEITENGRÖSSE', 'PAGESIZE' ),
	'index'                   => array( '1', '__INDIZIEREN__', '__INDEX__' ),
	'noindex'                 => array( '1', '__NICHT_INDIZIEREN__', '__NOINDEX__' ),
	'numberingroup'           => array( '1', 'BENUTZER_IN_GRUPPE', 'NUMBERINGROUP', 'NUMINGROUP' ),
	'staticredirect'          => array( '1', '__PERMANENTE_WEITERLEITUNG__', '__STATICREDIRECT__' ),
	'protectionlevel'         => array( '1', 'SCHUTZSTATUS', 'PROTECTIONLEVEL' ),
	'formatdate'              => array( '0', 'DATUMSFORMAT', 'formatdate', 'dateformat' ),
	'url_path'                => array( '0', 'PFAD', 'PATH' ),
	'url_query'               => array( '0', 'ABFRAGE', 'QUERY' ),
	'defaultsort_noerror'     => array( '0', 'keinfehler', 'noerror' ),
	'defaultsort_noreplace'   => array( '0', 'keineersetzung', 'noreplace' ),
);
=cut


use strict;

my ($bild, $datei, $image, $file) = (0, 0, 0, 0);
my ($redirect, $weiterleitung)  = (0, 0);
my ($sortierung, $defaultsort, $defaultsortkey, $defaultcategorysort) = (0, 0, 0, 0);
my ($seitentitel, $displaytitle) = (0, 0);
my ($thumb, $thumbnail, $miniatur, $mini, $thumb_, $thumbnail_, $miniatur_, $mini_, $hochkant, $upright, $px, $left, $links, $right, $rechts, $center, $centre, $zentriert, $none, $ohne, $baseline, $grundlinie, $sub, $tiefgestellt, $tief, $super, $sup, $hochgestellt, $hoch, $top, $oben, $textTop, $textOben, $middle, $mitte, $bottom, $unten, $textBottom, $textUnten, $gerahmt, $framed, $enframed, $frame, $rand, $border, $rahmenlos, $frameless, $alt, $alternativtext, $verweis, $link, $seite, $page) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

$/="</siteinfo>"; #Header überlesen
my $header = <>;
$/="</page>";

my ($title, $text);

while (my $page = <>) {

$text = "";
$text = $1 if ($page =~ m!<text[^>]*>(.*)</text>!s);

$sortierung++ if ($text =~ /\{\{SORTIERUNG:/);
$defaultsort++ if ($text =~ /\{\{DEFAULTSORT:/);
$defaultsortkey++ if ($text =~ /\{\{DEFAULTSORTKEY:/);
$defaultcategorysort++ if ($text =~ /\{\{DEFAULTCATEGORYSORT:/);
$weiterleitung++ if ($text =~ /^#WEITERLEITUNG/i);
$redirect++ if ($text =~ /^#REDIRECT/i);
$seitentitel++ if ($text =~ /\{\{SEITENTITEL:/);
$displaytitle++ if ($text =~ /\{\{DISPLAYTITLE:/);

while ($text =~ /\[\[\s*((?:datei|bild|image|file):[^\[\]]+(?:\[\[[^\[\]]+\]\][^\[\]]*)*\])\]/gi) {
my $media = $1;
$media =~ s/\[\[[^\[\]]+\]\]/((_))/g;

$bild++ if ($media =~ /^bild/i);
$datei++ if ($media =~ /^datei/i);
$image++ if ($media =~ /^image/i);
$file++ if ($media =~ /^file/i);

$thumb++ if ($media =~ /\|\s*thumb\s*[\]\|]/);
$thumbnail++ if ($media =~ /\|\s*thumbnail\s*[\]\|]/);
$miniatur++ if ($media =~ /\|\s*miniatur\s*[\]\|]/);
$mini++ if ($media =~ /\|\s*mini\s*[\]\|]/);
$thumb_++ if ($media =~ /\|\s*thumb=/);
$thumbnail_++ if ($media =~ /\|\s*thumbnail=/);
$miniatur_++ if ($media =~ /\|\s*miniatur=/);
$mini_++ if ($media =~ /\|\s*mini=/);
$hochkant++ if ($media =~ /\|\s*hochkant\s*[ =\]\|]/);
$upright++ if ($media =~ /\|\s*upright\s*[ =\]\|]/);
$px++ if ($media =~ /\|\s*\d*\s*x?\s*\d+\s*px\s*[\]\|]/);

$left++ if ($media =~ /\|\s*left\s*[\]\|]/);
$links++ if ($media =~ /\|\s*links\s*[\]\|]/);
$right++ if ($media =~ /\|\s*right\s*[\]\|]/);
$rechts++ if ($media =~ /\|\s*rechts\s*[\]\|]/);
$center++ if ($media =~ /\|\s*center\s*[\]\|]/);
$centre++ if ($media =~ /\|\s*centre\s*[\]\|]/);
$zentriert++ if ($media =~ /\|\s*zentriert\s*[\]\|]/);
$none++ if ($media =~ /\|\s*none\s*[\]\|]/);
$ohne++ if ($media =~ /\|\s*ohne\s*[\]\|]/);

$baseline++ if ($media =~ /\|\s*baseline\s*[\]\|]/);
$grundlinie++ if ($media =~ /\|\s*grundlinie\s*[\]\|]/);
$sub++ if ($media =~ /\|\s*sub\s*[\]\|]/);
$tiefgestellt++ if ($media =~ /\|\s*tiefgestellt\s*[\]\|]/);
$tief++ if ($media =~ /\|\s*tief\s*[\]\|]/);
$super++ if ($media =~ /\|\s*super\s*[\]\|]/);
$sup++ if ($media =~ /\|\s*sup\s*[\]\|]/);
$hochgestellt++ if ($media =~ /\|\s*hochgestellt\s*[\]\|]/);
$hoch++ if ($media =~ /\|\s*hoch\s*[\]\|]/);
$top++ if ($media =~ /\|\s*top\s*[\]\|]/);
$oben++ if ($media =~ /\|\s*oben\s*[\]\|]/);
$textTop++ if ($media =~ /\|\s*text-top\s*[\]\|]/);
$textOben++ if ($media =~ /\|\s*text-oben\s*[\]\|]/);
$middle++ if ($media =~ /\|\s*middle\s*[\]\|]/);
$mitte++ if ($media =~ /\|\s*mitte\s*[\]\|]/);
$bottom++ if ($media =~ /\|\s*bottom\s*[\]\|]/);
$unten++ if ($media =~ /\|\s*unten\s*[\]\|]/);
$textBottom++ if ($media =~ /\|\s*text-bottom\s*[\]\|]/);
$textUnten++ if ($media =~ /\|\s*text-unten\s*[\]\|]/);

$gerahmt++ if ($media =~ /\|\s*gerahmt\s*[\]\|]/);
$framed++ if ($media =~ /\|\s*framed\s*[\]\|]/);
$enframed++ if ($media =~ /\|\s*enframed\s*[\]\|]/);
$frame++ if ($media =~ /\|\s*frame\s*[\]\|]/);
$rand++ if ($media =~ /\|\s*rand\s*[\]\|]/);
$border++ if ($media =~ /\|\s*border\s*[\]\|]/);
$frameless++ if ($media =~ /\|\s*frameless\s*[\]\|]/);
$rahmenlos++ if ($media =~ /\|\s*rahmenlos\s*[\]\|]/);

$alt++ if ($media =~ /\|\s*alt=/);
$alternativtext++ if ($media =~ /\|\s*alternativtext=/);

$verweis++ if ($media =~ /\|\s*verweis=/);
$link++ if ($media =~ /\|\s*link=/);

$seite++ if ($media =~ /\|\s*seite[ =]/);
$page++ if ($media =~ /\|\s*page[ =]/);
}
}

my $gesamt = 0;
my $allebilder = 0;

$gesamt = $sortierung + $defaultsort + $defaultsortkey + $defaultcategorysort;
$gesamt = 1 if ($gesamt == 0);
printf " SORTIERUNG:  %d (%.0f %%)\n", $sortierung, 100 * $sortierung / $gesamt;
printf " DEFAULTSORT: %d (%.0f %%)\n", $defaultsort, 100 * $defaultsort / $gesamt;
printf " DEFAULTSORTKEY: %d (%.0f %%)\n", $defaultsortkey, 100 * $defaultsortkey / $gesamt if ($defaultsortkey > 0);
printf " DEFAULTCATEGORYSORT: %d (%.0f %%)\n", $defaultcategorysort, 100 * $defaultcategorysort / $gesamt if ($defaultcategorysort > 0);
print  " gesamt:      $gesamt\n\n";

$gesamt = $weiterleitung + $redirect;
$gesamt = 1 if ($gesamt == 0);
printf " REDIRECT:      %d (%.0f %%)\n", $redirect, 100 * $redirect / $gesamt;
printf " WEITERLEITUNG: %d (%.0f %%)\n", $weiterleitung, 100 * $weiterleitung / $gesamt;
print  " gesamt:      $gesamt\n\n";

$gesamt = $seitentitel + $displaytitle;
$gesamt = 1 if ($gesamt == 0);
printf " DISPLAYTITLE: %d (%.0f %%)\n", $displaytitle, 100 * $displaytitle / $gesamt;
printf " SEITENTITEL:  %d (%.0f %%)\n", $seitentitel, 100 * $seitentitel / $gesamt;
print  " gesamt:       $gesamt\n\n";

$gesamt = $datei + $bild + $file + $image;
$gesamt = 1 if ($gesamt == 0);
$allebilder = $gesamt;
printf " Datei:  %d (%.0f %%)\n", $datei, 100 * $datei / $gesamt;
printf " Bild:     %d (%.0f %%)\n", $bild, 100 * $bild / $gesamt;
printf " File:     %d ( %.0f %%)\n", $file, 100 * $file / $gesamt;
printf " Image:     %d ( %.0f %%)\n", $image, 100 * $image / $gesamt;
print  " gesamt: $gesamt\n\n";

$gesamt = $thumb + $thumbnail + $miniatur + $mini + $thumb_ + $thumbnail_ + $miniatur_ + $mini_;
$gesamt = 1 if ($gesamt == 0);
printf " miniatur: %d (%.0f %%)\n", $miniatur, 100 * $miniatur / $gesamt;
printf " mini:     %d (%.0f %%)\n", $mini, 100 * $mini / $gesamt;
printf " thumb:    %d (%.0f %%)\n", $thumb, 100 * $thumb / $gesamt;
printf " thumbnail:  %d (%.0f %%)\n", $thumbnail, 100 * $thumbnail / $gesamt;
printf " thumbnail=:    %d ( %.0f %%)\n", $thumbnail_, 100 * $thumbnail_ / $gesamt;
printf " thumb=:         %d ( %.0f %%)\n", $thumb_, 100 * $thumb_ / $gesamt;
printf " miniatur=:      %d ( %.0f %%)\n", $miniatur_, 100 * $miniatur_ / $gesamt;
printf " mini=:          %d ( %.0f %%)\n", $mini_, 100 * $mini_ / $gesamt if ($mini_ > 0);
printf " gesamt: %d (%.0f %% aller Bilder)\n\n", $gesamt, 100 * $gesamt / $allebilder;

$gesamt = $hochkant + $upright;
$gesamt = 1 if ($gesamt == 0);
printf " hochkant: %d (%.0f %%)\n", $hochkant, 100 * $hochkant / $gesamt;
printf " upright:   %d (%.0f %%)\n", $upright, 100 * $upright / $gesamt;
printf " gesamt:   %d (%.0f %% aller Bilder)\n\n", $gesamt, 100 * $gesamt / $allebilder;

printf " px: %d (%.0f %% aller Bilder)\n\n", $px, 100 * $px / $allebilder;

$gesamt = $left + $links + $right + $rechts + $center + $centre + $zentriert + $none + $ohne;
$gesamt = 1 if ($gesamt == 0);
printf " links:     %d (%.0f %%)\n", $links, 100 * $links / $gesamt;
printf " left:      %d (%.0f %%)\n", $left, 100 * $left / $gesamt;
printf " right:     %d (%.0f %%)\n", $right, 100 * $right / $gesamt;
printf " rechts:    %d (%.0f %%)\n", $rechts, 100 * $rechts / $gesamt;
printf " center:    %d (%.0f %%)\n", $center, 100 * $center / $gesamt;
printf " centre:       %d ( %.0f %%)\n", $centre, 100 * $centre / $gesamt;
printf " zentriert: %d ( %.0f %%)\n", $zentriert, 100 * $zentriert / $gesamt;
printf " none:       %d ( %.0f %%)\n", $none, 100 * $none / $gesamt;
printf " ohne:       %d ( %.0f %%)\n", $ohne, 100 * $ohne / $gesamt;
printf " gesamt:   %d (%.0f %% aller Bilder)\n\n", $gesamt, 100 * $gesamt / $allebilder;

$gesamt = $baseline + $grundlinie + $sub + $tiefgestellt + $tief + $super + $sup + $hochgestellt + $hoch + $top + $oben + $textTop + $textOben + $middle + $mitte + $bottom + $unten + $textBottom + $textUnten;
$gesamt = 1 if ($gesamt == 0);
printf " baseline:   %d (%.0f %%)\n", $baseline, 100 * $baseline / $gesamt;
printf " grundlinie:   %d ( %.0f %%)\n", $grundlinie, 100 * $grundlinie / $gesamt if ($grundlinie > 0);
printf " sub:        %d (%.0f %%)\n", $sub, 100 * $sub / $gesamt;
printf " tiefgestellt: %d ( %.0f %%)\n", $tiefgestellt, 100 * $tiefgestellt / $gesamt if ($tiefgestellt > 0);
printf " tief:         %d ( %.0f %%)\n", $tief, 100 * $tief / $gesamt if ($tief > 0);
printf " super:        %d ( %.0f %%)\n", $super, 100 * $super / $gesamt;
printf " sup:          %d ( %.0f %%)\n", $sup, 100 * $sup / $gesamt;
printf " hochgestellt: %d ( %.0f %%)\n", $hochgestellt, 100 * $hochgestellt / $gesamt if ($hochgestellt > 0);
printf " hoch:        %d ( %.0f %%)\n", $hoch, 100 * $hoch / $gesamt if ($hoch > 0);
printf " top:         %d ( %.0f %%)\n", $top, 100 * $top / $gesamt;
printf " oben:        %d ( %.0f %%)\n", $oben, 100 * $oben / $gesamt if ($oben > 0);
printf " text-top:    %d ( %.0f %%)\n", $textTop, 100 * $textTop / $gesamt;
printf " text-oben:    %d ( %.0f %%)\n", $textOben, 100 * $textOben / $gesamt if ($textOben > 0);
printf " middle:     %d (%.0f %%)\n", $middle, 100 * $middle / $gesamt;
printf " mitte:      %d (%.0f %%)\n", $mitte, 100 * $mitte / $gesamt if ($mitte > 0);
printf " bottom:      %d ( %.0f %%)\n", $bottom, 100 * $bottom / $gesamt;
printf " unten:       %d ( %.0f %%)\n", $unten, 100 * $unten / $gesamt if ($unten > 0);
printf " text-bottom: %d ( %.0f %%)\n", $textBottom, 100 * $textBottom / $gesamt;
printf " text-unten:   %d ( %.0f %%)\n", $textUnten, 100 * $textUnten / $gesamt if ($textUnten > 0);
printf " gesamt:     %d (%.0f %% aller Bilder)\n\n", $gesamt, 100 * $gesamt / $allebilder;

$gesamt = $gerahmt + $framed + $enframed + $frame;
$gesamt = 1 if ($gesamt == 0);
printf " framed:   %d (%.0f %%)\n", $framed, 100 * $framed / $gesamt;
printf " enframed: %d (%.0f %%)\n", $enframed, 100 * $enframed / $gesamt if ($enframed > 0);
printf " frame:    %d (%.0f %%)\n", $frame, 100 * $frame / $gesamt;
printf " gerahmt:  %d (%.0f %%)\n", $gerahmt, 100 * $gerahmt / $gesamt;
printf " gesamt: %d (%.0f %% aller Bilder)\n\n", $gesamt, 100 * $gesamt / $allebilder;

$gesamt = $rand + $border;
$gesamt = 1 if ($gesamt == 0);
printf " border: %d (%.0f %%)\n", $border, 100 * $border / $gesamt;
printf " rand:    %d (%.0f %%)\n", $rand, 100 * $rand / $gesamt;
printf " gesamt: %d (%.0f %% aller Bilder)\n\n", $gesamt, 100 * $gesamt / $allebilder;

$gesamt = $rahmenlos + $frameless;
$gesamt = 1 if ($gesamt == 0);
printf " rahmenlos: %d (%.0f %%)\n", $rahmenlos, 100 * $rahmenlos / $gesamt;
printf " frameless:  %d (%.0f %%)\n", $frameless, 100 * $frameless / $gesamt;
printf " gesamt:    %d (%.0f %% aller Bilder)\n\n", $gesamt, 100 * $gesamt / $allebilder;

$gesamt = $verweis + $link;
$gesamt = 1 if ($gesamt == 0);
printf " link:    %d (%.0f %%)\n", $link, 100 * $link / $gesamt;
printf " verweis: %d (%.0f %%)\n", $verweis, 100 * $verweis / $gesamt;
printf " gesamt:  %d (%.0f %% aller Bilder)\n\n", $gesamt, 100 * $gesamt / $allebilder;

$gesamt = $alt + $alternativtext;
$gesamt = 1 if ($gesamt == 0);
printf " alt:         %d (%.0f %%)\n", $alt, 100 * $alt / $gesamt;
printf " alternativtext: %d ( %.0f %%)\n", $alternativtext, 100 * $alternativtext / $gesamt;
printf " gesamt:      %d (%.0f %% aller Bilder)\n\n", $gesamt, 100 * $gesamt / $allebilder;

$gesamt = $seite + $page;
$gesamt = 1 if ($gesamt == 0);
printf " seite:  %d (%.0f %%)\n", $seite, 100 * $seite / $gesamt if ($seite > 0);
printf " page:   %d (%.0f %%)\n", $page, 100 * $page / $gesamt if ($page > 0);
printf " gesamt: %d (%.0f %% aller Bilder)\n\n", $gesamt, 100 * $gesamt / $allebilder;