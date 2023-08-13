#!/usr/bin/perl
## Label 3-card combinations by non-set/set {0, 1}
## Author: Gennady Khvorykh, info@inzilico.com

use strict;
use warnings;
use List::Util qw(all);
use Data::Dumper;

# Check 3 arguments were provided
my $args = $#ARGV + 1;
if ($args != 3) {
	print "There are should be 3 arguments.\n";
	exit 1;	
}

# Unitiate
my ($f1, $f2, $out) = @ARGV;
my ($k, $l); # total number of 3-card combinatinos, the number of sets

# Check input
die "$f1 doesn't exist or has zero length" unless -s $f1;
die "$f2 doesn't exist or has zero length" unless -s $f2;

# Show input
print "Input\nCombinations: $f1\nCards: $f2\nOutput: $out\n";

# Open files
open (my $fh1, '<', $f1) or die "Failed to open $f1"; 
open (my $fh2, '<', $f2) or die "Failed to open $f2"; 
open (my $fh3, '>', $out) or die "Failed to open $out"; 

# Slurp cards into array
my @cards = <$fh2>;
chomp @cards;
my $size = @cards;
print "Number of cards: $size\n";


# Process the file with 3-card combinations line by line
while (<$fh1>) {
	my $line = $_;
	chomp $line;
	my @ind1 = split ' ', $line;
	my @ind2;
	# Decrease indexes by one
	foreach (@ind1) {
		push @ind2, $_ - 1;
	}
	my $label = isset(@cards[@ind2]);
	print $fh3 "$line $label\n";
	$k = ++$k;
	$l = ++$l if $label == 1;
}

# Close files
close $fh1;
close $fh2;
close $fh3;

print "Total: $k\nSets: $l\n";

exit 0;

# ==== subs ====

sub isset {
	my @arg = @_;
	my @res;
	my $s = scalar (split ' ', $arg[0]);
	foreach (0..$s-1) {
		my $i = $_;
		my @ar1;
		foreach (@arg) {
			my @ar2 = split ' ', $_;
			push @ar1, $ar2[$i];
		}	
		my $sum = 0;
		$sum += $_ for (@ar1);
		my $sm = $sum % 3;
		push @res, $sm;
	}
	# Check if all elements equal to zero
	if (all { $_ == 0 } @res) { 
		return 1;
  } else { 
		return 0;
	}
}
