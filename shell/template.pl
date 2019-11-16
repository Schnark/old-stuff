#!/usr/bin/perl

use strict;

my $template = 'Infobox Krankenhaus';
my @params = ('Name', 'Logo', 'Logogrösse', 'Zugehörigkeit', 'Trägerschaft', 'Versorgungsstufe', 'Bettenzahl', 'Ort', 'Breitengrad', 'Längengrad', 'Region-ISO', 'Nebenbox', 'Bundesland', 'Kanton', 'Staat', 'Leitung', 'Leitungstitel', 'Mitarbeiterzahl', 'davon Ärzte', 'Fachgebiete', 'Jahresetat', 'Gründungsdatum', 'Website');

my $missing = '(fehlt)';
my $more = 'weitere Parameter';
my @templateNS = ('template', 'vorlage');

my $re;

sub print_head {
	print "\t$_" for (@params, $more);
	print "\n";
}

sub print_line {
	my %param = @_;
	for ('~~~~', @params) {
		my $val = $param{$_};
		if (defined $val) {
			delete $param{$_};
		} else {
			$val = $missing;
		}
		print "$val\t";
	}
	print join ', ', map {"$_=$param{$_}"} keys %param;
	print "\n";
}

sub read_template {
	my ($title, $text) = @_;
	my %param = ();

=for nobody
	$text =~ s/(<!--.*?-->|<nowiki>.*?<\/nowiki>)/
		$1 =~ s/\{\{/~~~~open/g
	/eg
	my @result = $text =~ /$re/o.exec(text.replace(/<!--.*?-->|<nowiki>.*?<\/nowiki>/g, function (all) {
				return all.replace(/\{\{/g, '~~~~open').replace(/\}\}/g, '~~~~close');
			}));


	if ($text =~ $re) {
		my $params = $1;
		$params =~ s/~~~~open/{{/g;
		$params =~ s/~~~~close/}}/g;
		$params =~ s/<!--\s*(?:\|[^=>]+=\s*)*-->\s*//g;

			.replace(/\n(\s*<!--[\s\S]*?-->)/g, function (all, $1) {
				return '\n|~~~~comment' + String(comments++) + '=' + $1;
			})
			.replace(/<!--.*?-->|<nowiki>.*?<\/nowiki>|\[\[.*?\]\]|\{\{[^{}]+\}\}/g, function (c) {
				return c.replace(/\|/g, '~~~~pipe');
			})

		var comments = 0, i, lastNL, afterNL;

		my @par = split '|', $params;

		for (i = 0; i < params.length; i++) {
			params[i] = params[i].replace(/~~~~pipe/g, '|');
			if (i === 0) {
				continue;
			}
			if (i !== params.length - 1) {
				params[i] = '|' + params[i];
			}
			lastNL = params[i - 1].lastIndexOf('\n');
			if (lastNL === -1) {
				lastNL = params[i - 1].search(/\s+$/);
			}
			if (lastNL > -1) {
				afterNL = params[i - 1].substr(lastNL);
				if (/^\s*(?:<!--[^\-]*-->\s*)*$/.test(afterNL)) {
					params[i] = afterNL + params[i];
					params[i - 1] = params[i - 1].substr(0, lastNL);
				}
			}
		}

		this.opening = params[0];
		this.closing = params.pop();

		var unnamed = 1;
		this.params = [];
		this.paramVals = {};
		for (i = 1; i < params.length; i++) {
			var pipe, name, equal, val;
			result = /^(\s*\|\s*)([^=]*[^=\s])(\s*=\s*)([\s\S]*)$/.exec(params[i]);
			if (result) {
				pipe = result[1];
				name = result[2];
				equal = result[3];
				val = result[4];
			} else if (allowUnnamed) {
				result = /^(\s*\|\s*)([\s\S]*)$/.exec(params[i]);
				pipe = result[1];
				name = String(unnamed++);
				equal = '=';
				val = result[2];
			} else {
				setLastError('unnamed parameter');
				return false;
			}
			var index = $.inArray(name, this.params);
			if (index > -1) {
				if (ignoreDuplicate) {
					this.params.splice(index, 1);
				} else {
					setLastError("duplicate parameter '" + name + "'");
					return false;
				}
			}
			this.params.push(name);
			this.paramVals[name] = {
				pipe: pipe,
				equal: equal,
				val: val
			};
		}
=cut

	my ($templ) = $text =~ $re;
	$templ =~ s/(\[\[[^\[\]\|]+)\|([^\[\]\|]+\]\])/$1~~~~pipe$2/g;
	$templ =~ s/(\{\{[^\{\}\|]+)\|([^\{\}\|]+\}\})/$1~~~~pipe$2/g;
	$templ =~ s/(\{\{[^\{\}\|]+)\|([^\{\}\|]+)\|([^\{\}\|]+\}\})/$1~~~~pipe$2~~~~pipe$3/g;
	$templ =~ s/(\{\{[^\{\}\|]+)\|([^\{\}\|]+)\|([^\{\}\|]+)\|([^\{\}\|]+\}\})/$1~~~~pipe$2~~~~pipe$3~~~~pipe$4/g;
	$templ =~ s/(\{\{[^\{\}\|]+)\|([^\{\}\|]+)\|([^\{\}\|]+)\|([^\{\}\|]+)\|([^\{\}\|]+\}\})/$1~~~~pipe$2~~~~pipe$3~~~~pipe$4~~~~pipe$5/g;
	$templ =~ s/(\{\{[^\{\}\|]+)\|([^\{\}\|]+)\|([^\{\}\|]+)\|([^\{\}\|]+)\|([^\{\}\|]+)\|([^\{\}\|]+\}\})/$1~~~~pipe$2~~~~pipe$3~~~~pipe$4~~~~pipe$5~~~~pipe$6/g;
	my @par = split '\|', $templ;

	for (@par) {
		my ($key, $val) = split '=', $_, 2;
		$val =~ s/~~~~pipe/|/g;
		$val =~ s/[\t\n]/ /g;
		$key =~ s/^\s+|\s+$//g;
		$val =~ s/^\s+|\s+$//g;
		next if ($key eq '' && $val eq '');
		$param{$key} = $val;
	}

	$param{'~~~~'} = $title;
	return %param;
}

sub makeCaseInvariant {
	my $c = $_[0];
	my $upper = "\U$c";
	if ($c eq '_') {
		return '[\s_]+';
	} else { if ($c eq $upper) {
		return $c;
	} else {
		return "[$c$upper]";
	} }
}

sub getRE {
	my $tNSRE = join '|', @templateNS;
	$tNSRE = qr/(?:(?:$tNSRE)\s*:\s*)?/i;

	my $templateNameRE = $template;
	$templateNameRE =~ s/^(.)/[\l$1\u$1]/;
	$templateNameRE =~ s/[\s_]+/[\\s_]+/g;
	my $inner = qr/(\s*(?:<!--(?:[^-]+|-[^-]|--[^>])*-->\s*)*\|(?:[^{}]+|\{[^{]|\}[^}]|\{\{[^{}]*\}\})*)/;

	return qr/\{\{\s*$tNSRE$templateNameRE$inner\}\}/;
}

$/ = '</siteinfo>'; #Header überlesen
my $header = <>;
$/ = '</page>';

$re = getRE();

print_head();

my ($title, $text);

while (my $page = <>) {

$title = '';
$title = $1 if ($page =~ m!<title>(.*)</title>!);
$text = '';
$text = $1 if ($page =~ m!<text[^>]*>(.*)</text>!s);

next if $title eq '';
next if $text eq '';

$text =~ s/&lt;/</g;
$text =~ s/&gt;/>/g;
$text =~ s/&quot;/"/g;
$text =~ s/&amp;/&/g;

my %param = read_template($title, $text);
print_line(%param) if (%param);

}