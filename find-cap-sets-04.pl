#!/usr/bin/perl
## Find cap sets
## File with 3-card combinations should be labeled by {0,1} having 4 columns.
## To check the possibility for the open cards to form sets,
## 2-card combinations among open cards are calculated and compared with all cards in deck. 
## The deck cards forming set with the given 2-card combination are removed. 
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

# Load cards
my ($cards, $ind)	 = load_cards($f2);

# Open file with labeled 3-card combinations
open (my $fh1, '<', $f1) or die "Failed to open $f1";

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
	my @deck = diff($ind, \@oc);
	# Generate 2-card combinations from open cards
	my @cmbs = combinations(\@oc, 2);
	# Process deck until it has cards
	until (@deck == 0) {
		# Loop over 2-card combinations
		foreach (@cmbs) {
			my @cmb = @$_;
			my %seen = ();
			# Loop over deck cards 
			foreach my $card (@deck) {
				# Make three cards for test
				my @test = @cmb;
				push @test, $card;
				# Test for set 
				my $res = is_set(@{ $cards }[@test]);
				# Mark bad cards
				$seen{$card} = 1 if $res == 1;
			}
			# Remove bad cards from deck
			my @deck_new;
			foreach my $item (@deck) {
				push @deck_new, $item unless($seen{$item}); 
			}
			# Check cards are left in deck
			last if (@deck_new == 0);
			# Update deck
			@deck = @deck_new;
		}
		# Check if deck still has cards
		last if (@deck == 0);
		# Take card from deck
		my $crd = shift @deck;
		# Add to open cards
		push @oc, $crd;		
		# Generate new 2-card combinations
		@cmbs = combinations(\@oc, 2);
	}

	# Show cap
	print $fh3 "@oc\n";
	$n =++ $n;
}

print "The number of non-sets processed: $n\n";

# Close files
close $fh1;
close $fh3;

exit 0;

# === subs ===

sub load_cards {
	my $f = $_[0];
	# Open file with cards 
	open (my $fh, '<', $f) or die "Failed to open $f";
	# Load cards
	my @cards = <$fh>;
	chomp @cards;
	my $size = @cards;
	print "Number of cards: $size\n";
	# Let cards start with index 1
	unshift @cards, 0;
	# Initiate card index
	my @ind = 1..$size;
	close $fh;
	return \@cards, \@ind;
}


sub is_set {
	my @arg = @_;
	my @res;
	my $s = () = split ' ', $arg[0], -1;
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

sub sets {
	my @x = @{$_[0]}; # 2-card combinations
	my $y = $_[1]; # Testing card
	my @z = @{$_[2]}; # All cards

	# Check each two-card combination
	foreach (@x) {
		my @cmb = @$_;
		push @cmb, $y;
		my $l = is_set(@z[@cmb]);
		return 1 if $l == 1;	
	}
	return 0;
}
