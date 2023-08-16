#!/usr/bin/perl
## Filter caps by lengh and process with tradein approach.
## Author: Gennady Khvorykh, info@inzilico.com

use strict;
use warnings;
use List::Util qw(all);
use Algorithm::Combinatorics qw(combinations);
use MCE::Flow;
use Data::Dumper;
use feature 'say';
use Getopt::Long;

# Initiate
my ($in, $out, $length, $cards_file);
my $nc = 10; # Number of CPUs

GetOptions(
	"--in=s" => \$in,
	"--out=s" => \$out,
	"--cards=s" => \$cards_file,
	"--length=i" => \$length,
	"--nc" => \$nc
) or die "Wrong argument"; 

# Check input
die "--in argument is required" unless defined $in;
die "$in doesn't exist or empty" unless -s $in;
die "--cards argument is required" unless defined $cards_file;
die "$cards_file doesn't exist or empty" unless -s $cards_file;
die "--length argument is required" unless defined $length;
die "--out argument is required" unless defined $out;

# Load caps of given length
my $caps = filter($in);

# Load cards
my ($cards, $ind) = load_cards($cards_file);

# Initilize MCE::Flow
MCE::Flow->init(
  chunk_size  => 10,
	max_workers => $nc
);

# Process chunks in parallel
my @results = mce_flow sub { do_work($_) }, $caps;

# Save new caps to file 
save($out, \@results);

exit 0;

# === subs ===

sub save {
	my ($out, $data) = @_;
	open (my $fh, '>', $out) or die "Failed to open $out";
	foreach my $item (@$data) {
		foreach my $element (@$item) {
			my $str = join ' ', @$element;
			print $fh "$str\n";
		}
	}
	close $fh;
}

sub do_work {
	foreach (@_) {
		foreach (@$_) {
			my $caps = tradein($_);
			MCE->gather($caps) if (@$caps);
		}
	}
}

sub tradein {
	my $cap = $_[0];
	my @out = ();
	# Loop over all cards in cap beside the last on
	for my $i (0..$length-2) {
		# Drop the card
		my @oc = drop($i, @$cap); 
		# Grow 
		my $new_cap = grow(@oc);
		# Check size
		my $s = @$new_cap;
		push @out, [@$new_cap] if ($s > $length); 
	}
	return \@out;
}

sub grow {
	my @oc = @_;
	# Initiate 2-card combinations from open cards
  my @cmbs = combinations(\@oc, 2);
	# Initiate deck
	my @deck = diff($ind, \@oc);
	# Process deck until it has cards
	until (@deck == 0) {
		# Take card from deck
		my $card = shift @deck;
		# Add card to open cards if it doesn't make sets with open cards
		# and update 2-card combinations
		unless (sets(\@cmbs, $card, $cards)) {
			push @oc, int($card);
			@cmbs = combinations(\@oc, 2);
		}
	}
	return \@oc;
}

sub drop {
	my ($i, @array) = @_;
	splice @array, $i, 1;
	return @array;
}

sub filter {
	my $in = $_[0];
	my @data = ();

	# Open file for reading 
	open (my $fh, '<', $in) or die "Failed to open $in";

	# Read file by lines and subset caps of length defined
	while (<$fh>) {
		chomp;
		my @arr = split / /;
		my $s = @arr;
		if ($s == $length) {
			my @arr_int;
			push @arr_int, int($_) foreach (@arr); 
			push @data, [ @arr_int ];
		}
	}

	close $fh;

	print "Lenght: $length\n";
	print "No of caps selected: ".(scalar @data)."\n";
	return \@data;

}

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

