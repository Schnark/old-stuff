#!/usr/bin/perl

#bzcat /media/mm151/dewiki-20100903-pages-articles.xml.bz2 | perl -CIOE ~/bin/fehlerliste.pl | less

use strict;

sub ausgabe {
my ($tag, $title) = @_;
$title = ':'.$title if ($title =~ /^(Kategorie:|Datei:)/);
$title = '[['.$title.']]';
print '<<'.$tag.'>> '.$title."\n";
}

$/="</siteinfo>"; #Header überlesen
my $header = <>;
$/="</page>";

my ($title, $text);

while (my $page = <>) {
#if ($. eq 2000) {last};     #zum Testen

$title = "";
$title = $1 if ($page =~ m!<title>(.*)</title>!);
$text = "";
$text = $1 if ($page =~ m!<text[^>]*>(.*)</text>!s);

$text =~ s/&lt;/</g;
$text =~ s/&gt;/>/g;
$text =~ s/&quot;/"/g;
$text =~ s/&amp;/&/g;

ausgabe('1', $title) if ($text =~ /hintergrundfarbe10/);
ausgabe('2', $title) if ($text =~ /imagemap-inline/);
ausgabe('3', $title) if ($text =~ /metadata[^-]/);
ausgabe('4', $title) if ($text =~ /metadata-label/);
ausgabe('5', $title) if ($text =~ /NavEnd/);
ausgabe('6', $title) if ($text =~ /nogrid/);
ausgabe('7', $title) if ($text =~ /palaeobox/);
}