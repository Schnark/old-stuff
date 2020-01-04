#!/bin/sh

#bzip2
#-dkc "~{src}"

bzcat $1 | perl /home/michael/Documents/wikidata.pl

