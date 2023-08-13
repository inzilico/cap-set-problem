#!/usr/bin/perl
## Find sets
## File with 3-card combinations should be labeled by {0 ,1} having 4 columns.
## Author: Gennady Khvorykh, info@inzilico.com

use strict;
use warnings;
use List::Util qw(all);
use Algorithm::Combinatorics qw(combinations);
use Data::Dumper;

# Initiate
my ($f1, $f2, $f3) = @ARGV;
my $n; # To count non-sets processed

# Check input
die "Wrong number of arguments" if ($#ARGV + 1 != 3); 
die "$f1 doesn't exist or empty" unless -s $f1;
die "$f2 doesn't exist or empty" unless -s $f2;

# Open file with labeled 3-card combinations
open (my $fh1, '<', $f1) or die "Failed to open $f1";

# Open file with cards 
open (my $fh2, '<', $f2) or die "Failed to open $f2";

# Load cards
my @cards = <$fh2>;
chomp @cards;
my $size = @cards;
print "Number of cards: $size\n";
# Let cards start with index 1
unshift @cards, 0;

# Initiate card index
my @ind = 1..$size;

# Open file to save output
open (my $fh3, '>', $f3) or die "Failed to open $f3";

# Loop over the file with labeled 3-card combinations 
while (<$fh1>) {
	chomp;
	# Initiate open cards
	my @oc;
	my @ar = split ' ', $_;
	foreach (@ar) {
		push @oc, int($_);
	}
	# Get label 
	my $l = pop @oc;
	# Skip if set
	next if $l == 1;
	# Initiate deck
	my @deck = diff(\@ind, \@oc);
	# Process deck until it has cards
	until (@deck == 0) {
		# Open card from deck
		push @oc, shift @deck;
		# Check open cards have at least one set
		if (has_sets(\@oc, \@cards)) {
			# Remove last added card 
			pop @oc;
		}
	}
	# Show cap
	print $fh3 "@oc\n";
	$n =++ $n;
}

print "The number of non-sets processed: $n\n";

# Close files
close $fh1;
close $fh2;
close $fh3;

exit 0;

# === subs ===

sub is_set {
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

sub diff {
	my @A = @{$_[0]};
	my @B = @{$_[1]};
	my %seen = (); # lookup table to test membership of B
	my @aonly = (); # answer
	# build lookup table
	foreach my $item (@B) { $seen{$item} = 1 }
	# find only elements in @A and not in @B
	foreach my $item (@A) {
			unless ($seen{$item}) {
					# it's not in %seen, so add to @aonly
					push(@aonly, $item);
			}
	}
	return @aonly;
}

sub has_sets {
	my @x = @{$_[0]}; # open cards
	my @y = @{$_[1]}; # cards
	# Make 3-card combinations from open cards
	my @cmbs = combinations(\@x, 3);
	# Check each combinations for being a set
	foreach (@cmbs) {
		my @cmb = @$_;
		my $l = is_set(@y[@cmb]);
		return 1 if $l == 1;
	}
	return 0;
}
