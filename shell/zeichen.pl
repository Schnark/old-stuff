#!/usr/bin/perl

#bzcat /media/mm151/dewiki-20100903-pages-articles.xml.bz2 | perl -CIOE ~/bin/fehlerliste.pl | less

use strict;

sub output {
local $_ = '';
my $last = -2;
foreach my $i (@_) {
	if ($last + 1 != $i) {
		$_ .= "-$last $i"
	}
	$last = $i;
}
$_ .= "-$last";
s/^--2//;
s/\b(\d+)-\1\b/$1/g;
print;
print "\n\n";
}

$| = 1;

my %seen = ();
while (<>) {
@seen{unpack('U*', $_)} = ();
output(sort {$a <=> $b} keys %seen) unless ($. % 1000000);
}

output(sort {$a <=> $b} keys %seen);