#! /usr/bin/perl -w

use strict;
use DB_File;
use MLDBM qw(DB_File Storable);

sub lst { #translate lst into Wiki/HTML
local $_ = $_[0];

#deutsche Lokalisierung
s/&lt;abschnitt\s+anfang/&lt;section begin/ig;
s/&lt;abschnitt\s+ende/&lt;section end/ig;
# Anfang durch ein #ifeq ersetzen, nur wenn der übergebene Parameter (default: text, egal ob groß oder klein) stimmt oder die Seite direkt betrachtet wird anzeigen
if (s!&lt;section\s+begin=(?:&quot;)?([^\s&]*)(?:&quot;)?\s*/\s*&gt;!&lt;includeonly&gt;{{#ifeq:{{{1|text}}}|$1|&lt;/includeonly&gt;!g) {
   s/\{\{#ifeq:\{\{\{1\|text\}\}\}\|Text\|/{{#ifeq:{{{1|Text}}}|Text|/g;
#Striche escapen
   s/\|/""/g;
   s/(\{\{[^}]*)""/$1|/mg;
   s/""/{{{!}}}/g;
}
s!&lt;section\s+begin\s*/\s*&gt;!!g;
# Ende schließen
s!&lt;section\s+end[^/]*/\s*&gt;!&lt;includeonly&gt;|}}&lt;/includeonly&gt;!ig;
# lst ist damit überflüssig
s/\{\{#lst:/{{:/g;

$_[0] = $_;
}

sub other {
local $_ = $_[0];

s/\[\[WP:/[[Wikipedia:/g;
s/\[\[P:/[[Portal:/g;

$_[0] = $_;
}

my $category1 = "Category"; #canonical name for category
my $category2 = $category1; #localised name (will be set from XML-Dump

my $defaultsort1 = "DEFAULTSORT"; #canonical name for defaultsort
my $defaultsort2 = $defaultsort1; #localised name

my %defaultsort = ( de => "SORTIERUNG" ); #localised defaultsort by languages

my %category_desc;    #will contain text of a category
tie (%category_desc, "DB_File", undef) or die "Error!"; #tie hash to file on disk, it consumes *very much* memoriy
%category_desc = ();

my %category_subcat;  #will contain all subcategories of a category
tie (%category_subcat, "MLDBM", undef) or die "Error!"; #tie hash to file on disk, it consumes *very much* memoriy
%category_subcat = ();

my %category_content; #will contain all pages of a category
tie (%category_content, "MLDBM", undef) or die "Error!"; #tie hash to file on disk, it consumes *very much* memoriy
%category_content = ();

$/="</siteinfo>";
my $header = <>; #read header
print $header;

$category2 = $1 if $header =~ m!<namespace key="14"[^>]*>(.*)</namespace>!; #get localised category
if ($header =~ /xml:lang="(.*)"/) {
   $defaultsort2 = $defaultsort{$1} || $defaultsort1; #get localised defaultsort
}

$/="</page>";
while (my $page = <>) { #for every page
  last if $page =~ m!</mediawiki>!;
  $page =~ m!<title>(.*)</title>!; #get title
  my $title = $1;
  my $is_cat = ($title =~ /^$category2:/o) ? 1:0; #is it a category?

  #poem($page);

  if ($is_cat) {
     $category_desc{$title} = $page; #if yes, then store it for later
  } else {
     print $page;
  }
  $page =~ s/^.*<text//s; #get rid of metadata, ...
  $page =~ s!&lt;\s*nowiki\s*&gt;.*?&lt;\s*/\s*nowiki\s*&gt;!!sg; #... nowikis, ...
  $page =~ s/&lt;!--.*?--&gt;//sg; #... comments, ...
  $page =~ s!&lt;\s*includeonly\s*&gt;.*?&lt;\s*/\s*includeonly\s*&gt;!!sg; # ... and includeonlys
# TODO: correct nesting

  my $sort = $title;
  $sort = $1 if $page =~ /\{\{(?:$defaultsort1|$defaultsort2):\s*(.*)\}\}/o; #get the default sortkey for this page

  while ($page =~ /\[\[(?:$category1|$category2):\s*(\S[^\]]*)\]\]/goi) { #for every category
    my $cat = $1;
    my $this_sort = $sort;
    $this_sort = $1 if $cat =~ s/\s*\|(.*)$//; #get special sortkey
    $cat =~ s/_/ /g; #underscore to space
    $cat =~ s/%([0-9A-Fa-f][0-9A-Fa-f])/chr(hex($1))/ge; #hex to chars
    $cat = $category2.":".$cat;

    my $entry = [$this_sort, $title]; #put entry in hash
    if ($is_cat) {
       my $temp = exists $category_subcat{$cat} ? $category_subcat{$cat} : [];
       push @$temp, $entry;
       $category_subcat{$cat} = $temp;
    } else {
       my $temp = exists $category_content{$cat} ? $category_content{$cat} : [];
       push @$temp, $entry;
       $category_content{$cat} = $temp;
    }
  }
}

while (my ($cat, $desc) = each (%category_desc)) { #print out all categories
  $desc =~ s!<text xml:space="preserve" />!<text xml:space="preserve">!; #empty cats
  $desc =~ s!</text>.*$!!s;
  print $desc; #description
  if ($category_subcat{$cat}) {foreach my $subcat (sort {$a->[0] cmp $b->[0]} @{$category_subcat{$cat}}) {
     $subcat = $subcat->[1];
     print "\n* [[:$subcat]]"; }} #subcategories
  if ($category_content{$cat}) {foreach my $content (sort {$a->[0] cmp $b->[0]} @{$category_content{$cat}}) {
     $content = $content->[1];
     print "\n* [[$content]]"; }} #pages
  print "</text></revision></page>"; #end
}
print "</mediawiki>";
untie %category_desc;
untie %category_subcat;
untie %category_content;