#!/usr/bin/perl

use strict;
use warnings;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my %tags = (
	'1' => 'PART',	# <U>
	'8' => 'DET',	# <T>
	'12' => 'ADP',	# <S>
	'16' => 'PRON',	# <P>
	'20' => 'ADP',	# <O>
	'22' => 'ADP',	# <O em="y">
	'24' => 'ADV',	# <R>
	'28' => 'SCONJ',	# <C>
	'32' => 'PRON',	# <Q>
	'36' => 'INTJ',	# <I>
	'40' => 'DET',	# <D>
	'64' => 'NOUN',	# <N pl="n" gnt="n">
	'72' => 'NOUN',	# <N pl="n" gnt="n" gnd="f">
	'76' => 'NOUN',	# <N pl="n" gnt="n" gnd="m">
	'80' => 'NOUN',	# <N pl="n" gnt="y">
	'88' => 'NOUN',	# <N pl="n" gnt="y" gnd="f">
	'92' => 'NOUN',	# <N pl="n" gnt="y" gnd="m">
	'96' => 'NOUN',	# <N pl="y" gnt="n">
	'104' => 'NOUN',	# <N pl="y" gnt="n" gnd="f">
	'108' => 'NOUN',	# <N pl="y" gnt="n" gnd="m">
	'128' => 'ADJ',	# <A pl="n" gnt="n">
	'152' => 'ADJ',	# <A pl="n" gnt="y" gnd="f">
	'156' => 'ADJ',	# <A pl="n" gnt="y" gnd="m">
	'160' => 'ADJ',	# <A pl="y" gnt="n">
	'200' => 'VERB',	# <V p="y" t="ord">
	'203' => 'VERB',	# <V p="y" t="caite">
	'204' => 'VERB',	# <V p="y" t="fáist">
	'206' => 'VERB',	# <V p="y" t="coinn">
);

# for POS; keys are word, vals are hash with POS's as keys
my %pos;
# for stems; keys are "word|POS", vals are hashes with possible stems as keys
my %stem;
my %overridden;

sub add_one {
	(my $w, my $t, my $s) = @_;
	if (exists($pos{$w})) {
		$pos{$w}->{$t} = 1;
	}
	else {
		$pos{$w} = { $t => 1 };
	}
	my $stemkey = "$w|$t";
	if (exists($stem{$stemkey})) {
		$stem{$stemkey}->{$s} = 1;
	}
	else {
		$stem{$stemkey} = { $s => 1 };
	}
}

sub add_from_file {
	(my $fn) = @_;
	open(EXTRAS, "<:utf8", $fn) or die "Could not open $fn: $!";
	while (<EXTRAS>) {
		chomp;
		(my $w, my $st, my $tag) = split(/\t/);
		add_one($w,$tag,$st);
	}
	close EXTRAS;
}

sub add_oveerrides {
	open(EXTRAS, "<:utf8", 'stem-override.tsv') or die "Could not open stem-override.tsv: $!";
	while (<EXTRAS>) {
		chomp;
		(my $w, my $st, my $tag) = split(/\t/);
		add_one($w,$tag,$st);
		$overridden{"$w|$tag"} = 1;
	}
	close EXTRAS;
}

sub add_gold_tags {
	open(GOLD, "<:utf8", "all.conllu") or die "Could not open all.conllu: $!";
	while (<GOLD>) {
		chomp;
		next if (m/^$/);
		next if (m/^#/);
		next if (m/^[0-9]+-/);
		my @all = split(/\t/);
		add_one($all[1],$all[3],$all[2]);
	}
	close GOLD;
}

sub kill_alt_stems {
	my %tabla;
	open(ALTS, "<:utf8", "alts.tsv") or die "Could not open alts.tsv: $!";
	# there are a few words in focloir.txt that are alts of distinct headwords
	# so this loop will overwrite the previously seen preferred word...
	# at the moment this doesn't matter since in no case do the multiple
	# preferred words share an inflected form
	# Get this list with:
	# $ cat alts.tsv | cut -f 1 | fr | egrep -v ' 1 '
	while (<ALTS>) {
		chomp;
		(my $alt, my $preferred) = split(/\t/);
		$preferred =~ s/\|.*//;
		$tabla{$alt} = $preferred;
	}
	close ALTS;
	# recall keys look like "daayl|NOUN"
	for my $k (keys %stem) {
		(my $w, my $t) = split(/\|/,$k);
		my %tokill;
		for my $s (keys %{$stem{$k}}) {
			$tokill{$s}=1 if (exists($tabla{"$s|$t"}) and exists($stem{$k}->{$tabla{"$s|$t"}}));
		}
		for my $x (keys %tokill) {
			delete $stem{$k}->{$x};
		}
	}
}


add_oveerrides();

# pipe GV.txt through this (see makefile)
my $new_word_p = 1;
my $st;
my $offset = 0;   # how many inflected forms into this headword are we
my $verb_p = 0;
my $vn;
my $pp;
while (<STDIN>) {
	chomp;
	if ($_ eq '-') {
		$new_word_p = 1;
	}
	elsif (m/ (ad|oo|shin) / or m/^xx /) {
		next;
		$offset++;
	}
	else {
		m/^(.+) ([0-9]+)/;
		my $focal = $1;
		my $tag = $tags{$2};
		if ($new_word_p==1) {
			$new_word_p = 0;
			$st = $focal;
			$offset = 0;
			$verb_p = ($tag eq 'VERB');
		}
		# dot after cap to skip dellal-L_nm, post-L, lheiney-T, scell-X
		$tag = 'PROPN' if ($tag eq 'NOUN' and $focal =~ m/[A-Z]./ and $focal !~ m/-(Voirr|Lyn)/);
		$tag = 'ADV' if ($tag eq 'PRON' and $focal =~ m/^(kys)$/);
		$tag = 'DET' if ($tag eq 'ADJ' and $focal =~ m/^(dagh|shoh|shen)$/);
		$tag = 'PRON' if ($tag eq 'ADJ' and $focal =~ m/^(hene)$/); # follow GD
		$tag = 'CCONJ' if ($tag eq 'SCONJ' and $focal =~ m/^(agh|as|chamoo|er-nonney|ny)$/);

		$vn = $focal if ($verb_p and $offset==1);   # ugh magic numbers
		$pp = $focal if ($verb_p and $offset==16);   # ugh magic numbers
		if ($verb_p and $offset >= 1 and $offset <= 15) {
			add_one($focal,$tag, $vn);
		}
		elsif ($verb_p and $offset >= 16 and $offset <= 31) {
			add_one($focal,$tag, $pp);
		}
		elsif (!exists($overridden{"$focal|$tag"})) {
			add_one($focal,$tag, $st);
		}
		$offset++;
	}
}

add_from_file('extras.tsv');
add_from_file('numbers.tsv');
add_gold_tags();
kill_alt_stems();

for my $k (sort keys %pos) {
	my $tags = $pos{$k};
	for my $tag (sort keys %{$pos{$k}}) {
		my $allstems = join('|',sort keys %{$stem{"$k|$tag"}});
		print "$k\t$allstems\t$tag\n";
	}
}
exit 0;
