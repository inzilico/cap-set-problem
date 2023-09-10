#!/usr/bin/perl
## Loop over existing caps and try to grow each by adding caps of size 3. 
## 3-caps building caps are removed and the left ones are saved.  
## Author: Gennady Khvorykh, inzilico.com

use strict;
use warnings;
use feature 'say';
use Data::Dumper;
use List::Util qw(all);
use List::Util::Uniq qw(is_uniq);
use Time::Elapsed qw(elapsed);
use Algorithm::Combinatorics qw(combinations);
use List::UtilsBy qw(uniq_by);
use Term::ProgressBar;
use MCE::Flow;
use Getopt::Long;

# Initiate variables
my ($f1, $f2, $f3, $f4, $f5, @res_raw);
my $ts = time;
my $nc = 8;
my $mat;

# Get arguments
GetOptions (
	"--in1=s" => \$f1,
  "--out1=s" => \$f2,
  "--cards=s" => \$f3,
  "--in2=s" => \$f4,
  "--out2=s" => \$f5,
	"--nc=i" => \$nc,
) or die("Wrong arguments!");

# Check input
die "File with caps wasn't defined (--in1)" unless defined $f1;
die "$f1 doesn't exist or empty" unless -s $f1;
die "File to save new caps wasn't defined (--out1)" unless defined $f2;
die "File with cards coded wasn't defined (--cards)" unless defined $f3;
die "$f3 doesn't exist or empty" unless -s $f3;
die "File with 3-caps wasn't defined (--in2)" unless defined $f4;
die "$f4 doesn't exist or empty" unless -s $f4;
#die "File to save matrix wasn't defined (--out2)" unless defined $f5;

# Show input
print "\nCaps: $f1\nNew caps: $f2\nCards: $f3\n3-caps: $f4\n";
#print "3-caps left: $f5\n";
print "No of workers: $nc\n\n";

# Load cards
my ($cards, $ind1) = load_cards($f3);

# Load 3-caps
my ($caps) = load_caps($f4);

# Initiate matrix of zeros
#my $mat = Math::Matrix->zeros($#{$caps} + 1);

# Get the number of lines 
my $wc = `wc -l $f1`;
chomp($wc);
$wc =~ /^\s*(\d+)(\D.*)?/ or die "Couldn't parse wc output: $wc";
my $nl = $1;
print "No of caps: $nl\n";


# Choose processing
if ($f1 eq $f4) { 

	# Inputs identical
	print "Inputs are identical\n";

	# Initiate workers
	MCE::Flow->init(
		chunk_size => 10,
		max_workers => $nc	
	);

	# Generate combinations
	my @seq = (0..$#$caps); 
	my @data = combinations(\@seq, 2);

	@res_raw = mce_flow sub { 
		foreach (@$_) {
			my @cmbs = @$_;
			my $i = $cmbs[0];
			my $j = $cmbs[1];
			my @oc = (@{$caps->[$i]}, @{$caps->[$j]});
			# Check card indexes are unique
			next unless is_uniq(@oc);
			# Check open cards for set
			next unless is_cap(@{$cards}[@oc]);
			MCE->gather(\@oc);
		} 
	}, \@data; 	

} else {

	# Initiate workers
	MCE::Flow->init(
		chunk_size => 1,
		max_workers => $nc	
	);
	
	# Read file by lines in parallel
	@res_raw = mce_flow_f sub {
		chomp;
		my @arr = split / /, $_;
		my $caps_new = grow(\@arr, $caps, $cards);
		MCE->gather(@$caps_new);
	}, $f1;

}

# Post-process the caps grown
my $res_clean = post_proc(\@res_raw);

# Open file to save output
open (my $fh2, '>', $f2) or die "Failed to open $f2"; 
my $n = 0;

foreach (@$res_clean) {
	print $fh2 "@$_\n";
	$n++
}

# Show the number of new caps written
print "No of new caps: $n\n"; 

# Close files 
close $fh2;

# Open file to save the matrix
#open (my $fh5, '>', $f5) or die "Failed to open $f5"; 
#print $fh5 $mat;

# Close
#close $fh5;

# Show elapsed time
my $dur = time - $ts;
print "Time elapsed: ", elapsed($dur), "\n";

exit 0;

# === subs ===

sub post_proc {

	my @data1 = @{$_[0]};
	my @data2 = ();

	# Loop over results gathered from all workers
	foreach (@data1) {
		my @arr1 = @$_;
		next unless @arr1;
		# Order the cards in cap
		my @arr2 = sort { $a <=> $b } @arr1;
		push @data2, \@arr2;
	}

	# Remove duplicates
	my @data3 = uniq_by { join '', @$_ } @data2;
	return \@data3;

}

sub grow {

	# Initiate variables
	my @cap = @{$_[0]}; # Cap to be grown up
	my @caps = @{$_[1]}; # 3-caps
	my @cards = @{$_[2]}; # Cards coded
	my @cap_new = (); 

	# Loop over caps and grow each
	foreach (@caps) {
		my @oc = (@cap, @$_);
		# Check card indexes are unique
  	next unless is_uniq(@oc);
  	# Check open cards for set
  	next unless is_cap(@cards[@oc]);
		push @cap_new, \@oc;
	}
	return \@cap_new; 	
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

sub load_caps {
  my $f = $_[0];
  my @cmbs = ();
  # Open file with 3-card combinations 
  open (my $fh, '<', $f) or die "Failed to open $f";
  # Read file by lines
  while (<$fh>) {
    chomp;
    my @ar = split / /, $_;
    push @cmbs, \@ar;
  }
  close $fh;
  my $size = @cmbs;
  print "No of 3-caps: $size\n";
  return \@cmbs;
}

sub is_set {
  # Check three cards to be a set 
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

sub is_cap {
  my @data = @_; # a set of features of cards 
  # Create 3 cards combinations
  my $max_ind = $#data;
  my @ind = (0 .. $max_ind);
  my @cmbs = combinations(\@ind, 3);
  # Check each combination 
  foreach (@cmbs) {
    return 0 if is_set(@data[@$_]);
  }
  return 1;
}

