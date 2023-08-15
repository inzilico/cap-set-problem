#!/usr/bin/perl
## Find cap sets starting from 2-card combinations
## Author: Gennady Khvorykh, info@inzilico.com

use strict;
use warnings;
use List::Util qw(all);
use Algorithm::Combinatorics qw(combinations);
use Getopt::Long;
use Data::Dumper;

# Initiate
my $f1; # Path/to/file with cards
my $f2; # Path/to/file to save output

# Get arguments
GetOptions (
	"--cards=s" => \$f1,
	"--out=s" => \$f2
) 
or die("Wrong arguments!");

# Check input
die "File with cards wasn't defined" unless defined $f1;
die "$f1 doesn't exist or empty" unless -s $f1;
die "Output file wasn't defined" unless defined $f2;

# Load cards
my ($cards, $ind) = load_cards($f1);

# Generate 2-card combinations
my @data = combinations($ind, 2);
print "No of 2-card combinations: ".(scalar @data)."\n";

# Open output file
open (my $fh2, '>', $f2) or die "Failed to open $f2";

# Loop over 2-card combinations
foreach (@data) {
	# Initiate open cards
	my @oc = @$_;
	# Initiate 2-card combinations from open cards
	my @cmbs = $_ ;
	# Initiate deck
	my @deck = diff($ind, \@oc);
	# Process deck until it has cards
	until (@deck == 0) {
    # Take card from deck
    my $card = shift @deck;
    # Add card to open cards if it doesn't make sets with open cards
    # and update 2-card combinations
    unless (sets(\@cmbs, $card, $cards)) {
      push @oc, $card;
      @cmbs = combinations(\@oc, 2);
    }
  }

  # Show cap
  print $fh2 "@oc\n";

}

close $fh2;
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
  print "No of cards: $size\n";
  # Let cards start with index 1
  unshift @cards, 0;
  # Initiate card index
  my @ind = 1..$size;
  close $fh;
  return \@cards, \@ind;
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

