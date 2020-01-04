#!/usr/bin/perl
#zcat dewiki-20121117-all-titles-in-ns0.gz | perl -CIOE willnicht.pl
use strict;

$| = 1;

while (<>) {
print if grep {$_ > 60000} unpack('U*', $_);
}