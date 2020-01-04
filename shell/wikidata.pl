#!/usr/bin/perl

# Usage: edit @keepLangs and @keepWiki to decide which items should be kept
# bzcat wikidatawiki-latest-pages-articles.xml.bz2 | perl wikidata.pl > wikidatawiki-latest-pages-articles.xml

use strict;

my @keepLangs = (); #keep all items that have a label/description in one of these languages
my @keepWiki = ('dewiki'); #keep all items that have a link to one of these wikis

my $re = join ('|', @keepLangs, @keepWiki);
$re = qr/&quot;(?:$re)&quot;/;

$/ = '</siteinfo>'; #read header
my $header = <>;
print $header;
$/ = '</page>';

my $title;

while (my $page = <>) {
#last if ($. eq 100); #for testing

$title = '';
$title = $1 if ($page =~ m!<title>(.*)</title>!);
last if ($title eq '');

next if ($title eq 'Q6293548'); #Special:RecentChanges

if ($title =~ /:/ || $page =~ $re) {
	print $page;
}

}

print '</mediawiki>';